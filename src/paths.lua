paths = {}

function paths.getImage(filename)
    return love.graphics.newImage("resources/images/" .. filename .. ".png")
end

function paths.getSound(filename)
    return love.audio.newSource("resources/sounds/" .. filename .. ".ogg", "static")
end

function paths.getChartData(filename)
    data = love.filesystem.read("resources/data/" .. filename .. ".json")
    return json.decode(data)
end

return paths