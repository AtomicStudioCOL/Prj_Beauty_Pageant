--!Type(UI)
--!Bind
local Lbl_Clock : UILabel = nil
--!Bind
local Theme_Contest : UILabel = nil
--!Bind
local Finish_Customization : UIButton = nil
--!Bind
local Txt_Btn_Finish : UILabel = nil

--Categories
--!Bind
local Clothes_Body : UIImage = nil
--!Bind
local Hats : UIImage = nil
--!Bind
local Shoes : UIImage = nil
--!Bind
local Decor_Eyes : UIImage = nil
--!Bind
local Style_Hair : UIImage = nil
--!Bind
local Decor_mouth : UIImage = nil

--Category's Elements
--!Bind
local Element_01 : UIImage = nil
--!Bind
local Element_02 : UIImage = nil
--!Bind
local Element_03 : UIImage = nil
--!Bind
local Element_04 : UIImage = nil
--!Bind
local Box_Element_01 : UIView = nil
--!Bind
local Box_Element_02 : UIView = nil
--!Bind
local Box_Element_03 : UIView = nil
--!Bind
local Box_Element_04 : UIView = nil

--!Bind
local Down_Upward_Element : UIImage = nil

--Unity Functions
function self:ClientAwake()
    Lbl_Clock:SetPrelocalizedText('03:00')
    Theme_Contest:SetPrelocalizedText('Rock and Roll')
    Txt_Btn_Finish:SetPrelocalizedText('Finish')
    Finish_Customization:Add(Txt_Btn_Finish)

    Box_Element_03.visible = false
    Box_Element_04.visible = false

    --Categories
    Clothes_Body:RegisterPressCallback(function()end)
    Hats:RegisterPressCallback(function()end)
    Shoes:RegisterPressCallback(function()end)
    Decor_Eyes:RegisterPressCallback(function()end)
    Style_Hair:RegisterPressCallback(function()end)
    Decor_mouth:RegisterPressCallback(function()end)

    --Elements
    Element_01:RegisterPressCallback(function()end)
    Element_02:RegisterPressCallback(function()end)
    Element_03:RegisterPressCallback(function()end)
    Element_04:RegisterPressCallback(function()end)
    Down_Upward_Element:RegisterPressCallback(function()end)

    --Finish
    Finish_Customization:RegisterPressCallback(function()end)
end