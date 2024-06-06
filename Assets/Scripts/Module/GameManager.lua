--Points of the respawn - Room
--!SerializeField
local pointRespawnLobby : GameObject = nil
--!SerializeField
local pointRespawnLockerRoom : GameObject = nil

-- Public Variables
--!SerializeField
local uiManager : GameObject = nil

-- Network Values
amountPlayersLobby = IntValue.new('AmountPlayersLobby', 0)
hasStartedRound = BoolValue.new('HasStartedRound', false)

-- Global Variables
UIManagerGlobal = nil
pointRespawnLobbyGlobal = nil
pointRespawnLockerRoomGlobal = nil
playerWithGameObject = {} -- Saving the gameObject of each player

--Unity Functions
function self:ClientAwake()
    pointRespawnLobbyGlobal = pointRespawnLobby
    pointRespawnLockerRoomGlobal = pointRespawnLockerRoom
    UIManagerGlobal = uiManager
end

scene.PlayerJoined:Connect(function(scene, player : Player)
    player.CharacterChanged:Connect(function (player : Player, character : Character)
        playerWithGameObject[player.name] = character.gameObject
    end)
end)