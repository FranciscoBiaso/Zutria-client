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

#ifndef OUTFIT_H
#define OUTFIT_H

#include <framework/util/color.h>
#include "thingtypemanager.h"

static Color outfit_color[9][13] = 
{   //red                orange             yellow             green              green 2            green 3            blue               blue 2             blue 3             purple             pink               pink 2             gray
	{ Color(51,0,0),     Color(51,25,0),    Color(51,51,0),    Color(25,51,0),    Color(0,51,0),     Color(0,51,25),    Color(0,51,51),    Color(0,25,51),    Color(0,0,51),     Color(25,0,51),    Color(51,0,51),    Color(51,0,25),    Color(0,0,0) },
	{ Color(102,0,0),    Color(102,51,0),   Color(102,102,0),  Color(51,102,0),   Color(0,102,0),    Color(0,102,51),   Color(0,102,102),  Color(0,51,102),   Color(0,0,102),    Color(51,0,102),   Color(102,0,102),  Color(102,0,51),   Color(32,32,32) },
	{ Color(153,0,0),    Color(153,76,0),   Color(153,153,0),  Color(76,153,0),   Color(0,153,0),    Color(0,153,76),   Color(0,153,153),  Color(0,76,153),   Color(0,0,153),    Color(76,0,153),   Color(153,0,153),  Color(153,0,78),   Color(64,64,64) },
	{ Color(204,0,0),    Color(204,102,0),  Color(204,204,0),  Color(102,204,0),  Color(0,204,0),    Color(0,204,102),  Color(0,204,204),  Color(0,102,204),  Color(0,0,204),    Color(102,0,204),  Color(204,0,204),  Color(204,0,102),  Color(96,96,96) },
	{ Color(255,0,0),    Color(255,128,0),  Color(255,255,0),  Color(128,255,0),  Color(0,255,0),    Color(0,255,128),  Color(0,255,255),  Color(0,128,255),  Color(0,0,255),    Color(128,0,255),  Color(255,0,255),  Color(255,0,128),  Color(128,128,128) },
	{ Color(255,51,51),  Color(255,153,51), Color(255,255,51), Color(153,255,51), Color(51,255,51),  Color(51,255,153), Color(51,255,255), Color(51,153,255), Color(51,51,255),  Color(153,51,255), Color(255,51,255), Color(255,51,153), Color(160,160,160) },
	{ Color(255,102,102),Color(255,178,102),Color(255,255,102),Color(178,255,102),Color(102,255,102),Color(102,255,178),Color(102,255,255),Color(102,178,255),Color(102,102,255),Color(178,102,255),Color(255,102,255),Color(255,102,178),Color(192,192,192) },
	{ Color(255,153,153),Color(255,204,153),Color(255,255,153),Color(204,255,153),Color(153,255,153),Color(153,255,204),Color(153,255,255),Color(153,204,255),Color(153,153,255),Color(204,153,255),Color(255,153,255),Color(255,153,204),Color(224,224,224) },
	{ Color(255,204,204),Color(255,229,204),Color(255,255,204),Color(229,255,204),  Color(204,255,204),Color(204,255,229),Color(204,255,255),Color(204,229,255),Color(204,204,255),Color(228,204,255),Color(255,204,255),Color(255,204,228),Color(255,255,255) }
};

class Outfit
{
    enum {
        HSI_SI_VALUES = 8,
        HSI_H_STEPS = 25
    };

public:
    Outfit();

    static Color getColor(int color);

    void setId(int id) { m_id = id; }
    void setAuxId(int id) { m_auxId = id; }
    void setHead(int head) { m_head = head; m_headColor = getColor(head); }
    void setBody(int body) { m_body = body; m_bodyColor = getColor(body); }
    void setLegs(int legs) { m_legs = legs; m_legsColor = getColor(legs); }
    void setFeet(int feet) { m_feet = feet; m_feetColor = getColor(feet); }
    void setAddons(int addons) { m_addons = addons; }
    void setMount(int mount) { m_mount = mount; }
    void setCategory(ThingCategory category) { m_category = category; }

    void resetClothes();

    int getId() const { return m_id; }
    int getAuxId() const { return m_auxId; }
    int getHead() const { return m_head; }
    int getBody() const { return m_body; }
    int getLegs() const { return m_legs; }
    int getFeet() const { return m_feet; }
    int getAddons() const { return m_addons; }
    int getMount() const { return m_mount; }
    ThingCategory getCategory() const { return m_category; }

    Color getHeadColor() const { return m_headColor; }
    Color getBodyColor() const { return m_bodyColor; }
    Color getLegsColor() const { return m_legsColor; }
    Color getFeetColor() const { return m_feetColor; }

private:
    ThingCategory m_category;
    int m_id, m_auxId, m_head, m_body, m_legs, m_feet, m_addons, m_mount;
    Color m_headColor, m_bodyColor, m_legsColor, m_feetColor;
};

#endif
