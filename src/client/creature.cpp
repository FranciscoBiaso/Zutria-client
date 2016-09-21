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

#include "creature.h"
#include "thingtypemanager.h"
#include "localplayer.h"
#include "map.h"
#include "tile.h"
#include "item.h"
#include "game.h"
#include "effect.h"
#include "luavaluecasts.h"
#include "lightview.h"

#include <framework/graphics/graphics.h>
#include <framework/core/eventdispatcher.h>
#include <framework/core/clock.h>

#include <framework/graphics/paintershaderprogram.h>
#include <framework/graphics/ogl/painterogl2_shadersources.h>
#include <framework/graphics/texturemanager.h>
#include <framework/graphics/framebuffermanager.h>
#include "spritemanager.h"

Creature::Creature() : Thing()
{
    m_id = 0;
    m_healthPercent = 100;
    m_speed = 200;
    m_direction = Otc::South;
    m_walkAnimationPhase = 0;
    m_walkedPixels = 0;
    m_walkTurnDirection = Otc::InvalidDirection;
    m_skull = Otc::SkullNone;
    m_shield = Otc::ShieldNone;
    m_emblem = Otc::EmblemNone;
    m_icon = Otc::NpcIconNone;
    m_lastStepDirection = Otc::InvalidDirection;
    m_nameCache.setFont(g_fonts.getFont("verdana-11px-rounded"));
    m_nameCache.setAlign(Fw::AlignTopCenter);
    m_footStep = 0;
    m_speedFormula.fill(-1);
    m_outfitColor = Color::white;

	m_attackAnimationPhase = 0;
	m_breathAnimationPhase = 0;
	m_walkAnimationPhase = 0;
	m_walkAttackAnimationPhase = 0;

	//start finite state machine
	//breathing
	onBreath();
	callLuaField("onCreate");
}

void Creature::draw(const Point& dest, float scaleFactor, bool animate, LightView *lightView)
{
    if(!canBeSeen())
        return;

    Point animationOffset = animate ? m_walkOffset : Point(0,0);

    if(m_showTimedSquare && animate)
	{
		int animationPhase = (g_clock.millis() % 1000) / 55.55;

        g_painter->setColor(m_timedSquareColor);
        //g_painter->drawBoundingRect(Rect(dest + (animationOffset - getDisplacement() + 2)*scaleFactor, Size(28, 28)*scaleFactor), std::max<int>((int)(2*scaleFactor), 1));
		g_painter->drawTexturedRect(Rect(dest + (animationOffset + 2) * scaleFactor, Size(28,28)*scaleFactor), m_squareTexture, Rect(animationPhase * 32,0,32,32));
				
        g_painter->setColor(Color::white);
    }

    if(m_showStaticSquare && animate) 
	{
        g_painter->setColor(m_staticSquareColor);
		int animationPhase = (g_clock.millis() % 1000) / 55.55;
       // g_painter->drawBoundingRect(Rect(dest + (animationOffset - getDisplacement())*scaleFactor, Size(Otc::TILE_PIXELS, Otc::TILE_PIXELS)*scaleFactor), std::max<int>((int)(2*scaleFactor), 1));		
		g_painter->drawTexturedRect(Rect(dest + (animationOffset + 2)*scaleFactor, Size(28,28)*scaleFactor), m_squareTexture, Rect(animationPhase * 32, 0, 32, 32));
		g_painter->setColor(Color::white);
    }

	internalDrawOutfit(dest + animationOffset * scaleFactor, scaleFactor, animate, animate, m_direction);

    if(lightView) {
        Light light = rawGetThingType()->getLight();
        if(m_light.intensity != light.intensity || m_light.color != light.color)
            light = m_light;

        // local player always have a minimum light in complete darkness
        if(isLocalPlayer() && (g_map.getLight().intensity < 64)) {
            light.intensity = std::max<uint8>(light.intensity, 7);
            if(light.color == 0 || light.color > 215)
                light.color = 215;
        }

        if(light.intensity > 0)
            lightView->addLightSource(dest + (animationOffset + Point(16,16)) * scaleFactor, scaleFactor, light);
    }
}

void Creature::internalDrawOutfit(Point dest, float scaleFactor, bool animateWalk, bool animateIdle, Otc::Direction direction, LightView *lightView)
{
	// select the correct outfit
	Outfit tmpOutfit = m_outfit;
	int tmpAnimationPhase = m_walkAnimationPhase;

	if (isPlayer())
	{
		if (m_creatureState == CreatureState::attacking)
		{
			tmpOutfit = m_attackOutfit;
			tmpAnimationPhase = m_attackAnimationPhase;

		}
		else if (m_creatureState == CreatureState::walking)
		{
			tmpOutfit = m_outfit;
			tmpAnimationPhase = m_walkAnimationPhase;
		}
		else //(m_creatureState == CreatureState::breathing)
		{
			tmpOutfit = m_breathingOutfit;
			tmpAnimationPhase = m_breathAnimationPhase;
		}
	}
	
	// set the outfit color (masks), based on player choices
	g_painter->setColor(m_outfitColor);

	// is outfit a real creature  ?
	if (tmpOutfit.getCategory() == ThingCategoryCreature) {

		// xPattern => creature direction
		int xPattern;
		if (direction == Otc::NorthEast || direction == Otc::SouthEast)
			xPattern = Otc::East;
		else if (direction == Otc::NorthWest || direction == Otc::SouthWest)
			xPattern = Otc::West;
		else
			xPattern = direction;

		int zPattern = 0;
		
		PointF jumpOffset = m_jumpOffset * scaleFactor;
		dest -= Point(stdext::round(jumpOffset.x), stdext::round(jumpOffset.y));

		// yPattern => creature addon
		for (int yPattern = 0; yPattern < getNumPatternY(); yPattern++) {

			// continue if we dont have this addon
			if (yPattern > 0 && !(tmpOutfit.getAddons() & (1 << (yPattern - 1))))
				continue;

			auto datType = rawGetThingType();
			datType->draw(dest, scaleFactor, 0, xPattern, yPattern, zPattern, m_walkAnimationPhase, yPattern == 0 ? lightView : nullptr);
			

			if (getLayers() > 1) {
				Color oldColor = g_painter->getColor();
				Painter::CompositionMode oldComposition = g_painter->getCompositionMode();
				g_painter->setCompositionMode(Painter::CompositionMode_Multiply);
				g_painter->setColor(tmpOutfit.getHeadColor());
				datType->draw(dest, scaleFactor, SpriteMaskYellow, xPattern, yPattern, zPattern, m_walkAnimationPhase);
				g_painter->setColor(tmpOutfit.getBodyColor());
				datType->draw(dest, scaleFactor, SpriteMaskRed, xPattern, yPattern, zPattern, m_walkAnimationPhase);
				g_painter->setColor(tmpOutfit.getLegsColor());
				datType->draw(dest, scaleFactor, SpriteMaskGreen, xPattern, yPattern, zPattern, m_walkAnimationPhase);
				g_painter->setColor(tmpOutfit.getFeetColor());
				datType->draw(dest, scaleFactor, SpriteMaskBlue, xPattern, yPattern, zPattern, m_walkAnimationPhase);
				g_painter->setColor(oldColor);
				g_painter->setCompositionMode(oldComposition);
			}			
		}
	}
	else {
		ThingType *type = g_things.rawGetThingType(tmpOutfit.getAuxId(), tmpOutfit.getCategory());

		int animationPhase = 0;
		int animationPhases = type->getAnimationPhases();
		int animateTicks = Otc::ITEM_TICKS_PER_FRAME;

		// when creature is an effect we cant render the first and last animation phase,
		// instead we should loop in the phases between
		if (tmpOutfit.getCategory() == ThingCategoryEffect) {
			animationPhases = std::max<int>(1, animationPhases - 2);
			animateTicks = Otc::INVISIBLE_TICKS_PER_FRAME;
		}

		if (animationPhases > 1) {
			if (animateIdle)
				animationPhase = (g_clock.millis() % (animateTicks * animationPhases)) / animateTicks;
			else
				animationPhase = animationPhases - 1;
		}

		if (tmpOutfit.getCategory() == ThingCategoryEffect)
			animationPhase = std::min<int>(animationPhase + 1, animationPhases);

		type->draw(dest - (getDisplacement() * scaleFactor), scaleFactor, 0, 0, 0, 0, animationPhase, lightView);
	}

	g_painter->resetColor();
}

void Creature::drawOutfit(const Rect& destRect, bool resize)
{
	int exactSize;
	if (m_outfit.getCategory() == ThingCategoryCreature)
		exactSize = getExactSize();
	else
		exactSize = g_things.rawGetThingType(m_outfit.getAuxId(), m_outfit.getCategory())->getExactSize();

	int frameSize;
	if (!resize)
		frameSize = std::max<int>(exactSize * 0.75f, 2 * Otc::TILE_PIXELS * 0.75f);
	else if (!(frameSize = exactSize))
		return;

	if (g_graphics.canUseFBO()) {
		const FrameBufferPtr& outfitBuffer = g_framebuffers.getTemporaryFrameBuffer();
		outfitBuffer->resize(Size(frameSize, frameSize));
		outfitBuffer->bind();
		g_painter->setAlphaWriting(true);
		g_painter->clear(Color::alpha);
		internalDrawOutfit(Point(frameSize - Otc::TILE_PIXELS, frameSize - Otc::TILE_PIXELS) + getDisplacement(), 1, false, true, Otc::South);
		outfitBuffer->release();
		outfitBuffer->draw(destRect, Rect(0, 0, frameSize, frameSize));
	}
	else {
		float scaleFactor = destRect.width() / (float)frameSize;
		Point dest = destRect.bottomRight() - (Point(Otc::TILE_PIXELS, Otc::TILE_PIXELS) - getDisplacement()) * scaleFactor;
		internalDrawOutfit(dest, scaleFactor, false, true, Otc::South);
	}
}

void Creature::drawInformation(const Point& Point, bool useGray, const Rect& parentRect, int drawFlags)
{
    if(m_healthPercent < 1) // creature is dead
        return;

    Color fillColor = Color(96, 96, 96);

    if(!useGray)
        fillColor = m_informationColor;
	bool l_isPlayer = isPlayer();
	LocalPlayerPtr localPlayer = g_game.getLocalPlayer();
	Rect backgroundRect(Point.x - 30, Point.y - 24, 60, 11);
	backgroundRect.bind(parentRect);
	Size nameSize = m_nameCache.getTextSize();
	
	Rect textRect;
	textRect = Rect(Point.x - nameSize.width() / 2.0, Point.y - 12 - 1, nameSize);
    textRect.bind(parentRect);

    // distance them
    if(textRect.top() == parentRect.top())
        backgroundRect.moveTop(textRect.top() + 12);
    if(backgroundRect.bottom() == parentRect.bottom())
        textRect.moveTop(backgroundRect.top() - 32);	

    // health rect is based on background rect, so no worries
    Rect healthRect = backgroundRect.expanded(-3);
	Rect healthRectBg = backgroundRect.expanded(-3);
	if (l_isPlayer)
		healthRect.setWidth((m_healthPercent / 100.0) * 28);
	else
		healthRect.setWidth((m_healthPercent / 100.0) * 25);

    // draw
	if (isNpc())
		fillColor = Color(0x99, 0xcc, 0xff);
	else if (isMonster())
		fillColor = Color(0xc0, 0xc0, 0xc0);
	else
		fillColor = Color(0x80,0xFF,0x00);

    if(drawFlags & Otc::DrawBars && (!isNpc() || !g_game.getFeature(Otc::GameHideNpcNames))) {
		g_painter->setColor(Color(0x80, 0x80, 0x80, 0x80));
		g_painter->drawFilledRect(healthRectBg);
		
		g_painter->setColor(Color(0xff, 0x00, 0x00, 0xff));
		g_painter->drawFilledRect(healthRect);		

		g_painter->setColor(Color::white);
		g_painter->drawTexturedRect(backgroundRect, m_healthBarTexture);
    }

    if(drawFlags & Otc::DrawNames) {
		g_painter->setColor(fillColor);
        m_nameCache.draw(textRect);
    }

    if(m_skull != Otc::SkullNone && m_skullTexture) {
        g_painter->setColor(Color::white);
        Rect skullRect = Rect(backgroundRect.x() + backgroundRect.width() + 1, Point.y - 1, m_skullTexture->getSize());
        g_painter->drawTexturedRect(skullRect, m_skullTexture);
    }
    if(m_shield != Otc::ShieldNone && m_shieldTexture && m_showShieldTexture) {
        g_painter->setColor(Color::white);
        Rect shieldRect = Rect(backgroundRect.x() + 13.5, backgroundRect.y() + 7, m_shieldTexture->getSize());
        g_painter->drawTexturedRect(shieldRect, m_shieldTexture);
    }
    if(m_emblem != Otc::EmblemNone && m_emblemTexture) {
        g_painter->setColor(Color::white);
        Rect emblemRect = Rect(backgroundRect.x() + 13.5 + 12, backgroundRect.y() + 16, m_emblemTexture->getSize());
        g_painter->drawTexturedRect(emblemRect, m_emblemTexture);
    }
    if(m_icon != Otc::NpcIconNone && m_iconTexture) {
        g_painter->setColor(Color::white);
        Rect iconRect = Rect(backgroundRect.x() + 13.5 + 12, backgroundRect.y() + 5, m_iconTexture->getSize());
        g_painter->drawTexturedRect(iconRect, m_iconTexture);
    }
}

void Creature::turn(Otc::Direction direction)
{
    // if is not walking change the direction right away
	if (~(m_creatureState & CreatureState::walking))
        setDirection(direction);
    // schedules to set the new direction when walk ends
    else
        m_walkTurnDirection = direction;
}

void Creature::onWalk()
{	
	if (m_walkUpdateEvent) {
		m_walkUpdateEvent->cancel();
		m_walkUpdateEvent = nullptr;
	}

	m_walkAnimationPhase = m_walkAnimationPhase % 2 + 1;

    // get walk direction
	m_lastStepDirection = m_oldPosition.getDirectionFromPosition(m_position);
	m_lastStepFromPosition = m_oldPosition;
	m_lastStepToPosition = m_position;

    // set current walking direction
    setDirection(m_lastStepDirection);

    // starts counting walk    
    m_walkTimer.restart();
    m_walkedPixels = 0;
	m_walkOffset = Point(0, 0);

    // no direction need to be changed when the walk ends
    m_walkTurnDirection = Otc::InvalidDirection;
	
	// now we are prepared to render
	// before enter on cycling state, turn on the state
	setFSM(CreatureState::walking); 
	updateWalk();
}

void Creature::updateWalk()
{
	float walkTicks = getStepDuration();
	float walkTicksPerPixel = walkTicks / 32;
	m_walkedPixels = std::min<int>(m_walkTimer.ticksElapsed() / walkTicksPerPixel, 32.0f);

	// needed for paralyze effect
	//m_walkedPixels = std::max<int>(m_walkedPixels, totalPixelsWalked);


	// update walk animation and offsets
	//updateWalkAnimation(totalPixelsWalked);
	if(m_walkTimer.ticksElapsed() % 200  <= 15) // near 0 ~
		m_walkAnimationPhase = m_walkAnimationPhase % 2 + 1;
	
	updateWalkOffset(m_walkedPixels);
	updateWalkingTile();

	// check finite state machine(fsm)
	// walking value will be changed outside fsm
	if ((m_walkTimer.ticksElapsed() >= walkTicks) || (m_walkedPixels >= 32))// || m_attacking)
	{
		terminateWalk();
		onBreath();
	}
	else//while walk occur, keep cycling
	{
		// schedules next update
		auto self = static_self_cast<Creature>();
		m_walkUpdateEvent = g_dispatcher.scheduleEvent([self] {
			self->m_walkUpdateEvent = nullptr;
			self->updateWalk();
		}, getStepDuration() / 32);
	}
}

void Creature::terminateWalk()
{
	// remove any scheduled walk update
	if (m_walkUpdateEvent) {
		m_walkUpdateEvent->cancel();
		m_walkUpdateEvent = nullptr;
	}

	// now the walk has ended, do any scheduled turn
	if (m_walkTurnDirection != Otc::InvalidDirection) {
		setDirection(m_walkTurnDirection);
		m_walkTurnDirection = Otc::InvalidDirection;
	}

	if (m_walkingTile) {
		m_walkingTile->removeWalkingCreature(static_self_cast<Creature>());
		m_walkingTile = nullptr;
	}

	// reset walk animation states	
	m_walkedPixels = 0;
	m_walkAnimationPhase = 0;
}

void Creature::stopWalk()
{
    if(~(m_creatureState & CreatureState::walking))
        return;

    // stops the walk right away
    terminateWalk();
}

void Creature::jump(int height, int duration)
{
    if(!m_jumpOffset.isNull())
        return;

    m_jumpTimer.restart();
    m_jumpHeight = height;
    m_jumpDuration = duration;

    updateJump();
}

void Creature::updateJump()
{
    int t = m_jumpTimer.ticksElapsed();
    double a = -4 * m_jumpHeight / (m_jumpDuration * m_jumpDuration);
    double b = +4 * m_jumpHeight / (m_jumpDuration);

    double height = a*t*t + b*t;
    int roundHeight = stdext::round(height);
    int halfJumpDuration = m_jumpDuration / 2;

    // schedules next update
    if(m_jumpTimer.ticksElapsed() < m_jumpDuration) {
        m_jumpOffset = PointF(height, height);

        int diff = 0;
        if(m_jumpTimer.ticksElapsed() < halfJumpDuration)
            diff = 1;
        else if(m_jumpTimer.ticksElapsed() > halfJumpDuration)
            diff = -1;

        int nextT, i = 1;
        do {
            nextT = stdext::round((-b + std::sqrt(std::max<int>(b*b + 4*a*(roundHeight+diff*i), 0.0)) * diff) / (2*a));
            ++i;

            if(nextT < halfJumpDuration)
                diff = 1;
            else if(nextT > halfJumpDuration)
                diff = -1;
        } while(nextT - m_jumpTimer.ticksElapsed() == 0 && i < 3);

        auto self = static_self_cast<Creature>();
        g_dispatcher.scheduleEvent([self] {
            self->updateJump();
        }, nextT - m_jumpTimer.ticksElapsed());
    }
    else
        m_jumpOffset = PointF(0, 0);
}

void Creature::onPositionChange(const Position& newPos, const Position& oldPos)
{
	//m_oldPosition = m_position;
	//m_position = newPos;
    callLuaField("onPositionChange", newPos, oldPos);
}

void Creature::onAppear()
{
    // cancel any disappear event
    if(m_disappearEvent) {
        m_disappearEvent->cancel();
        m_disappearEvent = nullptr;
    }

    // creature appeared the first time or wasn't seen for a long time
    if(m_removed) {
        stopWalk();
        m_removed = false;
        callLuaField("onAppear");
    // walk
    } else if(m_oldPosition != m_position && m_oldPosition.isInRange(m_position,1,1) && m_allowAppearWalk) {
        m_allowAppearWalk = false;
        //onWalk(m_oldPosition, m_position);
		// if creature is not walking
		//setFSM(CreatureState::walking);
		onWalk();
        callLuaField("onWalk", m_oldPosition, m_position);
    // teleport
    } else if(m_oldPosition != m_position) {
        stopWalk();
        callLuaField("onDisappear");
        callLuaField("onAppear");
    } // else turn
}

void Creature::onDisappear()
{
    if(m_disappearEvent)
        m_disappearEvent->cancel();

    //m_oldPosition = m_position;

    // a pair onDisappear and onAppear events are fired even when creatures walks or turns,
    // so we must filter
    auto self = static_self_cast<Creature>();
    m_disappearEvent = g_dispatcher.addEvent([self] {
        self->m_removed = true;
        self->stopWalk();

        self->callLuaField("onDisappear");

        // invalidate this creature position
        if(!self->isLocalPlayer())
            self->setPosition(Position());
        //self->m_oldPosition = Position();
        self->m_disappearEvent = nullptr;
    });
}

void Creature::onDeath()
{
    callLuaField("onDeath");
}


void Creature::onWalkAndAttack()
{
	auto self = static_self_cast<Creature>();
	m_walkAttackUpdateEvent = g_dispatcher.scheduleEvent([self] {
		self->m_walkAttackUpdateEvent = nullptr;
		self->updateWalkAndAttack();
	}, 50);
}


bool Creature::isAttacking(void)
{
	return getCreatureState() == CreatureState::attacking;
}

void Creature::updateWalkOffset(int totalPixelsWalked)
{
    m_walkOffset = Point(0,0);
    if(m_direction == Otc::North || m_direction == Otc::NorthEast || m_direction == Otc::NorthWest)
        m_walkOffset.y = 32 - totalPixelsWalked;
    else if(m_direction == Otc::South || m_direction == Otc::SouthEast || m_direction == Otc::SouthWest)
        m_walkOffset.y = totalPixelsWalked - 32;

    if(m_direction == Otc::East || m_direction == Otc::NorthEast || m_direction == Otc::SouthEast)
        m_walkOffset.x = totalPixelsWalked - 32;
    else if(m_direction == Otc::West || m_direction == Otc::NorthWest || m_direction == Otc::SouthWest)
        m_walkOffset.x = 32 - totalPixelsWalked;
}

void Creature::updateWalkingTile()
{
    // determine new walking tile
    TilePtr newWalkingTile;
    Rect virtualCreatureRect(Otc::TILE_PIXELS + (m_walkOffset.x - getDisplacementX()),
                             Otc::TILE_PIXELS + (m_walkOffset.y - getDisplacementY()),
                             Otc::TILE_PIXELS, Otc::TILE_PIXELS);

    for(int xi = -1; xi <= 1 && !newWalkingTile; ++xi) {
        for(int yi = -1; yi <= 1 && !newWalkingTile; ++yi) {
            Rect virtualTileRect((xi+1)*Otc::TILE_PIXELS, (yi+1)*Otc::TILE_PIXELS, Otc::TILE_PIXELS, Otc::TILE_PIXELS);

            // only render creatures where bottom right is inside tile rect
            if(virtualTileRect.contains(virtualCreatureRect.bottomRight())) {
                newWalkingTile = g_map.getOrCreateTile(m_position.translated(xi, yi, 0));
            }
        }
    }

    if(newWalkingTile != m_walkingTile) {
        if(m_walkingTile)
            m_walkingTile->removeWalkingCreature(static_self_cast<Creature>());
        if(newWalkingTile) {
            newWalkingTile->addWalkingCreature(static_self_cast<Creature>());

            // recache visible tiles in map views
            if(newWalkingTile->isEmpty())
                g_map.notificateTileUpdate(newWalkingTile->getPosition());
        }
        m_walkingTile = newWalkingTile;
    }
}

void Creature::updateWalkAndAttack()
{

	float walkTicksPerPixel = getStepDuration(true) / 32;
	int totalPixelsWalked = std::min<int>(m_walkAndAttackTimer.ticksElapsed() / walkTicksPerPixel, 32.0f);

	// needed for paralyze effect
	m_walkedPixels = std::max<int>(m_walkedPixels, totalPixelsWalked);
	//updateWalkAttackAnimation(totalPixelsWalked);
	updateWalkOffset(m_walkedPixels);
	updateWalkingTile();

	// update attack animation	
	m_walkAttackAnimationPhase = (m_walkAttackAnimationPhase + 1) % 4;

	// terminate attack
	if (m_walkAndAttackTimer.ticksElapsed() > getStepDuration() &&
		m_walkAttackAnimationPhase == 3)
	{
		terminateWalkAndAttack();
	}
}

void Creature::terminateWalkAndAttack()
{
	// remove any scheduled attack update
	if (m_walkAttackUpdateEvent) {
		m_walkAttackUpdateEvent->cancel();
		m_walkAttackUpdateEvent = nullptr;
	}
	
	m_walkAttackAnimationPhase = 0;
	
	if(m_walkAndAttackTimer.ticksElapsed() > 800)
		onBreath();
	else
	{
		m_attackAnimationPhase = m_walkAttackAnimationPhase;
		onAttack();
	}
}

//occur wen breath start's
void Creature::onBreath()
{
	m_breathTimer.restart();
	m_breathAnimationPhase = 0;
	
	//set the state
	setFSM(CreatureState::breathing);
	// cycle loop  10x in sec
	updateBreath();
}

//loop while breathing
void Creature::updateBreath()
{
	// remove any previous scheduled attack updates
	if (m_breathUpdateEvent)
		m_breathUpdateEvent->cancel();

	// breathing animation use only 2 frames 600 miliseconds is a good choice
	// for this case
	if (m_breathTimer.ticksElapsed() >= 600)
	{
		m_breathTimer.restart();
		//loop {0,1,0,1,0,1,...}
		m_breathAnimationPhase = (m_breathAnimationPhase + 1) % 2;
	}

	// check finite state machine(fsm)
	// if any state was actived we finish idle animation (breathing)
	if (getCreatureState() != CreatureState::breathing)
	{
		terminateBreath();		
	}
	//while attack not occur keep cycling
	else
	{
		// schedules next update
		auto self = static_self_cast<Creature>();
		m_breathUpdateEvent = g_dispatcher.scheduleEvent([self] {
			self->m_breathUpdateEvent = nullptr;
			self->updateBreath();
		}, 50); // we check if cycling equal to 50 ms
	}
}

//occur wen breath end's
void Creature::terminateBreath()
{
	// remove any scheduled attack update
	if (m_breathUpdateEvent)
	{
		m_breathUpdateEvent->cancel();
		m_breathUpdateEvent = nullptr;
	}

	m_breathAnimationPhase = 0;
}


//occur wen attack start's
void Creature::onAttack()
{
	// cycle loop  10x in sec
	m_attackTimer.restart();
	m_attackAnimationPhase = 0;

	updateAttack();
}

//loop while attacking
void Creature::updateAttack()
{
	// remove any previous scheduled attack updates
	if (m_attackUpdateEvent)
		m_attackUpdateEvent->cancel();

	// attacking time
	if (m_attackTimer.ticksElapsed() >= 150)
	{
		m_attackTimer.restart();
		//loop {0,1,2,3,0,1,2,3,0,1,2,3,...}
		m_attackAnimationPhase = (m_attackAnimationPhase + 1) % 4;
	}

	// check finite state machine(fsm)
	if (m_attackAnimationPhase == 3)
	{
		terminateAttack();
		setFSM(CreatureState::breathing);
		onBreath();
	}
	else //while walk not occur keep cycling
	{
		auto self = static_self_cast<Creature>();
		m_attackUpdateEvent = g_dispatcher.scheduleEvent([self] {
			self->m_attackUpdateEvent = nullptr;
			self->updateAttack();
		}, 100);
	}	
}

void Creature::terminateAttack()
{
	// remove any scheduled attack update
	if (m_attackUpdateEvent) {
		m_attackUpdateEvent->cancel();
		m_attackUpdateEvent = nullptr;
	}

	m_attackAnimationPhase = 0;
}

void Creature::setName(const std::string& name)
{
    m_name = name;
}

void Creature::setCachedName(const std::string & name)
{
	m_nameCache.setText(name);
}

void Creature::setHealthPercent(uint8 healthPercent)
{
	//if (healthPercent >= 50)
		//m_informationColor = Color(255.0 * ((50-(healthPercent-50))/50.0f), 0xff, 0x00);
	//else
		//m_informationColor = Color(0xff, 255.0 * healthPercent / 50.0f, 0x00);
	m_informationColor = Color(0xA5, 0x2A, 0x2A);

    m_healthPercent = healthPercent;
    callLuaField("	", healthPercent);

    if(healthPercent <= 0)
        onDeath();
}

void Creature::setDirection(Otc::Direction direction)
{
    assert(direction != Otc::InvalidDirection);
    m_direction = direction;
}

void Creature::setOutfit(const Outfit& outfit)
{
    Outfit oldOutfit = m_outfit;
    if(outfit.getCategory() != ThingCategoryCreature) 
	{
        if(!g_things.isValidDatId(outfit.getAuxId(), outfit.getCategory()))
            return;
        m_outfit.setAuxId(outfit.getAuxId());
        m_outfit.setCategory(outfit.getCategory());
    }
	else 
	{
        if(outfit.getId() > 0 && !g_things.isValidDatId(outfit.getId(), ThingCategoryCreature))
            return;
        m_outfit = outfit;
    }
    m_walkAnimationPhase = 0; // might happen when player is walking and outfit is changed.

    callLuaField("onOutfitChange", m_outfit, oldOutfit);
}

void Creature::setAttackOutfit(const Outfit& attackOutfit)
{
	Outfit oldOutfit = m_attackOutfit;
	if (attackOutfit.getCategory() != ThingCategoryCreature)
	{
		if (!g_things.isValidDatId(attackOutfit.getAuxId(), attackOutfit.getCategory()))
			return;
		m_attackOutfit.setAuxId(attackOutfit.getAuxId());
		m_attackOutfit.setCategory(attackOutfit.getCategory());
	}
	else
	{
		if (attackOutfit.getId() > 0 && !g_things.isValidDatId(attackOutfit.getId(), ThingCategoryCreature))
			return;
		m_attackOutfit = attackOutfit;
	}

	//callLuaField("onOutfitChange", m_outfit, oldOutfit);
}

void Creature::setBreathOutfit(const Outfit& breathOutfit)
{
	Outfit oldOutfit = m_breathingOutfit;
	if (breathOutfit.getCategory() != ThingCategoryCreature)
	{
		if (!g_things.isValidDatId(breathOutfit.getAuxId(), breathOutfit.getCategory()))
			return;
		m_breathingOutfit.setAuxId(breathOutfit.getAuxId());
		m_breathingOutfit.setCategory(breathOutfit.getCategory());
	}
	else
	{
		if (breathOutfit.getId() > 0 && !g_things.isValidDatId(breathOutfit.getId(), ThingCategoryCreature))
			return;
		m_breathingOutfit = breathOutfit;
	}

	//callLuaField("onOutfitChange", m_outfit, oldOutfit);
}

void Creature::setWalkAttackOutfit(const Outfit& walkAttackOutfit)
{
	Outfit oldOutfit = m_walkAttackOutfit;
	if (walkAttackOutfit.getCategory() != ThingCategoryCreature)
	{
		if (!g_things.isValidDatId(walkAttackOutfit.getAuxId(), walkAttackOutfit.getCategory()))
			return;
		m_walkAttackOutfit.setAuxId(walkAttackOutfit.getAuxId());
		m_walkAttackOutfit.setCategory(walkAttackOutfit.getCategory());
	}
	else
	{
		if (walkAttackOutfit.getId() > 0 && !g_things.isValidDatId(walkAttackOutfit.getId(), ThingCategoryCreature))
			return;
		m_walkAttackOutfit = walkAttackOutfit;
	}

	//callLuaField("onOutfitChange", m_outfit, oldOutfit);
}

void Creature::setOutfitColor(const Color& color, int duration)
{
    if(m_outfitColorUpdateEvent) {
        m_outfitColorUpdateEvent->cancel();
        m_outfitColorUpdateEvent = nullptr;
    }

    if(duration > 0) {
        Color delta = (color - m_outfitColor) / (float)duration;
        m_outfitColorTimer.restart();
        updateOutfitColor(m_outfitColor, color, delta, duration);
    }
    else
        m_outfitColor = color;
}

void Creature::updateOutfitColor(Color color, Color finalColor, Color delta, int duration)
{
    if(m_outfitColorTimer.ticksElapsed() < duration) {
        m_outfitColor = color + delta * m_outfitColorTimer.ticksElapsed();

        auto self = static_self_cast<Creature>();
        m_outfitColorUpdateEvent = g_dispatcher.scheduleEvent([=] {
            self->updateOutfitColor(color, finalColor, delta, duration);
        }, 100);
    }
    else {
        m_outfitColor = finalColor;
    }
}

void Creature::setSpeed(uint16 speed)
{
    uint16 oldSpeed = m_speed;
    m_speed = speed;

    // speed can change while walking (utani hur, paralyze, etc..)
   // if(getCreatureState() == CreatureState::walking)
        
		//nextWalkUpdate();

    callLuaField("onSpeedChange", m_speed, oldSpeed);
}

void Creature::setBaseSpeed(double baseSpeed)
{
    if(m_baseSpeed != baseSpeed) {
        double oldBaseSpeed = m_baseSpeed;
        m_baseSpeed = baseSpeed;

        callLuaField("onBaseSpeedChange", baseSpeed, oldBaseSpeed);
    }
}

void Creature::setSkull(uint8 skull)
{
    m_skull = skull;
    callLuaField("onSkullChange", m_skull);
}

void Creature::setShield(uint8 shield)
{
    m_shield = shield;
    callLuaField("onShieldChange", m_shield);
}

void Creature::setEmblem(uint8 emblem)
{
    m_emblem = emblem;
    callLuaField("onEmblemChange", m_emblem);
}

void Creature::setIcon(uint8 icon)
{
    m_icon = icon;
    callLuaField("onIconChange", m_icon);
}


void Creature::setSquareTexture(const std::string& filename)
{
	m_squareTexture = g_textures.getTexture(filename);
}

void Creature::setSkullTexture(const std::string& filename)
{
    m_skullTexture = g_textures.getTexture(filename);
}

void Creature::setHealthBarTexture(const std::string & filename)
{
	m_healthBarTexture = g_textures.getTexture(filename);
}

void Creature::setShieldTexture(const std::string& filename, bool blink)
{
    m_shieldTexture = g_textures.getTexture(filename);
    m_showShieldTexture = true;

    if(blink && !m_shieldBlink) {
        auto self = static_self_cast<Creature>();
        g_dispatcher.scheduleEvent([self]() {
            self->updateShield();
        }, SHIELD_BLINK_TICKS);
    }

    m_shieldBlink = blink;
}

void Creature::setEmblemTexture(const std::string& filename)
{
    m_emblemTexture = g_textures.getTexture(filename);
}

void Creature::setIconTexture(const std::string& filename)
{
    m_iconTexture = g_textures.getTexture(filename);
}


void Creature::setSpeedFormula(double speedA, double speedB, double speedC)
{
    m_speedFormula[Otc::SpeedFormulaA] = speedA;
    m_speedFormula[Otc::SpeedFormulaB] = speedB;
    m_speedFormula[Otc::SpeedFormulaC] = speedC;
}

bool Creature::hasSpeedFormula()
{
    return m_speedFormula[Otc::SpeedFormulaA] != -1 && m_speedFormula[Otc::SpeedFormulaB] != -1
            && m_speedFormula[Otc::SpeedFormulaC] != -1;
}

void Creature::addTimedSquare(uint8 color)
{
    m_showTimedSquare = true;
    m_timedSquareColor = Color::from8bit(color);

    // schedule removal
    auto self = static_self_cast<Creature>();
    g_dispatcher.scheduleEvent([self]() {
        self->removeTimedSquare();
    }, VOLATILE_SQUARE_DURATION);
}

void Creature::updateShield()
{
    m_showShieldTexture = !m_showShieldTexture;

    if(m_shield != Otc::ShieldNone && m_shieldBlink) {
        auto self = static_self_cast<Creature>();
        g_dispatcher.scheduleEvent([self]() {
            self->updateShield();
        }, SHIELD_BLINK_TICKS);
    }
    else if(!m_shieldBlink)
        m_showShieldTexture = true;
}

Point Creature::getDrawOffset()
{
    Point drawOffset;
    if(m_creatureState & CreatureState::walking) {
        if(m_walkingTile)
            drawOffset -= Point(1,1) * m_walkingTile->getDrawElevation();
        drawOffset += m_walkOffset;
    } else {
        const TilePtr& tile = getTile();
        if(tile)
            drawOffset -= Point(1,1) * tile->getDrawElevation();
    }
    return drawOffset;
}

int Creature::getStepDuration(bool ignoreDiagonal, Otc::Direction dir)
{
    int speed = m_speed;
    if(speed < 1)
        return 0;

    int groundSpeed = 0;
    Position tilePos;

    if(dir == Otc::InvalidDirection)
        tilePos = m_lastStepToPosition;
    else
        tilePos = m_position.translatedToDirection(dir);

    if(!tilePos.isValid())
        tilePos = m_position;
    const TilePtr& tile = g_map.getTile(tilePos);
    
	if(tile) 
	{
        groundSpeed = tile->getGroundSpeed();
        if(groundSpeed == 0)
            groundSpeed = 150;
    }

    int interval = 1000;
    
	if(groundSpeed > 0 && speed > 0)
        interval = 1000 * groundSpeed;

    interval /= speed;

    //float factor = 2;

    interval = std::max<int>(interval, g_game.getServerBeat());

    //if(!ignoreDiagonal && (m_lastStepDirection == Otc::NorthWest || m_lastStepDirection == Otc::NorthEast ||
    //   m_lastStepDirection == Otc::SouthWest || m_lastStepDirection == Otc::SouthEast))
    //    interval *= factor;

    return interval;
}

Point Creature::getDisplacement()
{
    if(m_outfit.getCategory() == ThingCategoryEffect)
        return Point(8, 8);
    else if(m_outfit.getCategory() == ThingCategoryItem)
        return Point(0, 0);
    return Thing::getDisplacement();
}

int Creature::getDisplacementX()
{
    if(m_outfit.getCategory() == ThingCategoryEffect)
        return 8;
    else if(m_outfit.getCategory() == ThingCategoryItem)
        return 0;

    if(m_outfit.getMount() != 0) {
        auto datType = g_things.rawGetThingType(m_outfit.getMount(), ThingCategoryCreature);
        return datType->getDisplacementX();
    }

    return Thing::getDisplacementX();
}

int Creature::getDisplacementY()
{
    if(m_outfit.getCategory() == ThingCategoryEffect)
        return 8;
    else if(m_outfit.getCategory() == ThingCategoryItem)
        return 0;

    if(m_outfit.getMount() != 0) {
        auto datType = g_things.rawGetThingType(m_outfit.getMount(), ThingCategoryCreature);
        return datType->getDisplacementY();
    }

    return Thing::getDisplacementY();
}

int Creature::getExactSize(int layer, int xPattern, int yPattern, int zPattern, int animationPhase)
{
    int exactSize = 0;

    animationPhase = 0;
    xPattern = Otc::South;

    zPattern = 0;
    if(m_outfit.getMount() != 0)
        zPattern = 1;

    for(yPattern = 0; yPattern < getNumPatternY(); yPattern++) {
        if(yPattern > 0 && !(m_outfit.getAddons() & (1 << (yPattern-1))))
            continue;

        for(layer = 0; layer < getLayers(); ++layer)
            exactSize = std::max<int>(exactSize, Thing::getExactSize(layer, xPattern, yPattern, zPattern, animationPhase));
    }

    return exactSize;
}

const ThingTypePtr& Creature::getThingType()
{
    return g_things.getThingType(m_outfit.getId(), ThingCategoryCreature);
}

ThingType* Creature::rawGetThingType()
{
    return g_things.rawGetThingType(m_outfit.getId(), ThingCategoryCreature);
}
