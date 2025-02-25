local Workspace = game.get_workspace()

local Get, NewCheckbox, NewColorPicker, NewSliderInt = ui.get, ui.new_checkbox, ui.new_colorpicker, ui.new_slider_int
local FindFirstChild, FindFirstChildOfClass, GetLocalPlayer = Workspace.find_first_child, Workspace.find_first_child_of_class, entity.get_local_player
local Vector, WorldToScreen = vector, utility.world_to_screen
local GetDist, GetName, GetChildren, GetLocalPlayer, GetPosition, GetCharacterPosition = Vector(0,0,0).dist_to, Workspace.get_name, Workspace.get_children, entity.get_local_player, Workspace.get_position, GetLocalPlayer().get_position
local MeasureText, DrawText = render.measure_text, render.text

local Map, Filter = FindFirstChild(Workspace, "Map"), FindFirstChild(Workspace, "Filter")
local Piles, Tools, Cash = FindFirstChild(Filter, "SpawnedPiles"), FindFirstChild(Filter, "SpawnedTools"), FindFirstChild(Filter, "SpawnedBread")
local Money, Shops, ATMs, Vending = FindFirstChild(Map, "BredMakurz"), FindFirstChild(Map, "Shopz"), FindFirstChild(Map, "ATMz"), FindFirstChild(Map, "VendingMachines")

local Interface = {
    DealerToggle = NewCheckbox("Scripts", "Elements", "Dealer"),
    DealerPicker = NewColorPicker("Scripts", "Elements", "Dealer Color", 255, 255, 255, 255, true),
   
    ATMToggle = NewCheckbox("Scripts", "Elements", "ATM"),
    ATMPicker = NewColorPicker("Scripts", "Elements", "ATM Color", 255, 255, 255, 255, true),

    VendingToggle = NewCheckbox("Scripts", "Elements", "Vending Machines"),
    VendingPicker = NewColorPicker("Scripts", "Elements", "Vending Machine Color", 255, 255, 255, 255, true),

    ScrapToggle = NewCheckbox("Scripts", "Elements", "Scrap"),
    ScrapPicker = NewColorPicker("Scripts", "Elements", "Scrap Color", 255, 255, 255, 255, true),

    ItemToggle = NewCheckbox("Scripts", "Elements", "Dropped Items"),
    ItemPicker = NewColorPicker("Scripts", "Elements", "Dropped Item Color", 255, 255, 255, 255, true),

    CashToggle = NewCheckbox("Scripts", "Elements", "Dropped Cash"),
    CashPicker = NewColorPicker("Scripts", "Elements", "Dropped Cash Color", 255, 255, 255, 255, true),

    SmallSafeToggle = NewCheckbox("Scripts", "Elements", "Small Safe"),
    SmallSafePicker = NewColorPicker("Scripts", "Elements", "Small Safe Color", 255, 255, 0, 255, true),

    MediumSafeToggle = NewCheckbox("Scripts", "Elements", "Medium Safe"),
    MediumSafePicker = NewColorPicker("Scripts", "Elements", "Medium Safe Color", 0, 255, 0, 255, true),

    RegisterToggle = NewCheckbox("Scripts", "Elements", "Register"),
    RegisterPicker = NewColorPicker("Scripts", "Elements", "Register Color", 255, 255, 255, 255, true),

    HideBrokenToggle = NewCheckbox("Scripts", "Elements", "Hide Broken"),
    DistanceToggle = NewCheckbox("Scripts", "Elements", "Distance"),

    MinDistanceValue = NewSliderInt("Scripts", "Elements", "Min Distance", 0, 3000, 0),
    MaxDistanceValue = NewSliderInt("Scripts", "Elements", "Max Distance", 0, 3000, 700),

    FontValue = NewSliderInt("Scripts", "Elements", "Font", 0, 2, 0),
}

local NameMap = {
    Shiv = "Shiv",
    Wrench = "Wrench",
    HammerPart = "Revolver",
    SupressorPart = "Supressed Weapon (Unknown)",
    WeaponHandle = "Weapon (Unknown)",
    HandleMeshPart = "Sellable"
}

local function TranslateDropped(Item)
    for Child, Translation in pairs(NameMap) do
        if FindFirstChild(Item, Child) then
            return Translation
        end
    end

    return "(Unknown)"
end

local function Render(Part, Text, Color)
    local Character = GetLocalPlayer()
    local LocalPosition = Vector(GetCharacterPosition(Character))
    local Position = Vector(GetPosition(Part))
    local Dist = GetDist(LocalPosition, Position)

    if Dist >= Get(Interface.MaxDistanceValue) or Dist <= Get(Interface.MinDistanceValue) then return end
    local ScreenPositionX, ScreenPositionY = WorldToScreen(Position:unpack())

    if ScreenPositionX and ScreenPositionY and ScreenPositionX > 0 and ScreenPositionY > 0 then
        local Width, Height = MeasureText(0, false, Text)
        DrawText(ScreenPositionX - Width / 2, ScreenPositionY - Height / 2, Color[1], Color[2], Color[3], Color[4], Get(Interface.FontValue), false, Text)

        if Get(Interface.DistanceToggle) then
            local _, Height = MeasureText(0, false, Dist)
            DrawText(ScreenPositionX - Width / 2, ScreenPositionY + Height / 1, Color[1], Color[2], Color[3], Color[4], Get(Interface.FontValue), false, string.format("%s studs", math.floor(Dist)))
        end
    end
end

local function ProcessItems(Category, Toggle, Picker, GetText, GetPart)
    if not Get(Toggle) then return end

    for _, Item in next, GetChildren(Category) do
        local Part = GetPart(Item)

        if Part then
            Render(Part, GetText(Item), Get(Picker))
        end
    end
end

cheat.set_callback("paint", function()
    ProcessItems(Piles, Interface.ScrapToggle,      Interface.ScrapPicker,      function() return "Scrap" end, function(Item) return FindFirstChild(Item, "MeshPart") end)
    ProcessItems(Tools, Interface.ItemToggle,       Interface.ItemPicker,       TranslateDropped, function(Item) return FindFirstChildOfClass(Item, "Part") or FindFirstChildOfClass(Item, "MeshPart") end)
    ProcessItems(Cash, Interface.CashToggle,        Interface.CashPicker,       function(Item) return string.format("Cash (%s)", FindFirstChild(Item, "Value"):get_int_value()) end, function(Item) return Item end)
    ProcessItems(Shops, Interface.DealerToggle,     Interface.DealerPicker,     function(Item) return (GetName(Item) == "ArmoryDealer" and "Dealer (Armory)") or "Dealer" end, function(Item) return FindFirstChild(Item, "MainPart") end)
    ProcessItems(ATMs, Interface.ATMToggle,         Interface.ATMPicker,        function() return "ATM" end, function(Item) return FindFirstChild(Item, "MainPart") end)
    ProcessItems(Vending, Interface.VendingToggle,  Interface.VendingPicker,    function() return "Vending Machine" end, function(Item) return FindFirstChild(Item, "MainPart") end)

    if Get(Interface.SmallSafeToggle) or Get(Interface.MediumSafeToggle) or Get(Interface.RegisterToggle) then
        for _, Thing in next, GetChildren(Money) do
            local Part, Values = FindFirstChild(Thing, "MainPart"), FindFirstChild(Thing, "Values")
            local Broken = Values and FindFirstChild(Values, "Broken")

            if not Part or not Values or (Get(Interface.HideBrokenToggle) and Broken:get_int_value() > 0) then goto continue end

            if Get(Interface.MediumSafeToggle) and string.find(GetName(Thing), "MediumSafe") then
                Render(Part, "Safe (Medium)", Get(Interface.MediumSafePicker))
            elseif Get(Interface.SmallSafeToggle) and string.find(GetName(Thing), "SmallSafe") then
                Render(Part, "Safe (Small)", Get(Interface.SmallSafePicker))
            elseif Get(Interface.RegisterToggle) and string.find(GetName(Thing), "Register") then
                Render(Part, "Register", Get(Interface.RegisterPicker))
            end

            ::continue::
        end
    end
end)