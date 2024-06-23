--Managers
local countdownsGame = require('CountdownsGame')

--!Type(UI)
--!Bind
local Waiting_Players : UILabel = nil
--!Bind
local Timer_General : UILabel = nil
--!Bind
local Info_Btn_Spectator : UILabel = nil
--!Bind
local Spectator_Lobby : UIImage = nil

--Pop up selecting Theme
--!Bind
local Pop_up_Theme_Contest : UIImage = nil
--!Bind
local Btn_Return_Lobby : UIImage = nil
--!Bind
local Close_Pop_up_Theme : UIImage = nil
--!Bind
local Txt_Theme : UILabel = nil
--!Bind
local Timer_Theme : UILabel = nil

--UIs
local UI_Pop_up_Confirmation = nil
local UI_Customization_Player = nil

--Local functions
function SettingStartUI()
    Waiting_Players:SetPrelocalizedText('')
    Timer_General:SetPrelocalizedText('')
    Txt_Theme:SetPrelocalizedText('')
    Timer_Theme:SetPrelocalizedText('')
    Info_Btn_Spectator:SetPrelocalizedText('')
    
    EnablePopupThemeContest(false)
    EnableSpectatorModeLobby(false)
    
    UI_Pop_up_Confirmation = self.gameObject:GetComponent(Pop_up_Confirmation)
    UI_Customization_Player = self.gameObject:GetComponent(UI_Customization_Model)
end

--Unity Function
function self:ClientAwake()
    SettingStartUI()

    Btn_Return_Lobby:RegisterPressCallback(function()
        EnablePopupThemeContest(false)
        UI_Pop_up_Confirmation.SetTypePopupConfirmation('return_lobby')
        UI_Pop_up_Confirmation.SetWhichUIReturnCancel('PopUp_Theme')
        UI_Pop_up_Confirmation.SetStatusPopupConfirmation(true)
        countdownsGame.StopCountdownCurrentGame() --Stop timer for that user 
    end)

    Close_Pop_up_Theme:RegisterPressCallback(function()
        countdownsGame.StopCountdownCurrentGame()
        countdownsGame.resetCountdowns()

        EnablePopupThemeContest(false)
        SetTimerCloseWindowTheme('')
        SetThemeBeautyContest('')
        SetWaitingPlayersRound('LOCKER ROOM')

        UI_Customization_Player.EnableCustomizationPlayer(true)
        UI_Customization_Player.EnablePopupInfoCustomization(true)
        countdownsGame.StartCountdownCustomizationPlayer(UI_Customization_Player)
    end)

    Spectator_Lobby:RegisterPressCallback(function()
        UI_Pop_up_Confirmation.SetTypePopupConfirmation('spectator_contest')
        UI_Pop_up_Confirmation.SetStatusPopupConfirmation(true)
    end)
end

--Global Functions
function SetWaitingPlayersRound(text)
    Waiting_Players:SetPrelocalizedText(text)
end

function SetTimerSendPlayerToLockerRoom(text)
    Timer_General:SetPrelocalizedText(text)
end

function EnableSpectatorModeLobby(status)
    Spectator_Lobby.visible = status
    Info_Btn_Spectator.visible = status

    if status then
        Info_Btn_Spectator:SetPrelocalizedText('Click on the spectate button and vote for the on-going pageant')
    end
end

function EnablePopupThemeContest(status)
    Pop_up_Theme_Contest.visible = status
end

function SetTimerCloseWindowTheme(text)
    Timer_Theme:SetPrelocalizedText(text)
end

function SetThemeBeautyContest(text)
    Txt_Theme:SetPrelocalizedText('Theme: ' .. text)
end