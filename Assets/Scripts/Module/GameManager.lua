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
local cameraLockerRoom : GameObject = nil
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
--!SerializeField
local naveMeshLockerRoom : GameObject = nil

-- Network Values Global
numberPlayersCurrentContest = IntValue.new('NumberPlayersCurrentContest', 0)
numberPlayersModeled = IntValue.new('NumberPlayersModeled', 0)
numPlayersFinishCustomization = IntValue.new('NumPlayersFinishCustomization', 0)
playerModelingCurrently = StringValue.new('PlayerModelingCurrently', '')
numberPlayersSendModelingArea = IntValue.new('NumberPlayersSendModelingArea', 0)
startingAvatarContest = BoolValue.new('StartingAvatarContest', false)
hasBeenSentNewAvatarCatwalk = BoolValue.new('HasBeenSentNewAvatarCatwalk', false)

-- Events Local
local showUIVotingClient = Event.new('ShowUIVotingClient')
local sendAvatarToBackstageClient = Event.new('SendAvatarToBackstageClient')
local returnAllPlayersToTheLobby = Event.new('ReturnAllPlayersToTheLobby')
local sendPlayersLockerRoomClient = Event.new('SendPlayersLockerRoomClient')

--Events Global
sendPlayerModelingAreaClient = Event.new('SendPlayerModelingAreaClient')
sendPlayerBackstageContestClient = Event.new('SendPlayerBackstageContestClient')
noThereAreEnoughPlayersInContest = Event.new('NoThereAreEnoughPlayersInContest')
sendPlayerLockerRoom = Event.new('SendPlayerLockerRoom')
eventCleanDataClient = Event.new('CleanDataClient')
playerLeftNextAvatarModel = Event.new('PlayerLeftNextAvatarModel')
newAvatarToTheCatwalk = Event.new('NewAvatarToTheCatwalk')
newAvatarToTheCatwalkClient = Event.new('NewAvatarToTheCatwalkClient')

-- Remote Functions Global
RF_UpdateNumPlayersCurrentContest = RemoteFunction.new('UpdateNumPlayersCurrentContest')

-- Remote Functions Locals
local RF_ShowUIVotingServer = RemoteFunction.new('ShowUIVotingServer')
local RF_UpdateNumPlayersFinishCustomization = RemoteFunction.new('UpdateNumPlayersFinishCustomization')
local RF_SendAvatarToBackstageServer = RemoteFunction.new('SendAvatarToBackstageServer')

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
cameraLockerRoomGlobal = nil
cameraModelingGlobal = nil
naveMeshGameGlobal = nil
naveMeshCatwalkGlobal = nil
naveMeshLockerRoomGlobal = nil
playerWithGameObject = {} -- Saving the gameObject of each player
playerCharacter = {} -- Saving the gameObject of each player
playersCurrentlyCompeting = {}
spectatorsWaitingVoting = {}
playersAlreadyModeling = {}

-- UIs
UI_Customization = nil
UI_EndCustomization = nil
UI_BeautyContest = nil
UI_ConstestVoting = nil
UI_RatingContest = nil
UI_PopupConfirmation = nil

--Countdowns
local countdownGameObj = nil

--Fucntions
function resetAllData()
    numberPlayersSendModelingArea.value = 0
    startingAvatarContest.value = false
    numberPlayersCurrentContest.value = 0
    numberPlayersModeled.value = 0
    numPlayersFinishCustomization.value = 0
    hasBeenSentNewAvatarCatwalk.value = false

    playersCurrentlyCompeting = {}
    playersAlreadyModeling = {}
    spectatorsWaitingVoting = {}
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

function teleportPlayersLockerRoom(character : Character, objCharacter : GameObject)
    if character == nil or objCharacter == nil then return end
    if tostring(objCharacter.transform) == 'null' then return end
    
    objCharacter.transform:SetLocalPositionAndRotation(
        pointRespawnLockerRoom.transform.position, 
        Quaternion.Euler(0, 0, 0)
    )
    character:Teleport(pointRespawnLockerRoom.transform.position, function()end)
    navMeshGame:SetActive(false)
    naveMeshLockerRoom:SetActive(true)
    naveMeshCatwalk:SetActive(false)
    mainCamera:SetActive(false)
    cameraLockerRoom:SetActive(true)
    character.transform:LookAt(cameraLockerRoom.transform.position)
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

    --print(`Char: {character} - OBJ: {objCharacter}`)
    --[[ objCharacter.transform:SetLocalPositionAndRotation(
        pointRespawnModelingArea.transform.position, 
        Quaternion.Euler(0, 0, 0)
    ) ]]
    objCharacter.transform.position = pointRespawnModelingArea.transform.position
    character:Teleport(pointRespawnModelingArea.transform.position, function()end)
    character.transform:LookAt(cameraModeling.transform.position)
    --print(`{pointRespawnModelingArea.transform.position} - {objCharacter.transform.position}`)
end

function resetAllGameManager(player, namePlayer)
    playerWithGameObject[namePlayer] = nil
    playerCharacter[namePlayer] = nil
    playersCurrentlyCompeting[namePlayer] = nil
    if numberPlayersCurrentContest.value > 0 then numberPlayersCurrentContest.value -= 1 end
    if numberPlayersSendModelingArea.value > 0 then numberPlayersSendModelingArea.value -= 1 end
    if numPlayersFinishCustomization.value > 0 then numPlayersFinishCustomization.value -= 1 end
    
    if playersAlreadyModeling[namePlayer] then
        if numberPlayersModeled.value > 0 then numberPlayersModeled.value -= 1 end
        playersAlreadyModeling[namePlayer] = nil

        if numberPlayersModeled.value == numberPlayersCurrentContest.value or numberPlayersCurrentContest.value == 1 then
            returnAllPlayersToTheLobby:FireAllClients()
        end
        
        playerLeftNextAvatarModel:FireAllClients(namePlayer)
    else
        if numberPlayersCurrentContest.value == 1 then
            noThereAreEnoughPlayersInContest:FireAllClients()
        end
    end
end

--Unity Functions
function self:ClientAwake()
    pointRespawnLobbyGlobal = pointRespawnLobby
    UIManagerGlobal = uiManager
    mainCameraGlobal = mainCamera
    cameraModelingGlobal = cameraModeling
    cameraLockerRoomGlobal = cameraLockerRoom
    naveMeshGameGlobal = navMeshGame
    naveMeshCatwalkGlobal = naveMeshCatwalk
    naveMeshLockerRoomGlobal = naveMeshLockerRoom

    UI_Customization = uiManager:GetComponent(UI_Customization_Model)
    UI_EndCustomization = uiManager:GetComponent(UI_Screen_Waiting_EndCustomization)
    UI_ConstestVoting = uiManager:GetComponent(UI_Contest_Voting)
    UI_BeautyContest = uiManager:GetComponent(UI_Beauty_Pageant)
    UI_RatingContest = uiManager:GetComponent(UI_Rating_Contest)
    UI_PopupConfirmation = uiManager:GetComponent(Pop_up_Confirmation)

    countdownGameObj = self.gameObject:GetComponent(CountdownsGame)
    ScorePlayerCompeting = self.gameObject:GetComponent(GetScorePlayerCompeting)
    TrackingPlayersLobbyScript = self.gameObject:GetComponent(TrackingPlayersLobby)
    TrackingPlayersEndRoundScript = self.gameObject:GetComponent(TrackingPlayersEndRound)
    CatwalkContestantsScript = self.gameObject:GetComponent(CatwalkContestants)
    VotingZoneScript = self.gameObject:GetComponent(VotingZone)

    showUIVotingClient:Connect(function()
        if playersCurrentlyCompeting[game.localPlayer.name] then --or spectatorsWaitingVoting[game.localPlayer.name]
            UI_BeautyContest.SetWaitingPlayersRound('Voting Area!')
            UI_Customization.SettingStart()
            UI_Customization.StopCurrentTimerPlaying()
            UI_EndCustomization.SettingStart()
            UI_ConstestVoting.EnableContestVoting(true)

            sendPlayersToModelingArea(game.localPlayer.character, game.localPlayer.character.gameObject)
            RF_SendAvatarToBackstageServer:InvokeServer(game.localPlayer, function(response)end)
            navMeshGame:SetActive(false)
            naveMeshLockerRoom:SetActive(false)
            naveMeshCatwalk:SetActive(true)
            cameraLockerRoom:SetActive(false)
            cameraModeling:SetActive(true)
        end
    end)

    sendPlayersLockerRoomClient:Connect(function(namePlayer)
        if game.localPlayer.name ~= namePlayer then
            teleportPlayersLockerRoom(playerCharacter[namePlayer], playerWithGameObject[namePlayer])
        end
    end)
    
    sendAvatarToBackstageClient:Connect(function(namePlayer)
        if playersCurrentlyCompeting[game.localPlayer.name] then
            sendPlayersToModelingArea(playerCharacter[namePlayer], playerWithGameObject[namePlayer])
        end
    end)

    sendPlayerModelingAreaClient:Connect(function(namePlayer)
        if not playerCharacter[namePlayer] or not playerWithGameObject[namePlayer] then return end
        local isCompeting = playersCurrentlyCompeting[game.localPlayer.name]
        local isSpectator = spectatorsWaitingVoting[game.localPlayer.name]
        
        --print(`Is Spectator Client: {isSpectator} - {game.localPlayer.name} - `)
        if isSpectator then
            UI_BeautyContest.SetWaitingPlayersRound('Voting Area!')
            UI_BeautyContest.EnableSpectatorModeLobby(false)
            UI_Customization.SettingStart()
            UI_Customization.StopCurrentTimerPlaying()
            UI_EndCustomization.SettingStart()
            UI_PopupConfirmation.SettingStartGame()
            UI_PopupConfirmation.SetStatusPopupConfirmation(false)
            UI_ConstestVoting.EnableContestVoting(true)

            cameraLockerRoom:SetActive(false)
            cameraModeling:SetActive(true)
        end

        sendPlayerModelingArea(playerCharacter[namePlayer], playerWithGameObject[namePlayer])
        UI_ConstestVoting.SetNamePlayerContestant(namePlayer)
        
        if game.localPlayer.name == namePlayer then
            UI_ConstestVoting.SetPlayerVotingStatus(false)
        elseif game.localPlayer.name ~= namePlayer and (isCompeting or isSpectator) then
            UI_ConstestVoting.SetPlayerVotingStatus(true)
        end
    end)

    returnAllPlayersToTheLobby:Connect(function()
        if not CatwalkContestantsScript then return end
        CatwalkContestantsScript.endCatwalkShowLeaderboard()
    end)

    noThereAreEnoughPlayersInContest:Connect(function()
        TrackingPlayersEndRoundScript.ResetAllInformationGame()
    end)

    eventCleanDataClient:Connect(function(namePlayer)
        playersCurrentlyCompeting[namePlayer] = nil
    end)
    
    playerLeftNextAvatarModel:Connect(function(namePlayer)
        if numberPlayersModeled.value < numberPlayersCurrentContest.value and numberPlayersCurrentContest.value > 0 then
            UI_ConstestVoting.CleanStarsSelecting()
            newAvatarToTheCatwalk:FireServer(namePlayer)
        end
    end)

    newAvatarToTheCatwalkClient:Connect(function(namePlayer)
        VotingZoneScript.eventStartTimerAreaVoting:FireServer()
        countdownGameObj.eventResetStopTimers:FireServer()
        ScorePlayerCompeting.cleanInfoLeaderboardPlayerLeftGame:FireServer(namePlayer)
        --print(`Player left: {namePlayer}`)
    end)
end

function self:ServerAwake()
    sendPlayerLockerRoom:Connect(function(player : Player)
        sendPlayersLockerRoomClient:FireAllClients(player.name)
    end)

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
        playersCurrentlyCompeting[player.name] = nil

        if numberPlayersCurrentContest.value > 0 then numberPlayersCurrentContest.value -= 1 end
        if numberPlayersSendModelingArea.value > 0 then numberPlayersSendModelingArea.value -= 1 end
        if numPlayersFinishCustomization.value > 0 then numPlayersFinishCustomization.value -= 1 end

        if numberPlayersCurrentContest.value == 1 then
            noThereAreEnoughPlayersInContest:FireAllClients()
        end

        eventCleanDataClient:FireClient(player, player.name)
        return true
    end

    newAvatarToTheCatwalk:Connect(function(player : Player, namePlayer)
        --print(`Has been sent: {hasBeenSentNewAvatarCatwalk.value} - {player.name}`)
        if not hasBeenSentNewAvatarCatwalk.value then
            newAvatarToTheCatwalkClient:FireClient(player, namePlayer)
            hasBeenSentNewAvatarCatwalk.value = true
        end
    end)

    server.PlayerDisconnected:Connect(function(player : Player)
        resetAllGameManager(player, player.name)
        eventCleanDataClient:FireClient(player, player.name)
    end)
end

scene.PlayerJoined:Connect(function(scene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        playerWithGameObject[player.name] = character.gameObject
        playerCharacter[player.name] = character
    end)
end)