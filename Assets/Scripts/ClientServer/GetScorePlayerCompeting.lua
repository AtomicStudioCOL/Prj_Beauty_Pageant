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

--Event
local printerPlayerScoreUI = Event.new('PrinterPlayerScoreUI')
sendScorePlayerCompeting = Event.new('SendScorePlayerCompeting')
showScoreBeautyContest = Event.new('ShowScoreBeautyContest')
eventResetAllData = Event.new('ResetAllDataScore')
askingIfPlayerHasVoting = Event.new('AskingIfPlayerHasVoting')
cleanInfoLeaderboardPlayerLeftGame = Event.new('CleanInfoLeaderboardPlayerLeftGame')

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
            if not score then continue end
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
end

function self:ServerAwake()
    sendScorePlayerCompeting:Connect(function(player : Player, score)
        updateRatingContest(
            gameManager.playerModelingCurrently.value,
            player.name,
            score
        )
    end)

    showScoreBeautyContest:Connect(function(player : Player)
        sortLeaderboard()
        countdownsGame.resetCountdowns()
        countdownsGame.StartCountdownEndRound()
    end)

    eventResetAllData:Connect(function(player : Player)
        resetAllData()
    end)

    askingIfPlayerHasVoting:Connect(function(player : Player)
        local hasPassedThroughCatwalk = gameManager.playerModelingCurrently.value

        if not resultContest[hasPassedThroughCatwalk] then
            resultContest[hasPassedThroughCatwalk] = 55
        end
    end)

    cleanInfoLeaderboardPlayerLeftGame:Connect(function(player : Player, namePlayer)
        print(`Player left score: {namePlayer}`)
        resultContest[namePlayer] = nil
    end)
end