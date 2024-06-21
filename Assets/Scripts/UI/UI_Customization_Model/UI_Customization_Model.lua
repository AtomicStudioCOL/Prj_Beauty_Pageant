--!Type(UI)
--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--!Bind
local Customization_Model : UILuaView = nil

--!Bind
local Lbl_Clock : UILabel = nil
--!Bind
local Theme_Contest : UILabel = nil

--!Bind
local Pop_Up_Info : UIView = nil
--!Bind
local Btn_Close : UIImage = nil
--!Bind
local Txt_Info_Customization : UILabel = nil

--!Bind
local Finish_Customization : UIButton = nil
--!Bind
local Txt_Btn_Finish : UILabel = nil

--UIs
local UI_Waiting_EndCustomization = nil

--Functions
function SettingStart()
    Lbl_Clock:SetPrelocalizedText('')
    Theme_Contest:SetPrelocalizedText('')
    Txt_Info_Customization:SetPrelocalizedText("Head to your profile's closet, dress up according to the theme as best you can, then come back to this screen and click on 'Confirm' when you're done! You have 3 minutes.")

    Txt_Btn_Finish:SetPrelocalizedText('Confirm')
    Finish_Customization:Add(Txt_Btn_Finish)

    EnableCustomizationPlayer(false)
    EnablePopupInfoCustomization(false)

    UI_Waiting_EndCustomization = self.gameObject:GetComponent(UI_Screen_Waiting_EndCustomization)
end

function SetTimerCustomizationPlayer(timer)
    Lbl_Clock:SetPrelocalizedText(timer)
    UI_Waiting_EndCustomization.SetTimerCurrentCustomization(timer)
end

function SetThemeBeautyContest(text)
    Theme_Contest:SetPrelocalizedText('Theme: ' .. text)
end

function EnableCustomizationPlayer(status)
    Customization_Model.visible = status
end

function EnablePopupInfoCustomization(status)
    Pop_Up_Info.visible = status
end

function finishedTimerCustomizationPlayers()
    gameManager.showUIVotingAllPlayers()
end

function ShowUIFinishPlayerCustomization()
    local numPlayersContest = gameManager.numberPlayersCurrentContest.value
    local numPlayersFinishCustomization = gameManager.numPlayersFinishCustomization.value

    if numPlayersFinishCustomization < numPlayersContest then
        SettingStart()
        UI_Waiting_EndCustomization.EnableWaitingEndCustomization(true)
        --countdownsGame.StopCountdownCurrentGame()
    elseif numPlayersFinishCustomization >= numPlayersContest then
        gameManager.showUIVotingAllPlayers()
    end
end

function StopCurrentTimerPlaying()
    countdownsGame.StopCountdownCurrentGame()
end

--Unity Functions
function self:ClientAwake()
    SettingStart()

    Btn_Close:RegisterPressCallback(function()
        EnablePopupInfoCustomization(false)
    end)

    --Finish
    Finish_Customization:RegisterPressCallback(function()
        gameManager.updateNumPlayersFinish()
    end)
end