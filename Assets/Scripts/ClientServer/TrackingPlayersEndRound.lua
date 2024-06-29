--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--Event
local resetAllVariablesServer = Event.new('ResetAllVariablesServer')
local updateAllPlayersSendLobbyServer = Event.new('UpdateAllPlayersSendLobbyServer')
local updateAllPlayersSendLobbyClient = Event.new('UpdateAllPlayersSendLobbyClient')
local onePlayerInCompeting = Event.new('onePlayerInCompeting')

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
    --gameManager.amountPlayersLobby.value = 0
    gameManager.hasStartedRound.value = false
    gameManager.numberPlayersCurrentContest.value = 0
    gameManager.numberPlayersSendModelingArea.value = 0
    gameManager.numberPlayersModeled.value = 0
    gameManager.numPlayersFinishCustomization.value = 0
    gameManager.startingAvatarContest.value = false
    gameManager.playerModelingCurrently.value = ''
    gameManager.playersCurrentlyCompeting = {}
    gameManager.playersAlreadyModeling = {}

    countdownsGame.playerWentSentToLockerRoom.value = false
    countdownsGame.nextPlayerModelingArea.value = false
    countdownsGame.hasRoundFinished.value = false
    countdownsGame.resetCountdowns()
end

--Unity functions
function self:ClientAwake()
    updateAllPlayersSendLobbyClient:Connect(function(namePlayer)
        if namePlayer ~= game.localPlayer.name then
            sendPlayersToLobby(gameManager.previousPlayers[namePlayer], gameManager.playerWithGameObject[namePlayer])
        end
    end)

    onePlayerInCompeting:Connect(function()
        SettingStart()
        StartingResetAllVariables()
        sendPlayersToLobby(game.localPlayer.character, game.localPlayer.character.gameObject)
        updateAllPlayersSendLobbyServer:FireServer()
    end)
end

function self:ClientUpdate()
    if countdownsGame.hasRoundFinished.value then
        SettingStart()

        --Return all players to the lobby
        sendPlayersToLobby(game.localPlayer.character, game.localPlayer.character.gameObject)
        updateAllPlayersSendLobbyServer:FireServer()

        StartingResetAllVariables()
        resetAllVariablesServer:FireServer()

        countdownsGame.hasRoundFinished.value = false
    end
end

function self:ServerAwake()
    resetAllVariablesServer:Connect(function(player : Player)
        StartingResetAllVariables()
    end)

    updateAllPlayersSendLobbyServer:Connect(function(player : Player)
        updateAllPlayersSendLobbyClient:FireAllClients(player.name)
    end)
end

function self:ServerUpdate()
    if gameManager.numberPlayersCurrentContest.value == 1 then
        StartingResetAllVariables()
        onePlayerInCompeting:FireAllClients()
    end
end