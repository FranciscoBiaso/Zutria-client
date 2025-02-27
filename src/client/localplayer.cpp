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

#include "localplayer.h"
#include "map.h"
#include "game.h"
#include "tile.h"
#include <framework/core/eventdispatcher.h>
#include <framework/graphics/graphics.h>

LocalPlayer::LocalPlayer()
{
    m_states = 0;
    m_vocation = 0;
    m_blessings = Otc::BlessingNone;
    m_walkLockExpiration = 0;

    m_skillsLevel.fill(-1);
    m_skillsBaseLevel.fill(-1);
    m_skillsLevelPercent.fill(-1);

	for (int i = 0; i < 12; i++)
		m_skills[i] = -1;

    m_health = -1;
    m_maxHealth = -1;
    m_freeCapacity = -1;
    m_experience = -1;
    m_level = -1;
	m_levelPoints = -1;
    m_levelPercent = -1;
    m_mana = -1;
    m_maxMana = -1;
    m_magicLevel = -1;
    m_magicLevelPercent = -1;
    m_baseMagicLevel = -1;
    m_soul = -1;
    m_stamina = -1;
    m_baseSpeed = -1;
    m_regenerationTime = -1;
    m_offlineTrainingTime = -1;
    m_totalCapacity = -1;
}

void LocalPlayer::lockWalk(int millis)
{
    m_walkLockExpiration = std::max<int>(m_walkLockExpiration, (ticks_t) g_clock.millis() + millis);
}

bool LocalPlayer::canWalk(Otc::Direction direction)
{
    // cannot walk while locked
    if(m_walkLockExpiration != 0 && g_clock.millis() < m_walkLockExpiration)
        return false;

    // paralyzed
    if(m_speed == 0)
        return false;

    // last walk is not done yet
    if((m_walkTimer.ticksElapsed() < getStepDuration()) && !isAutoWalking())
        return false;

    // avoid doing more walks than wanted when receiving a lot of walks from server
    if(!m_lastPrewalkDone)// && m_preWalking)// && !prewalkTimeouted)
        return false;

    // cannot walk while already walking
    if(getCreatureState() == CreatureState::walking && !isAutoWalking())
        return false;

    return true;
}

void LocalPlayer::cancelWalk(Otc::Direction direction)
{
	m_position = m_oldPosition;

    // only cancel client side walks
    if(getCreatureState() == CreatureState::walking)
        stopWalk();

    m_lastPrewalkDone = true;
    m_idleTimer.restart();
    lockWalk();

    if(m_autoWalkDestination.isValid()) {
        g_game.stop();
        auto self = asLocalPlayer();
        if(m_autoWalkContinueEvent)
            m_autoWalkContinueEvent->cancel();
        m_autoWalkContinueEvent = g_dispatcher.scheduleEvent([self]() {
            if(self->m_autoWalkDestination.isValid())
                self->autoWalk(self->m_autoWalkDestination);
        }, 500);
    }

    // turn to the cancel direction
    if(direction != Otc::InvalidDirection)
        setDirection(direction);

    callLuaField("onCancelWalk", direction);
}

bool LocalPlayer::autoWalk(const Position& destination)
{
    bool tryKnownPath = false;
    if(destination != m_autoWalkDestination) {
        m_knownCompletePath = false;
        tryKnownPath = true;
    }

    std::tuple<std::vector<Otc::Direction>, Otc::PathFindResult> result;
    std::vector<Otc::Direction> limitedPath;

    if(destination == m_position)
        return true;

    // try to find a path that we know
    if(tryKnownPath || m_knownCompletePath) {
        result = g_map.findPath(m_position, destination, 50000, 0);
        if(std::get<1>(result) == Otc::PathFindResultOk) {
            limitedPath = std::get<0>(result);
            // limit to 127 steps
            if(limitedPath.size() > 127)
                limitedPath.resize(127);
            m_knownCompletePath = true;
        }
    }

    // no known path found, try to discover one
    if(limitedPath.empty()) {
        result = g_map.findPath(m_position, destination, 50000, Otc::PathFindAllowNotSeenTiles);
        if(std::get<1>(result) != Otc::PathFindResultOk) {
            callLuaField("onAutoWalkFail", std::get<1>(result));
            stopAutoWalk();
            return false;
        }

        Position currentPos = m_position;
        for(auto dir : std::get<0>(result)) {
            currentPos = currentPos.translatedToDirection(dir);
            if(!hasSight(currentPos))
                break;
            else
                limitedPath.push_back(dir);
        }
    }

    m_autoWalkDestination = destination;
    m_lastAutoWalkPosition = m_position.translatedToDirections(limitedPath).back();

    /*
    // debug calculated path using minimap
    for(auto pos : m_position.translatedToDirections(limitedPath)) {
        g_map.getOrCreateTile(pos)->overwriteMinimapColor(215);
        g_map.notificateTileUpdate(pos);
    }
    */

    g_game.autoWalk(limitedPath);
    return true;
}

void LocalPlayer::stopAutoWalk()
{
    m_autoWalkDestination = Position();
    m_lastAutoWalkPosition = Position();
    m_knownCompletePath = false;

    if(m_autoWalkContinueEvent)
        m_autoWalkContinueEvent->cancel();
}


void LocalPlayer::stopWalk()
{
    Creature::stopWalk(); // will call terminateWalk

    m_lastPrewalkDone = true;
    m_lastPrewalkDestination = Position();
}


bool LocalPlayer::hasSpell(uint8 spellId)
{
	for (auto it = m_spells.begin(); it != m_spells.end(); ++it)
		if (std::get<0>(*it) == spellId)
			return true;
	return false;
}

void LocalPlayer::onAppear()
{
    Creature::onAppear();

    /* Does not seem to be needed anymore
    // on teleports lock the walk
    if(!m_oldPosition.isInRange(m_position,1,1))
        lockWalk();
    */
}

void LocalPlayer::onPositionChange(const Position& newPos, const Position& oldPos)
{
    Creature::onPositionChange(newPos, oldPos);

    if(newPos == m_autoWalkDestination)
        stopAutoWalk();
    else if(m_autoWalkDestination.isValid() && newPos == m_lastAutoWalkPosition)
        autoWalk(m_autoWalkDestination);
}

void LocalPlayer::setStates(int states)
{
    if(m_states != states) {
        int oldStates = m_states;
        m_states = states;

        callLuaField("onStatesChange", states, oldStates);
    }
}

void LocalPlayer::setSkill(int skillId, double newSkill)
{
    int oldSkill = m_skills[skillId];
    
	if (oldSkill != newSkill) {
		m_skills[skillId] = newSkill;

		callLuaField("onSkillChange", skillId, newSkill, oldSkill);
    }
}

void LocalPlayer::setBaseSkill(Otc::Skill skill, int baseLevel)
{
}


void LocalPlayer::setMaxHealth(double maxHealth)
{
	m_maxHealth = maxHealth;
	callLuaField("onHealthChange", getHealth(), maxHealth);
}

void LocalPlayer::setHealth(double health)
{
    if(m_health != health) {
        double oldHealth = m_health;
        m_health = health;


		if (m_healthPercent >= 50)
			m_informationColor = Color(255.0 * ((50 - (m_healthPercent - 50)) / 50.0f), 0xff, 0x00);
		else
			m_informationColor = Color(0xff, 255.0 * m_healthPercent / 50.0f, 0x00);

        callLuaField("onHealthChange", health, getMaxHealth());

        // cannot walk while dying
        if(health == 0) {            
            lockWalk();
        }
    }
}

void LocalPlayer::setFreeCapacity(double freeCapacity)
{
    if(m_freeCapacity != freeCapacity) {
        double oldFreeCapacity = m_freeCapacity;
        m_freeCapacity = freeCapacity;

        callLuaField("onFreeCapacityChange", freeCapacity, oldFreeCapacity);
    }
}

void LocalPlayer::setTotalCapacity(double totalCapacity)
{
    if(m_totalCapacity != totalCapacity) {
        double oldTotalCapacity = m_totalCapacity;
        m_totalCapacity = totalCapacity;

        callLuaField("onTotalCapacityChange", totalCapacity, oldTotalCapacity);
    }
}

void LocalPlayer::setExperience(double experience)
{
    if(m_experience != experience) {
        double oldExperience = m_experience;
        m_experience = experience;

        callLuaField("onExperienceChange", experience, oldExperience);
    }
}

void LocalPlayer::setLevel(double level, double levelPercent)
{
    if(m_level != level || m_levelPercent != levelPercent) {
		double oldLevel = m_level;
        double oldLevelPercent = m_levelPercent;
        m_level = level;
        m_levelPercent = levelPercent;

        callLuaField("onLevelChange", level, levelPercent, oldLevel, oldLevelPercent);
    }

	setCachedName(getName() + " (" + std::to_string((int)getLevel()) + ")");
}


void LocalPlayer::setLevelPoints(double levelPoints)
{
	if (m_levelPoints != levelPoints)
	{
		m_levelPoints = levelPoints;

		callLuaField("onLevelPointsChange", levelPoints);
	}
}

void LocalPlayer::setMana(double mana)
{
	float manaPercentage = (mana / getSkillValue(skillsID::PLAYER_ATTR_INTELLIGENCE)) * 100.0;
	if (manaPercentage >= 50)
		m_manaInformationColor = Color(255.0 * ((50 - (manaPercentage - 50)) / 50.0f), 0, 0xff);
	else
		m_manaInformationColor = Color(0xff, 0x00, 255.0 * (manaPercentage / 50.0f));

    if(m_mana != mana) {
        double oldMana = m_mana;
        m_mana = mana;

        callLuaField("onManaChange", mana, oldMana);
    }
}

void LocalPlayer::setMaxMana(double maxMana)
{

	m_maxMana = maxMana;

	callLuaField("onManaChange", getMana(), maxMana);

	float manaPercentage = (getMana() / getMaxMana()) * 100.0;
	if (manaPercentage >= 50)
		m_manaInformationColor = Color(255.0 * ((50 - (manaPercentage - 50)) / 50.0f), 0, 0xff);
	else
		m_manaInformationColor = Color(0xff, 0x00, 255.0 * (manaPercentage / 50.0f));

}

void LocalPlayer::setMagicLevel(double magicLevel, double magicLevelPercent)
{
    if(m_magicLevel != magicLevel || m_magicLevelPercent != magicLevelPercent) {
        double oldMagicLevel = m_magicLevel;
        double oldMagicLevelPercent = m_magicLevelPercent;
        m_magicLevel = magicLevel;
        m_magicLevelPercent = magicLevelPercent;

        callLuaField("onMagicLevelChange", magicLevel, magicLevelPercent, oldMagicLevel, oldMagicLevelPercent);
    }
}

void LocalPlayer::setBaseMagicLevel(double baseMagicLevel)
{
    if(m_baseMagicLevel != baseMagicLevel) {
        double oldBaseMagicLevel = m_baseMagicLevel;
        m_baseMagicLevel = baseMagicLevel;

        callLuaField("onBaseMagicLevelChange", baseMagicLevel, oldBaseMagicLevel);
    }
}

void LocalPlayer::setSoul(double soul)
{
    if(m_soul != soul) {
        double oldSoul = m_soul;
        m_soul = soul;

        callLuaField("onSoulChange", soul, oldSoul);
    }
}

void LocalPlayer::setStamina(double stamina)
{
    if(m_stamina != stamina) {
        double oldStamina = m_stamina;
        m_stamina = stamina;

        callLuaField("onStaminaChange", stamina, oldStamina);
    }
}

void LocalPlayer::setInventoryItem(Otc::InventorySlot inventory, const ItemPtr& item)
{
    if(inventory >= Otc::LastInventorySlot) {
        g_logger.traceError("invalid slot");
        return;
    }

    if(m_inventoryItems[inventory] != item) {
        ItemPtr oldItem = m_inventoryItems[inventory];
        m_inventoryItems[inventory] = item;

        callLuaField("onInventoryChange", inventory, item, oldItem);
    }
}

void LocalPlayer::setVocation(int vocation)
{
    if(m_vocation != vocation) {
        int oldVocation = m_vocation;
        m_vocation = vocation;

        callLuaField("onVocationChange", vocation, oldVocation);
    }
}

void LocalPlayer::setPremium(bool premium)
{
    if(m_premium != premium) {
        m_premium = premium;

        callLuaField("onPremiumChange", premium);
    }
}

void LocalPlayer::setRegenerationTime(double regenerationTime)
{
    if(m_regenerationTime != regenerationTime) {
        double oldRegenerationTime = m_regenerationTime;
        m_regenerationTime = regenerationTime;

        callLuaField("onRegenerationChange", regenerationTime, oldRegenerationTime);
    }
}

void LocalPlayer::setOfflineTrainingTime(double offlineTrainingTime)
{
    if(m_offlineTrainingTime != offlineTrainingTime) {
        double oldOfflineTrainingTime = m_offlineTrainingTime;
        m_offlineTrainingTime = offlineTrainingTime;

        callLuaField("onOfflineTrainingChange", offlineTrainingTime, oldOfflineTrainingTime);
    }
}

void LocalPlayer::setSpells(std::list<std::tuple<unsigned char, unsigned char>>& spells)
{
    if(m_spells != spells) {
		std::list<std::tuple<unsigned char, unsigned char>> oldSpells = m_spells;
        m_spells = spells;

        callLuaField("onSpellsChange", spells, oldSpells);
    }
}


void LocalPlayer::setSpell(std::tuple<unsigned char, unsigned char> &spell)
{
	std::tuple<unsigned char, unsigned char> * ptr_spell = nullptr;
	for (auto it = m_spells.begin(); it != m_spells.end(); it++)
	{
		if (std::get<0>(*it) == std::get<0>(spell))
			ptr_spell = &(*it);
	}
	if (ptr_spell == nullptr)
		m_spells.push_back(spell);
	else
		std::get<1>(*ptr_spell) = std::get<1>(spell);

	callLuaField("onSpellChange", std::get<0>(spell), std::get<1>(spell));

}


void LocalPlayer::setBreath(uint8 breath)
{
	if (m_breath != breath)
		m_breath = breath;
	callLuaField("onBreathChange", breath);

}

void LocalPlayer::setBlessings(int blessings)
{
    if(blessings != m_blessings) {
        int oldBlessings = m_blessings;
        m_blessings = blessings;

        callLuaField("onBlessingsChange", blessings, oldBlessings);
    }
}


void LocalPlayer::setLocalBalance(uint32_t local_balance)
{
	if (local_balance != m_local_balance) 
	{
		int old_local_balance = m_local_balance;
		m_local_balance = local_balance;

		callLuaField("onUpdateLocalBalance", local_balance, old_local_balance);
	}
}

void LocalPlayer::setGlobalBalance(uint32_t global_balance)
{
	if (global_balance != m_global_balance)
	{
		int old_global_balance = m_global_balance;
		m_global_balance = global_balance;

		callLuaField("onUpdateGlobalBalance", global_balance, old_global_balance);
	}
}

// --
void LocalPlayer::openNpcWindow(uint32 windowId)
{
	callLuaField("onOpenNpcWindow", windowId);
}

bool LocalPlayer::hasSight(const Position& pos)
{
    return m_position.isInRange(pos, g_map.getAwareRange().left - 1, g_map.getAwareRange().top - 1);
}


/* 
	return -1 on fail;
	return spell level on success;
*/
uint8 LocalPlayer::getSpellLevel(unsigned char spellId)
{
	for (auto i = m_spells.begin(); i != m_spells.end(); i++)
		if (std::get<0>(*i) == spellId)
			return std::get<1>(*i);
	return -1;
}