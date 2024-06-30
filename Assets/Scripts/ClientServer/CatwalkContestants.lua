--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--Network value
local printScore = BoolValue.new('PrinterScore', false)

function endCatwalkShowLeaderboard()
    gameManager.UI_ConstestVoting.CleanStarsSelecting()
    gameManager.UI_ConstestVoting.SettingStart()
    gameManager.UI_BeautyContest.SettingStartUI()
    gameManager.UI_RatingContest.EnableRatingContest(true)
    gameManager.ScorePlayerCompeting.updateCanPrinterInfoLeaderboard:FireServer()

    gameManager.numberPlayersModeled.value = 0
end

--function self:ClientUpdate()
    --[[ local nextPlayer = countdownsGame.nextPlayerModelingArea.value
    local continueContest = gameManager.numberPlayersModeled.value < gameManager.numberPlayersCurrentContest.value

    if nextPlayer and continueContest then
        print(`Catwalk -> Name: {game.localPlayer.name} - {nextPlayer}`)
        --gameManager.ScorePlayerCompeting.askingIfPlayerHasVoting:FireServer()
        gameManager.RF_GoNextPlayerContest:InvokeServer(game.localPlayer.name, function(response)end)
        
        countdownsGame.RF_ResetNextPlayerVoting:InvokeServer(game.localPlayer.name, function(response)end)
        countdownsGame.nextPlayerModelingArea.value = false
    end ]]

    --[[ local playersContestant = gameManager.numberPlayersModeled.value
    local playersCurrentContest = gameManager.numberPlayersCurrentContest.value
    local finishLastPlayer = countdownsGame.nextPlayerModelingArea.value

    if playersContestant == playersCurrentContest and playersCurrentContest > 0 and finishLastPlayer then
        endCatwalkShowLeaderboard()
    end ]]
--end