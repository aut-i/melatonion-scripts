local data = game.get_data_model()
local replicated_storage = data:find_first_child("ReplicatedStorage")
local weapons = replicated_storage:find_first_child("Weapons")
for _, v in pairs(weapons:get_descendants()) do
    local name = v:get_name();
    if (name == "FireRate") then
        v:set_number_value(0);
    end
    if (name == "Ammo" or name == "StoredAmmo") then
        v:set_int_value(999999999);
    end
    if (name == "Spread") then
        for i, spread in pairs(v:get_children()) do
            spread:set_number_value(0);
        end
    end
end