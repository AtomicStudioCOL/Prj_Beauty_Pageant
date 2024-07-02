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
themesSelected = {}

--Events
local stopTimerSendPlayersToLockerRoom = Event.new('StopTimerSendPlayersToLockerRoom')
local startTimerSendPlayersLockerRoom = Event.new('StartTimerSendPlayersLockerRoom')

--Remotes Functions Local
local RF_UpdateNumPlayersLobbyBeforeStartRound = RemoteFunction.new('UpdateNumPlayersLobbyBeforeStartRound')
local RF_ShowUIWithThemeSelected = RemoteFunction.new('ShowUIWithThemeSelected')

--Remotes Functions Global
RF_SelectNewThemeContest = RemoteFunction.new('SelectNewThemeContest')

--Network values local
local randomTheme = StringValue.new('RandomTheme', '')
local amountPlayersLobby = IntValue.new('AmountPlayersLobby', 0)

--Network values global
selectThemeBeautyContest = BoolValue.new('SelectThemeBeautyContest', false)
hasStartedCountdownSendPlayersLockerRoom = BoolValue.new('StartedCountdownSendPlayersLockerRoom', false)

local function numPlayersInLobby()
    local numPlayers = 0

    for namePlayer, objPlayer in pairs(gameManager.playerWithGameObject) do
        if not objPlayer and tostring(objPlayer) == 'null' then continue end
        numPlayers += 1
    end

    return numPlayers
end

local function selectThemeContest()
    for index, theme in ipairs(themesBeautyContest) do
        if themesSelected[index] then continue end

        if not themesSelected[index] then
            themesSelected[index] = themesBeautyContest[index]
            return themesSelected[index]
        end
    end
    
    themesSelected = {}
    themesSelected[1] = themesBeautyContest[1]
    return themesSelected[1]
end

function settingLobbyPlayer()
    if hasStartedCountdownSendPlayersLockerRoom.value and not countdownsGame.playerWentSentToLockerRoom.value then
        uiManager.SetWaitingPlayersRound('Next match starts in..')
        startTimerSendPlayersLockerRoom:FireServer()
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

    stopTimerSendPlayersToLockerRoom:Connect(function()
        hasStartedCountdownSendPlayersLockerRoom.value = false
        settingLobbyPlayer()
    end)

    RF_ShowUIWithThemeSelected.OnInvokeClient = function(theme)
        uiManager.SetThemeBeautyContest(theme)
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
            randomTheme.value = selectThemeContest()
            countdownsGame.themeSelectedContest.value = randomTheme.value
            selectThemeBeautyContest.value = true
        end
        
        RF_ShowUIWithThemeSelected:InvokeClient(
            player, 
            randomTheme.value,
            function(response)end
        )

        gameManager.numberPlayersCurrentContest.value += 1
        gameManager.playersCurrentlyCompeting[player.name] = true
        return true
    end

    startTimerSendPlayersLockerRoom:Connect(function(player : Player)
        countdownsGame.StartCountdownSendPlayersToLockerRoom()
        selectThemeBeautyContest.value = false
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        amountPlayersLobby.value = numPlayersInLobby()
    end)
end

function self:ServerUpdate()
    if amountPlayersLobby.value >= minNumPlayersStartRound and not countdownsGame.playerWentSentToLockerRoom.value and not hasStartedCountdownSendPlayersLockerRoom.value then
        countdownsGame.StartCountdownSendPlayersToLockerRoom()
        selectThemeBeautyContest.value = false
        hasStartedCountdownSendPlayersLockerRoom.value = true
    end

    if amountPlayersLobby.value < minNumPlayersStartRound and not countdownsGame.playerWentSentToLockerRoom.value and hasStartedCountdownSendPlayersLockerRoom.value then
        stopTimerSendPlayersToLockerRoom:FireAllClients()
        countdownsGame.resetCountdowns()
        countdownsGame.StopCountdownCurrentGame()
        hasStartedCountdownSendPlayersLockerRoom.value = false
    end
end