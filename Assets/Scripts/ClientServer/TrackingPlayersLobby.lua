-- Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

-- Public Variables
--!SerializeField
local minNumPlayersStartRound : number = 4

-- Local Variables
local uiManager = nil
local localCharacterInstantiatedEvent = nil

--Events
local updateNumPlayersLobbyBeforeStartRound = Event.new('UpdateNumPlayersLobbyBeforeStartRound')
local timerSendPlayersToLockerRoom = Event.new('TimerSendPlayersToLockerRoom')
local stopTimerSendPlayersToLockerRoom = Event.new('StopTimerSendPlayersToLockerRoom')

--Network values
local hasStartedCountdownSendPlayersLockerRoom = BoolValue.new('StartedCountdownSendPlayersLockerRoom', false)

local function numPlayersInLobby()
    local numPlayers = 0

    for namePlayer, objPlayer in pairs(gameManager.playerWithGameObject) do
        if not objPlayer and tostring(objPlayer) == 'null' then continue end
        numPlayers += 1
    end
    
    return numPlayers
end

function settingLobbyPlayer()
    updateNumPlayersLobbyBeforeStartRound:FireServer()

    if localCharacterInstantiatedEvent then
        localCharacterInstantiatedEvent:Disconnect()
        localCharacterInstantiatedEvent = nil
    end
end

function self:ClientAwake()
    uiManager = gameManager.UIManagerGlobal:GetComponent(UI_Beauty_Pageant)

    localCharacterInstantiatedEvent = client.localPlayer.CharacterChanged:Connect(function(player : Player, character : Character)
        if character then
            settingLobbyPlayer()
        end
    end)

    timerSendPlayersToLockerRoom:Connect(function()
        countdownsGame.StartCountdownSendPlayersToLockerRoom(uiManager)
    end)

    stopTimerSendPlayersToLockerRoom:Connect(function()
        countdownsGame.StopCountdownCurrentGame()
    end)
end

function self:ServerAwake()
    updateNumPlayersLobbyBeforeStartRound:Connect(function()
        gameManager.amountPlayersLobby.value = numPlayersInLobby()
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        gameManager.amountPlayersLobby.value = numPlayersInLobby()
    end)
end

function self:ServerUpdate()
    if gameManager.amountPlayersLobby.value >= minNumPlayersStartRound and not countdownsGame.playerWentSentToLockerRoom.value and not hasStartedCountdownSendPlayersLockerRoom.value then
        timerSendPlayersToLockerRoom:FireAllClients()
        hasStartedCountdownSendPlayersLockerRoom.value = true
    end

    if gameManager.amountPlayersLobby.value < minNumPlayersStartRound and not countdownsGame.playerWentSentToLockerRoom.value and hasStartedCountdownSendPlayersLockerRoom.value then
        stopTimerSendPlayersToLockerRoom:FireAllClients()
        hasStartedCountdownSendPlayersLockerRoom.value = false
    end
end

function self:Update()
    if countdownsGame.playerWentSentToLockerRoom then
    end
end