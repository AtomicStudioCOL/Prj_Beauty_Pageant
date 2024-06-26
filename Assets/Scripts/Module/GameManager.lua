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

-- Network Values
amountPlayersLobby = IntValue.new('AmountPlayersLobby', 0)
hasStartedRound = BoolValue.new('HasStartedRound', false)
numberPlayersCurrentContest = IntValue.new('NumberPlayersCurrentContest', 0)
numberPlayersSendModelingArea = IntValue.new('NumberPlayersSendModelingArea', 0)
numberPlayersModeled = IntValue.new('NumberPlayersModeled', 0)
numPlayersFinishCustomization = IntValue.new('NumPlayersFinishCustomization', 0)
startingAvatarContest = BoolValue.new('StartingAvatarContest', false)
playerModelingCurrently = StringValue.new('PlayerModelingCurrently', '')
local playerDisconnected = BoolValue.new('PlayerDisconnected', false)

-- Events
local showUIVotingClient = Event.new('ShowUIVotingClient')
local showUIVotingServer = Event.new('ShowUIVotingServer')
local updateNumPlayersFinishCustomization = Event.new('UpdateNumPlayersFinishCustomization')
local showUIAfterCustomization = Event.new('ShowUIAfterCustomization')
local sendAvatarToBackstageServer = Event.new('SendAvatarToBackstageServer')
local sendAvatarToBackstageClient = Event.new('SendAvatarToBackstageClient')
local sendPlayerModelingAreaClient = Event.new('SendPlayerModelingAreaClient')
local sendPlayerBackstageContestClient = Event.new('SendPlayerBackstageContestClient')
goNextPlayerContest = Event.new('GoNextPlayerContest')
updateNumPlayersCurrentContest = Event.new('UpdateNumPlayersCurrentContest')
local mustSelectPlayerMasterTimer = Event.new('SelectPlayerMasterTimer')
local mustSelectPlayerMasterTimerPlayerDisconnected = Event.new('SelectPlayerMasterTimerPlayerDisconnected')
local updateIfPlayerDisconnected = Event.new('UpdateIfPlayerDisconnected')

-- Global Variables
gameObjectManager = self.gameObject
UIManagerGlobal = nil
ScorePlayerCompeting = nil
TrackingPlayersLobbyScript = nil
pointRespawnLobbyGlobal = nil
pointRespawnLockerRoomGlobal = nil
pointRespawnModelingAreaGlobal = nil
mainCameraGlobal = nil
cameraModelingGlobal = nil
playerWithGameObject = {} -- Saving the gameObject of each player
playersCurrentlyCompeting = {}

-- Local Variables
previousPlayers = {}
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
function updateNumPlayersFinish()
    updateNumPlayersFinishCustomization:FireServer()
end

function showUIVotingAllPlayers()
    showUIVotingServer:FireServer()
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

--Unity Functions
function self:ClientAwake()
    pointRespawnLobbyGlobal = pointRespawnLobby
    pointRespawnLockerRoomGlobal = pointRespawnLockerRoom
    UIManagerGlobal = uiManager
    pointRespawnModelingAreaGlobal = pointRespawnModelingArea
    mainCameraGlobal = mainCamera
    cameraModelingGlobal = cameraModeling

    UI_Customization = uiManager:GetComponent(UI_Customization_Model)
    UI_EndCustomization = uiManager:GetComponent(UI_Screen_Waiting_EndCustomization)
    UI_ConstestVoting = uiManager:GetComponent(UI_Contest_Voting)
    UI_BeautyContest = uiManager:GetComponent(UI_Beauty_Pageant)
    UI_RatingContest = uiManager:GetComponent(UI_Rating_Contest)

    countdownGameObj = self.gameObject:GetComponent(CountdownsGame)
    ScorePlayerCompeting = self.gameObject:GetComponent(GetScorePlayerCompeting)
    TrackingPlayersLobbyScript = self.gameObject:GetComponent(TrackingPlayersLobby)

    showUIAfterCustomization:Connect(function()
        UI_Customization.ShowUIFinishPlayerCustomization()
    end)

    showUIVotingClient:Connect(function()
        if playersCurrentlyCompeting[game.localPlayer.name] then
            UI_BeautyContest.SetWaitingPlayersRound('Voting Area!')
            UI_Customization.SettingStart()
            UI_Customization.StopCurrentTimerPlaying()
            UI_EndCustomization.SettingStart()
            UI_ConstestVoting.EnableContestVoting(true)

            sendPlayersToModelingArea(game.localPlayer.character, game.localPlayer.character.gameObject)
            sendAvatarToBackstageServer:FireServer()
            mainCamera:SetActive(false)
            cameraModeling:SetActive(true)
        end
    end)
    
    sendAvatarToBackstageClient:Connect(function(namePlayer)
        if playersCurrentlyCompeting[game.localPlayer.name] then
            sendPlayersToModelingArea(previousPlayers[namePlayer], playerWithGameObject[namePlayer])
        end
    end)

    sendPlayerModelingAreaClient:Connect(function(namePlayer)
        sendPlayerModelingArea(previousPlayers[namePlayer], playerWithGameObject[namePlayer])
        UI_ConstestVoting.SetNamePlayerContestant(namePlayer)
        countdownGameObj.StartCountdownVotingArea(UI_ConstestVoting)

        if game.localPlayer.name == namePlayer then
            UI_ConstestVoting.SetPlayerVotingStatus(false)
        elseif game.localPlayer.name ~= namePlayer and playersCurrentlyCompeting[game.localPlayer.name] then
            UI_ConstestVoting.SetPlayerVotingStatus(true)
        end
    end)

    sendPlayerBackstageContestClient:Connect(function(namePlayer)
        sendPlayersToModelingArea(previousPlayers[namePlayer], playerWithGameObject[namePlayer])
        UI_ConstestVoting.CleanStarsSelecting()
        countdownGameObj.resetCountdowns()
        countdownGameObj.StopCountdownCurrentGame()
    end)

    mustSelectPlayerMasterTimer:Connect(function()
        playersCurrentlyCompeting[game.localPlayer.name] = nil
        countdownGameObj.selectNewMasterServer:FireServer('')
    end)

    mustSelectPlayerMasterTimerPlayerDisconnected:Connect(function(namePlayer)
        if not playerDisconnected.value then
            countdownGameObj.selectNewMasterServer:FireServer('PlayerLeftGame')
            updateIfPlayerDisconnected:FireServer()
            playersCurrentlyCompeting[namePlayer] = nil
            playerDisconnected.value = true
        end
    end)
end

function self:ServerAwake()
    updateNumPlayersFinishCustomization:Connect(function(player : Player)
        numPlayersFinishCustomization.value += 1
        showUIAfterCustomization:FireClient(player)
    end)

    showUIVotingServer:Connect(function(player : Player)
        showUIVotingClient:FireAllClients()
    end)

    sendAvatarToBackstageServer:Connect(function(player : Player)
        numberPlayersSendModelingArea.value += 1
        sendAvatarToBackstageClient:FireAllClients(player.name)
    end)

    goNextPlayerContest:Connect(function(player : Player)
        for namePlayer, value in pairs(playersAlreadyModeling) do
            sendPlayerBackstageContestClient:FireAllClients(namePlayer)
        end

        startingAvatarContest.value = false
    end)

    updateNumPlayersCurrentContest:Connect(function(player : Player)
        numberPlayersCurrentContest.value -= 1
        playersCurrentlyCompeting[player.name] = nil
        mustSelectPlayerMasterTimer:FireClient(player)
    end)

    updateIfPlayerDisconnected:Connect(function(player : Player)
        playerDisconnected.value = true
    end)

    game.PlayerDisconnected:Connect(function(player : Player)
        playerWithGameObject[player.name] = nil
        previousPlayers[player.name] = nil
        playersCurrentlyCompeting[player.name] = nil
        numberPlayersCurrentContest.value -= 1
        numberPlayersSendModelingArea.value -= 1
        playerDisconnected.value = false
        --startingAvatarContest.value = false --add revisando cuando un player se sale en el area de votación.
        mustSelectPlayerMasterTimerPlayerDisconnected:FireAllClients(player.name)
    end)
end

function self:ServerUpdate()
    if numberPlayersCurrentContest.value == numberPlayersSendModelingArea.value and not startingAvatarContest.value and numberPlayersCurrentContest.value > 0 then --Ya todos estan tras banbalinas
        for namePlayer, objPlayer in pairs(playerWithGameObject) do
            if playersCurrentlyCompeting[namePlayer] and not playersAlreadyModeling[namePlayer] then
                sendPlayerModelingAreaClient:FireAllClients(namePlayer)
                playerModelingCurrently.value = namePlayer
                playersAlreadyModeling[namePlayer] = true
                break
            end
        end

        startingAvatarContest.value = true
        numberPlayersModeled.value += 1
    end
end

scene.PlayerJoined:Connect(function(scene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        playerWithGameObject[player.name] = character.gameObject
        previousPlayers[player.name] = character
    end)
end)