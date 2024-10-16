local ExploitsButton = ui.new_button("Scripts", "Elements", "Apply Gun Exploits", function()
    local data = game.get_data_model()
    local replicated_storage = data:find_first_child("ReplicatedStorage")
    local weapons = replicated_storage:find_first_child("Weapons")

    if weapons then
        print("Applying mods")
        for _, v in pairs(weapons:get_descendants()) do
            local name = v:get_name()
            if name == "FireRate" or "BFireRate" then
                if v:get_number_value() > 0.21 then
                    v:set_number_value(0.21)
                end
            end
            if name == "StoredAmmo" then
                v:set_int_value(150)
            end
            if name == "ReloadTime" then
                v:set_number_value(0.1)
            end
            if name == "Speed" then
                v:set_int_value(99999)
            end
            if name == "Ammo" then
                v:set_int_value(100)
            end
            if name == "RecoilControl" then
                v:set_number_value(0.01)
            end
            if name == "Range" then
                v:set_int_value(9999)
            end
            if name == "Spread" or name == "MaxSpread" then
                v:set_int_value(0)
            end
            if name == "DMG" then
                v:set_number_value(1)
            end
            if name == "Auto" then
                v:set_int_value(1)
            end
        end
    else
        print("Weapons not found!")
    end
end)
