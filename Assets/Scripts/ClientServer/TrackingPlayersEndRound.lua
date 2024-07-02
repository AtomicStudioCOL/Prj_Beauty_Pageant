--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--Event local
local resetAllVariablesServer = Event.new('ResetAllVariablesServer')
local updateAllPlayersSendLobbyClient = Event.new('UpdateAllPlayersSendLobbyClient')

--Event global
updateAllPlayersSendLobbyServer = Event.new('UpdateAllPlayersSendLobbyServer')

--Functions
function sendPlayersToLobby(character : Character, objCharacter : GameObject)
    objCharacter.transform.position = gameManager.pointRespawnLobbyGlobal.transform.position
    character:MoveTo(gameManager.pointRespawnLobbyGlobal.transform.position, 6, function()end)
end

function SettingStart()
    --Change camera
    gameManager.naveMeshGameGlobal:SetActive(true)
    gameManager.naveMeshLockerRoomGlobal:SetActive(false)
    gameManager.naveMeshCatwalkGlobal:SetActive(false)
    gameManager.mainCameraGlobal:SetActive(true)
    gameManager.cameraLockerRoomGlobal:SetActive(false)
    gameManager.cameraModelingGlobal:SetActive(false)
    
    --Reset all UIs
    gameManager.UI_BeautyContest.SettingStartUI()
    gameManager.UI_ConstestVoting.SettingStart()
    gameManager.UI_Customization.SettingStart()
    gameManager.UI_EndCustomization.SettingStart()
    gameManager.UI_RatingContest.StartSetting()

    --Reset all variables
    gameManager.TrackingPlayersLobbyScript.hasStartedCountdownSendPlayersLockerRoom.value = false
    gameManager.TrackingPlayersLobbyScript.settingLobbyPlayer()
    gameManager.ScorePlayerCompeting.resetAllData()
    gameManager.ScorePlayerCompeting.eventResetAllData:FireServer()
end

function StartingResetAllVariables()
    --Reset all variables
    gameManager.resetAllData()

    countdownsGame.playerWentSentToLockerRoom.value = false
    countdownsGame.resetCountdowns()
end

function ResetAllInformationGame()
    StartingResetAllVariables()
    resetAllVariablesServer:FireServer()
    SettingStart()

    --Return all players to the lobby
    sendPlayersToLobby(game.localPlayer.character, game.localPlayer.character.gameObject)
    updateAllPlayersSendLobbyServer:FireServer()
end

--Unity functions
function self:ClientStart()
    updateAllPlayersSendLobbyClient:Connect(function(namePlayer)
        if namePlayer ~= game.localPlayer.name then
            sendPlayersToLobby(gameManager.playerCharacter[namePlayer], gameManager.playerWithGameObject[namePlayer])
        end
    end)
end

function self:ServerStart()
    resetAllVariablesServer:Connect(function(player : Player)
        StartingResetAllVariables()
    end)

    updateAllPlayersSendLobbyServer:Connect(function(player : Player)
        updateAllPlayersSendLobbyClient:FireAllClients(player.name)
    end)
end