--!Type(UI)

--!Bind
local _localname : UILabel = nil -- Do not touch this line
--!Bind
local _localscore : UILabel = nil -- Do not touch this line

--!Bind
local _content : VisualElement = nil -- Do not touch this line
--!Bind
local _ranklist : UIScrollView = nil -- Do not touch this line

--!Bind
local _closeButton : VisualElement = nil -- Do not touch this line

-- Change this to the number of players you want to display
local maxPlayers = 15

-- Register a callback to close the ranking UI
_closeButton:RegisterPressCallback(function()
  self.gameObject:SetActive(false) -- Hide the UI
end, true, true, true)

-- Function to get the suffix of a position
function GetPositionSuffix(position)
  if position == 1 then
    return "1st"
  elseif position == 2 then
    return "2nd"
  elseif position == 3 then
    return "3rd"
  else
    return position .. "th"
  end
end

-- Function to update the local player
function UpdateLocalPlayer(score: number)
  local player = client.localPlayer

  _localname:SetPrelocalizedText(player.name) -- Set the name of the local player
  _localscore:SetPrelocalizedText(tostring(score)) -- Set the score of the local player

  -- Note: When passing the "score" make sure you convert it to a string
end

-- Function to update the leaderboard
function UpdateLeaderboard(players)
  -- Clear the previous leaderboard entries
  _ranklist:Clear()

  -- Get the number of players to display
  local playersCount = #players

  -- Clamp the number of players to display
  if playersCount > maxPlayers then playersCount = maxPlayers end -- Ensure only 5 entries are displayed

  -- Loop through the players and add them to the leaderboard
  for i = 1, playersCount do

    -- Create a new rank item
    local _rankItem = VisualElement.new()
    _rankItem:AddToClassList("rank-item")

    -- Get the player entry
    local entry = players[i]

    local name = entry.name -- Get the name of the player
    local score = entry.score -- Get the score of the player

    -- Create the rank, name, and score labels
    local _rankLabel = UILabel.new()
    _rankLabel:SetPrelocalizedText(GetPositionSuffix(i))
    _rankLabel:AddToClassList("rank-label")

    -- Set the name and score of the player
    local _nameLabel = UILabel.new()
    _nameLabel:SetPrelocalizedText(name)
    _nameLabel:AddToClassList("name-label")

    -- Set the score of the player
    local _scoreLabel = UILabel.new()
    _scoreLabel:SetPrelocalizedText(tostring(score))
    _scoreLabel:AddToClassList("score-label")

    -- Add the rank, name, and score labels to the rank item
    _rankItem:Add(_rankLabel)
    _rankItem:Add(_nameLabel)
    _rankItem:Add(_scoreLabel)

    -- Add the rank item to the leaderboard
    _ranklist:Add(_rankItem)
  end
end

-- Hardcoded players, replace this with your own data
-- Make sure the players have a "name" and "score" field
-- Otherwise, you will need to modify the code to match your data
local players = {
  {name = "Player 1", score = 100},
  {name = "Player 2", score = 90},
  {name = "Player 3", score = 80},
  {name = "Player 4", score = 70},
  {name = "Player 5", score = 60},
  {name = "Player 6", score = 50},
  {name = "Player 7", score = 40},
  {name = "Player 8", score = 30},
  {name = "Player 9", score = 20},
  {name = "Player 10", score = 10},
  {name = "Player 11", score = 5},
  {name = "Player 12", score = 4},
  {name = "Player 13", score = 3},
  {name = "Player 14", score = 2},
  {name = "Player 15", score = 1}
}

-- Debugging purposes
local cooldown = 5 -- Update every 5 seconds
local timer = 0 -- Timer to keep track of the time

-- Function to update the leaderboard
-- Optional: You can update the leaderboard every 5 seconds
-- Note: You could use this update function to update the leaderboard in real-time in 
-- Any other way you see fit, even if you place it in another script and you reference the leaderboard UI
function self:ClientUpdate()
  timer = timer + Time.deltaTime
  if timer >= cooldown then
    -- Debugging purposes
    -- Change the scores randomly
    -- Note: Do not use this in your actual implementation
    -- This is for testing purposes only
    -- All you need is "UpdateLeaderboard(players)" with your actual data
    for i = 1, #players do
      players[i].score = math.random(1, 1000) -- Remove this line in your actual implementation
    end

    -- Sort the players by score
    table.sort(players, function(a, b) return a.score > b.score end)

    -- Call the function to update the leaderboard
    -- Note: This function can be called from another script
    UpdateLeaderboard(players)
    timer = 0
  end
end

-- Call the function to update the leaderboard
-- Note: This function can be called from another script
UpdateLocalPlayer(5)