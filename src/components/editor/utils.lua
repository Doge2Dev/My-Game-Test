utils = {}

function utils.generateChartChess(offset)
    x = offset
    currentPatternID = 1
    chessPattern = {
        {0.6, 0.6, 0.6, 1},
        {0.3, 0.3, 0.3, 1}
    }
    for p = 1, 24, 1 do
        love.graphics.push()
            love.graphics.setColor(chessPattern[currentPatternID])
            love.graphics.rectangle("fill", x, love.graphics.getHeight() / 2, 64, 64)
            currentPatternID = currentPatternID + 1
            if currentPatternID > 2 then
                currentPatternID = 1
            end
            x = x - 64
        love.graphics.pop()
    end
    love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 64)
    love.graphics.pop()
end


return utils