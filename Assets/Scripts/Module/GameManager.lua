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
numPlayersFinishCustomization = IntValue.new('NumPlayersFinishCustomization', 0)
startingAvatarContest = BoolValue.new('StartingAvatarContest', false)

-- Events
local showUIVotingClient = Event.new('ShowUIVotingClient')
local showUIVotingServer = Event.new('ShowUIVotingServer')
local updateNumPlayersFinishCustomization = Event.new('UpdateNumPlayersFinishCustomization')
local showUIAfterCustomization = Event.new('ShowUIAfterCustomization')
local sendAvatarToBackstageServer = Event.new('SendAvatarToBackstageServer')
local sendAvatarToBackstageClient = Event.new('SendAvatarToBackstageClient')
local sendPlayerModelingAreaServer = Event.new('SendPlayerModelingAreaServer')
local sendPlayerModelingAreaClient = Event.new('SendPlayerModelingAreaClient')
local sendPlayerContestServer = Event.new('SendPlayerContestServer')
local sendPlayerContestClient = Event.new('SendPlayerContestClient')

-- Global Variables
gameObjectManager = self.gameObject
UIManagerGlobal = nil
pointRespawnLobbyGlobal = nil
pointRespawnLockerRoomGlobal = nil
pointRespawnModelingAreaGlobal = nil
playerWithGameObject = {} -- Saving the gameObject of each player
playersCurrentlyCompeting = {}

-- Local Variables
local previousPlayers = {}
local playersAlreadyModeling = {}

-- UIs
local UI_Customization = nil
local UI_EndCustomization = nil
local UI_ConstestVoting = nil
local UI_BeautyContest = nil

--Fucntions
function updateNumPlayersFinish()
    updateNumPlayersFinishCustomization:FireServer()
end

function showUIVotingAllPlayers()
    showUIVotingServer:FireServer()
end

function sendPlayersToModelingArea(character : Character, objCharacter : GameObject)
    objCharacter.transform.position = pointRespawnZoneVoting.transform.position
    character:MoveTo(pointRespawnZoneVoting.transform.position, 6, function()end)
end

function sendPlayerModelingArea(character : Character, objCharacter : GameObject)
    objCharacter.transform.position = pointRespawnModelingArea.transform.position
    character:MoveTo(pointRespawnModelingArea.transform.position, 6, function()end)
end

--Unity Functions
function self:ClientAwake()
    pointRespawnLobbyGlobal = pointRespawnLobby
    pointRespawnLockerRoomGlobal = pointRespawnLockerRoom
    UIManagerGlobal = uiManager
    pointRespawnModelingAreaGlobal = pointRespawnModelingArea

    UI_Customization = uiManager:GetComponent(UI_Customization_Model)
    UI_EndCustomization = uiManager:GetComponent(UI_Screen_Waiting_EndCustomization)
    UI_ConstestVoting = uiManager:GetComponent(UI_Contest_Voting)
    UI_BeautyContest = uiManager:GetComponent(UI_Beauty_Pageant)

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
            UI_ConstestVoting.SetNamePlayerContestant(game.localPlayer.name)

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

    sendPlayerModelingAreaClient:Connect(function()
        if not playersAlreadyModeling[game.localPlayer.name] then
            sendPlayerModelingArea(game.localPlayer.character, game.localPlayer.character.gameObject)
            sendPlayerContestServer:FireServer()
        end
    end)

    sendPlayerContestClient:Connect(function(namePlayer)
        if namePlayer ~= game.localPlayer.name and playersCurrentlyCompeting[game.localPlayer.name] then
            sendPlayersToModelingArea(previousPlayers[namePlayer], playerWithGameObject[namePlayer])
            playersAlreadyModeling[namePlayer] = true
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

    sendPlayerContestServer:Connect(function(player : Player)
        sendPlayerContestClient:FireAllClients(player.name)

        Timer.After(10, function()
            sendPlayerModelingAreaClient:FireAllClients()
        end)
    end)
end

function self:ServerUpdate()
    if numberPlayersCurrentContest.value == numberPlayersSendModelingArea.value and not startingAvatarContest.value and numberPlayersCurrentContest.value > 0 then --Ya todos estan tras banbalinas
        print(`{numberPlayersCurrentContest.value} - {numberPlayersSendModelingArea.value}`)
        sendPlayerModelingAreaClient:FireAllClients()
        startingAvatarContest.value = true
    end
end

scene.PlayerJoined:Connect(function(scene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        playerWithGameObject[player.name] = character.gameObject
        previousPlayers[player.name] = character
    end)
end)