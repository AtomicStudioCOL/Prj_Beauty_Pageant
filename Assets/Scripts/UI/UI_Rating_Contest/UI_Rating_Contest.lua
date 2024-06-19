--!Type(UI)
--!Bind
local Rating_Contest : UILuaView = nil
--!Bind
local Name_Contest : UILabel = nil
--!Bind
local Txt_Info_Rating : UILabel = nil

--!Bind
local Img_Trophy : UIImage = nil
--!Bind
local Img_no_Trophy : UIImage = nil
--!Bind
local Img_Crown : UIImage = nil

--Unity Functions
function self:ClientAwake()
    Name_Contest:SetPrelocalizedText('JhonASG66')
    Txt_Info_Rating:SetPrelocalizedText('Congratulations!')

    Img_Trophy.visible = false
    Img_no_Trophy.visible = false
    Img_Crown.visible = false

    Rating_Contest.visible = false
end