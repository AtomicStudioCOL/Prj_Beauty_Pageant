--!Type(UI)
--Managers
local countdownsGame = require('CountdownsGame')

--!Bind
local Contest_Voting : UILuaView = nil
--!Bind
local Name_Contest : UILabel = nil
--!Bind
local Lbl_Clock : UILabel = nil
--!Bind
local Info_Voting : UILabel = nil

--Rating
--!Bind
local Rating_1 : UIImage = nil
--!Bind
local Rating_2 : UIImage = nil
--!Bind
local Rating_3 : UIImage = nil
--!Bind
local Rating_4 : UIImage = nil
--!Bind
local Rating_5 : UIImage = nil

--Functions
function SettingStart()
    Name_Contest:SetPrelocalizedText('')
    Lbl_Clock:SetPrelocalizedText('00:30')
    Info_Voting:SetPrelocalizedText('Please rate from 1 to 5, where 5 is the best and 1 is the worst.')

    EnableContestVoting(false)
end

function SetNamePlayerContestant(namePlayer)
    Name_Contest:SetPrelocalizedText(namePlayer)
end

function SetTimerForVoting(timer)
    Lbl_Clock:SetPrelocalizedText(timer)
end

function EnableContestVoting(status)
    Contest_Voting.visible = status

    if status then
        countdownsGame.StopCountdownCurrentGame()
    end
end

--Unity Functions
function self:ClientAwake()
    SettingStart()

    Rating_1:RegisterPressCallback(function()
        Rating_1:AddToClassList('enableStar_01')

        Rating_2:RemoveFromClassList('enableStar_02')
        Rating_3:RemoveFromClassList('enableStar_03')
        Rating_4:RemoveFromClassList('enableStar_04')
        Rating_5:RemoveFromClassList('enableStar_05')
    end)

    Rating_2:RegisterPressCallback(function()
        Rating_1:AddToClassList('enableStar_01')
        Rating_2:AddToClassList('enableStar_02')

        Rating_3:RemoveFromClassList('enableStar_03')
        Rating_4:RemoveFromClassList('enableStar_04')
        Rating_5:RemoveFromClassList('enableStar_05')
    end)

    Rating_3:RegisterPressCallback(function()
        Rating_1:AddToClassList('enableStar_01')
        Rating_2:AddToClassList('enableStar_02')
        Rating_3:AddToClassList('enableStar_03')

        Rating_4:RemoveFromClassList('enableStar_04')
        Rating_5:RemoveFromClassList('enableStar_05')
    end)

    Rating_4:RegisterPressCallback(function()
        Rating_1:AddToClassList('enableStar_01')
        Rating_2:AddToClassList('enableStar_02')
        Rating_3:AddToClassList('enableStar_03')
        Rating_4:AddToClassList('enableStar_04')

        Rating_5:RemoveFromClassList('enableStar_05')
    end)

    Rating_5:RegisterPressCallback(function()
        Rating_1:AddToClassList('enableStar_01')
        Rating_2:AddToClassList('enableStar_02')
        Rating_3:AddToClassList('enableStar_03')
        Rating_4:AddToClassList('enableStar_04')
        Rating_5:AddToClassList('enableStar_05')
    end)
end