-- Local Variables
local countdownGame : Timer = nil
local minutes : string = ''
local seconds : string = ''

-- Countdown to send players to locker Room
countdownSendPlayersToLockerRoom = IntValue.new('CountdownStartHiddenPlayers', 30)
playerWentSentToLockerRoom = BoolValue.new('PlayerWentSentToLockerRoom', false)
selectThemeBeautyContest = BoolValue.new('SelectThemeBeautyContest', false)

-- Countdown to close window theme
countdownCloseWindowTheme = IntValue.new('CountdownCloseWindowTheme', 20)

-- Player master
local playerMaster = StringValue.new('PlayerMaster', '')
local updateWhoIsPlayerMaster = BoolValue.new('UpdateWhoIsPlayerMaster', true)

--Events
local updateIfPlayersWentSendToLockerRoom = Event.new('UpdateIfPlayersWentSendToLockerRoom')
local updateTimerSendPlayersToLockerRoom = Event.new('UpdateTimerSendPlayersToLockerRoom')
local updateTimerWindowTheme = Event.new('UpdateTimerWindowTheme')

-- Functions
function resetCountdowns()
    playerMaster.value = ''
    updateWhoIsPlayerMaster.value = true
    countdownSendPlayersToLockerRoom.value = 30
    countdownCloseWindowTheme.value = 20
end

function selectMainPlayer(mainClient, namePlayer, countdownCurrent, canUpdate)
    if mainClient.value ~= '' and namePlayer == mainClient.value then
        countdownCurrent.value -= 1
    end

    if mainClient.value == '' and canUpdate.value then
        mainClient.value = namePlayer
        canUpdate.value = false
    end
end

function StartCountdownSendPlayersToLockerRoom(uiManager)
    if countdownGame then countdownGame:Stop() end
    
    uiManager.SetWaitingPlayersRound('Towards the locker room.')
    
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

function StartCountdownCloseWindowTheme(uiManager)
    if countdownGame then countdownGame:Stop() end
    
    countdownGame = Timer.new(1, function()
        seconds = countdownCloseWindowTheme.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerCloseWindowTheme('00:' .. seconds)
        updateTimerWindowTheme:FireServer()

        if countdownCloseWindowTheme.value <= 0 then
            uiManager.EnablePopupThemeContest(false)
            uiManager.SetTimerCloseWindowTheme('')
            uiManager.SetThemeBeautyContest('')
            countdownGame:Stop()
            resetCountdowns()
        end
    end, true)
end

function StopCountdownCurrentGame()
    if countdownGame then
        countdownGame:Stop()
        resetCountdowns()
    end
end

-- Unity Functions
function self:ServerAwake()
    updateIfPlayersWentSendToLockerRoom:Connect(function(player : Player)
        playerWentSentToLockerRoom.value = true
        selectThemeBeautyContest.value = true
    end)

    updateTimerSendPlayersToLockerRoom:Connect(function(player : Player)
        selectMainPlayer(playerMaster, player.name, countdownSendPlayersToLockerRoom, updateWhoIsPlayerMaster)
    end)

    updateTimerWindowTheme:Connect(function (player : Player)
        selectMainPlayer(playerMaster, player.name, countdownCloseWindowTheme, updateWhoIsPlayerMaster)
    end)
end