--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--Event local
local resetAllVariablesServer = Event.new('ResetAllVariablesServer')
local updateAllPlayersSendLobbyServer = Event.new('UpdateAllPlayersSendLobbyServer')
local updateAllPlayersSendLobbyClient = Event.new('UpdateAllPlayersSendLobbyClient')

--Functions
function sendPlayersToLobby(character : Character, objCharacter : GameObject)
    objCharacter.transform.position = gameManager.pointRespawnLobbyGlobal.transform.position
    character:MoveTo(gameManager.pointRespawnLobbyGlobal.transform.position, 6, function()end)
end

function SettingStart()
    --Change camera
    gameManager.naveMeshGameGlobal:SetActive(true)
    gameManager.naveMeshCatwalkGlobal:SetActive(false)
    gameManager.mainCameraGlobal:SetActive(true)
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
end

function StartingResetAllVariables()
    --Reset all variables
    gameManager.resetAllData()

    countdownsGame.playerWentSentToLockerRoom.value = false
    countdownsGame.nextPlayerModelingArea.value = false
    countdownsGame.hasRoundFinished.value = false
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

function self:ClientUpdate()
    if countdownsGame.hasRoundFinished.value then
        ResetAllInformationGame()
        countdownsGame.hasRoundFinished.value = false
    end
end

function self:ServerStart()
    resetAllVariablesServer:Connect(function(player : Player)
        StartingResetAllVariables()
    end)

    updateAllPlayersSendLobbyServer:Connect(function(player : Player)
        updateAllPlayersSendLobbyClient:FireAllClients(player.name)
    end)
end