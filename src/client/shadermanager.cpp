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

#include "shadermanager.h"
#include <framework/graphics/paintershaderprogram.h>
#include <framework/graphics/graphics.h>
#include <framework/graphics/ogl/painterogl2_shadersources.h>
#include <framework/core/resourcemanager.h>

ShaderManager g_shaders;

void ShaderManager::init()
{
    if(!g_graphics.canUseShaders())
        return;

    //m_defaultItemShader = createFragmentShaderFromCode("Item", glslMainFragmentShader + glslTextureSrcFragmentShader);
    //setupItemShader(m_defaultItemShader);

    m_defaultMapShader = createShader("DefaultMap", "shaders/default.vert","shaders/default.frag");

    PainterShaderProgram::release();
}

void ShaderManager::terminate()
{
    m_defaultItemShader = nullptr;
    m_defaultMapShader = nullptr;
    m_shaders.clear();
}

PainterShaderProgramPtr ShaderManager::createShader(const std::string& name, std::string vertFile, std::string fragFile)
{
    if(!g_graphics.canUseShaders()) {
        g_logger.error(stdext::format("unable to create shader '%s', shaders are not supported", name));
        return nullptr;
    }

    PainterShaderProgramPtr shader(new PainterShaderProgram);
	m_shaders[name] = shader;
	if (!shader)
		return nullptr;

	vertFile = g_resources.guessFilePath(vertFile, "vert");

	if (!shader->addShaderFromSourceFile(Shader::Vertex, vertFile))
	{
		g_logger.error(stdext::format("unable to load vertex shader '%s' from source file '%s'", name, vertFile));
		return nullptr;
	}
	
	fragFile = g_resources.guessFilePath(fragFile, "frag");

	if (!shader->addShaderFromSourceFile(Shader::Fragment, fragFile)) {
		g_logger.error(stdext::format("unable to load fragment shader '%s' from source file '%s'", name, fragFile));
		return nullptr;
	}

	if (!shader->link()) {
		g_logger.error(stdext::format("unable to link shader '%s' from file '%s'", name, vertFile + fragFile));
		return nullptr;
	}

	m_shaders[name] = shader;

	return shader;
}

//paintershaderprogramptr shadermanager::createfragmentshaderfromcode(const std::string& name, const std::string& code)
//{
//    paintershaderprogramptr shader = createshader(name);
//    if(!shader)
//        return nullptr;
//
//    shader->addshaderfromsourcecode(shader::vertex, glslmainwithtexcoordsvertexshader + glslpositiononlyvertexshader);
//    if(!shader->addshaderfromsourcecode(shader::fragment, code)) {
//        g_logger.error(stdext::format("unable to load fragment shader '%s'", name));
//        return nullptr;
//    }
//
//    if(!shader->link()) {
//        g_logger.error(stdext::format("unable to link shader '%s'", name));
//        return nullptr;
//    }
//
//    m_shaders[name] = shader;
//    return shader;
//}
//
//PainterShaderProgramPtr ShaderManager::createItemShader(const std::string& name, const std::string& file)
//{
//    PainterShaderProgramPtr shader = createFragmentShader(name, file);
//    if(shader)
//        setupItemShader(shader);
//    return shader;
//}
//
//PainterShaderProgramPtr ShaderManager::createMapShader(const std::string& name, const std::string& file)
//{
//    PainterShaderProgramPtr shader = createFragmentShader(name, file);
//    if(shader)
//        setupMapShader(shader);
//    return shader;
//}
//
//void ShaderManager::setupItemShader(const PainterShaderProgramPtr& shader)
//{
//    if(!shader)
//        return;
//    shader->bindUniformLocation(ITEM_ID_UNIFORM, "u_ItemId");
//}

void ShaderManager::setupMapShader(const PainterShaderProgramPtr& shader)
{
    if(!shader)
        return;
    shader->bindUniformLocation(MAP_CENTER_COORD, "u_MapCenterCoord");
    shader->bindUniformLocation(MAP_GLOBAL_COORD, "u_MapGlobalCoord");
    shader->bindUniformLocation(MAP_ZOOM, "u_MapZoom");
}

PainterShaderProgramPtr ShaderManager::getShader(const std::string& name)
{
    auto it = m_shaders.find(name);
    if(it != m_shaders.end())
        return it->second;
    return nullptr;
}


