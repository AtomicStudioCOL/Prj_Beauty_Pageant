--!Type(UI)
--!Bind
local Contest_Voting : UILuaView = nil
--!Bind
local Name_Contest : UILabel = nil

--Unity Functions
function self:ClientAwake()
    Name_Contest:SetPrelocalizedText('JhonASG66')
    Contest_Voting.visible = false
end