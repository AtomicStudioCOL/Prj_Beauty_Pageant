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