--!Type(UI)
--Managers
local gameManager = require('GameManager')

--!Bind
local Rating_Contest : UILuaView = nil

--!Bind
local Txt_Info_Rating : UILabel = nil
--!Bind
local Leaderboard : UIScrollView = nil
--!Bind
local Lbl_Clock : UILabel = nil

--Variables
local dataLeaderboard = {}

--Functions
function UpdateLeaderboard(ranking : string, namePlayer : string, score : number)
    -- Create a new rank item
    local _rankItem = VisualElement.new()
    _rankItem:AddToClassList("rank-item")

    -- Create the rank, name, and score labels
    local _rankLabel = UILabel.new()
    _rankLabel:SetPrelocalizedText(ranking)
    _rankLabel:AddToClassList("rank-label")

    -- Set the name and score of the player
    local _nameLabel = UILabel.new()
    _nameLabel:SetPrelocalizedText(namePlayer)
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
    Leaderboard:Add(_rankItem)
end

function EnableRatingContest(status)
    Rating_Contest.visible = status

    if status then
        Leaderboard:Clear() -- Clear the previous leaderboard entries
        gameManager.ScorePlayerCompeting.showScoreBeautyContest:FireServer()
        
    end
end

function StartSetting()
    Txt_Info_Rating:SetPrelocalizedText('Leaderboard Beauty Pageant!')
    Lbl_Clock:SetPrelocalizedText('00:10')
    EnableRatingContest(false)
end

--Unity Functions
function self:ClientAwake()
    StartSetting()
end