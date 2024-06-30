--[[
    Rating Beauty Contest

    {
        [name_player_contestant] = {
            [player_voting] = value_rating
        }
    }

    Result Contest

    {
        [name_player_contestant] = score
    }
--]]
--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame') 

--Storage player's score in the voting
local ratingContest = {}
resultContest = {}

--Sort player's score
local showResults = {}
local playerSaved = {}
local namePlayerSaved = {}
local beforeScore = 0
local namePlayerGreaterScore = ''

--Network values
local wasPrinterInfo = BoolValue.new('WasPrinterInfoLeaderboard', false)

--Event
local printerPlayerScoreUI = Event.new('PrinterPlayerScoreUI')
local startCountdownEnd = Event.new('StartCountdownEnd')
updateCanPrinterInfoLeaderboard = Event.new('CanPrinterInfoLeaderboard')
sendScorePlayerCompeting = Event.new('SendScorePlayerCompeting')
showScoreBeautyContest = Event.new('ShowScoreBeautyContest')
eventResetAllData = Event.new('ResetAllDataScore')
askingIfPlayerHasVoting = Event.new('AskingIfPlayerHasVoting')

--Functions
function resetAllData()
    ratingContest = {}
    resultContest = {}
    showResults = {}
    playerSaved = {}
    namePlayerSaved = {}
    beforeScore = 0
    namePlayerGreaterScore = ''
end

local function sortLeaderboard()
    for i = 1, gameManager.numberPlayersCurrentContest.value do
        for namePlayer, score in pairs(resultContest) do
            if playerSaved[namePlayer] then continue end

            if beforeScore < score then
                beforeScore = score
                namePlayerGreaterScore = namePlayer
            elseif beforeScore == score and namePlayerGreaterScore ~= namePlayer then
                beforeScore = score
                namePlayerGreaterScore = namePlayer
            elseif beforeScore == score and namePlayerGreaterScore == namePlayer then
                continue
            end
        end

        showResults[i] = beforeScore
        namePlayerSaved[i] = namePlayerGreaterScore
        playerSaved[namePlayerGreaterScore] = true
        beforeScore = 0
    end

    for rank, score in ipairs(showResults) do
        printerPlayerScoreUI:FireAllClients(rank, namePlayerSaved[rank], score)
    end
end

function updateRatingContest(playerContestant, playerVote, valueVote)
    if not ratingContest[playerContestant] then
        ratingContest[playerContestant] = {}
    end

    if not ratingContest[playerContestant][playerVote] then
        ratingContest[playerContestant][playerVote] = valueVote

        if resultContest[playerContestant] then
            resultContest[playerContestant] += valueVote
        else
            resultContest[playerContestant] = valueVote
        end
    else
        if ratingContest[playerContestant][playerVote] ~= valueVote then
            resultContest[playerContestant] -= ratingContest[playerContestant][playerVote]
            resultContest[playerContestant] += valueVote
        end
    end
end

--Unity functions
function self:ClientStart()
    printerPlayerScoreUI:Connect(function(ranking, namePlayer, score)
        gameManager.UI_RatingContest.UpdateLeaderboard(ranking, namePlayer, score)
    end)

    startCountdownEnd:Connect(function()
        countdownsGame.StartCountdownEndRound(gameManager.UI_RatingContest)
    end)
end

function self:ServerStart()
    sendScorePlayerCompeting:Connect(function(player : Player, score)
        updateRatingContest(
            gameManager.playerModelingCurrently.value,
            player.name,
            score
        )
    end)

    showScoreBeautyContest:Connect(function(player : Player)
        if not wasPrinterInfo.value then
            sortLeaderboard()
            countdownsGame.resetCountdowns()
            startCountdownEnd:FireAllClients()
            wasPrinterInfo.value = true
        end
    end)

    updateCanPrinterInfoLeaderboard:Connect(function(player : Player)
        wasPrinterInfo.value = false
    end)

    eventResetAllData:Connect(function(player : Player)
        resetAllData()
    end)

    askingIfPlayerHasVoting:Connect(function(player : Player)
        if not gameManager.canAskIfPlayerHasVoting.value then
            local hasPassedThroughCatwalk = gameManager.playerModelingCurrently.value

            if not resultContest[hasPassedThroughCatwalk] then
                resultContest[hasPassedThroughCatwalk] = 55
            end
            
            gameManager.canAskIfPlayerHasVoting.value = true
        end
    end)
end