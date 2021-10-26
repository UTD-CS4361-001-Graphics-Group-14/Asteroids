local lives = 3

function decrementLives()
    lives = lives - 1
    return lives
end

function setLives(val)
    lives = val
    return lives
end

function drawLives()
    width = love.graphics.getWidth()
    love.graphics.printf("Lives: ".. lives, width-350, 10, 300, "right")
end

return lives