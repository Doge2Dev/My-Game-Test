editor = {}

function editor:init()
    love.filesystem.createDirectory("charts")

    utils = require 'src.components.editor.utils'
    conductor = require 'src.components.conductor'
    Camera = require 'libraries.camera'
    camera = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    --camera:zoom(0.6)

    marker = 0
    curNote = 1
    gridZoom = 6
    sectionOffset = 1
    showGrid = true
    bgSectionOffset = love.graphics.getWidth()
    isPlaying = false
    Song = {
        name = "dubnix",
        bpm = 85,
        noteSpeed = 1.1,
        notes = {}
    }

    NoteSrc = paths.getImage("block")
    bg = paths.getImage("bgs/game_bg4")

    noteGroup = gui:collapsegroup('Notes', {0, 70, 128, gui.style.unit})
    noteGroup.drag = false
    for i = 1, 4 do
		option = gui:option('note '.. i, {0, gui.style.unit * i, 128, gui.style.unit}, noteGroup, i)
		function option.click(this)
            curNote = i
        end
	end

    inp_songname = gui:input('Song Name', {256, 16, 128, 24})
    inp_songname.keyrepeat = true
    inp_songname.done = function(this)
		this.Gspot:unfocus()
	end

    inp_bpm = gui:input('Song BPM', {256, 42, 64, 24})
    inp_bpm.keyrepeat = true
    inp_bpm.done = function(this)
		this.Gspot:unfocus()
	end

    inp_notespeed = gui:input('Note speed', {256, 68, 64, 24})
    inp_notespeed.keyrepeat = true
    inp_notespeed.done = function(this)
		this.Gspot:unfocus()
	end

    inp_songname.value = tostring(Song.name)
    inp_bpm.value = tostring(Song.bpm)
    inp_notespeed.value = tostring(Song.noteSpeed)

    btn_save = gui:button("save", {389, 16, 96, 24})
    btn_apply = gui:button("apply", {389, 42, 96, 24})
    btn_load = gui:button("load", {490, 16, 96, 24})

    btn_showGrid = gui:button("Show grid [" .. tostring(showGrid) .. "]", {490, 68, 96, 24})

    btn_plus = gui:button(" + ", {156, 8, 24, 24})
    btn_minus = gui:button(" - ", {128, 8, 24, 24})

    function btn_showGrid.click(this)
        if showGrid then
            showGrid = false
            btn_showGrid.label = "Show grid [" .. tostring(showGrid) .. "]"
        else
            showGrid = true
            btn_showGrid.label = "Show grid [" .. tostring(showGrid) .. "]"
        end
    end

    function btn_apply.click(this)
        Song.bpm = tonumber(inp_bpm.value)
        Song.noteSpeed = tonumber(inp_notespeed.value)

        inp_bpm.value = tostring(Song.bpm)
        inp_notespeed.value = tostring(Song.noteSpeed)
    end

    function btn_save.click(this)
        Song.name = inp_songname.value
        Song.bpm = tonumber(inp_bpm.value)
        Song.noteSpeed = tonumber(inp_notespeed.value)

        chartFile = love.filesystem.newFile("charts/" .. inp_songname.value .. ".json", "w")
        chartFile:write(json.beautify(Song))
        chartFile:close()
    end
    

    function btn_load.click(this)
        --Song.notes = {}
        --Song = paths.getChartData(tostring(inp_songname.value))
        --inp_songname.value = tostring(Song.name)
        --inp_bpm.value = tostring(Song.bpm)
        --inp_notespeed.value = tostring(Song.noteSpeed)

        music = paths.getSound(tostring(inp_songname.value))
        conductor.load("resources/sounds/" .. tostring(inp_songname.value))
        conductor.bpm = Song.bpm
    end

    function btn_plus.click(this)
        gridZoom = gridZoom + 1
    end
    function btn_minus.click(this)
        gridZoom = gridZoom - 1
    end

end

function editor:draw()
    camera:attach()
        love.graphics.push()
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.scale(0.68, 0.68)
            love.graphics.draw(bg, 0, 0)
        love.graphics.pop()

        utils.generateChartChess(bgSectionOffset)

        if love.mouse.getY() > 360 and love.mouse.getY() < 424 then
            love.graphics.push()
                love.graphics.setColor(1, 0, 0, 1)
                love.graphics.rectangle("line", marker, love.graphics.getHeight() / 2, 64, 64)
            love.graphics.pop()
        end

        renderNote()

        gui:draw()

        if showGrid then
            for s = 1, 1280, (2 ^ gridZoom) do
                love.graphics.push()
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.setLineWidth(1)
                    love.graphics.rectangle("line", s, love.graphics.getHeight() / 2, (2 ^ gridZoom), 64)
                love.graphics.pop()
            end
        end

        love.graphics.push()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("Current note : " .. curNote, 0, 0)
            love.graphics.print("Current offset : " .. sectionOffset, 0, 10)
            love.graphics.print("Note count : " .. #Song.notes, 0, 20)
            love.graphics.print("Grid zoom : " .. gridZoom, 0, 30)
        love.graphics.pop()
    camera:detach()
end

function editor:update(elapsed)
    marker = math.floor(love.mouse.getX() / 2 ^ gridZoom) * 2 ^ gridZoom

    conductor.update()

    if isPlaying then
        sectionOffset = (Song.noteSpeed * 0.1) + (sectionOffset + (conductor.dspSongTime * 1000) * 0.5)
        bgSectionOffset = sectionOffset

        if bgSectionOffset < -128 then
            bgSectionOffset = 0
        end
    end

    gui:update(elapsed)

    if curNote < 1 then
        curNote = 1
    end
    
    if gridZoom < 1 then
        gridZoom = 1
    end

    if gridZoom > 6 then
        gridZoom = 6
    end

    if sectionOffset < 1 then
        sectionOffset = 1
    end

    if curNote > 4 then
        curNote = 4
    end
end

function editor:keypressed(k, code)
    if gui.focus then
		gui:keypress(k)
    end

    if k == "return" then
        if isPlaying then
            isPlaying = false
        else
            isPlaying = true
        end

        if isPlaying then
            isSongPlaying = conductor.play()
            if not isSongPlaying then
                isPlaying = false
            end
        else
            sectionOffset = 1
            bgSectionOffset = 0
            conductor.pause()
        end
    end

    if k == "r" then
        sectionOffset = 1
    end
end

function editor:textinput(k)
    if gui.focus then
		gui:textinput(k)
	end
end


function editor:mousepressed(x, y, btn)
    gui:mousepress(x, y, btn)

    if btn == 1 then
        if love.mouse.getY() > 360 and love.mouse.getY() < 424 then
            if not isHover(marker + (sectionOffset * (2 ^ gridZoom)), love.graphics.getHeight() / 2) then
                print("added")
                addNote(curNote, marker + (sectionOffset * 64), love.graphics.getHeight() / 2)
            end
        end
    end
    if btn == 2 then
        if love.mouse.getY() > 360 and love.mouse.getY() < 424 then
            if isHover(marker + (sectionOffset * 64), love.graphics.getHeight() / 2) then
                print("removed")
                removeNote(marker + (sectionOffset * 64), love.graphics.getHeight() / 2)
            end
        end
    end
end

function editor:mousereleased(x, y, btn)
    gui:mouserelease(x, y, button)
end

function editor:wheelmoved(x, y)
    gui:mousewheel(x, y)

    if y > 0 then
        sectionOffset = sectionOffset + 1
    elseif y < 0 then
        sectionOffset = sectionOffset - 1
    end
end

------------------------------------------

function isHover(x, y)
    for k, Note in pairs(Song.notes) do
        if Note.x == x then
            if Note.y == y then
                return true
            else
                return false
            end
        end
    end
end

function renderNote()
    for k, Note in pairs(Song.notes) do
        if Note.type == 1 then
            love.graphics.push()
                love.graphics.setColor(love.math.colorFromBytes(242, 187, 17, 255))
                love.graphics.draw(NoteSrc, Note.x - (sectionOffset * 64), Note.y)
            love.graphics.pop()
        end
        if Note.type == 2 then
            love.graphics.push()
                love.graphics.setColor(love.math.colorFromBytes(17, 174, 242, 255))
                love.graphics.draw(NoteSrc, Note.x - (sectionOffset * 64), Note.y)
            love.graphics.pop()            
        end
        if Note.type == 3 then
            love.graphics.push()
                love.graphics.setColor(love.math.colorFromBytes(242, 17, 17, 255))
                love.graphics.draw(NoteSrc, Note.x - (sectionOffset * 64), Note.y)
            love.graphics.pop()            
        end
        if Note.type == 4 then
            love.graphics.push()
                love.graphics.setColor(love.math.colorFromBytes(239, 17, 242, 255))
                love.graphics.draw(NoteSrc, Note.x - (sectionOffset * 64), Note.y)
            love.graphics.pop()            
        end
    end
end

function addNote(type, x, y)
    Note = {
        type = type,
        x = x,
        y = y
    } 

    table.insert(Song.notes, Note)
end

function removeNote(x, y)
    for k, Note in pairs(Song.notes) do
        if Note.x == x then
            if Note.y == y then
                table.remove(Song.notes, k)
            end
        end
    end
end

return editor