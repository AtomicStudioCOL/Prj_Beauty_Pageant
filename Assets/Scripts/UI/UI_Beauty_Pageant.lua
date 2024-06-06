--!Type(UI)
--!Bind
local Countdown : UILabel = nil
--!Bind
local Title_Customization : UILabel = nil
--!Bind
local Timer_Customization : UILabel = nil

Countdown:SetPrelocalizedText('')
Title_Customization:SetPrelocalizedText('CUSTOMIZATION')
Timer_Customization:SetPrelocalizedText('01:00')

--Functions
function SetCountdownGame(text)
    Countdown:SetPrelocalizedText(text)
end