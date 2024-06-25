--!Type(UI)
--Managers
local countdownsGame = require('CountdownsGame')

--!Bind
local Waiting_End_Customization : UILuaView = nil
--!Bind
local Lbl_Clock : UILabel = nil
--!Bind
local Btn_Return_Lobby : UIImage = nil
--!Bind
local Close_Pop_up : UIImage = nil
--!Bind
local Txt_Info : UILabel = nil

--UIs
local UI_Pop_up_Confirmation = nil

--Functions
function SettingStart()
    Lbl_Clock:SetPrelocalizedText('')
    Txt_Info:SetPrelocalizedText('Hang tight! Waiting for other players to finish dressing up')
    EnableWaitingEndCustomization(false)

    UI_Pop_up_Confirmation = self.gameObject:GetComponent(Pop_up_Confirmation)
end

function EnableWaitingEndCustomization(status)
    Waiting_End_Customization.visible = status
end

function SetTimerCurrentCustomization(timer)
    Lbl_Clock:SetPrelocalizedText(timer)
end

--Unity Functions
function self:ClientAwake()
    SettingStart()

    Btn_Return_Lobby:RegisterPressCallback(function()
        EnableWaitingEndCustomization(false)

        UI_Pop_up_Confirmation.SetTypePopupConfirmation('return_lobby')
        UI_Pop_up_Confirmation.SetWhichUIReturnCancel('Waiting_EndCustomization')
        UI_Pop_up_Confirmation.SetStatusPopupConfirmation(true)
        countdownsGame.StopCountdownCurrentGame() --Stop timer for that user
    end)

    Close_Pop_up:RegisterPressCallback(function()
        EnableWaitingEndCustomization(false)
    end)
end