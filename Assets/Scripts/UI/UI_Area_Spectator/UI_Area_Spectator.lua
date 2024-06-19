--!Type(UI)
--!Bind
local Btns_Area_Spectator : UIView = nil
--!Bind
local Leaderboard_Contest : UIView = nil
--!Bind
local Pos_Player_1 : UILabel = nil
--!Bind
local Pos_Player_2 : UILabel = nil

--Unity functions
function self:ClientAwake()
    Btns_Area_Spectator.visible = false
    Leaderboard_Contest.visible = false

    Pos_Player_1:SetPrelocalizedText('1. HugoUruena.') --Temp
    Pos_Player_2:SetPrelocalizedText('2. JhonASG66.') --Temp
end