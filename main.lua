function love.load()
    --=[ Modules ]=--
    gamestate = require 'libraries.gamestate'
    json = require 'libraries.json'
    gui = require 'libraries.gspot'
    tween = require 'libraries.tween'
    paths = require 'src.paths'
    require "libraries.json-beautify"

    --=[ states ]=--
    editor = require 'src.states.editor'
    -- setup --
    gamestate.registerEvents()
    gamestate.switch(editor)
end

function love.draw()
    
end

function love.update(dt)
    
end