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

#include "protocolcodes.h"
#include "const.h"

namespace Proto {

std::map<uint8, uint8> messageModesMap;

void buildMessageModesMap(int version) {
    messageModesMap.clear();

    //messageModesMap[Otc::MessageNone]                    = 0;
    //messageModesMap[Otc::MessageSay]                     = 1;
    //messageModesMap[Otc::MessageWhisper]                 = 2;
    //messageModesMap[Otc::MessageYell]                    = 3;
    //messageModesMap[Otc::MessagePrivateFrom]             = 4;
    //messageModesMap[Otc::MessagePrivateTo]               = 4;
    //messageModesMap[Otc::MessageChannel]                 = 5;
    //messageModesMap[Otc::MessageRVRChannel]              = 6;
    //messageModesMap[Otc::MessageRVRAnswer]               = 7;
    //messageModesMap[Otc::MessageRVRContinue]             = 8;
    //messageModesMap[Otc::MessageGamemasterBroadcast]     = 9;
    //messageModesMap[Otc::MessageGamemasterChannel]       = 10;
    //messageModesMap[Otc::MessageGamemasterPrivateFrom]   = 11;
    //messageModesMap[Otc::MessageGamemasterPrivateTo]     = 11;
    //messageModesMap[Otc::MessageChannelHighlight]        = 12;
    //// 13, 14, 15 ??
    //messageModesMap[Otc::MessageMonsterSay]              = 16;
    //messageModesMap[Otc::MessageMonsterYell]             = 17;
    //messageModesMap[Otc::MessageWarning]                 = 18;
    //messageModesMap[Otc::MessageGame]                    = 19;
    //messageModesMap[Otc::MessageLogin]                   = 20;
    //messageModesMap[Otc::MessageStatus]                  = 21;
    //messageModesMap[Otc::MessageLook]                    = 22;
    //messageModesMap[Otc::MessageFailure]                 = 23;
    //messageModesMap[Otc::MessageBlue]                    = 24;
    //messageModesMap[Otc::MessageRed]                     = 25;
    //messageModesMap[Otc::MessageLevelUp]                 = 26;

}

Otc::MessageMode translateMessageModeFromServer(uint8 mode)
{
    //auto it = std::find_if(messageModesMap.begin(), messageModesMap.end(), [=] (const std::pair<uint8, uint8>& p) { return p.second == mode; });
    //if(it != messageModesMap.end())
    //    return (Otc::MessageMode)it->first;
    return Otc::MessageMode::MSG_BROADCAST;
}

uint8 translateMessageModeToServer(Otc::MessageMode mode)
{
   /* if(mode < 0 || mode >= Otc::LastMessage)
        return Otc::MessageInvalid;
    auto it = messageModesMap.find(mode);
    if(it != messageModesMap.end())
        return it->second;*/
	return Otc::MessageMode::MSG_BROADCAST;
}
