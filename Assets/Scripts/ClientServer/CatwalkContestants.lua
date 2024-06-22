--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

function self:ClientUpdate()
    local nextPlayer = countdownsGame.nextPlayerModelingArea.value
    local continueContest = gameManager.numberPlayersModeled.value < gameManager.numberPlayersCurrentContest.value
    
    if nextPlayer and continueContest then
        gameManager.goNextPlayerContest:FireServer()
        countdownsGame.eventResetNextPlayerVoting:FireServer()
        countdownsGame.nextPlayerModelingArea.value = false
    end
end