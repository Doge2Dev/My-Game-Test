function love.load()
    --=[ Modules ]=--
    gamestate = require 'libraries.gamestate'
    json = require 'libraries.json'
    require "libraries.json-beautify"
    gui = require 'libraries.gspot'
    tween = require 'libraries.tween'
    paths = require 'src.paths'

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