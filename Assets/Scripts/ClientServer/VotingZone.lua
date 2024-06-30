--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

eventStartTimerAreaVoting = Event.new('StartTimerAreaVoting')

function sendNextPlayerToVoting()
    for namePlayer, objPlayer in pairs(gameManager.playerWithGameObject) do
        if not objPlayer or tostring(objPlayer) == 'null' then continue end
        
        if gameManager.playersCurrentlyCompeting[namePlayer] and not gameManager.playersAlreadyModeling[namePlayer] then
            print(`Name Server: {namePlayer}`)
            gameManager.sendPlayerModelingAreaClient:FireAllClients(namePlayer)
            gameManager.playerModelingCurrently.value = namePlayer
            countdownsGame.StartCountdownVotingArea(gameManager.playerModelingCurrently.value)
            gameManager.playersAlreadyModeling[namePlayer] = true
            break
        end
    end

    gameManager.numberPlayersModeled.value += 1
end

--Unity Functions
function self:ServerStart()
    eventStartTimerAreaVoting:Connect(function(player : Player)
        sendNextPlayerToVoting()
    end)
end

function self:ServerUpdate()
    if gameManager.numberPlayersCurrentContest.value == gameManager.numberPlayersSendModelingArea.value and not gameManager.startingAvatarContest.value and gameManager.numberPlayersCurrentContest.value > 0 then --Ya todos estan tras banbalinas
        for namePlayer, objPlayer in pairs(gameManager.playerWithGameObject) do
            if not objPlayer or tostring(objPlayer) == 'null' then continue end
            
            if gameManager.playersCurrentlyCompeting[namePlayer] and not gameManager.playersAlreadyModeling[namePlayer] then
                print(`Name Server update: {namePlayer}`)
                gameManager.sendPlayerModelingAreaClient:FireAllClients(namePlayer)
                gameManager.playerModelingCurrently.value = namePlayer
                countdownsGame.StartCountdownVotingArea(gameManager.playerModelingCurrently.value)
                gameManager.playersAlreadyModeling[namePlayer] = true
                break
            end
        end

        gameManager.startingAvatarContest.value = true
        gameManager.numberPlayersModeled.value += 1
    end
end