--Points of the respawn - Room
--!Header("Respawn points")
--!SerializeField
local pointRespawnLobby : GameObject = nil
--!SerializeField
local pointRespawnLockerRoom : GameObject = nil
--!SerializeField
local pointRespawnZoneVoting : GameObject = nil
--!SerializeField
local pointRespawnModelingArea : GameObject = nil

-- Cameras
--!Header("Cameras")
--!SerializeField
local mainCamera : GameObject = nil
--!SerializeField
local cameraModeling : GameObject = nil

-- UI
--!Header("UI")
--!SerializeField
local uiManager : GameObject = nil

--!Header("NavMesh")
--!SerializeField
local navMeshGame : GameObject = nil 
--!SerializeField
local naveMeshCatwalk : GameObject = nil

-- Network Values Global
numberPlayersCurrentContest = IntValue.new('NumberPlayersCurrentContest', 0)
numberPlayersModeled = IntValue.new('NumberPlayersModeled', 0)
numPlayersFinishCustomization = IntValue.new('NumPlayersFinishCustomization', 0)
playerModelingCurrently = StringValue.new('PlayerModelingCurrently', '')
canAskIfPlayerHasVoting = BoolValue.new('CanAskIfPlayerHasVoting', false)

-- Network Values local
numberPlayersSendModelingArea = IntValue.new('NumberPlayersSendModelingArea', 0)
startingAvatarContest = BoolValue.new('StartingAvatarContest', false)
local playerDisconnected = BoolValue.new('PlayerDisconnected', false)

-- Events Local
local showUIVotingClient = Event.new('ShowUIVotingClient')
local sendAvatarToBackstageClient = Event.new('SendAvatarToBackstageClient')
local mustSelectPlayerMasterTimerPlayerDisconnected = Event.new('SelectPlayerMasterTimerPlayerDisconnected')
local returnAllPlayersToTheLobby = Event.new('ReturnAllPlayersToTheLobby')

--Events Global
sendPlayerModelingAreaClient = Event.new('SendPlayerModelingAreaClient')
sendPlayerBackstageContestClient = Event.new('SendPlayerBackstageContestClient')
noThereAreEnoughPlayersInContest = Event.new('NoThereAreEnoughPlayersInContest')

-- Remote Functions Global
RF_GoNextPlayerContest = RemoteFunction.new('GoNextPlayerContest')
RF_UpdateNumPlayersCurrentContest = RemoteFunction.new('UpdateNumPlayersCurrentContest')

-- Remote Functions Locals
local RF_ShowUIVotingServer = RemoteFunction.new('ShowUIVotingServer')
local RF_UpdateNumPlayersFinishCustomization = RemoteFunction.new('UpdateNumPlayersFinishCustomization')
local RF_SendAvatarToBackstageServer = RemoteFunction.new('SendAvatarToBackstageServer')
local RF_CanSelectPlayerMasterTimer = RemoteFunction.new('SelectPlayerMasterTimer')
local RF_UpdateIfPlayerDisconnected = RemoteFunction.new('UpdateIfPlayerDisconnected')

-- Global Variables
gameObjectManager = self.gameObject
UIManagerGlobal = nil
ScorePlayerCompeting = nil
TrackingPlayersLobbyScript = nil
TrackingPlayersEndRoundScript = nil
CatwalkContestantsScript = nil
VotingZoneScript = nil
pointRespawnLobbyGlobal = nil
mainCameraGlobal = nil
cameraModelingGlobal = nil
naveMeshGameGlobal = nil
naveMeshCatwalkGlobal = nil
playerWithGameObject = {} -- Saving the gameObject of each player
playerCharacter = {} -- Saving the gameObject of each player
playersCurrentlyCompeting = {}

-- Local Variables
playersAlreadyModeling = {}

-- UIs
UI_Customization = nil
UI_EndCustomization = nil
UI_BeautyContest = nil
UI_ConstestVoting = nil
UI_RatingContest = nil

--Countdowns
local countdownGameObj = nil

--Fucntions
function resetAllData()
    numberPlayersSendModelingArea.value = 0
    startingAvatarContest.value = false
    numberPlayersCurrentContest.value = 0
    numberPlayersModeled.value = 0
    numPlayersFinishCustomization.value = 0

    playersCurrentlyCompeting = {}
    playersAlreadyModeling = {}
end

function updateNumPlayersFinish()
    RF_UpdateNumPlayersFinishCustomization:InvokeServer('', function(response)
        if response then
            UI_Customization.ShowUIFinishPlayerCustomization()
        end
    end)
end

function showUIVotingAllPlayers()
    RF_ShowUIVotingServer:InvokeServer('', function(response)end)
end

function sendPlayersToModelingArea(character : Character, objCharacter : GameObject)
    if character == nil or objCharacter == nil then return end
    if tostring(objCharacter.transform) == 'null' then return end
    
    objCharacter.transform:SetLocalPositionAndRotation(
        pointRespawnZoneVoting.transform.position, 
        Quaternion.Euler(0, 0, 0)
    )
    character:Teleport(pointRespawnZoneVoting.transform.position, function()end)
end

function sendPlayerModelingArea(character : Character, objCharacter : GameObject)
    if character == nil or objCharacter == nil then return end
    if tostring(objCharacter.transform) == 'null' then return end

    objCharacter.transform:SetLocalPositionAndRotation(
        pointRespawnModelingArea.transform.position, 
        Quaternion.Euler(0, 0, 0)
    )
    character:Teleport(pointRespawnModelingArea.transform.position, function()end)
    character.transform:LookAt(cameraModeling.transform.position)
end

function resetAllGameManager(player, namePlayer)
    playerWithGameObject[namePlayer] = nil
    playerCharacter[namePlayer] = nil
    playersCurrentlyCompeting[namePlayer] = nil
    if numberPlayersCurrentContest.value > 0 then numberPlayersCurrentContest.value -= 1 end
    if numberPlayersSendModelingArea.value > 0 then numberPlayersSendModelingArea.value -= 1 end
    playerDisconnected.value = false

    print(`Name: {namePlayer} - Modeled: {playersAlreadyModeling[namePlayer]}`)
    if playersAlreadyModeling[namePlayer] then
        if numberPlayersModeled.value > 0 then numberPlayersModeled.value -= 1 end
        playersAlreadyModeling[namePlayer] = nil
        
        if numberPlayersModeled.value == numberPlayersCurrentContest.value or numberPlayersCurrentContest.value == 1 then
            returnAllPlayersToTheLobby:FireAllClients()
        end

        sendPlayersToModelingArea(
            playerCharacter[namePlayer], 
            playerWithGameObject[namePlayer]
        )
    else
        if numberPlayersCurrentContest.value == 1 then
            noThereAreEnoughPlayersInContest:FireAllClients()
        end
    end

    mustSelectPlayerMasterTimerPlayerDisconnected:FireAllClients(namePlayer)
end

--Unity Functions
function self:ClientAwake()
    pointRespawnLobbyGlobal = pointRespawnLobby
    UIManagerGlobal = uiManager
    mainCameraGlobal = mainCamera
    cameraModelingGlobal = cameraModeling
    naveMeshGameGlobal = navMeshGame
    naveMeshCatwalkGlobal = naveMeshCatwalk

    UI_Customization = uiManager:GetComponent(UI_Customization_Model)
    UI_EndCustomization = uiManager:GetComponent(UI_Screen_Waiting_EndCustomization)
    UI_ConstestVoting = uiManager:GetComponent(UI_Contest_Voting)
    UI_BeautyContest = uiManager:GetComponent(UI_Beauty_Pageant)
    UI_RatingContest = uiManager:GetComponent(UI_Rating_Contest)

    countdownGameObj = self.gameObject:GetComponent(CountdownsGame)
    ScorePlayerCompeting = self.gameObject:GetComponent(GetScorePlayerCompeting)
    TrackingPlayersLobbyScript = self.gameObject:GetComponent(TrackingPlayersLobby)
    TrackingPlayersEndRoundScript = self.gameObject:GetComponent(TrackingPlayersEndRound)
    CatwalkContestantsScript = self.gameObject:GetComponent(CatwalkContestants)
    VotingZoneScript = self.gameObject:GetComponent(VotingZone)

    showUIVotingClient:Connect(function()
        if playersCurrentlyCompeting[game.localPlayer.name] then
            UI_BeautyContest.SetWaitingPlayersRound('Voting Area!')
            UI_Customization.SettingStart()
            UI_Customization.StopCurrentTimerPlaying()
            UI_EndCustomization.SettingStart()
            UI_ConstestVoting.EnableContestVoting(true)

            sendPlayersToModelingArea(game.localPlayer.character, game.localPlayer.character.gameObject)
            RF_SendAvatarToBackstageServer:InvokeServer(game.localPlayer, function(response)end)
            navMeshGame:SetActive(false)
            naveMeshCatwalk:SetActive(true)
            mainCamera:SetActive(false)
            cameraModeling:SetActive(true)
        end
    end)
    
    sendAvatarToBackstageClient:Connect(function(namePlayer)
        if playersCurrentlyCompeting[game.localPlayer.name] then
            sendPlayersToModelingArea(playerCharacter[namePlayer], playerWithGameObject[namePlayer])
        end
    end)

    sendPlayerModelingAreaClient:Connect(function(namePlayer)
        if not playerCharacter[namePlayer] or not playerWithGameObject[namePlayer] then return end
        
        sendPlayerModelingArea(playerCharacter[namePlayer], playerWithGameObject[namePlayer])
        UI_ConstestVoting.SetNamePlayerContestant(namePlayer)
        
        if game.localPlayer.name == namePlayer then
            UI_ConstestVoting.SetPlayerVotingStatus(false)
        elseif game.localPlayer.name ~= namePlayer and playersCurrentlyCompeting[game.localPlayer.name] then
            UI_ConstestVoting.SetPlayerVotingStatus(true)
        end
    end)

    RF_CanSelectPlayerMasterTimer.OnInvokeClient = function()
        playersCurrentlyCompeting[game.localPlayer.name] = nil
        countdownGameObj.RF_SelectNewMasterServer:InvokeServer('', function(response)end)
        return true;
    end

    mustSelectPlayerMasterTimerPlayerDisconnected:Connect(function(namePlayer)
        if not playerDisconnected.value then
            countdownGameObj.RF_SelectNewMasterServer:InvokeServer('PlayerLeftGame', function(response)end)
            RF_UpdateIfPlayerDisconnected:InvokeServer(game.localPlayer, function(response)end)
            playersCurrentlyCompeting[namePlayer] = nil
            playerDisconnected.value = true
        end
    end)

    returnAllPlayersToTheLobby:Connect(function()
        if not CatwalkContestantsScript then return end
        CatwalkContestantsScript.endCatwalkShowLeaderboard()
    end)

    noThereAreEnoughPlayersInContest:Connect(function()
        TrackingPlayersEndRoundScript.ResetAllInformationGame()
    end)
end

function self:ServerStart()
    RF_UpdateNumPlayersFinishCustomization.OnInvokeServer = function ()
        numPlayersFinishCustomization.value += 1
        return true
    end

    RF_ShowUIVotingServer.OnInvokeServer = function()
        showUIVotingClient:FireAllClients()
        return true
    end

    RF_SendAvatarToBackstageServer.OnInvokeServer = function(player)
        numberPlayersSendModelingArea.value += 1
        sendAvatarToBackstageClient:FireAllClients(player.name)
        return true
    end

    RF_UpdateNumPlayersCurrentContest.OnInvokeServer = function(player)
        numberPlayersCurrentContest.value -= 1
        playersCurrentlyCompeting[player.name] = nil
        RF_CanSelectPlayerMasterTimer:InvokeClient(
            player, 
            '', 
            function(response)end
        )
        return true
    end

    RF_UpdateIfPlayerDisconnected.OnInvokeServer = function(player)
        playerDisconnected.value = true
        return true
    end

    server.PlayerDisconnected:Connect(function(player : Player)
        resetAllGameManager(player, player.name)
    end)
end

scene.PlayerJoined:Connect(function(scene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        playerWithGameObject[player.name] = character.gameObject
        playerCharacter[player.name] = character
    end)
end)