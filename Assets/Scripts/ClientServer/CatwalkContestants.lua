--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--Network value
local printScore = BoolValue.new('PrinterScore', false)

function self:ClientUpdate()
    local nextPlayer = countdownsGame.nextPlayerModelingArea.value
    local continueContest = gameManager.numberPlayersModeled.value < gameManager.numberPlayersCurrentContest.value

    if nextPlayer and continueContest then
        gameManager.goNextPlayerContest:FireServer()
        countdownsGame.eventResetNextPlayerVoting:FireServer()
        countdownsGame.nextPlayerModelingArea.value = false
    end

    local playersContestant = gameManager.numberPlayersModeled.value
    local playersCurrentContest = gameManager.numberPlayersCurrentContest.value
    local finishLastPlayer = countdownsGame.nextPlayerModelingArea.value

    if playersContestant == playersCurrentContest and playersCurrentContest > 0 and finishLastPlayer then
        gameManager.UI_ConstestVoting.CleanStarsSelecting()
        gameManager.UI_ConstestVoting.SettingStart()
        gameManager.UI_BeautyContest.SettingStartUI()
        gameManager.ScorePlayerCompeting.updateCanPrinterInfoLeaderboard:FireServer()
        gameManager.UI_RatingContest.EnableRatingContest(true)

        gameManager.numberPlayersModeled.value = 0
    end
end