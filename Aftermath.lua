local game = game.get_data_model()
local workspace_folder = game:find_first_child_of_class("Workspace")
local world_assets = workspace_folder:find_first_child("world_assets")
local static_objects = world_assets:find_first_child("StaticObjects")
local misc = static_objects:find_first_child("Misc")
local game_assets = workspace_folder:find_first_child("game_assets")
local npcs = game_assets:find_first_child("NPCs")

local elements = {
    ["Zombies/NPCs"] = ui.new_checkbox("Scripts", "Elements", "Zombies/NPCs"),
    ["Zombies/NPCs Color"] = ui.new_colorpicker("Scripts", "Elements", "Zombies/NPCs Color", 255, 0, 255, 255, true),
    ["Zombies/NPCs Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Zombies/NPCs Distance ESP"),
    ["Zombies/NPCs Distance"] = ui.new_slider_int("Scripts", "Elements", "Zombies/NPCs Distance", 0, 1200, 300),
    ["Spawnables"] = ui.new_checkbox("Scripts", "Elements", "Spawnables (Performance Intensive)"),
    ["Spawnables Color"] = ui.new_colorpicker("Scripts", "Elements", "Spawnables Color", 255, 0, 255, 255, true),
    ["Spawnables Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Spawnables Distance ESP"),
    ["Spawnables Distance"] = ui.new_slider_int("Scripts", "Elements", "Spawnables Distance", 0, 1200, 300),
    ["Spawnables Types"] = ui.new_multiselect("Scripts", "Elements", "Spawnables Types", {"Weapon", "Bandage", "Antibiotics", "Ammo"}),
}


local g_zombies = {}
local g_spawnables = {}

local function contains(items, thing)
    for _, v in pairs(items) do
        if v == thing then
            return true
        end
    end
    return false
end

local function on_update()
    if (ui.get(elements["Zombies/NPCs"])) then

        g_zombies = {}
        for _, zombie in pairs(npcs:get_children()) do
            local main = zombie:find_first_child("HumanoidRootPart")
            
            if main then
                g_zombies[#g_zombies + 1] = {
                    name = "Zombie",
                    pos = vector(main:get_position())
                }
            end
        end
    end

    if (ui.get(elements["Spawnables"])) then
        g_spawnables = {}
        local selected_types = ui.get(elements["Spawnables Types"])

        for _, spawnable in pairs(misc:get_children()) do
            local spawnable_name = spawnable:get_name()
            local select_name = spawnable_name

            if spawnable_name:sub(1, 4) == "Ammo" then
                select_name = "Ammo"
            end

            if spawnable_name == "WorldModel" then
                select_name = "Weapon"
            end

            if contains(selected_types, select_name) then
                local main = nil
                for _, container in pairs(spawnable:get_children()) do
                    local container_class_name =  container:get_class_name()
                    if container_class_name == "Part" then
                        main = container
                    end

                    if not main and container_class_name == "MeshPart" then
                        main = container
                    end
                end

                if spawnable_name == "WorldModel" then spawnable_name = "Weapon" end
            
                if main then
                    g_spawnables[#g_spawnables + 1] = {
                        name = spawnable_name,
                        pos = vector(main:get_position())
                    }
                end
            end
        end
    end
end

local function on_paint()
    local local_player = entity.get_local_player()
    local local_position = vector(local_player:get_position())
    if (ui.get(elements["Zombies/NPCs"])) then
        for _, zombie in pairs(g_zombies) do
            
            local distance = local_position:dist_to(zombie.pos)
            distance = math.floor(distance + 0.5)
    
            local zombie_dist_slider = (ui.get(elements["Zombies/NPCs Distance"]))
            if zombie_dist_slider < distance then goto continue end        

            local screen_pos = vector(utility.world_to_screen(zombie.pos:unpack()))
            if (screen_pos:is_zero()) then goto continue end
    
            local clr = ui.get(elements["Zombies/NPCs Color"])
            local w, h = render.measure_text(0, false, zombie.name)
    
            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, zombie.name)
            if (ui.get(elements["Zombies/NPCs Distance ESP"])) then
                local w1, h1 = render.measure_text(0, false, distance)
                render.text(screen_pos.x - w1/2, screen_pos.y - h1/2 + 7 , clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance).. "M")
            end
            ::continue::
        end
    end
    if (ui.get(elements["Spawnables"])) then
        for _, spawnable in pairs(g_spawnables) do
            
            local distance = local_position:dist_to(spawnable.pos)
            distance = math.floor(distance + 0.5)
    
            local spawnables_dist_slider = (ui.get(elements["Spawnables Distance"]))
            if spawnables_dist_slider < distance then goto continue end        

            local screen_pos = vector(utility.world_to_screen(spawnable.pos:unpack()))
            if (screen_pos:is_zero()) then goto continue end
    
            local clr = ui.get(elements["Spawnables Color"])
            local w, h = render.measure_text(0, false, spawnable.name)
    
            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, spawnable.name)
            if (ui.get(elements["Spawnables Distance ESP"])) then
                local w2, h2 = render.measure_text(0, false, distance)
                render.text(screen_pos.x - w2/2, screen_pos.y - h2/2 + 7 , clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance).. "M")
            end
            ::continue::
        end
    end
end

cheat.set_callback("update", on_update)
cheat.set_callback("paint", on_paint)