-- Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

-- Public Variables
--!SerializeField
local minNumPlayersStartRound : number = 4

-- Local Variables
local uiManager = nil
local localCharacterInstantiatedEvent = nil
themesBeautyContest = {
    [1] = 'Rock and Roll',
    [2] = 'Gothic',
    [3] = 'Kawaii',
}

--Events
local timerSendPlayersToLockerRoom = Event.new('TimerSendPlayersToLockerRoom')
local stopTimerSendPlayersToLockerRoom = Event.new('StopTimerSendPlayersToLockerRoom')

--Remotes Functions Local
local RF_UpdateNumPlayersLobbyBeforeStartRound = RemoteFunction.new('UpdateNumPlayersLobbyBeforeStartRound')
local RF_UpdateNumberPlayersCurrentContest = RemoteFunction.new('UpdateNumberPlayersCurrentContest')
local RF_ShowUIWithThemeSelected = RemoteFunction.new('ShowUIWithThemeSelected')

--Remotes Functions Global
RF_SelectNewThemeContest = RemoteFunction.new('SelectNewThemeContest')

--Network values local
local selectThemeBeautyContest = BoolValue.new('SelectThemeBeautyContest', false)
local randomTheme = IntValue.new('RandomTheme', 0)
local amountPlayersLobby = IntValue.new('AmountPlayersLobby', 0)

--Network values global
hasStartedCountdownSendPlayersLockerRoom = BoolValue.new('StartedCountdownSendPlayersLockerRoom', false)

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
        RF_UpdateNumPlayersLobbyBeforeStartRound:InvokeServer('', function(response)end)
    end

    if localCharacterInstantiatedEvent then
        localCharacterInstantiatedEvent:Disconnect()
        localCharacterInstantiatedEvent = nil
    end
end

function self:ClientAwake()
    uiManager = gameManager.UI_BeautyContest
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

    RF_ShowUIWithThemeSelected.OnInvokeClient = function(theme)
        uiManager.SetThemeBeautyContest(theme)
        countdownsGame.StartCountdownCloseWindowTheme(uiManager, gameManager.UI_Customization)
        return true;
    end
end

function self:ServerStart()
    RF_UpdateNumPlayersLobbyBeforeStartRound.OnInvokeServer = function(player)
        amountPlayersLobby.value = numPlayersInLobby()
        hasStartedCountdownSendPlayersLockerRoom.value = false
        return true;
    end

    RF_SelectNewThemeContest.OnInvokeServer = function(player)
        if not selectThemeBeautyContest.value then
            randomTheme.value = math.random(1, 3)
            countdownsGame.themeSelectedContest.value = themesBeautyContest[randomTheme.value]
            RF_ShowUIWithThemeSelected:InvokeClient(
                player, 
                themesBeautyContest[randomTheme.value], 
                function(response)end
            )
            selectThemeBeautyContest.value = true
        else
            RF_ShowUIWithThemeSelected:InvokeClient(
                player, 
                themesBeautyContest[randomTheme.value], 
                function(response)end
            )
        end

        gameManager.numberPlayersCurrentContest.value += 1
        gameManager.playersCurrentlyCompeting[player.name] = true
        return true
    end

    server.PlayerDisconnected:Connect(function(player : Player)
        amountPlayersLobby.value = numPlayersInLobby()
    end)
end

function self:ServerUpdate()
    if amountPlayersLobby.value >= minNumPlayersStartRound and not countdownsGame.playerWentSentToLockerRoom.value and not hasStartedCountdownSendPlayersLockerRoom.value then
        timerSendPlayersToLockerRoom:FireAllClients()
        hasStartedCountdownSendPlayersLockerRoom.value = true
    end

    if amountPlayersLobby.value < minNumPlayersStartRound and not countdownsGame.playerWentSentToLockerRoom.value and hasStartedCountdownSendPlayersLockerRoom.value then
        stopTimerSendPlayersToLockerRoom:FireAllClients()
        countdownsGame.resetCountdowns()
        hasStartedCountdownSendPlayersLockerRoom.value = false
    end
end