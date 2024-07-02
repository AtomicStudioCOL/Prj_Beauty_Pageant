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
    --print(`Num Players Contest: {gameManager.numberPlayersCurrentContest.value} debe ser 3`) --> 3
    for i = 1, gameManager.numberPlayersCurrentContest.value do
        --[[ print(`HugoUruena - Server: {resultContest['HugoUruena']}`)
        print(`VirtualPlayer2 - Server: {resultContest['VirtualPlayer2']}`)
        print(`VirtualPlayer3 - Server: {resultContest['VirtualPlayer3']}`) ]]
        for namePlayer, score in pairs(resultContest) do
            --print(`Name: {namePlayer} - Score: {score}`)
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
        --print(`showResults: {showResults[i]} - NamePlayerSaved: {namePlayerSaved[i]}`)
        beforeScore = 0
    end

    for rank, score in ipairs(showResults) do
        --print(`{rank}) {namePlayerSaved[rank]} - {score}`)
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

    --print(`Score: {resultContest[playerContestant]} - Player votante {playerVote} - Player Concursante {playerContestant}`)
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

    showScoreBeautyContest:Connect(function(player : Player, lastModel)
        --[[ print(`Player call me: {player.name}`)
        print(`HugoUruena - Server: {resultContest['HugoUruena']}`)
        print(`VirtualPlayer2 - Server: {resultContest['VirtualPlayer2']}`)
        print(`VirtualPlayer3 - Server: {resultContest['VirtualPlayer3']}`) ]]
        if player.name == lastModel then
            sortLeaderboard()
            countdownsGame.resetCountdowns()
            countdownsGame.StartCountdownEndRound()
        end
    end)

    eventResetAllData:Connect(function(player : Player)
        --print(`Reset all data`)
        resetAllData()
    end)

    askingIfPlayerHasVoting:Connect(function(player : Player)
        local hasPassedThroughCatwalk = gameManager.playerModelingCurrently.value

        if not resultContest[hasPassedThroughCatwalk] then
            resultContest[hasPassedThroughCatwalk] = 1
        end

        --print(`Print default result: {resultContest[hasPassedThroughCatwalk]}`)
    end)

    cleanInfoLeaderboardPlayerLeftGame:Connect(function(player : Player, namePlayer)
        --print(`Clean Info`)
        resultContest[namePlayer] = nil
    end)
end