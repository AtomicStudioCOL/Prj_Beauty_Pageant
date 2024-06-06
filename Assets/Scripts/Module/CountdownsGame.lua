-- Local Variables
local countdownGame : Timer = nil
local countdownEndGame : Timer = nil
local minutes : string = ''
local seconds : string = ''

-- Global Variables
countdownSendPlayersToLockerRoom = IntValue.new('CountdownStartHiddenPlayers', 30)
playerWentSentToLockerRoom = BoolValue.new('PlayerWentSentToLockerRoom', false)

--Events
local updateTimerSendPlayersToLockerRoom = Event.new('UpdateTimerSendPlayersToLockerRoom')
local updateIfPlayersWentSendToLockerRoom = Event.new('UpdateIfPlayersWentSendToLockerRoom')

-- Functions
function resetCountdowns()
    countdownSendPlayersToLockerRoom.value = 30
end

function StartCountdownSendPlayersToLockerRoom(uiManager)
    if countdownGame then countdownGame:Stop() end
    
    countdownGame = Timer.new(1, function()
        seconds = countdownSendPlayersToLockerRoom.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetCountdownGame('00:' .. seconds)
        countdownSendPlayersToLockerRoom.value -= 1

        if countdownSendPlayersToLockerRoom.value <= 0 then
            updateIfPlayersWentSendToLockerRoom:FireServer()
            countdownGame:Stop()
        end
    end, true)
end

function StopCountdownCurrentGame()
    if countdownGame then
        countdownGame:Stop()
    end
end

-- Unity Functions
function self:ServerAwake()
    updateIfPlayersWentSendToLockerRoom:Connect(function(player : Player)
        playerWentSentToLockerRoom.value = true
    end)
end