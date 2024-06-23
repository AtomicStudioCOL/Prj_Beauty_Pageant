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

--Storage player's score in the voting
local ratingContest = {}
resultContest = {}

--Event
sendScorePlayerCompeting = Event.new('SendScorePlayerCompeting')
showScoreBeautyContest = Event.new('ShowScoreBeautyContest')

--Functions
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

function self:ServerAwake()
    sendScorePlayerCompeting:Connect(function(player : Player, score)
        updateRatingContest(
            gameManager.playerModelingCurrently.value,
            player.name,
            score
        )
    end)

    showScoreBeautyContest:Connect(function(player : Player)
        for namePlayer, score in pairs(resultContest) do
            print(`Player: {namePlayer} - Score: {score}`)
        end
    end)
end