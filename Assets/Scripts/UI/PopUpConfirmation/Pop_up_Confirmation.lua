--Managers
local gameManager = require('GameManager')
local countdownsGame = require('CountdownsGame')

--!Type(UI)
--!Bind
local Pop_up_Confirmation : UILuaView = nil
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

--UIs
local UI_Beauty_Contest = nil
local UI_Waiting_EndCustomization = nil
local UI_CustomizationPlayer = nil

--Variables
local trackingPlayersScript = nil
local typePopupConfirmation = ''
local whichUIReturnCancel = ''

--Functions
local function SettingStartGame()
    Txt_Confirmation:SetPrelocalizedText('')

    Txt_Btn_Confirm:SetPrelocalizedText('Confirm')
    Btn_Confirm:Add(Txt_Btn_Confirm)

    Txt_Btn_Cancel:SetPrelocalizedText('Cancel')
    Btn_Cancel:Add(Txt_Btn_Cancel)

    UI_Beauty_Contest = self.gameObject:GetComponent(UI_Beauty_Pageant)
    trackingPlayersScript = gameManager.gameObjectManager:GetComponent(TrackingPlayersLobby)
    UI_Waiting_EndCustomization = self.gameObject:GetComponent(UI_Screen_Waiting_EndCustomization)
    UI_CustomizationPlayer = self.gameObject:GetComponent(UI_Customization_Model)
end

local function ReturnLobbyWithRunningRound()
    UI_Beauty_Contest.SetWaitingPlayersRound('Pageant in Progress!')
    UI_Beauty_Contest.EnableSpectatorModeLobby(true)
    UI_Beauty_Contest.SetTimerCloseWindowTheme('')
    UI_Beauty_Contest.SetThemeBeautyContest('')

    SetStatusPopupConfirmation(false)
end

local function SetWhichWindowReturn(window)
    if window == 'PopUp_Theme' then
        UI_Beauty_Contest.SetWaitingPlayersRound('')
        UI_Beauty_Contest.SetTimerSendPlayerToLockerRoom('')
        UI_Beauty_Contest.EnablePopupThemeContest(true)
        UI_Beauty_Contest.SetThemeBeautyContest(
            trackingPlayersScript.themesBeautyContest[trackingPlayersScript.randomTheme.value]
        )
        countdownsGame.StartCountdownCloseWindowTheme(UI_Beauty_Contest, UI_CustomizationPlayer)
    elseif window == 'Waiting_EndCustomization' then
        UI_Waiting_EndCustomization.EnableWaitingEndCustomization(true)
    end
end

local function CancelOperationPopup()
    if typePopupConfirmation == 'return_lobby' then
        SetStatusPopupConfirmation(false)
        SetWhichWindowReturn(whichUIReturnCancel)
    elseif typePopupConfirmation == 'spectator_contest' then
        ReturnLobbyWithRunningRound()
    end
end

--Unity Functions
function self:ClientAwake()
    SettingStartGame()

    Close_Pop_up_Confirmation:RegisterPressCallback(function()
        CancelOperationPopup()
    end)

    Btn_Confirm:RegisterPressCallback(function()
        if typePopupConfirmation == 'return_lobby' then
            ReturnLobbyWithRunningRound()
        elseif typePopupConfirmation == 'spectator_contest' then
            print(`Enviar a la pantalla de votación`)
        end
    end)

    Btn_Cancel:RegisterPressCallback(function()
        CancelOperationPopup()
    end)

    SetStatusPopupConfirmation(false)
end

function SetStatusPopupConfirmation(status)
    Pop_up_Confirmation.visible = status
    Bg_Pop_up_Confirmation.visible = status

    if not status then return end

    if typePopupConfirmation == 'return_lobby' then
        Txt_Confirmation:SetPrelocalizedText('Do you want to head to lobby?')
    elseif typePopupConfirmation == 'spectator_contest' then
        Txt_Confirmation:SetPrelocalizedText('Do you want to spectate and vote in the on-going pageant?')
    end
end

function SetTypePopupConfirmation(text)
    typePopupConfirmation = text
end

function SetWhichUIReturnCancel(text)
    whichUIReturnCancel = text
end