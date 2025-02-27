/*
 * Copyright (c) 2010-2015 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "protocolgame.h"

#include "localplayer.h"
#include "thingtypemanager.h"
#include "game.h"
#include "map.h"
#include "item.h"
#include "effect.h"
#include "missile.h"
#include "tile.h"
#include "luavaluecasts.h"
#include <framework/core/eventdispatcher.h>

void ProtocolGame::parseMessage(const InputMessagePtr& msg)
{
    int opcode = -1;
    int prevOpcode = -1;

    try {
        while(!msg->eof()) {
            opcode = msg->getU8();
			callLuaField("seeopcode", opcode);

            // must be > so extended will be enabled before GameStart.
            if(!g_game.getFeature(Otc::GameLoginPending)) {
                if(!m_gameInitialized && opcode > Proto::GameServerFirstGameOpcode) {
                    g_game.processGameStart();
                    m_gameInitialized = true;
                }
            }

            // try to parse in lua first
            int readPos = msg->getReadPos();
            if(callLuaField<bool>("onOpcode", opcode, msg))
                continue;
            else
                msg->setReadPos(readPos); // restore read pos

            switch(opcode) 
			{
				case Proto::GameServerLoginOrPendingState:
					if(g_game.getFeature(Otc::GameLoginPending))
						parsePendingGame(msg);
					else
						parseLogin(msg);
					break;
				case Proto::GameServerFullMap:
					parseMapDescription(msg);
					break;
				case Proto::GameServerGMActions:
					parseGMActions(msg);
					break;
				case Proto::GameServerUpdateNeeded:
					parseUpdateNeeded(msg);
					break;
				case Proto::GameServerLoginError:
					parseLoginError(msg);
					break;
				case Proto::GameServerLoginAdvice:
					parseLoginAdvice(msg);
					break;
				case Proto::GameServerLoginWait:
					parseLoginWait(msg);
					break;
				case Proto::GameServerLoginToken:
					parseLoginToken(msg);
					break;
				case Proto::GameServerPing:
				case Proto::GameServerPingBack:
					if((opcode == Proto::GameServerPing && g_game.getFeature(Otc::GameClientPing)) ||
					   (opcode == Proto::GameServerPingBack && !g_game.getFeature(Otc::GameClientPing)))
						parsePingBack(msg);
					else
						parsePing(msg);
					break;
				case Proto::GameServerChallenge:
					parseChallenge(msg);
					break;
				case Proto::GameServerDeath:
					parseDeath(msg);
					break;     

				case Proto::GameServerOnPlayerAttack:
				{
					uint32_t creatureId = msg->getU32();
					g_game.onAttack(creatureId);
				}
					break;

				case Proto::GameServerMapTopRow:
					parseMapMoveNorth(msg);
					break;
				case Proto::GameServerMapRightRow:
					parseMapMoveEast(msg);
					break;
				case Proto::GameServerMapBottomRow:
					parseMapMoveSouth(msg);
					break;
				case Proto::GameServerMapLeftRow:
					parseMapMoveWest(msg);
					break;
				case Proto::GameServerUpdateTile:
					parseUpdateTile(msg);
					break;
				case Proto::GameServerCreateOnMap:
					parseTileAddThing(msg);
					break;
				case Proto::GameServerChangeOnMap:
					parseTileTransformThing(msg);
					break;
				case Proto::GameServerDeleteOnMap:
					parseTileRemoveThing(msg);
					break;
				case Proto::GameServerMoveCreature:
					parseCreatureMove(msg);
					break;
				case Proto::GameServerOpenContainer:
					parseOpenContainer(msg);
					break;
				case Proto::GameServerCloseContainer:
					parseCloseContainer(msg);
					break;
				case Proto::GameServerCreateContainer:
					parseContainerAddItem(msg);
					break;
				case Proto::GameServerChangeInContainer:
					parseContainerUpdateItem(msg);
					break;
				case Proto::GameServerDeleteInContainer:
					parseContainerRemoveItem(msg);
					break;
				case Proto::GameServerSetInventory:
					parseAddInventoryItem(msg);
					break;
				case Proto::GameServerDeleteInventory:
					parseRemoveInventoryItem(msg);
					break;
				case Proto::GameServerOpenNpcTrade:
					parseOpenNpcTrade(msg);
					break;
				case Proto::GameServerPlayerGoods:
					parsePlayerGoods(msg);
					break;
				case Proto::GameServerCloseNpcTrade:
					parseCloseNpcTrade(msg);
					break;
				case Proto::GameServerOwnTrade:
					parseOwnTrade(msg);
					break;
				case Proto::GameServerCounterTrade:
					parseCounterTrade(msg);
					break;
				case Proto::GameServerCloseTrade:
					parseCloseTrade(msg);
					break;
				case Proto::GameServerAmbient:
					parseWorldLight(msg);
					break;
				case Proto::GameServerGraphicalEffect:
					parseMagicEffect(msg);
					break;
				case Proto::GameServerTextEffect:
					parseAnimatedText(msg);
					break;
				case Proto::GameServerMissleEffect:
					parseDistanceMissile(msg);
					break;
				case Proto::GameServerMarkCreature:
					parseCreatureMark(msg);
					break;
				case Proto::GameServerTrappers:
					parseTrappers(msg);
					break;
				case Proto::GameServerCreatureHealth:
					parseCreatureHealth(msg);
					break;
				case Proto::GameServerCreatureLight:
					parseCreatureLight(msg);
					break;
				case Proto::GameServerCreatureOutfit:
					parseCreatureOutfit(msg);
					break;
				case Proto::GameServerCreatureSpeed:
					parseCreatureSpeed(msg);
					break;
				case Proto::GameServerCreatureSkull:
					parseCreatureSkulls(msg);
					break;
				case Proto::GameServerCreatureParty:
					parseCreatureShields(msg);
					break;
				case Proto::GameServerCreatureUnpass:
					parseCreatureUnpass(msg);
					break;
				case Proto::GameServerEditText:
					parseEditText(msg);
					break;
				case Proto::GameServerEditList:
					parseEditList(msg);
					break;
				case Proto::GameServerTextsEffect:
					parseAnimatedTexts(msg);
					break;
				// PROTOCOL>=1038
				case Proto::GameServerPremiumTrigger:
					parsePremiumTrigger(msg);
					break;
				case Proto::GameServerPlayerData:
					parsePlayerStats(msg);
					break;
				case Proto::GameServerPlayerSkills:
					parsePlayerSkills(msg);
					break;
				case Proto::GameServerPlayerState:
					parsePlayerState(msg);
					break;
				case Proto::GameServerClearTarget:
					parsePlayerCancelAttack(msg);
					break;
				case Proto::GameServerPlayerModes:
					parsePlayerModes(msg);
					break;
				
				case Proto::GameServerUpdateBalance:
					parseUpdateBalance(msg);
					break;

				case Proto::GameServerTalk:
					parseTalk(msg);
					break;
				case Proto::GameServerChannels:
					parseChannelList(msg);
					break;
				case Proto::GameServerOpenChannel:
					parseOpenChannel(msg);
					break;
				case Proto::GameServerOpenPrivateChannel:
					parseOpenPrivateChannel(msg);
					break;
				case Proto::GameServerRuleViolationChannel:
					parseRuleViolationChannel(msg);
					break;
				case Proto::GameServerRuleViolationRemove:
					parseRuleViolationRemove(msg);
					break;
				case Proto::GameServerRuleViolationCancel:
					parseRuleViolationCancel(msg);
					break;
				case Proto::GameServerRuleViolationLock:
					parseRuleViolationLock(msg);
					break;
				case Proto::GameServerOpenOwnChannel:
					parseOpenOwnPrivateChannel(msg);
					break;
				case Proto::GameServerCloseChannel:
					parseCloseChannel(msg);
					break;
				case Proto::GameServerTextMessage:
					parseTextMessage(msg);
					break;
				case Proto::GameServerCancelWalk:
					parseCancelWalk(msg);
					break;
				case Proto::GameServerWalkWait:
					parseWalkWait(msg);
					break;
				case Proto::GameServerFloorChangeUp:
					parseFloorChangeUp(msg);
					break;
				case Proto::GameServerFloorChangeDown:
					parseFloorChangeDown(msg);
					break;
				case Proto::GameServerChooseOutfit:
					parseOpenOutfitWindow(msg);
					break;
				case Proto::GameServerVipAdd:
					parseVipAdd(msg);
					break;
				case Proto::GameServerVipState:
					parseVipState(msg);
					break;
				case Proto::GameServerVipLogout:
					parseVipLogout(msg);
					break;
				case Proto::GameServerTutorialHint:
					parseTutorialHint(msg);
					break;
				case Proto::GameServerAutomapFlag:
					parseAutomapFlag(msg);
					break;
				case Proto::GameServerQuestLog:
					parseQuestLog(msg);
					break;
				case Proto::GameServerQuestLine:
					parseQuestLine(msg);
					break;
				// PROTOCOL>=870
				case Proto::GameServerSpellDelay:
					parseSpellCooldown(msg);
					break;
				case Proto::GameServerSpellGroupDelay:
					parseSpellGroupCooldown(msg);
					break;
				case Proto::GameServerMultiUseDelay:
					parseMultiUseCooldown(msg);
					break;
				// PROTOCOL>=910
				case Proto::GameServerChannelEvent:
					parseChannelEvent(msg);
					break;
				case Proto::GameServerItemInfo:
					parseItemInfo(msg);
					break;
				case Proto::GameServerPlayerInventory:
					parsePlayerInventory(msg);
					break;
				// PROTOCOL>=950
				case Proto::GameServerPlayerDataBasic:
					parsePlayerInfo(msg);
					break;
				// PROTOCOL>=970
				case Proto::GameServerModalDialog:
					parseModalDialog(msg);
					break;
				// PROTOCOL>=980
				case Proto::GameServerLoginSuccess:
					parseLogin(msg);
					break;
				case Proto::GameServerEnterGame:
					parseEnterGame(msg);
					break;
				case Proto::GameServerPlayerHelpers:
					parsePlayerHelpers(msg);
					break;
				// PROTOCOL>=1000
				case Proto::GameServerCreatureMarks:
					parseCreaturesMark(msg);
					break;
				case Proto::GameServerCreatureType:
					parseCreatureType(msg);
					break;
				// PROTOCOL>=1055
				case Proto::GameServerBlessings:
					parseBlessings(msg);
					break;
				case Proto::GameServerUnjustifiedStats:
					parseUnjustifiedStats(msg);
					break;
				case Proto::GameServerPvpSituations:
					parsePvpSituations(msg);
					break;
				case Proto::GameServerPreset:
					parsePreset(msg);
					break;
				// otclient ONLY
				case Proto::GameServerExtendedOpcode:
					parseExtendedOpcode(msg);
					break;
				case Proto::GameServerChangeMapAwareRange:
					parseChangeMapAwareRange(msg);
					break;
				case Proto::GameServerPlayerFirstStats:
					parsePlayerFirstStats(msg);
					break;
				case Proto::GameServerPlayerSpells:
					parsePlayerSpells(msg);
					break;
				case Proto::GameServerPlayerSpell:
					parsePlayerSpellLearned(msg);
					break;
				case Proto::GameServerPlayerBreath:
					parsePlayerBreath(msg);
					break;
				case Proto::GameServerPlayerNpcWindow:
					parsePlayerNpcWindow(msg);
					break;
				default:
					stdext::throw_exception(stdext::format("unhandled opcode %d", (int)opcode));
					break;
            }
            prevOpcode = opcode;
        }
    } catch(stdext::exception& e) {
        g_logger.error(stdext::format("ProtocolGame parse message exception (%d bytes unread, last opcode is %d, prev opcode is %d): %s",
                                      msg->getUnreadSize(), opcode, prevOpcode, e.what()));
    }
}

void ProtocolGame::parseLogin(const InputMessagePtr& msg)
{
    uint32_t playerId = msg->getU32();
    int serverBeat = msg->getU16();
	bool canReportBugs = msg->getU8();
  
    m_localPlayer->setId(playerId);
    g_game.setServerBeat(serverBeat);
    g_game.setCanReportBugs(canReportBugs);

    g_game.processLogin();
}

void ProtocolGame::parsePendingGame(const InputMessagePtr& msg)
{
    //set player to pending game state
    g_game.processPendingGame();
}

void ProtocolGame::parseEnterGame(const InputMessagePtr& msg)
{
    //set player to entered game state
    g_game.processEnterGame();

    if(!m_gameInitialized) {
        g_game.processGameStart();
        m_gameInitialized = true;
    }
}

void ProtocolGame::parseBlessings(const InputMessagePtr& msg)
{
    uint16 blessings = msg->getU16();
    m_localPlayer->setBlessings(blessings);
}

void ProtocolGame::parsePreset(const InputMessagePtr& msg)
{
    uint16 preset = msg->getU32();
}

void ProtocolGame::parseUnjustifiedStats(const InputMessagePtr& msg)
{
    UnjustifiedPoints unjustifiedPoints;
    unjustifiedPoints.killsDay = msg->getU8();
    unjustifiedPoints.killsDayRemaining = msg->getU8();
    unjustifiedPoints.killsWeek = msg->getU8();
    unjustifiedPoints.killsWeekRemaining = msg->getU8();
    unjustifiedPoints.killsMonth = msg->getU8();
    unjustifiedPoints.killsMonthRemaining = msg->getU8();
    unjustifiedPoints.skullTime = msg->getU8();

    g_game.setUnjustifiedPoints(unjustifiedPoints);
}

void ProtocolGame::parsePvpSituations(const InputMessagePtr& msg)
{
    uint8 openPvpSituations = msg->getU8();

    g_game.setOpenPvpSituations(openPvpSituations);
}

void ProtocolGame::parsePlayerHelpers(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int helpers = msg->getU16();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature)
        g_game.processPlayerHelpers(helpers);
    else
        g_logger.traceError(stdext::format("could not get creature with id %d", id));
}

void ProtocolGame::parseGMActions(const InputMessagePtr& msg)
{
    std::vector<uint8> actions;

    int numViolationReasons;

    if(g_game.getClientVersion() >= 850)
        numViolationReasons = 20;
    else if(g_game.getClientVersion() >= 840)
        numViolationReasons = 23;
    else
        numViolationReasons = 32;

    for(int i = 0; i < numViolationReasons; ++i)
        actions.push_back(msg->getU8());
    g_game.processGMActions(actions);
}

void ProtocolGame::parseUpdateNeeded(const InputMessagePtr& msg)
{
    std::string signature = msg->getString();
    g_game.processUpdateNeeded(signature);
}

void ProtocolGame::parseLoginError(const InputMessagePtr& msg)
{
    std::string error = msg->getString();

    g_game.processLoginError(error);
}

void ProtocolGame::parseLoginAdvice(const InputMessagePtr& msg)
{
    std::string message = msg->getString();
    g_game.processLoginAdvice(message);
}

void ProtocolGame::parseLoginWait(const InputMessagePtr& msg)
{
    std::string message = msg->getString();
    int time = msg->getU8();
    g_game.processLoginWait(message, time);
}

void ProtocolGame::parseLoginToken(const InputMessagePtr& msg)
{
    bool unknown = (msg->getU8() == 0);
    g_game.processLoginToken(unknown);
}

void ProtocolGame::parsePing(const InputMessagePtr& msg)
{
    g_game.processPing();
}

void ProtocolGame::parsePingBack(const InputMessagePtr& msg)
{
    g_game.processPingBack();
}

void ProtocolGame::parseChallenge(const InputMessagePtr& msg)
{
    uint timestamp = msg->getU32();
    uint8 random = msg->getU8();

    sendLoginPacket(timestamp, random);
}

void ProtocolGame::parseDeath(const InputMessagePtr& msg)
{
    int penality = 100;
    int deathType = Otc::DeathRegular;

    if(g_game.getFeature(Otc::GameDeathType))
        deathType = msg->getU8();

    if(g_game.getFeature(Otc::GamePenalityOnDeath) && deathType == Otc::DeathRegular)
        penality = msg->getU8();

    g_game.processDeath(deathType, penality);
}

void ProtocolGame::parseMapDescription(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);

    if(!m_mapKnown)
        m_localPlayer->setPosition(pos);

    g_map.setCentralPosition(pos);

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y - range.top, pos.z, range.horizontal(), range.vertical());

    if(!m_mapKnown) {
        g_dispatcher.addEvent([] { g_lua.callGlobalField("g_game", "onMapKnown"); });
        m_mapKnown = true;
    }

    g_dispatcher.addEvent([] { g_lua.callGlobalField("g_game", "onMapDescription"); });
}

void ProtocolGame::parseMapMoveNorth(const InputMessagePtr& msg)
{
    Position pos;
    if(g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.y--;

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y - range.top, pos.z, range.horizontal(), 1);
    g_map.setCentralPosition(pos);
}

void ProtocolGame::parseMapMoveEast(const InputMessagePtr& msg)
{
    Position pos;
    if(g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.x++;

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x + range.right, pos.y - range.top, pos.z, 1, range.vertical());
    g_map.setCentralPosition(pos);
}

void ProtocolGame::parseMapMoveSouth(const InputMessagePtr& msg)
{
    Position pos;
    if(g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.y++;

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y + range.bottom, pos.z, range.horizontal(), 1);
    g_map.setCentralPosition(pos);
}

void ProtocolGame::parseMapMoveWest(const InputMessagePtr& msg)
{
    Position pos;
    if(g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    pos.x--;

    AwareRange range = g_map.getAwareRange();
    setMapDescription(msg, pos.x - range.left, pos.y - range.top, pos.z, 1, range.vertical());
    g_map.setCentralPosition(pos);
}

void ProtocolGame::parseUpdateTile(const InputMessagePtr& msg)
{
    Position tilePos = getPosition(msg);
    setTileDescription(msg, tilePos);
}

void ProtocolGame::parseTileAddThing(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);
    int stackPos = -1;

    if(g_game.getClientVersion() >= 841)
        stackPos = msg->getU8();

    ThingPtr thing = getThing(msg);
    g_map.addThing(thing, pos, stackPos);
}

void ProtocolGame::parseTileTransformThing(const InputMessagePtr& msg)
{
    ThingPtr thing = getMappedThing(msg);
    ThingPtr newThing = getThing(msg);

    if(!thing) {
        g_logger.traceError("no thing");
        return;
    }

    Position pos = thing->getPosition();
    int stackpos = thing->getStackPos();

    if(!g_map.removeThing(thing)) {
        g_logger.traceError("unable to remove thing");
        return;
    }

    g_map.addThing(newThing, pos, stackpos);
}

void ProtocolGame::parseTileRemoveThing(const InputMessagePtr& msg)
{
    ThingPtr thing = getMappedThing(msg);
    if(!thing) {
        g_logger.traceError("no thing");
        return;
    }

    if(!g_map.removeThing(thing))
        g_logger.traceError("unable to remove thing");
}

void ProtocolGame::parseCreatureMove(const InputMessagePtr& msg)
{
    ThingPtr thing = getMappedThing(msg);
    Position newPos = getPosition(msg);

    if(!thing || !thing->isCreature()) {
        g_logger.traceError("no creature found to move");
        return;
    }

    if(!g_map.removeThing(thing)) {
        g_logger.traceError("unable to remove creature");
        return;
    }

    CreaturePtr creature = thing->static_self_cast<Creature>();
    creature->allowAppearWalk();

    g_map.addThing(thing, newPos, -1);
}

void ProtocolGame::parseOpenContainer(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    ItemPtr containerItem = getItem(msg);
    std::string name = msg->getString();
    int capacity = msg->getU8();
    bool hasParent = (msg->getU8() != 0);

    bool isUnlocked = true;
    bool hasPages = false;
    int containerSize = 0;
    int firstIndex = 0;

    if(g_game.getFeature(Otc::GameContainerPagination)) {
        isUnlocked = (msg->getU8() != 0); // drag and drop
        hasPages = (msg->getU8() != 0); // pagination
        containerSize = msg->getU16(); // container size
        firstIndex = msg->getU16(); // first index
    }

    int itemCount = msg->getU8();

    std::vector<ItemPtr> items(itemCount);
    for(int i = 0; i < itemCount; i++)
        items[i] = getItem(msg);

    g_game.processOpenContainer(containerId, containerItem, name, capacity, hasParent, items, isUnlocked, hasPages, containerSize, firstIndex);
}

void ProtocolGame::parseCloseContainer(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    g_game.processCloseContainer(containerId);
}

void ProtocolGame::parseContainerAddItem(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    int slot = 0;
    if(g_game.getFeature(Otc::GameContainerPagination)) {
        slot = msg->getU16(); // slot
    }
    ItemPtr item = getItem(msg);
    g_game.processContainerAddItem(containerId, item, slot);
}

void ProtocolGame::parseContainerUpdateItem(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    int slot;
    if(g_game.getFeature(Otc::GameContainerPagination)) {
        slot = msg->getU16();
    } else {
        slot = msg->getU8();
    }
    ItemPtr item = getItem(msg);
    g_game.processContainerUpdateItem(containerId, slot, item);
}

void ProtocolGame::parseContainerRemoveItem(const InputMessagePtr& msg)
{
    int containerId = msg->getU8();
    int slot;
    ItemPtr lastItem;
    if(g_game.getFeature(Otc::GameContainerPagination)) {
        slot = msg->getU16();

        int itemId = msg->getU16();
        if(itemId != 0)
            lastItem = getItem(msg, itemId);
    } else {
        slot = msg->getU8();
    }
    g_game.processContainerRemoveItem(containerId, slot, lastItem);
}

void ProtocolGame::parseAddInventoryItem(const InputMessagePtr& msg)
{
    int slot = msg->getU8();
    ItemPtr item = getItem(msg);
    g_game.processInventoryChange(slot, item);
}

void ProtocolGame::parseRemoveInventoryItem(const InputMessagePtr& msg)
{
    int slot = msg->getU8();
    g_game.processInventoryChange(slot, ItemPtr());
}

void ProtocolGame::parseOpenNpcTrade(const InputMessagePtr& msg)
{
    std::vector<std::tuple<ItemPtr, std::string, int, int, int>> items;
    std::string npcName;

    if(g_game.getFeature(Otc::GameNameOnNpcTrade))
        npcName = msg->getString();

    int listCount;

    if(g_game.getClientVersion() >= 900)
        listCount = msg->getU16();
    else
        listCount = msg->getU8();

    for(int i = 0; i < listCount; ++i) {
        uint16 itemId = msg->getU16();
        uint8 count = msg->getU8();

        ItemPtr item = Item::create(itemId);
        item->setCountOrSubType(count);

        std::string name = msg->getString();
        int weight = msg->getU32();
        int buyPrice = msg->getU32();
        int sellPrice = msg->getU32();
        items.push_back(std::make_tuple(item, name, weight, buyPrice, sellPrice));
    }

    g_game.processOpenNpcTrade(items);
}

void ProtocolGame::parsePlayerGoods(const InputMessagePtr& msg)
{
    std::vector<std::tuple<ItemPtr, int>> goods;

    int money;
    if(g_game.getClientVersion() >= 973)
        money = msg->getU64();
    else
        money = msg->getU32();

    int size = msg->getU8();
    for(int i = 0; i < size; i++) {
        int itemId = msg->getU16();
        int amount;

        if(g_game.getFeature(Otc::GameDoubleShopSellAmount))
            amount = msg->getU16();
        else
            amount = msg->getU8();

        goods.push_back(std::make_tuple(Item::create(itemId), amount));
    }

    g_game.processPlayerGoods(money, goods);
}

void ProtocolGame::parseCloseNpcTrade(const InputMessagePtr&)
{
    g_game.processCloseNpcTrade();
}

void ProtocolGame::parseOwnTrade(const InputMessagePtr& msg)
{
    std::string name = g_game.formatCreatureName(msg->getString());
    int count = msg->getU8();

    std::vector<ItemPtr> items(count);
    for(int i = 0; i < count; i++)
        items[i] = getItem(msg);

    g_game.processOwnTrade(name, items);
}

void ProtocolGame::parseCounterTrade(const InputMessagePtr& msg)
{
    std::string name = g_game.formatCreatureName(msg->getString());
    int count = msg->getU8();

    std::vector<ItemPtr> items(count);
    for(int i = 0; i < count; i++)
        items[i] = getItem(msg);

    g_game.processCounterTrade(name, items);
}

void ProtocolGame::parseCloseTrade(const InputMessagePtr&)
{
    g_game.processCloseTrade();
}

void ProtocolGame::parseWorldLight(const InputMessagePtr& msg)
{
    Light light;
    light.intensity = msg->getU8();
    light.color = msg->getU8();

    g_map.setLight(light);
}

void ProtocolGame::parseMagicEffect(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);
    int effectId = msg->getU8();

    if(!g_things.isValidDatId(effectId, ThingCategoryEffect)) {
        g_logger.traceError(stdext::format("invalid effect id %d", effectId));
        return;
    }

    EffectPtr effect = EffectPtr(new Effect());
    effect->setId(effectId);
    g_map.addThing(effect, pos);
}

void ProtocolGame::parseAnimatedText(const InputMessagePtr& msg)
{
    Position position = getPosition(msg);
    int color = msg->getU8();
    std::string text = msg->getString();

    AnimatedTextPtr animatedText = AnimatedTextPtr(new AnimatedText);
    animatedText->setColor(color);
    animatedText->setText(text);
    g_map.addThing(animatedText, position);
}

void ProtocolGame::parseAnimatedTexts(const InputMessagePtr& msg)
{
	Position position = getPosition(msg);
	int colorOne = msg->getU8();
	int colorTwo = msg->getU8();
	std::string textOne = msg->getString();
	std::string textTwo = msg->getString();

	AnimatedTextPtr animatedText = AnimatedTextPtr(new AnimatedText);
	animatedText->setColors(colorOne,colorTwo);
	animatedText->setTexts(textOne,textTwo);

	g_map.addThing(animatedText, position);
}

void ProtocolGame::parseDistanceMissile(const InputMessagePtr& msg)
{
    Position fromPos = getPosition(msg);
    Position toPos = getPosition(msg);
    int shotId = msg->getU8();

    if(!g_things.isValidDatId(shotId, ThingCategoryMissile)) {
        g_logger.traceError(stdext::format("invalid missile id %d", shotId));
        return;
    }

    MissilePtr missile = MissilePtr(new Missile());
    missile->setId(shotId);
    missile->setPath(fromPos, toPos);
    g_map.addThing(missile, fromPos);
}

void ProtocolGame::parseCreatureMark(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int color = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature)
        creature->addTimedSquare(color);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseTrappers(const InputMessagePtr& msg)
{
    int numTrappers = msg->getU8();

    if(numTrappers > 8)
        g_logger.traceError("too many trappers");

    for(int i=0;i<numTrappers;++i) {
        uint id = msg->getU32();
        CreaturePtr creature = g_map.getCreatureById(id);
        if(creature) {
            //TODO: set creature as trapper
        } else
            g_logger.traceError("could not get creature");
    }
}

void ProtocolGame::parseCreatureHealth(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int healthPercent = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature)
        creature->setHealthPercent(healthPercent);

    // some servers has a bug in get spectators and sends unknown creatures updates
    // so this code is disabled
    /*
    else
        g_logger.traceError("could not get creature");
    */
}

void ProtocolGame::parseCreatureLight(const InputMessagePtr& msg)
{
    uint id = msg->getU32();

    Light light;
    light.intensity = msg->getU8();
    light.color = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature)
        creature->setLight(light);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureOutfit(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
	Outfit outfit = getOutfit(msg);
	uint attackOutfitId = msg->getU32();

    CreaturePtr creature = g_map.getCreatureById(id);
	if (creature)
	{
		creature->setOutfit(outfit);
	}
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureSpeed(const InputMessagePtr& msg)
{
    uint id = msg->getU32();

    int baseSpeed = -1;
    if(g_game.getClientVersion() >= 1059)
        baseSpeed = msg->getU16();

    int speed = msg->getU16();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature) {
        creature->setSpeed(speed);
        if(baseSpeed != -1)
            creature->setBaseSpeed(baseSpeed);
    }

    // some servers has a bug in get spectators and sends unknown creatures updates
    // so this code is disabled
    /*
    else
        g_logger.traceError("could not get creature");
    */
}

void ProtocolGame::parseCreatureSkulls(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int skull = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature)
        creature->setSkull(skull);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureShields(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    int shield = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature)
        creature->setShield(shield);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseCreatureUnpass(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    bool unpass = msg->getU8();

    CreaturePtr creature = g_map.getCreatureById(id);
    if(creature)
        creature->setPassable(!unpass);
    else
        g_logger.traceError("could not get creature");
}

void ProtocolGame::parseEditText(const InputMessagePtr& msg)
{
    uint id = msg->getU32();

    int itemId;
    if(g_game.getClientVersion() >= 1010) {
        // TODO: processEditText with ItemPtr as parameter
        ItemPtr item = getItem(msg);
        itemId = item->getId();
    } else
        itemId = msg->getU16();

    int maxLength = msg->getU16();
    std::string text = msg->getString();

    std::string writer = msg->getString();
    std::string date = "";
    if(g_game.getFeature(Otc::GameWritableDate))
        date = msg->getString();

    g_game.processEditText(id, itemId, maxLength, text, writer, date);
}

void ProtocolGame::parseEditList(const InputMessagePtr& msg)
{
    int doorId = msg->getU8();
    uint id = msg->getU32();
    const std::string& text = msg->getString();

    g_game.processEditList(id, doorId, text);
}

void ProtocolGame::parsePremiumTrigger(const InputMessagePtr& msg)
{
    int triggerCount = msg->getU8();
    std::vector<int> triggers;
    for(int i=0;i<triggerCount;++i) {
        triggers.push_back(msg->getU8());
    }
    bool something = msg->getU8() == 1;
}

void ProtocolGame::parsePlayerInfo(const InputMessagePtr& msg)
{
    bool premium = msg->getU8(); // premium
    int vocation = msg->getU8(); // vocation
    if(g_game.getFeature(Otc::GamePremiumExpiration))
        int premiumEx = msg->getU32(); // premium expiration used for premium advertisement

    m_localPlayer->setPremium(premium);
    m_localPlayer->setVocation(vocation);
}

void ProtocolGame::parsePlayerStats(const InputMessagePtr& msg)
{
	double health = msg->getU16();
	double mana = msg->getU16();
	double freeCapacity = msg->getU32() / 100.0;
	double experience = msg->getU32();
	double level = msg->getU16();
	double levelPercent = msg->getU8();
	double baseSpeed = msg->getU16();

	m_localPlayer->setHealth(health);
	m_localPlayer->setMana(mana);
	m_localPlayer->setFreeCapacity(freeCapacity);
	m_localPlayer->setBaseSpeed(baseSpeed);
	m_localPlayer->setExperience(experience);
	m_localPlayer->setLevel(level, levelPercent);
}

void ProtocolGame::parsePlayerSkills(const InputMessagePtr& msg)
{
	int16_t vitality = msg->getU16();
	int16_t force = msg->getU16();
	int16_t agility = msg->getU16();
	int16_t intelligence = msg->getU16();
	int16_t concentration = msg->getU16();
	int16_t stamina = msg->getU16();

	int16_t distance = msg->getU16();
	int16_t melee = msg->getU16();
	int16_t mentality = msg->getU16();
	int16_t trainer = msg->getU16();
	int16_t defense = msg->getU16();

	int16_t levelPoints = msg->getU16();
	int16_t unusedMagicPoints = msg->getU8();	

	m_localPlayer->setSkill(0, vitality);
	m_localPlayer->setSkill(1, force);
	m_localPlayer->setSkill(2, agility);
	m_localPlayer->setSkill(3, intelligence);
	m_localPlayer->setSkill(4, concentration);
	m_localPlayer->setSkill(5, stamina);

	m_localPlayer->setSkill(6, distance);
	m_localPlayer->setSkill(7, melee);
	m_localPlayer->setSkill(8, mentality);
	m_localPlayer->setSkill(9, trainer);
	m_localPlayer->setSkill(10, defense);

	m_localPlayer->setLevelPoints(levelPoints);
}

void ProtocolGame::parsePlayerState(const InputMessagePtr& msg)
{
    int states;
    if(g_game.getFeature(Otc::GamePlayerStateU16))
        states = msg->getU16();
    else
        states = msg->getU8();

    m_localPlayer->setStates(states);
}

void ProtocolGame::parsePlayerFirstStats(const InputMessagePtr& msg)
{
	int16_t health = msg->getU16();
	int16_t mana = msg->getU16();
	int32_t freeCapacity = msg->getU32();
	int32_t experience = msg->getU32();
	int16_t levelInfo = msg->getU16();
	int16_t levelPercent = msg->getU8();
	int16_t baseSpeed = msg->getU16();
	int16_t maxHealth = msg->getU16();
	int16_t maxMana = msg->getU16();

	m_localPlayer->setHealth(health);
	m_localPlayer->setMana(mana);
	m_localPlayer->setFreeCapacity(freeCapacity);
	m_localPlayer->setExperience(experience);
	m_localPlayer->setLevel(levelInfo, levelPercent);
	m_localPlayer->setBaseSpeed(baseSpeed);
	m_localPlayer->setMaxHealth(maxHealth);
	m_localPlayer->setMaxMana(maxMana);	
}

void ProtocolGame::parsePlayerSpells(const InputMessagePtr& msg)
{
	uint8 countSpells = msg->getU8();
	std::list<std::tuple<unsigned char, unsigned char>> spells;
	unsigned char spellId;
	unsigned char level;
	for (int i = 0; i < countSpells; i++)
	{
		spellId = msg->getU8();
		level = msg->getU8();
		spells.push_back(std::make_tuple(spellId, level));

	}
	m_localPlayer->setSpells(spells);
}

void ProtocolGame::parsePlayerSpellLearned(const InputMessagePtr& msg)
{
	uint8 spellId = msg->getU8();
	uint8 spellLevel = msg->getU8();

	m_localPlayer->setSpell(std::make_tuple(spellId, spellLevel));
}


void ProtocolGame::parsePlayerBreath(const InputMessagePtr& msg)
{
	uint8 breath = msg->getU8();
	m_localPlayer->setBreath(breath);
}


void ProtocolGame::parsePlayerNpcWindow(const InputMessagePtr& msg)
{
	uint16 windowId = msg->getU16();

	switch (windowId)
	{
		case 1: //open npc window
			m_localPlayer->openNpcWindow(windowId);
		break;


		default:
		break;
	}
}

void ProtocolGame::parsePlayerCancelAttack(const InputMessagePtr& msg)
{
    uint seq = 0;
    if(g_game.getFeature(Otc::GameAttackSeq))
        seq = msg->getU32();

    g_game.processAttackCancel(seq);
}

void ProtocolGame::parsePlayerModes(const InputMessagePtr& msg)
{
    int fightMode = msg->getU8();
    int chaseMode = msg->getU8();
    bool safeMode = msg->getU8();

    int pvpMode = 0;
    if(g_game.getFeature(Otc::GamePVPMode))
        pvpMode = msg->getU8();

    g_game.processPlayerModes((Otc::FightModes)fightMode, (Otc::ChaseModes)chaseMode, safeMode, (Otc::PVPModes)pvpMode);
}

void ProtocolGame::parseUpdateBalance(const InputMessagePtr& msg)
{
	uint32_t localBalance = msg->getU32();

	m_localPlayer->setLocalBalance(localBalance);
}

void ProtocolGame::parseSpellCooldown(const InputMessagePtr& msg)
{
    int spellId = msg->getU8();
    int delay = msg->getU32();

    g_lua.callGlobalField("g_game", "onSpellCooldown", spellId, delay);
}

void ProtocolGame::parseSpellGroupCooldown(const InputMessagePtr& msg)
{
    int groupId = msg->getU8();
    int delay = msg->getU32();

    g_lua.callGlobalField("g_game", "onSpellGroupCooldown", groupId, delay);
}

void ProtocolGame::parseMultiUseCooldown(const InputMessagePtr& msg)
{
    int delay = msg->getU32();

    g_lua.callGlobalField("g_game", "onMultiUseCooldown", delay);
}

void ProtocolGame::parseTalk(const InputMessagePtr& msg)
{
    std::string name = g_game.formatCreatureName(msg->getString());

    int level = 0;

	Otc::MessageMode mode = (Otc::MessageMode)msg->getU8();
    int channelId = 0;
    Position pos;

    switch(mode) {
		case Otc::MSG_PLAYER_TALK:
		case Otc::MSG_PLAYER_WHISPER:
		case Otc::MSG_PLAYER_YELL:
		case Otc::MSG_MONSTER_TALK:
		case Otc::MSG_MONSTER_YELL:
            pos = getPosition(msg);
            break;
		case Otc::MSG_PLAYER_PRIVATE_TO:

			channelId = msg->getU16(); 
            break;
        default:
            //stdext::throw_exception(stdext::format("unknown message mode %d", mode));
            break;
	}

    std::string text = msg->getString();
	
    g_game.processTalk(name, level, mode, text, channelId, pos);
}

void ProtocolGame::parseChannelList(const InputMessagePtr& msg)
{
    int count = msg->getU8();
    std::vector<std::tuple<int, std::string> > channelList;
    for(int i = 0; i < count; i++) {
        int id = msg->getU16();
        std::string name = msg->getString();
        channelList.push_back(std::make_tuple(id, name));
    }

    g_game.processChannelList(channelList);
}

void ProtocolGame::parseOpenChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();
    std::string name = msg->getString();

    if(g_game.getFeature(Otc::GameChannelPlayerList)) {
        int joinedPlayers = msg->getU16();
        for(int i=0;i<joinedPlayers;++i)
            g_game.formatCreatureName(msg->getString()); // player name
        int invitedPlayers = msg->getU16();
        for(int i=0;i<invitedPlayers;++i)
            g_game.formatCreatureName(msg->getString()); // player name
    }

    g_game.processOpenChannel(channelId, name);
}

void ProtocolGame::parseOpenPrivateChannel(const InputMessagePtr& msg)
{
    std::string name = g_game.formatCreatureName(msg->getString());

    g_game.processOpenPrivateChannel(name);
}

void ProtocolGame::parseOpenOwnPrivateChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();
    std::string name = msg->getString();

    g_game.processOpenOwnPrivateChannel(channelId, name);
}

void ProtocolGame::parseCloseChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();

    g_game.processCloseChannel(channelId);
}

void ProtocolGame::parseRuleViolationChannel(const InputMessagePtr& msg)
{
    int channelId = msg->getU16();

    g_game.processRuleViolationChannel(channelId);
}

void ProtocolGame::parseRuleViolationRemove(const InputMessagePtr& msg)
{
    std::string name = msg->getString();

    g_game.processRuleViolationRemove(name);
}

void ProtocolGame::parseRuleViolationCancel(const InputMessagePtr& msg)
{
    std::string name = msg->getString();

    g_game.processRuleViolationCancel(name);
}

void ProtocolGame::parseRuleViolationLock(const InputMessagePtr& msg)
{
    g_game.processRuleViolationLock();
}

void ProtocolGame::parseTextMessage(const InputMessagePtr& msg)
{
	uint8 targetGUI = msg->getU8();
    uint8 mode = msg->getU8();
	uint8 color = msg->getU8();
    std::string text = msg->getString();

    g_game.processTextMessage((Otc::MessageMode)mode, targetGUI, color, text);
}

void ProtocolGame::parseCancelWalk(const InputMessagePtr& msg)
{
    Otc::Direction direction = (Otc::Direction)msg->getU8();

    g_game.processWalkCancel(direction);
}

void ProtocolGame::parseWalkWait(const InputMessagePtr& msg)
{
    int millis = msg->getU16();
    m_localPlayer->lockWalk(millis);
}

void ProtocolGame::parseFloorChangeUp(const InputMessagePtr& msg)
{
    Position pos;
    if(g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    AwareRange range = g_map.getAwareRange();
    pos.z--;

    int skip = 0;
    if(pos.z == Otc::SEA_FLOOR)
        for(int i = Otc::SEA_FLOOR - Otc::AWARE_UNDEGROUND_FLOOR_RANGE; i >= 0; i--)
            skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, i, range.horizontal(), range.vertical(), 8 - i, skip);
    else if(pos.z > Otc::SEA_FLOOR)
        skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, pos.z - Otc::AWARE_UNDEGROUND_FLOOR_RANGE, range.horizontal(), range.vertical(), 3, skip);

    pos.x++;
    pos.y++;
    g_map.setCentralPosition(pos);
}

void ProtocolGame::parseFloorChangeDown(const InputMessagePtr& msg)
{
    Position pos;
    if(g_game.getFeature(Otc::GameMapMovePosition))
        pos = getPosition(msg);
    else
        pos = g_map.getCentralPosition();
    AwareRange range = g_map.getAwareRange();
    pos.z++;

    int skip = 0;
    if(pos.z == Otc::UNDERGROUND_FLOOR) 
	{
        int j, i;
        for(i = pos.z, j = -1; i <= pos.z + Otc::AWARE_UNDEGROUND_FLOOR_RANGE; ++i, --j)
            skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, i, range.horizontal(), range.vertical(), j, skip);
    }
    else if(pos.z > Otc::UNDERGROUND_FLOOR && pos.z < Otc::MAX_Z-1)
        skip = setFloorDescription(msg, pos.x - range.left, pos.y - range.top, pos.z + Otc::AWARE_UNDEGROUND_FLOOR_RANGE, range.horizontal(), range.vertical(), -3, skip);

    pos.x--;
    pos.y--;
    g_map.setCentralPosition(pos);
}

void ProtocolGame::parseOpenOutfitWindow(const InputMessagePtr& msg)
{
	//parse current outfit and colors
    Outfit currentOutfit = getOutfit(msg);

	//outfits and addons
	std::vector<std::pair<std::uint8_t,std::uint8_t>> outfits;

	//parsing
	uint8_t vSize = msg->getU8();
	for (int i = 0; i < vSize; i++)
	{
		//parse outfit
		uint8_t outfit = msg->getU8();
		uint8_t addons = msg->getU8();
		outfits.push_back(std::make_pair(outfit, addons));		
	}

    g_game.processOpenOutfitWindow(currentOutfit, outfits);
}

void ProtocolGame::parseVipAdd(const InputMessagePtr& msg)
{
    uint id, iconId = 0, status;
    std::string name, desc = "";
    bool notifyLogin = false;

    id = msg->getU32();
    name = g_game.formatCreatureName(msg->getString());
    if(g_game.getFeature(Otc::GameAdditionalVipInfo)) {
        desc = msg->getString();
        iconId = msg->getU32();
        notifyLogin = msg->getU8();
    }
    status = msg->getU8();

    g_game.processVipAdd(id, name, status, desc, iconId, notifyLogin);
}

void ProtocolGame::parseVipState(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    if(g_game.getFeature(Otc::GameLoginPending)) {
        uint status = msg->getU8();
        g_game.processVipStateChange(id, status);
    }
    else {
        g_game.processVipStateChange(id, 1);
    }
}

void ProtocolGame::parseVipLogout(const InputMessagePtr& msg)
{
    uint id = msg->getU32();
    g_game.processVipStateChange(id, 0);
}

void ProtocolGame::parseTutorialHint(const InputMessagePtr& msg)
{
    int id = msg->getU8();
    g_game.processTutorialHint(id);
}

void ProtocolGame::parseAutomapFlag(const InputMessagePtr& msg)
{
    Position pos = getPosition(msg);
    int icon = msg->getU8();
    std::string description = msg->getString();

    bool remove = false;
    if(g_game.getFeature(Otc::GameMinimapRemove))
        remove = msg->getU8() != 0;

    if(!remove)
        g_game.processAddAutomapFlag(pos, icon, description);
    else
        g_game.processRemoveAutomapFlag(pos, icon, description);
}

void ProtocolGame::parseQuestLog(const InputMessagePtr& msg)
{
    std::vector<std::tuple<int, std::string, bool> > questList;
    int questsCount = msg->getU16();
    for(int i = 0; i < questsCount; i++) {
        int id = msg->getU16();
        std::string name = msg->getString();
        bool completed = msg->getU8();
        questList.push_back(std::make_tuple(id, name, completed));
    }

    g_game.processQuestLog(questList);
}

void ProtocolGame::parseQuestLine(const InputMessagePtr& msg)
{
    std::vector<std::tuple<std::string, std::string>> questMissions;
    int questId = msg->getU16();
    int missionCount = msg->getU8();
    for(int i = 0; i < missionCount; i++) {
        std::string missionName = msg->getString();
        std::string missionDescrition = msg->getString();
        questMissions.push_back(std::make_tuple(missionName, missionDescrition));
    }

    g_game.processQuestLine(questId, questMissions);
}

void ProtocolGame::parseChannelEvent(const InputMessagePtr& msg)
{
    msg->getU16(); // channel id
    g_game.formatCreatureName(msg->getString()); // player name
    msg->getU8(); // event type
}

void ProtocolGame::parseItemInfo(const InputMessagePtr& msg)
{
    std::vector<std::tuple<ItemPtr, std::string>> list;
    int size = msg->getU8();
    for(int i=0;i<size;++i) {
        ItemPtr item(new Item);
        item->setId(msg->getU16());
        item->setCountOrSubType(msg->getU8());

        std::string desc = msg->getString();
        list.push_back(std::make_tuple(item, desc));
    }

    g_lua.callGlobalField("g_game", "onItemInfo", list);
}

void ProtocolGame::parsePlayerInventory(const InputMessagePtr& msg)
{
    int size = msg->getU16();
    for(int i=0;i<size;++i) {
        msg->getU16(); // id
        msg->getU8(); // subtype
        msg->getU16(); // count
    }
}

void ProtocolGame::parseModalDialog(const InputMessagePtr& msg)
{
    uint32 id = msg->getU32();
    std::string title = msg->getString();
    std::string message = msg->getString();

    int sizeButtons = msg->getU8();
    std::vector<std::tuple<int, std::string> > buttonList;
    for(int i = 0; i < sizeButtons; ++i) {
        std::string value = msg->getString();
        int id = msg->getU8();
        buttonList.push_back(std::make_tuple(id, value));
    }

    int sizeChoices = msg->getU8();
    std::vector<std::tuple<int, std::string> > choiceList;
    for(int i = 0; i < sizeChoices; ++i) {
        std::string value = msg->getString();
        int id = msg->getU8();
        choiceList.push_back(std::make_tuple(id, value));
    }

    int enterButton, escapeButton;
    if(g_game.getClientVersion() > 970) {
        escapeButton = msg->getU8();
        enterButton = msg->getU8();
    }
    else {
        enterButton = msg->getU8();
        escapeButton = msg->getU8();
    }

    bool priority = msg->getU8() == 0x01;

    g_game.processModalDialog(id, title, message, buttonList, enterButton, escapeButton, choiceList, priority);
}

void ProtocolGame::parseExtendedOpcode(const InputMessagePtr& msg)
{
    int opcode = msg->getU8();
    std::string buffer = msg->getString();

    if(opcode == 0)
        m_enableSendExtendedOpcode = true;
    else if(opcode == 2)
        parsePingBack(msg);
    else
        callLuaField("onExtendedOpcode", opcode, buffer);
}

void ProtocolGame::parseChangeMapAwareRange(const InputMessagePtr& msg)
{
    int xrange = msg->getU8();
    int yrange = msg->getU8();

    AwareRange range;
    range.left = xrange/2 - ((xrange+1) % 2);
    range.right = xrange/2;
    range.top = yrange/2 - ((yrange+1) % 2);
    range.bottom = yrange/2;

    g_map.setAwareRange(range);
    g_lua.callGlobalField("g_game", "onMapChangeAwareRange", xrange, yrange);
}

void ProtocolGame::parseCreaturesMark(const InputMessagePtr& msg)
{
    int len;
    if(g_game.getClientVersion() >= 1035) {
        len = 1;
    } else {
        len = msg->getU8();
    }

    for(int i=0; i<len; ++i) {
        uint32 id = msg->getU32();
        bool isPermanent = msg->getU8() != 1;
        uint8 markType = msg->getU8();

        CreaturePtr creature = g_map.getCreatureById(id);
        if(creature) {
            if(isPermanent) {
                if(markType == 0xff)
                    creature->hideStaticSquare();
                else
                    creature->showStaticSquare(Color::from8bit(markType));
            } else
                creature->addTimedSquare(markType);
        } else
            g_logger.traceError("could not get creature");
    }
}

void ProtocolGame::parseCreatureType(const InputMessagePtr& msg)
{
    uint32 id = msg->getU32();
    uint8 type = msg->getU8();
}

void ProtocolGame::setMapDescription(const InputMessagePtr& msg, int x, int y, int z, int width, int height)
{
    int startz, endz, zstep;

    if(z > Otc::SEA_FLOOR) {
        startz = z - Otc::AWARE_UNDEGROUND_FLOOR_RANGE;
        endz = std::min<int>(z + Otc::AWARE_UNDEGROUND_FLOOR_RANGE, (int)Otc::MAX_Z);
        zstep = 1;
    }
    else {
        startz = Otc::SEA_FLOOR;
        endz = 0;
        zstep = -1;
    }

    int skip = 0;
    for(int nz = startz; nz != endz + zstep; nz += zstep)
        skip = setFloorDescription(msg, x, y, nz, width, height, z - nz, skip);
}

int ProtocolGame::setFloorDescription(const InputMessagePtr& msg, int x, int y, int z, int width, int height, int offset, int skip)
{
    for(int nx = 0; nx < width; nx++) {
        for(int ny = 0; ny < height; ny++) {
            Position tilePos(x + nx + offset, y + ny + offset, z);
            if(skip == 0)
                skip = setTileDescription(msg, tilePos);
            else {
                g_map.cleanTile(tilePos);
                skip--;
            }
        }
    }
    return skip;
}

int ProtocolGame::setTileDescription(const InputMessagePtr& msg, Position position)
{
    g_map.cleanTile(position);

    bool gotEffect = false;
    for(int stackPos=0;stackPos<256;stackPos++) {
        if(msg->peekU16()  >= 0xff00)
            return msg->getU16() & 0xff;

        if(g_game.getFeature(Otc::GameEnvironmentEffect) && !gotEffect) {
            msg->getU16(); // environment effect
            gotEffect = true;
            continue;
        }

        if(stackPos > 10)
            g_logger.traceError(stdext::format("too many things, pos=%s, stackpos=%d", stdext::to_string(position), stackPos));

        ThingPtr thing = getThing(msg);
        g_map.addThing(thing, position, stackPos);
    }

    return 0;
}
Outfit ProtocolGame::getOutfit(const InputMessagePtr& msg)
{
    Outfit outfit;

    int lookType = msg->getU8();

    if(lookType != 0) 
	{
        outfit.setCategory(ThingCategoryCreature);
        int head = msg->getU32();
		int body = msg->getU32();
		int legs = msg->getU32();
		int feet = msg->getU32();
        int addons = msg->getU8();

        if(!g_things.isValidDatId(lookType, ThingCategoryCreature)) 
		{
            g_logger.traceError(stdext::format("invalid outfit looktype %d", lookType));
            lookType = 0;
        }

        outfit.setId(lookType);
        outfit.setHead(head);
        outfit.setBody(body);
        outfit.setLegs(legs);
        outfit.setFeet(feet);
        outfit.setAddons(addons);
    }
    else 
	{
        int lookTypeEx = msg->getU16();
        if(lookTypeEx == 0) {
            outfit.setCategory(ThingCategoryEffect);
            outfit.setAuxId(13); // invisible effect id
        }
        else {
            if(!g_things.isValidDatId(lookTypeEx, ThingCategoryItem)) {
                g_logger.traceError(stdext::format("invalid outfit looktypeex %d", lookTypeEx));
                lookTypeEx = 0;
            }
            outfit.setCategory(ThingCategoryItem);
            outfit.setAuxId(lookTypeEx);
        }
    }

   /* if(g_game.getFeature(Otc::GamePlayerMounts)) {
        int mount = msg->getU16();
        outfit.setMount(mount);
    }*/

    return outfit;
}

ThingPtr ProtocolGame::getThing(const InputMessagePtr& msg)
{
    ThingPtr thing;

    int id = msg->getU16();

    if(id == 0)
        stdext::throw_exception("invalid thing id");
    else if(id == Proto::UnknownCreature || id == Proto::OutdatedCreature || id == Proto::Creature)
        thing = getCreature(msg, id);
    else if(id == Proto::StaticText) // otclient only
        thing = getStaticText(msg, id);
    else // item
        thing = getItem(msg, id);

    return thing;
}

ThingPtr ProtocolGame::getMappedThing(const InputMessagePtr& msg)
{
    ThingPtr thing;
    uint16 x = msg->getU16();

    if(x != 0xffff) {
        Position pos;
        pos.x = x;
        pos.y = msg->getU16();
        pos.z = msg->getU8();
        uint8 stackpos = msg->getU8();
        assert(stackpos != 255);
        thing = g_map.getThing(pos, stackpos);
        if(!thing)
            g_logger.traceError(stdext::format("no thing at pos:%s, stackpos:%d", stdext::to_string(pos), stackpos));
    } else {
        uint32 id = msg->getU32();
        thing = g_map.getCreatureById(id);
        if(!thing)
            g_logger.traceError(stdext::format("no creature with id %u", id));
    }

    return thing;
}

CreaturePtr ProtocolGame::getCreature(const InputMessagePtr& msg, int type)
{
    if(type == 0)
        type = msg->getU16();

    CreaturePtr creature;
    bool known = (type != Proto::UnknownCreature);
    if(type == Proto::OutdatedCreature || type == Proto::UnknownCreature) {
        if(known) {
            uint id = msg->getU32();
            creature = g_map.getCreatureById(id);
            if(!creature)
                g_logger.traceError("server said that a creature is known, but it's not");
        } else {
            uint removeId = msg->getU32();
            g_map.removeCreatureById(removeId);

            uint id = msg->getU32();

            int creatureType;
            if(g_game.getClientVersion() >= 910)
                creatureType = msg->getU8();
            else {
                if(id >= Proto::PlayerStartId && id < Proto::PlayerEndId)
                    creatureType = Proto::CreatureTypePlayer;
                else if(id >= Proto::MonsterStartId && id < Proto::MonsterEndId)
                    creatureType = Proto::CreatureTypeMonster;
                else
                    creatureType = Proto::CreatureTypeNpc;
            }

            std::string name = g_game.formatCreatureName(msg->getString());

            if(id == m_localPlayer->getId())
                creature = m_localPlayer;
            else if(creatureType == Proto::CreatureTypePlayer) {
                // fixes a bug server side bug where GameInit is not sent and local player id is unknown
                if(m_localPlayer->getId() == 0 && name == m_localPlayer->getName())
                    creature = m_localPlayer;
                else
                    creature = PlayerPtr(new Player);
            }
            else if(creatureType == Proto::CreatureTypeMonster)
                creature = MonsterPtr(new Monster);
            else if(creatureType == Proto::CreatureTypeNpc)
                creature = NpcPtr(new Npc);
            else
                g_logger.traceError("creature type is invalid");

            if(creature) {
                creature->setId(id);
				creature->setName(name);
                
				//if (creature->isPlayer())
				//{
				//	//creature->setCachedName(creature->getName() + " (" + std::to_string((int)((LocalPlayerPtr)creature)->getLevel()) + ")");
				//}
				creature->setCachedName(creature->getName());

                g_map.addCreature(creature);
            }
        }

        int healthPercent = msg->getU8();
        Otc::Direction direction = (Otc::Direction)msg->getU8();
        Outfit outfit = getOutfit(msg);
		Outfit AttackOutfit = outfit;
		AttackOutfit.setId(msg->getU16());
		Outfit breathOutfit = outfit;
		breathOutfit.setId(msg->getU16());
		Outfit walkAttackOutfit = outfit;
		walkAttackOutfit.setId(msg->getU16());

        Light light;
        light.intensity = msg->getU8();
        light.color = msg->getU8();

        int speed = msg->getU16();
        int skull = msg->getU8();
        int shield = msg->getU8();

        // emblem is sent only when the creature is not known
        int emblem = -1;
        int icon = -1;
        bool unpass = true;
        uint8 mark;

        if(g_game.getFeature(Otc::GameCreatureEmblems) && !known)
            emblem = msg->getU8();

        if(g_game.getFeature(Otc::GameThingMarks)) {
            msg->getU8(); // creature type for summons
        }

        if(g_game.getFeature(Otc::GameCreatureIcons)) {
            icon = msg->getU8();
        }

        if(g_game.getFeature(Otc::GameThingMarks)) {
            mark = msg->getU8(); // mark
            msg->getU16(); // helpers

            if(creature) {
                if(mark == 0xff)
                    creature->hideStaticSquare();
                else
                    creature->showStaticSquare(Color::from8bit(mark));
            }
        }

        if(g_game.getClientVersion() >= 854)
            unpass = msg->getU8();

        if(creature) {
            creature->setHealthPercent(healthPercent);
            creature->setDirection(direction);
            creature->setOutfit(outfit);
			creature->setAttackOutfit(AttackOutfit);
			creature->setBreathOutfit(breathOutfit);
			creature->setWalkAttackOutfit(walkAttackOutfit);
            creature->setSpeed(speed);
            creature->setSkull(skull);
            creature->setShield(shield);
            creature->setPassable(!unpass);
            creature->setLight(light);
            if(emblem != -1)
                creature->setEmblem(emblem);
            if(icon != -1)
                creature->setIcon(icon);

            if(creature == m_localPlayer && !m_localPlayer->isKnown())
                m_localPlayer->setKnown(true);
        }
    } else if(type == Proto::Creature) {
        uint id = msg->getU32();
        creature = g_map.getCreatureById(id);

        if(!creature)
            g_logger.traceError("invalid creature");

        Otc::Direction direction = (Otc::Direction)msg->getU8();
        if(creature)
            creature->turn(direction);

        if(g_game.getClientVersion() >= 953) {
            bool unpass = msg->getU8();

            if(creature)
                creature->setPassable(!unpass);
        }

    } else {
        stdext::throw_exception("invalid creature opcode");
    }

    return creature;
}

ItemPtr ProtocolGame::getItem(const InputMessagePtr& msg, int id)
{
	if (id == 0)
		id = msg->getU16();

    ItemPtr item = Item::create(id);
    if(item->getId() == 0)
        stdext::throw_exception(stdext::format("unable to create item with invalid id %d", id));

    if(g_game.getFeature(Otc::GameThingMarks)) {
        msg->getU8(); // mark
    }

    if(item->isStackable() || item->isFluidContainer() || item->isSplash() || item->isChargeable())
        item->setCountOrSubType(msg->getU8());

    if(g_game.getFeature(Otc::GameItemAnimationPhase)) {
        if(item->getAnimationPhases() > 1) {
            // 0x00 => automatic phase
            // 0xFE => random phase
            // 0xFF => async phase
            msg->getU8();
            //item->setPhase(msg->getU8());
        }
    }

    return item;
}

StaticTextPtr ProtocolGame::getStaticText(const InputMessagePtr& msg, int id)
{
    int colorByte = msg->getU8();
    Color color = Color::from8bit(colorByte);
    std::string fontName = msg->getString();
    std::string text = msg->getString();
    StaticTextPtr staticText = StaticTextPtr(new StaticText);
    staticText->setText(text);
    staticText->setFont(fontName);
    staticText->setColor(color);
    return staticText;
}

Position ProtocolGame::getPosition(const InputMessagePtr& msg)
{
    uint16 x = msg->getU16();
    uint16 y = msg->getU16();
    uint8 z = msg->getU8();

    return Position(x, y, z);
}
