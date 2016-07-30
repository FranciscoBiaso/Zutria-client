-- @docclass
ProtocolLogin = extends(Protocol, "ProtocolLogin")

LoginServerError = 10
LoginServerTokenSuccess = 12
LoginServerTokenError = 13
LoginServerUpdate = 17
LoginServerMotd = 20
LoginServerUpdateNeeded = 30
LoginServerSessionKey = 40
LoginServerCharacterList = 1
LoginServerExtendedCharacterList = 101

-- Since 10.76
LoginServerRetry = 10
LoginServerErrorNew = 11

function ProtocolLogin:login(host, port, accountName, accountPassword, authenticatorToken, stayLogged)
  if string.len(host) == 0 or port == nil or port == 0 then
    signalcall(self.onLoginError, self, tr("You must enter a valid server address and port."))
    return
  end

  self.accountName = accountName
  self.accountPassword = accountPassword
  self.authenticatorToken = authenticatorToken
  self.stayLogged = stayLogged
  self.connectCallback = self.sendLoginPacket

  self:connect(host, port)
end

function ProtocolLogin:cancelLogin()
  self:disconnect()
end

function ProtocolLogin:sendLoginPacket()
  local msg = OutputMessage.create()
  -- first protocol of the game 
  msg:addU8(ClientOpcodes.ClientEnterAccount)
  -- client operating system
  msg:addU16(g_game.getOs())
  -- protocol version
  msg:addU16(g_game.getProtocolVersion())
  
  -- msg:addU32(g_things.getDatSignature())
  -- msg:addU32(g_sprites.getSprSignature())
  -- msg:addU32(PIC_SIGNATURE)

  
  msg:addU32(tonumber(self.accountName))
  msg:addString(self.accountPassword)

  self:send(msg)
  
  self:recv()
end

function ProtocolLogin:onConnect()
  self.gotConnection = true
  self:connectCallback()
  self.connectCallback = nil
end

function ProtocolLogin:onRecv(msg)
  while not msg:eof() do
    local opcode = msg:getU8()
    if opcode == LoginServerErrorNew then
      self:parseError(msg)
    elseif opcode == LoginServerError then
      self:parseError(msg)
    elseif opcode == LoginServerMotd then
      self:parseMotd(msg)
    elseif opcode == LoginServerUpdateNeeded then
      signalcall(self.onLoginError, self, tr("Client needs update."))
    elseif opcode == LoginServerTokenSuccess then
      local unknown = msg:getU8()
    elseif opcode == LoginServerTokenError then
      -- TODO: prompt for token here
      local unknown = msg:getU8()
      signalcall(self.onLoginError, self, tr("Invalid authentification token."))
    elseif opcode == LoginServerCharacterList then
      self:parseCharacterList(msg)
    elseif opcode == LoginServerExtendedCharacterList then
      self:parseExtendedCharacterList(msg)
    elseif opcode == LoginServerUpdate then
      local signature = msg:getString()
      signalcall(self.onUpdateNeeded, self, signature)
    elseif opcode == LoginServerSessionKey then
      self:parseSessionKey(msg)
    else
      self:parseOpcode(opcode, msg)
    end
  end
  self:disconnect()
end

function ProtocolLogin:parseError(msg)
  local errorMessage = msg:getString()
  self:disconnect()
  signalcall(self.onLoginError, self, errorMessage)
end

function ProtocolLogin:parseMotd(msg)
  local motd = msg:getString()
  signalcall(self.onMotd, self, motd)
end

function ProtocolLogin:parseSessionKey(msg)
  local sessionKey = msg:getString()
  signalcall(self.onSessionKey, self, sessionKey)
end

function ProtocolLogin:parseCharacterList(msg)
  local characters = {}
  
  local charactersCount = msg:getU8()
  for i=1,charactersCount do
    local character = {}
    character.name = msg:getString()
    character.worldName = msg:getString()
    character.worldIp = iptostring(msg:getU32())
    character.worldPort = msg:getU16()
 
    characters[i] = character
  end
  

  local account = {}
  account.premDays = msg:getU16()
  signalcall(self.onCharacterList, self, characters, account)
end

function ProtocolLogin:parseExtendedCharacterList(msg)
  local characters = msg:getTable()
  local account = msg:getTable()
  local otui = msg:getString()
  signalcall(self.onCharacterList, self, characters, account, otui)
end

function ProtocolLogin:parseOpcode(opcode, msg)
  signalcall(self.onOpcode, self, opcode, msg)
end

function ProtocolLogin:onError(msg, code)
  local text = translateNetworkError(code, self:isConnecting(), msg)
  signalcall(self.onLoginError, self, text)
end