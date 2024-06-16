--Managers
local countdownsGame = require('CountdownsGame')

--!Type(UI)
--!Bind
local Waiting_Players : UILabel = nil
--!Bind
local Timer_General : UILabel = nil
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

--Local functions
local function SettingStartUI()
    Waiting_Players:SetPrelocalizedText('')
    Timer_General:SetPrelocalizedText('')
    Txt_Theme:SetPrelocalizedText('')
    Timer_Theme:SetPrelocalizedText('')
    
    EnablePopupThemeContest(false)
    EnableSpectatorModeLobby(false)

    UI_Pop_up_Confirmation = self.gameObject:GetComponent(Pop_up_Confirmation)
end

--Unity Function
function self:ClientAwake()
    SettingStartUI()

    Btn_Return_Lobby:RegisterPressCallback(function()
        EnablePopupThemeContest(false)
        UI_Pop_up_Confirmation.SetTypePopupConfirmation('return_lobby')
        UI_Pop_up_Confirmation.SetStatusPopupConfirmation(true)
        countdownsGame.StopCountdownCurrentGame() --Stop timer for that user 
    end)

    Close_Pop_up_Theme:RegisterPressCallback(function()
        EnablePopupThemeContest(false)
        SetTimerCloseWindowTheme('')
        SetThemeBeautyContest('')
        countdownsGame.StopCountdownCurrentGame()
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
end

function EnablePopupThemeContest(status)
    Pop_up_Theme_Contest.visible = status
end

function SetTimerCloseWindowTheme(text)
    Timer_Theme:SetPrelocalizedText(text)
end

function SetThemeBeautyContest(text)
    Txt_Theme:SetPrelocalizedText(text)
end