-- Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

-- Public Variables
--!SerializeField
local minNumPlayersStartRound : number = 4

-- Local Variables
local uiManager = nil
local UI_Customization_Player = nil
local localCharacterInstantiatedEvent = nil
themesBeautyContest = {
    [1] = 'Rock and Roll',
    [2] = 'Gothic',
    [3] = 'Kawaii',
}

--Events
local updateNumPlayersLobbyBeforeStartRound = Event.new('UpdateNumPlayersLobbyBeforeStartRound')
local timerSendPlayersToLockerRoom = Event.new('TimerSendPlayersToLockerRoom')
local stopTimerSendPlayersToLockerRoom = Event.new('StopTimerSendPlayersToLockerRoom')
local updateNumberPlayersCurrentContest = Event.new('UpdateNumberPlayersCurrentContest')
local selectNewThemeContest = Event.new('SelectNewThemeContest')
local showUIWithThemeSelected = Event.new('ShowUIWithThemeSelected')

--Network values
hasStartedCountdownSendPlayersLockerRoom = BoolValue.new('StartedCountdownSendPlayersLockerRoom', false)
randomTheme = IntValue.new('RandomTheme', 0)
selectThemeBeautyContest = BoolValue.new('SelectThemeBeautyContest', false)
themeSelectedCompeting = StringValue.new('ThemeSelectedCompeting', '')

local function numPlayersInLobby()
    local numPlayers = 0

    for namePlayer, objPlayer in pairs(gameManager.playerWithGameObject) do
        if not objPlayer and tostring(objPlayer) == 'null' then continue end
        numPlayers += 1
    end
    
    return numPlayers
end

function settingLobbyPlayer()
    if hasStartedCountdownSendPlayersLockerRoom.value and not countdownsGame.playerWentSentToLockerRoom.value then
        uiManager.SetWaitingPlayersRound('Next match starts in..')
        countdownsGame.StartCountdownSendPlayersToLockerRoom(uiManager)
    elseif not hasStartedCountdownSendPlayersLockerRoom.value and not countdownsGame.playerWentSentToLockerRoom.value then
        uiManager.SetWaitingPlayersRound('Waiting for 3 players to start the pageant.')
        uiManager.SetTimerSendPlayerToLockerRoom('')
    end

    if countdownsGame.playerWentSentToLockerRoom.value and hasStartedCountdownSendPlayersLockerRoom.value then
        uiManager.SetWaitingPlayersRound('Pageant in Progress!')
        uiManager.EnableSpectatorModeLobby(true)
        countdownsGame.playerWentSentToLockerRoom.value = false
    else
        updateNumPlayersLobbyBeforeStartRound:FireServer()
    end

    if localCharacterInstantiatedEvent then
        localCharacterInstantiatedEvent:Disconnect()
        localCharacterInstantiatedEvent = nil
    end
end

function self:ClientAwake()
    uiManager = gameManager.UIManagerGlobal:GetComponent(UI_Beauty_Pageant)
    UI_Customization_Player = gameManager.UIManagerGlobal:GetComponent(UI_Customization_Model)
    hasStartedCountdownSendPlayersLockerRoom.value = false
    
    localCharacterInstantiatedEvent = client.localPlayer.CharacterChanged:Connect(function(player : Player, character : Character)
        if character then
            settingLobbyPlayer()
        end
    end)

    timerSendPlayersToLockerRoom:Connect(function()
        countdownsGame.StartCountdownSendPlayersToLockerRoom(uiManager)
    end)

    stopTimerSendPlayersToLockerRoom:Connect(function()
        hasStartedCountdownSendPlayersLockerRoom.value = false
        settingLobbyPlayer()
        countdownsGame.StopCountdownCurrentGame()
    end)

    showUIWithThemeSelected:Connect(function(theme)
        uiManager.SetThemeBeautyContest(theme)
        countdownsGame.StartCountdownCloseWindowTheme(uiManager, UI_Customization_Player)
    end)

    countdownsGame.remoteFunctionShowThemeUI.OnInvokeClient = function()
        uiManager.SetWaitingPlayersRound('')
        uiManager.SetTimerSendPlayerToLockerRoom('')
        uiManager.EnablePopupThemeContest(true)
        
        selectNewThemeContest:FireServer()
        updateNumberPlayersCurrentContest:FireServer()
        gameManager.playersCurrentlyCompeting[game.localPlayer.name] = true
        return true
    end
end

function self:ServerAwake()
    updateNumPlayersLobbyBeforeStartRound:Connect(function(player : Player)
        gameManager.amountPlayersLobby.value = numPlayersInLobby()
        hasStartedCountdownSendPlayersLockerRoom.value = false
    end)

    updateNumberPlayersCurrentContest:Connect(function(player : Player)
        gameManager.numberPlayersCurrentContest.value += 1
        gameManager.playersCurrentlyCompeting[player.name] = true
    end)

    selectNewThemeContest:Connect(function(player : Player)
        if not selectThemeBeautyContest.value then
            randomTheme.value = math.random(1, 3)
            countdownsGame.themeSelectedContest.value = themesBeautyContest[randomTheme.value]
            showUIWithThemeSelected:FireClient(player, themesBeautyContest[randomTheme.value])
            selectThemeBeautyContest.value = true
        else
            showUIWithThemeSelected:FireClient(player, themesBeautyContest[randomTheme.value])
        end
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
        countdownsGame.resetCountdowns()
        hasStartedCountdownSendPlayersLockerRoom.value = false
    end
end