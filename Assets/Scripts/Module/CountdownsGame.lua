-- Local Variables
local countdownGame : Timer = nil
local timerEndGame : Timer = nil
local timerScreenTheme : Timer = nil
local timerCustomizationClient : Timer = nil
local timerVotingArea : Timer = nil
local minutes : string = ''
local seconds : string = ''
local gameManagerObj = nil

-- Countdown to send players to locker Room
countdownSendPlayersToLockerRoom = IntValue.new('CountdownStartHiddenPlayers', 10)
playerWentSentToLockerRoom = BoolValue.new('PlayerWentSentToLockerRoom', false)

-- Countdown to close window theme
countdownCloseWindowTheme = IntValue.new('CountdownCloseWindowTheme', 5)

-- Countdown customization of the player
countdownCustomizationPlayer = IntValue.new('CountdownCustomizationPlayer', 180)
finishCustomizationSendModelingArea = BoolValue.new('FinishCustomizationSendModelingArea', false)

-- Countdown voting area
countdownVotingArea = IntValue.new('CountdownVotingArea', 10)

-- Countdown end game - return to the lobby
countdownEndRound = IntValue.new('CountdownEndRound', 10)

-- Theme Contest
themeSelectedContest = StringValue.new('ThemeSelectedContest', '')

--Remotes Functions Local
local RF_HasFinishedTimerCustomizationPlayer = RemoteFunction.new('HasFinishedTimerCustomizationPlayer')
local RF_ShootWhenFinishCustomization = RemoteFunction.new('ShootWhenFinishCustomization')

--Locker Room
local updateUILockerRoom = Event.new('UpdateUILockerRoom')
local goLockerRoom = Event.new('GoLockerRoom')

--Voting Area
local updateUIVotingArea = Event.new('UpdateUIVotingArea')
local goNextPlayerContestant = Event.new('GoNextPlayerContestant')
local hasFinishedContestant = Event.new('HasFinishedContestant')

--Screen theme
local updateUIScreenTheme = Event.new('UpdateUIScreenTheme')
local goPlayerCustomization = Event.new('GoPlayerCustomization')
reactiveTimerScreenTheme = Event.new('ReactiveTimerScreenTheme')

--Customization Player
local updateScreenPlayerCustomization = Event.new('updateScreenPlayerCustomization')
local goAreaVoting = Event.new('GoAreaVoting')

--End Round
local updateUIEndRound = Event.new('UpdateUIEndRound')
local goLobby = Event.new('GoLobby')

--Reset - Stop
eventResetStopTimers = Event.new('EventResetStopTimers')

local playersContestant = nil
local playersCurrentContest = nil

-- Functions
function resetCountdowns()    
    countdownSendPlayersToLockerRoom.value = 10
    countdownCloseWindowTheme.value = 5
    countdownCustomizationPlayer.value = 180
    countdownVotingArea.value = 10
    countdownEndRound.value = 10
end

function StartCountdownSendPlayersToLockerRoom()
    if countdownGame then countdownGame:Stop() end
    
    countdownGame = Timer.new(1, function()
        seconds = countdownSendPlayersToLockerRoom.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        updateUILockerRoom:FireAllClients(seconds)
        countdownSendPlayersToLockerRoom.value -= 1

        if countdownSendPlayersToLockerRoom.value <= -1 then
            playerWentSentToLockerRoom.value = true
            goLockerRoom:FireAllClients()
            countdownGame:Stop()
            resetCountdowns()
            StartCountdownCloseWindowTheme()
        end
    end, true)
end

function StartCountdownCloseWindowTheme()
    if timerScreenTheme then timerScreenTheme:Stop() end
    
    timerScreenTheme = Timer.new(1, function()
        seconds = countdownCloseWindowTheme.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        updateUIScreenTheme:FireAllClients(seconds)
        countdownCloseWindowTheme.value -= 1

        if countdownCloseWindowTheme.value <= -1 then
            goPlayerCustomization:FireAllClients()
            timerScreenTheme:Stop()
            resetCountdowns()
            finishCustomizationSendModelingArea.value = false
            StartCountdownCustomizationPlayer()
        end
    end, true)
end

function StartCountdownCustomizationPlayer()
    if timerCustomizationClient then timerCustomizationClient:Stop() end

    timerCustomizationClient = Timer.new(1, function()
        minutes = tostring(math.floor(countdownCustomizationPlayer.value / 60))
        seconds = tostring(countdownCustomizationPlayer.value % 60)

        if tonumber(minutes) < 10 then
            minutes = `0{minutes}`
        end

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        updateScreenPlayerCustomization:FireAllClients(minutes, seconds, countdownCustomizationPlayer.value)
        countdownCustomizationPlayer.value -= 1

        if countdownCustomizationPlayer.value <= -1 then
            goAreaVoting:FireAllClients()
            timerCustomizationClient:Stop()
            resetCountdowns()
        end
    end, true)
end

function StartCountdownVotingArea(modelCurrent)
    if timerVotingArea then timerVotingArea:Stop() end
    
    timerVotingArea = Timer.new(1, function()
        seconds = countdownVotingArea.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end
        
        updateUIVotingArea:FireAllClients(seconds)
        countdownVotingArea.value -= 1

        if countdownVotingArea.value <= -1 then
            print(`Fin timer Voting Area!`)
            hasFinishedContestant:FireAllClients(modelCurrent)
            goNextPlayerContestant:FireAllClients(modelCurrent)
            resetCountdowns()
            timerVotingArea:Stop()
        end
    end, true)
end

function StartCountdownEndRound()
    if timerEndGame then timerEndGame:Stop() end
    
    timerEndGame = Timer.new(1, function()
        seconds = countdownEndRound.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        updateUIEndRound:FireAllClients(seconds)
        countdownEndRound.value -= 1

        if countdownEndRound.value <= -1 then
            goLobby:FireAllClients()
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
function self:ClientStart()
    gameManagerObj = self.gameObject:GetComponent(GameManager)

    RF_ShootWhenFinishCustomization.OnInvokeClient = function(message)
        gameManagerObj.UI_Customization.finishedTimerCustomizationPlayers()
        return true;
    end

    updateUILockerRoom:Connect(function(seconds)
        if seconds == 10 then
            gameManagerObj.UI_BeautyContest.SetWaitingPlayersRound('Next match starts in..')
        end
        gameManagerObj.UI_BeautyContest.SetTimerSendPlayerToLockerRoom('00:' .. seconds)
    end)

    goLockerRoom:Connect(function()
        gameManagerObj.UI_BeautyContest.SetWaitingPlayersRound('')
        gameManagerObj.UI_BeautyContest.SetTimerSendPlayerToLockerRoom('')
        gameManagerObj.UI_BeautyContest.EnablePopupThemeContest(true)

        gameManagerObj.TrackingPlayersLobbyScript.RF_SelectNewThemeContest:InvokeServer('', function(response)end)
        gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name] = true
        gameManagerObj.teleportPlayersLockerRoom(
            gameManagerObj.playerCharacter[game.localPlayer.name],
            gameManagerObj.playerWithGameObject[game.localPlayer.name]
        )
        gameManagerObj.sendPlayerLockerRoom:FireServer()
    end)

    updateUIScreenTheme:Connect(function(seconds)
        gameManagerObj.UI_BeautyContest.SetTimerCloseWindowTheme('00:' .. seconds)
    end)

    goPlayerCustomization:Connect(function()
        print(`Is competing: {gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name]}`)
        if gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name] then
            gameManagerObj.UI_BeautyContest.EnablePopupThemeContest(false)
            gameManagerObj.UI_BeautyContest.SetTimerCloseWindowTheme('')
            gameManagerObj.UI_BeautyContest.SetThemeBeautyContest('')
            gameManagerObj.UI_BeautyContest.SetWaitingPlayersRound('LOCKER ROOM')
            
            gameManagerObj.UI_Customization.EnableCustomizationPlayer(true)
            gameManagerObj.UI_Customization.EnablePopupInfoCustomization(true)
        end
    end)

    updateScreenPlayerCustomization:Connect(function(minutes, seconds, valueStart)
        if valueStart == 180 then
            gameManagerObj.UI_Customization.SetThemeBeautyContest(themeSelectedContest.value)
        end
        gameManagerObj.UI_Customization.SetTimerCustomizationPlayer(minutes .. ':' .. seconds)
    end)

    goAreaVoting:Connect(function()
        RF_HasFinishedTimerCustomizationPlayer:InvokeServer('', function(response)end)
    end)

    updateUIVotingArea:Connect(function(seconds)
        gameManagerObj.UI_ConstestVoting.SetTimerForVoting('00:' .. seconds)
    end)

    goNextPlayerContestant:Connect(function(namePlayer)
        playersContestant = gameManagerObj.numberPlayersModeled.value
        playersCurrentContest = gameManagerObj.numberPlayersCurrentContest.value

        if playersContestant < playersCurrentContest and playersCurrentContest > 0 then
            gameManagerObj.sendPlayersToModelingArea(
                gameManagerObj.playerCharacter[gameManagerObj.playerModelingCurrently.value], 
                gameManagerObj.playerWithGameObject[gameManagerObj.playerModelingCurrently.value]
            )

            if game.localPlayer.name == namePlayer then
                gameManagerObj.UI_ConstestVoting.CleanStarsSelecting()
                gameManagerObj.ScorePlayerCompeting.askingIfPlayerHasVoting:FireServer()

                Timer.After(0.15, function()
                    gameManagerObj.VotingZoneScript.eventStartTimerAreaVoting:FireServer()
                end)
            else
                gameManagerObj.UI_ConstestVoting.CleanStarsSelecting()
            end
        end
    end)

    hasFinishedContestant:Connect(function(namePlayer)
        playersContestant = gameManagerObj.numberPlayersModeled.value
        playersCurrentContest = gameManagerObj.numberPlayersCurrentContest.value

        print(`Players Fin concurso: {playersContestant} - {playersCurrentContest}`)
        if playersContestant >= playersCurrentContest and playersCurrentContest > 0 then
            if game.localPlayer.name == gameManagerObj.playerModelingCurrently.value then
                gameManagerObj.ScorePlayerCompeting.askingIfPlayerHasVoting:FireServer()
                gameManagerObj.ScorePlayerCompeting.showScoreBeautyContest:FireServer()
            end
            gameManagerObj.CatwalkContestantsScript.endCatwalkShowLeaderboard()
            gameManagerObj.sendPlayersToModelingArea(
                gameManagerObj.playerCharacter[gameManagerObj.playerModelingCurrently.value], 
                gameManagerObj.playerWithGameObject[gameManagerObj.playerModelingCurrently.value]
            )
        end
    end)

    updateUIEndRound:Connect(function(seconds)
        gameManagerObj.UI_RatingContest.SetTimerEndRound('00:' .. seconds)
    end)

    goLobby:Connect(function()
        gameManagerObj.TrackingPlayersEndRoundScript.ResetAllInformationGame()
    end)
end

function self:ServerStart()
    RF_HasFinishedTimerCustomizationPlayer.OnInvokeServer = function(player)
        if not finishCustomizationSendModelingArea.value then
            RF_ShootWhenFinishCustomization:InvokeClient(
                player, 
                '', 
                function(response)end
            )
            finishCustomizationSendModelingArea.value = true
        end
        return true;
    end

    reactiveTimerScreenTheme:Connect(function(player : Player)
        print(`finishCustomizationSendModelingArea: {finishCustomizationSendModelingArea.value}`)
        StartCountdownCloseWindowTheme()
    end)

    eventResetStopTimers:Connect(function(player : Player)
        resetCountdowns()
    end)
end