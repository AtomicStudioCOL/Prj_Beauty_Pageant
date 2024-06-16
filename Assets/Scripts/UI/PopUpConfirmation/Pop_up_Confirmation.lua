--!Type(UI)
--!Bind
local Bg_Pop_up_Confirmation : UIImage = nil
--!Bind
local Close_Pop_up_Confirmation : UIImage = nil
--!Bind
local Txt_Confirmation : UILabel = nil
--!Bind
local Btn_Confirm : UIButton = nil
--!Bind
local Txt_Btn_Confirm : UILabel = nil
--!Bind
local Btn_Cancel : UIButton = nil
--!Bind
local Txt_Btn_Cancel : UILabel = nil

--Unity Functions
function self:ClientAwake()
    Txt_Confirmation:SetPrelocalizedText('')

    Txt_Btn_Confirm:SetPrelocalizedText('Confirm')
    Btn_Confirm:Add(Txt_Btn_Confirm)

    Txt_Btn_Cancel:SetPrelocalizedText('Cancel')
    Btn_Cancel:Add(Txt_Btn_Cancel)

    Close_Pop_up_Confirmation:RegisterPressCallback(function()end)

    Btn_Confirm:RegisterPressCallback(function()end)

    Btn_Cancel:RegisterPressCallback(function()end)

    SetStatusPopupConfirmation(false)
end

function SetStatusPopupConfirmation(status)
    Bg_Pop_up_Confirmation.visible = status
end