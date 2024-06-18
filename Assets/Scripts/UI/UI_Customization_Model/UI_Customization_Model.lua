--!Type(UI)
--!Bind
local Customization_Model : UILuaView = nil

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
--!Bind
local Model : UIImage = nil

--Variables
local statusCurrentElementsVisible = 'first' --There're two status 'first' - 'second'
local wasAddedShirt = false
local wasAddedPant = false

local element01 : UIImage = nil
local element02 : UIImage = nil
local element03 : UIImage = nil
local element04 : UIImage = nil

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
    Element_01:RegisterPressCallback(function()
        if element03 then element03.visible = false end

        if not wasAddedShirt then
            element01 = UIImage.new(true)
            Model:Add(element01)
            element01:AddToClassList('clothes_01')
            element01.visible = true

            wasAddedShirt = true
        end
    end)
    Element_02:RegisterPressCallback(function()
        if element04 then element04.visible = false end

        if not wasAddedPant then
            element02 = UIImage.new(true)
            Model:Add(element02)
            element02:AddToClassList('clothes_02')
            element02.visible = true

            wasAddedPant = true
        end
    end)

    Element_03:RegisterPressCallback(function()
        if element01 then element01.visible = false end
        if element02 then element02.visible = false end
        if element04 then element04.visible = false end

        if not wasAddedShirt then
            element03 = UIImage.new(true)
            Model:Add(element03)
            element03:AddToClassList('clothes_03')
            element03.visible = true

            wasAddedShirt = true
        end
    end)

    Element_04:RegisterPressCallback(function()
        if element02 then element02.visible = false end

        if not wasAddedPant then
            element04 = UIImage.new(true)
            Model:Add(element04)
            element04:AddToClassList('clothes_04')
            element04.visible = true

            wasAddedPant = true
        end
    end)
    
    Down_Upward_Element:RegisterPressCallback(function()
        if statusCurrentElementsVisible == 'first' then
            Box_Element_01.visible = false
            Box_Element_02.visible = false
            Box_Element_03.visible = true
            Box_Element_04.visible = true

            wasAddedShirt = false
            wasAddedPant = false
            statusCurrentElementsVisible = 'second'

            Down_Upward_Element:RemoveFromClassList('downwards_element')
            Down_Upward_Element:AddToClassList('upwards_element')
        elseif statusCurrentElementsVisible == 'second' then
            Box_Element_01.visible = true
            Box_Element_02.visible = true
            Box_Element_03.visible = false
            Box_Element_04.visible = false
            
            wasAddedShirt = false
            wasAddedPant = false
            statusCurrentElementsVisible = 'first'

            Down_Upward_Element:RemoveFromClassList('upwards_element')
            Down_Upward_Element:AddToClassList('downwards_element')
        end
    end)

    --Finish
    Finish_Customization:RegisterPressCallback(function()end)

    Customization_Model.visible = false
end