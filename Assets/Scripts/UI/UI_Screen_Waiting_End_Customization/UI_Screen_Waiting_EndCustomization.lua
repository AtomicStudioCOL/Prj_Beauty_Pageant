--!Type(UI)
--!Bind
local Waiting_End_Customization : UILuaView = nil
--!Bind
local Txt_Info : UILabel = nil

--Unity Functions
function self:ClientAwake()
    Txt_Info:SetPrelocalizedText('Hang tight! Waiting for others to finish or the timer to run out.')
    Waiting_End_Customization.visible = false
end