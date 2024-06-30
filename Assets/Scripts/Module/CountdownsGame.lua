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
nextPlayerModelingArea = BoolValue.new('NextPlayerModelingArea', false)

-- Countdown end game - return to the lobby
countdownEndRound = IntValue.new('CountdownEndRound', 10)
hasRoundFinished = BoolValue.new('HasRoundFinished', false)

-- Player master
local playerMaster = StringValue.new('PlayerMaster', '')
local updateWhoIsPlayerMaster = BoolValue.new('UpdateWhoIsPlayerMaster', true)

-- Theme Contest
themeSelectedContest = StringValue.new('ThemeSelectedContest', '')

--Remotes Functions Local
local RF_UpdateIfPlayersWentSendToLockerRoom = RemoteFunction.new('UpdateIfPlayersWentSendToLockerRoom')
local RF_UpdateTimerSendPlayersToLockerRoom = RemoteFunction.new('UpdateTimerSendPlayersToLockerRoom')
local RF_HasFinishedTimerWindowTheme = RemoteFunction.new('HasFinishedTimerWindowTheme')
local RF_UpdateTimerWindowTheme = RemoteFunction.new('UpdateTimerWindowTheme')
local RF_HasFinishedTimerCustomizationPlayer = RemoteFunction.new('HasFinishedTimerCustomizationPlayer')
local RF_ShootWhenFinishCustomization = RemoteFunction.new('ShootWhenFinishCustomization')
local RF_UpdateTimerCustomizationPlayer = RemoteFunction.new('UpdateTimerCustomizationPlayer')
local RF_UpdateTimerVotingArea = RemoteFunction.new('UpdateTimerVotingArea')
local RF_UpdateTimerEndRound = RemoteFunction.new('UpdateTimerEndRound')
local RF_EndRound = RemoteFunction.new('EndRound') 
local RF_NextPlayerVoting = RemoteFunction.new('NextPlayerVoting')

--Remotes Functions Global
RF_ResetNextPlayerVoting = RemoteFunction.new('ResetNextPlayerVoting')

-- Select a new master when the master before left contest.
local playersInCompetingClient = Event.new('PlayersInCompetingClient')
local RF_PlayersInCompetingServer = RemoteFunction.new('PlayersInCompetingServer')
RF_SelectNewMasterServer = RemoteFunction.new('SelectNewMasterServer')

local updateUIVotingArea = Event.new('UpdateUIVotingArea')
local goNextPlayerContestant = Event.new('GoNextPlayerContestant')
local hasFinishedContestant = Event.new('HasFinishedContestant')

local playersContestant = nil
local playersCurrentContest = nil

-- Functions
function resetCountdowns()
    playerMaster.value = ''
    updateWhoIsPlayerMaster.value = true
    
    countdownSendPlayersToLockerRoom.value = 10
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
        RF_UpdateTimerSendPlayersToLockerRoom:InvokeServer('', function(response)end)

        if countdownSendPlayersToLockerRoom.value <= 0 then
            RF_UpdateIfPlayersWentSendToLockerRoom:InvokeServer('', function(response)end)
            
            uiManager.SetWaitingPlayersRound('')
            uiManager.SetTimerSendPlayerToLockerRoom('')
            uiManager.EnablePopupThemeContest(true)

            gameManagerObj.TrackingPlayersLobbyScript.RF_SelectNewThemeContest:InvokeServer('', function(response)end)
            gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name] = true
            countdownGame:Stop()
            resetCountdowns()
        end
    end, true)
end

function StartCountdownCloseWindowTheme(uiManager, uiCustomization)
    if timerScreenTheme then timerScreenTheme:Stop() end
    
    timerScreenTheme = Timer.new(1, function()
        seconds = countdownCloseWindowTheme.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerCloseWindowTheme('00:' .. seconds)
        RF_UpdateTimerWindowTheme:InvokeServer('', function(response)end)

        if countdownCloseWindowTheme.value <= 0 then
            if gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name] then
                RF_HasFinishedTimerWindowTheme:InvokeServer('', function(response)end)
                timerScreenTheme:Stop()
                resetCountdowns()
                finishCustomizationSendModelingArea.value = false

                uiManager.EnablePopupThemeContest(false)
                uiManager.SetTimerCloseWindowTheme('')
                uiManager.SetThemeBeautyContest('')
                uiManager.SetWaitingPlayersRound('LOCKER ROOM')
                
                uiCustomization.EnableCustomizationPlayer(true)
                uiCustomization.EnablePopupInfoCustomization(true)
                StartCountdownCustomizationPlayer(uiCustomization)
            end
        end
    end, true)
end

function StartCountdownCustomizationPlayer(uiManager)
    if timerCustomizationClient then timerCustomizationClient:Stop() end
    uiManager.SetThemeBeautyContest(themeSelectedContest.value)

    timerCustomizationClient = Timer.new(1, function()
        minutes = tostring(math.floor(countdownCustomizationPlayer.value / 60))
        seconds = tostring(countdownCustomizationPlayer.value % 60)

        if tonumber(minutes) < 10 then
            minutes = `0{minutes}`
        end

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerCustomizationPlayer(minutes .. ':' .. seconds)
        RF_UpdateTimerCustomizationPlayer:InvokeServer('', function(response)end)

        if countdownCustomizationPlayer.value <= 0 then       
            RF_HasFinishedTimerCustomizationPlayer:InvokeServer('', function(response)end)
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

        if countdownVotingArea.value <= 0 then
            hasFinishedContestant:FireAllClients(modelCurrent)
            goNextPlayerContestant:FireAllClients(modelCurrent)
            resetCountdowns()
            timerVotingArea:Stop()
        end
    end, true)
end

function StartCountdownEndRound(uiManager)
    if timerEndGame then timerEndGame:Stop() end
    
    timerEndGame = Timer.new(1, function()
        seconds = countdownEndRound.value

        if tonumber(seconds) < 10 then
            seconds = `0{seconds}`
        end

        uiManager.SetTimerEndRound('00:' .. seconds)
        RF_UpdateTimerEndRound:InvokeServer('', function(response)end)

        if countdownEndRound.value <= 0 then
            RF_EndRound:InvokeServer('', function(response)end)
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

    playersInCompetingClient:Connect(function()
        if gameManagerObj.playersCurrentlyCompeting[game.localPlayer.name] and updateWhoIsPlayerMaster.value then
            RF_PlayersInCompetingServer:InvokeServer('', function(response)end)
            updateWhoIsPlayerMaster.value = false
        end
    end)

    RF_ShootWhenFinishCustomization.OnInvokeClient = function(message)
        gameManagerObj.UI_Customization.finishedTimerCustomizationPlayers()
        return true;
    end

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

        if playersContestant == playersCurrentContest and playersCurrentContest > 0 then
            gameManagerObj.sendPlayersToModelingArea(
                gameManagerObj.playerCharacter[gameManagerObj.playerModelingCurrently], 
                gameManagerObj.playerWithGameObject[gameManagerObj.playerModelingCurrently]
            )
            gameManagerObj.CatwalkContestantsScript.endCatwalkShowLeaderboard()
        end
    end)
end

function self:ServerStart()
    RF_UpdateIfPlayersWentSendToLockerRoom.OnInvokeServer = function(player)
        playerWentSentToLockerRoom.value = true
        resetCountdowns()
        return true;
    end

    RF_HasFinishedTimerWindowTheme.OnInvokeServer = function(player)
        finishCustomizationSendModelingArea.value = false
        resetCountdowns()
        return true;
    end

    RF_HasFinishedTimerCustomizationPlayer.OnInvokeServer = function(player)
        if not finishCustomizationSendModelingArea.value then
            RF_ShootWhenFinishCustomization:InvokeClient(
                player, 
                '', 
                function(response)end
            )
            finishCustomizationSendModelingArea.value = true
        end

        resetCountdowns()
        return true;
    end

    RF_EndRound.OnInvokeServer = function(player)
        hasRoundFinished.value = true
        resetCountdowns()
        return true;
    end

    RF_UpdateTimerSendPlayersToLockerRoom.OnInvokeServer = function(player)
        selectMainPlayer(playerMaster, player.name, countdownSendPlayersToLockerRoom, updateWhoIsPlayerMaster)
        return true;
    end

    RF_UpdateTimerWindowTheme.OnInvokeServer = function(player)
        selectMainPlayer(playerMaster, player.name, countdownCloseWindowTheme, updateWhoIsPlayerMaster)
        return true;
    end

    RF_UpdateTimerCustomizationPlayer.OnInvokeServer = function(player)
        selectMainPlayer(playerMaster, player.name, countdownCustomizationPlayer, updateWhoIsPlayerMaster)
        return true;
    end

    RF_UpdateTimerVotingArea.OnInvokeServer = function(player)
        selectMainPlayer(playerMaster, player.name, countdownVotingArea, updateWhoIsPlayerMaster)
        return true;
    end

    RF_UpdateTimerEndRound.OnInvokeServer = function(player)
        selectMainPlayer(playerMaster, player.name, countdownEndRound, updateWhoIsPlayerMaster)
        return true;
    end

    RF_SelectNewMasterServer.OnInvokeServer = function(player, statusPlayer)
        if playerMaster.value == player.name or statusPlayer == 'PlayerLeftGame' then
            playerMaster.value = ''
            updateWhoIsPlayerMaster.value = true
            playersInCompetingClient:FireAllClients()
        end
        return true;
    end

    RF_PlayersInCompetingServer.OnInvokeServer = function(player)
        selectMainPlayer(playerMaster, player.name, countdownCloseWindowTheme, updateWhoIsPlayerMaster)
        return true
    end
end