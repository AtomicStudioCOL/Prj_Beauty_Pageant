--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--Event
local resetAllVariablesServer = Event.new('ResetAllVariablesServer')
local updateAllPlayersSendLobbyServer = Event.new('UpdateAllPlayersSendLobbyServer')
local updateAllPlayersSendLobbyClient = Event.new('UpdateAllPlayersSendLobbyClient')

--Functions
function sendPlayersToLobby(character : Character, objCharacter : GameObject)
    objCharacter.transform.position = gameManager.pointRespawnLobbyGlobal.transform.position
    character:MoveTo(gameManager.pointRespawnLobbyGlobal.transform.position, 6, function()end)
end

--Unity functions
function self:ClientAwake()
    updateAllPlayersSendLobbyClient:Connect(function(namePlayer)
        if namePlayer ~= game.localPlayer.name then
            sendPlayersToLobby(gameManager.previousPlayers[namePlayer], gameManager.playerWithGameObject[namePlayer])
        end
    end)
end

function self:ClientUpdate()
    if countdownsGame.hasRoundFinished.value then
        --Change camera
        gameManager.mainCameraGlobal:SetActive(true)
        gameManager.cameraModelingGlobal:SetActive(false)
        
        --Reset all UIs
        gameManager.UI_BeautyContest.SettingStartUI()
        gameManager.UI_ConstestVoting.SettingStart()
        gameManager.UI_Customization.SettingStart()
        gameManager.UI_EndCustomization.SettingStart()
        gameManager.UI_RatingContest.StartSetting()

        --Return all players to the lobby
        sendPlayersToLobby(game.localPlayer.character, game.localPlayer.character.gameObject)
        updateAllPlayersSendLobbyServer:FireServer()

        --Reset all variables
        gameManager.TrackingPlayersLobbyScript.hasStartedCountdownSendPlayersLockerRoom.value = false
        gameManager.amountPlayersLobby.value = 0
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
        countdownsGame.selectThemeBeautyContest.value = false
        countdownsGame.nextPlayerModelingArea.value = false
        countdownsGame.hasRoundFinished.value = false
        countdownsGame.resetCountdowns()

        resetAllVariablesServer:FireServer()

        --Setting Game
        gameManager.TrackingPlayersLobbyScript.settingLobbyPlayer()

        countdownsGame.hasRoundFinished.value = false
    end
end

function self:ServerAwake()
    resetAllVariablesServer:Connect(function(player : Player)
        gameManager.amountPlayersLobby.value = 0
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
        countdownsGame.selectThemeBeautyContest.value = false
        countdownsGame.nextPlayerModelingArea.value = false
        countdownsGame.hasRoundFinished.value = false
        countdownsGame.resetCountdowns()
    end)

    updateAllPlayersSendLobbyServer:Connect(function(player : Player)
        updateAllPlayersSendLobbyClient:FireAllClients(player.name)
    end)
end