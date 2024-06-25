-- Local Variables
local countdownGame : Timer = nil
local timerEndGame : Timer = nil
local minutes : string = ''
local seconds : string = ''
local gameManagerObj = nil

-- Countdown to send players to locker Room
countdownSendPlayersToLockerRoom = IntValue.new('CountdownStartHiddenPlayers', 30)
playerWentSentToLockerRoom = BoolValue.new('PlayerWentSentToLockerRoom', false)
selectThemeBeautyContest = BoolValue.new('SelectThemeBeautyContest', false)

-- Countdown to close window theme
countdownCloseWindowTheme = IntValue.new('CountdownCloseWindowTheme', 5)

-- Countdown customization of the player
countdownCustomizationPlayer = IntValue.new('CountdownCustomizationPlayer', 180)

-- Countdown voting area
countdownVotingArea = IntValue.new('CountdownVotingArea', 10)
nextPlayerModelingArea = BoolValue.new('NextPlayerModelingArea', false)

-- Countdown end game - return to the lobby
countdownEndRound = IntValue.new('CountdownEndRound', 10)
hasRoundFinished = BoolValue.new('HasRoundFinished', false)

-- Player master
local playerMaster = StringValue.new('PlayerMaster', '')
local updateWhoIsPlayerMaster = BoolValue.new('UpdateWhoIsPlayerMaster', true)

-- Theme Contest
themeSelectedContest = StringValue.new('ThemeSelectedContest', '')

--Events
local updateIfPlayersWentSendToLockerRoom = Event.new('UpdateIfPlayersWentSendToLockerRoom')
local updateTimerSendPlayersToLockerRoom = Event.new('UpdateTimerSendPlayersToLockerRoom')
local hasFinishedTimerWindowTheme = Event.new('HasFinishedTimerWindowTheme')
local updateTimerWindowTheme = Event.new('UpdateTimerWindowTheme')
local hasFinishedTimerCustomizationPlayer = Event.new('HasFinishedTimerCustomizationPlayer')
local updateTimerCustomizationPlayer = Event.new('UpdateTimerCustomizationPlayer')
local updateTimerVotingArea = Event.new('UpdateTimerVotingArea')
local eventNextPlayerVoting = Event.new('NextPlayerVoting')
eventResetNextPlayerVoting = Event.new('ResetNextPlayerVoting')
local updateTimerEndRound = Event.new('UpdateTimerEndRound')
local eventEndRound = Event.new('EventEndRound')
-- Select a new master when the master before left contest.
selectNewMasterServer = Event.new('SelectNewMasterServer')
local playersInCompetingServer = Event.new('playersInCompetingServer')
local playersInCompetingClient = Event.new('playersInCompetingClient')

-- Functions
function resetCountdowns()
    playerMaster.value = ''
    updateWhoIsPlayerMaster.value = true
    countdownSendPlayersToLockerRoom.value = 30
    countdownCloseWindowTheme.value = 5
    countdownCustomizationPlayer.value = 180
    countdownVotingArea.value = 10
    countdownEndRound.value = 10
end

function selectMainPlayer(mainClient, namePlayer, countdownCurrent, canUpdate)
    if mainClient.value ~= '' and namePlayer == mainClient.value then
        countdownCurrent.value -= 1
    end

    if mainClient.value == '' and canUpdate.value then
        mainClient.value = namePlayer
        canUpdate.value = false
        print(`New Master: {mainClient.value}`)
    end
end

function StartCountdownSendPlayersToLockerRoom(uiManager)
    if countdownGame then countdownGame:Stop() end
    
    uiManager.SetWaitingPlayersRound('Next match starts in..')
    countdownGame = Timer.new(1, function()
        seconds = countdownSendPlayersToLockerRoom.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerSendPlayerToLockerRoom('00:' .. seconds)
        updateTimerSendPlayersToLockerRoom:FireServer()

        if countdownSendPlayersToLockerRoom.value <= 0 then
            updateIfPlayersWentSendToLockerRoom:FireServer()
            countdownGame:Stop()
            resetCountdowns()
        end
    end, true)
end

function StartCountdownCloseWindowTheme(uiManager, uiCustomization)
    if countdownGame then countdownGame:Stop() end
    
    countdownGame = Timer.new(1, function()
        seconds = countdownCloseWindowTheme.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerCloseWindowTheme('00:' .. seconds)
        updateTimerWindowTheme:FireServer()

        if countdownCloseWindowTheme.value <= 0 then
            hasFinishedTimerWindowTheme:FireServer()
            countdownGame:Stop()
            resetCountdowns()

            uiManager.EnablePopupThemeContest(false)
            uiManager.SetTimerCloseWindowTheme('')
            uiManager.SetThemeBeautyContest('')
            uiManager.SetWaitingPlayersRound('LOCKER ROOM')

            uiCustomization.EnableCustomizationPlayer(true)
            uiCustomization.EnablePopupInfoCustomization(true)
            StartCountdownCustomizationPlayer(uiCustomization)
        end
    end, true)
end

function StartCountdownCustomizationPlayer(uiManager)
    if countdownGame then countdownGame:Stop() end
    uiManager.SetThemeBeautyContest(themeSelectedContest.value)

    countdownGame = Timer.new(1, function()
        minutes = tostring(math.floor(countdownCustomizationPlayer.value / 60))
        seconds = tostring(countdownCustomizationPlayer.value % 60)

        if tonumber(minutes) < 10 then
            minutes = `0{minutes}`
        end

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerCustomizationPlayer(minutes .. ':' .. seconds)
        updateTimerCustomizationPlayer:FireServer()

        if countdownCustomizationPlayer.value <= 0 then
            uiManager.finishedTimerCustomizationPlayers()
            hasFinishedTimerCustomizationPlayer:FireServer()
            countdownGame:Stop()
            resetCountdowns()
        end
    end, true)
end

function StartCountdownVotingArea(uiManager)
    if countdownGame then countdownGame:Stop() end

    countdownGame = Timer.new(1, function()
        seconds = countdownVotingArea.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerForVoting('00:' .. seconds)
        updateTimerVotingArea:FireServer()

        if countdownVotingArea.value <= 0 then
            eventNextPlayerVoting:FireServer()
            resetCountdowns()
            countdownGame:Stop()
        end
    end, true)
end

function StartCountdownEndRound(uiManager)
    if timerEndGame then timerEndGame:Stop() end
    print(`Timer end round!`)
    timerEndGame = Timer.new(1, function()
        seconds = countdownEndRound.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        print(`Timer: {'00:' .. seconds}`)
        uiManager.SetTimerEndRound('00:' .. seconds)
        updateTimerEndRound:FireServer()

        if countdownEndRound.value <= 0 then
            eventEndRound:FireServer()
            resetCountdowns()
            timerEndGame:Stop()
        end
    end, true)
end

function StopCountdownCurrentGame()
    if countdownGame then
        resetCountdowns()
        countdownGame:Stop()
    end
end

-- Unity Functions
function self:ClientAwake()
    gameManagerObj = self.gameObject:GetComponent(GameManager)

    playersInCompetingClient:Connect(function()
        print(`Is competing: {gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name]}`)
        if gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name] and updateWhoIsPlayerMaster.value then
            playersInCompetingServer:FireServer()
            updateWhoIsPlayerMaster.value = false
        end
    end)
end

function self:ServerAwake()
    updateIfPlayersWentSendToLockerRoom:Connect(function(player : Player)
        playerWentSentToLockerRoom.value = true
        selectThemeBeautyContest.value = true
        resetCountdowns()
    end)

    hasFinishedTimerWindowTheme:Connect(function(player : Player)
        resetCountdowns()
    end)

    hasFinishedTimerCustomizationPlayer:Connect(function(player : Player)
        resetCountdowns()
    end)

    eventNextPlayerVoting:Connect(function(player : Player)
        nextPlayerModelingArea.value = true
        resetCountdowns()
    end)

    eventResetNextPlayerVoting:Connect(function(player : Player)
        nextPlayerModelingArea.value = false
    end)

    eventEndRound:Connect(function(player : Player)
        hasRoundFinished.value = true
        resetCountdowns()
    end)

    updateTimerSendPlayersToLockerRoom:Connect(function(player : Player)
        selectMainPlayer(playerMaster, player.name, countdownSendPlayersToLockerRoom, updateWhoIsPlayerMaster)
    end)

    updateTimerWindowTheme:Connect(function (player : Player)
        print(`Updating - {playerMaster.value}`)
        selectMainPlayer(playerMaster, player.name, countdownCloseWindowTheme, updateWhoIsPlayerMaster)
    end)

    updateTimerCustomizationPlayer:Connect(function (player : Player)
        selectMainPlayer(playerMaster, player.name, countdownCustomizationPlayer, updateWhoIsPlayerMaster)
    end)

    updateTimerVotingArea:Connect(function(player : Player)        
        selectMainPlayer(playerMaster, player.name, countdownVotingArea, updateWhoIsPlayerMaster)
    end)

    updateTimerEndRound:Connect(function(player : Player)
        selectMainPlayer(playerMaster, player.name, countdownEndRound, updateWhoIsPlayerMaster)
    end)

    selectNewMasterServer:Connect(function(player : Player, statusPlayer)
        print(`{playerMaster.value} - {player.name} - {statusPlayer}`)
        if playerMaster.value == player.name or statusPlayer == 'PlayerLeftGame' then
            playerMaster.value = ''
            updateWhoIsPlayerMaster.value = true
            playersInCompetingClient:FireAllClients()
        end
    end)

    playersInCompetingServer:Connect(function(player : Player)
        print(`Select New Master`)
        selectMainPlayer(playerMaster, player.name, countdownCloseWindowTheme, updateWhoIsPlayerMaster)
    end)
end