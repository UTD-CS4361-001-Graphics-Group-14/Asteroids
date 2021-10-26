local score = 0

function incrementScore()
    score = score + 20
    return score
end

function getScore()
    return score
end

function setScore(val)
    score = val
    return score
end

function drawScore()
    love.graphics.printf("Score: ".. score, 20, 10, 300, "left")
end

return score