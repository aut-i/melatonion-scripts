local game = game.get_data_model()
local workspace_folder = game:find_first_child_of_class("Workspace")
local window_width, window_height = cheat.get_window_size()

local elements = {
    ["Anti-Clutter (For Ingredients)"] = ui.new_checkbox("Scripts", "Elements", "Anti-Clutter (For Ingredients)"),
    ["Ingredients ESP"] = ui.new_checkbox("Scripts", "Elements", "Ingredients ESP"),
    ["Ingredients Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Ingredients Distance ESP"),
    ["Ingredients Tracers"] = ui.new_checkbox("Scripts", "Elements", "Ingredients Tracers"),
    ["Ingredients Color"] = ui.new_colorpicker("Scripts", "Elements", "Ingredients Color", 150, 150, 0, 255, true),
    ["Ingredients Distance"] = ui.new_slider_int("Scripts", "Elements", "Ingredients Distance", 0, 2000, 1000),
    ["Mobs ESP"] = ui.new_checkbox("Scripts", "Elements", "Mobs ESP"),
    ["Mobs Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Mobs Distance ESP"),
    ["Mobs Tracers"] = ui.new_checkbox("Scripts", "Elements", "Mobs Tracers"),
    ["Mobs Color"] = ui.new_colorpicker("Scripts", "Elements", "Mobs Color", 255, 0, 0, 255, true),
    ["Mobs Distance"] = ui.new_slider_int("Scripts", "Elements", "Mobs Distance", 0, 2000, 1000),
    ["NPCs ESP"] = ui.new_checkbox("Scripts", "Elements", "NPCs ESP"),
    ["NPCs Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "NPCs Distance ESP"),
    ["NPCs Tracers"] = ui.new_checkbox("Scripts", "Elements", "NPCs Tracers"),
    ["NPCs Color"] = ui.new_colorpicker("Scripts", "Elements", "NPCs Color", 0, 0, 180, 255, true),
    ["NPCs Distance"] = ui.new_slider_int("Scripts", "Elements", "NPCs Distance", 0, 2000, 1000),
    ["AreaMarkers ESP"] = ui.new_checkbox("Scripts", "Elements", "AreaMarkers ESP"),
    ["AreaMarkers Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "AreaMarkers Distance ESP"),
    ["AreaMarkers Tracers"] = ui.new_checkbox("Scripts", "Elements", "AreaMarkers Tracers"),
    ["AreaMarkers Color"] = ui.new_colorpicker("Scripts", "Elements", "AreaMarkers Color", 150, 20, 150, 255, true),
    ["AreaMarkers Distance"] = ui.new_slider_int("Scripts", "Elements", "AreaMarkers Distance", 0, 15000, 4000),
}

local g_ingredients = {}
local g_mobs = {}
local g_npcs = {}
local g_aremarkers = {}

local function on_update()

    if ui.get(elements["AreaMarkers ESP"]) then
        local replicated = game:find_first_child("ReplicatedStorage");
        local markerworkspace = replicated:find_first_child("MarkerWorkspace");
        local AreaMarkers = markerworkspace:find_first_child("AreaMarkers");

        g_aremarkers = {}
        for _, areamarker in pairs(AreaMarkers:get_children()) do
            local root_part = areamarker:find_first_child("Part")
            if not root_part then
                root_part = areamarker:find_first_child("AreaMarker")
            end

            if root_part then
                g_aremarkers[#g_aremarkers + 1] = {
                    name = areamarker:get_name(),
                    pos = vector(root_part:get_position())
                }
            end
        end
    end

    if ui.get(elements["NPCs ESP"]) then
        local npcs = workspace_folder:find_first_child("NPCs")
        g_npcs = {}
        for _, npc in pairs(npcs:get_children()) do
            local root = npc:find_first_child("HumanoidRootPart")
            if root then
                g_npcs[#g_npcs + 1] = {
                    name = npc:get_name(),
                    pos = vector(root:get_position())
                }
            end
        end
    end

    if ui.get(elements["Ingredients ESP"]) then
        local ingredients = workspace_folder:find_first_child("Ingredients")
        g_ingredients = {}
        for _, ingredient in pairs(ingredients:get_children()) do
            g_ingredients[#g_ingredients + 1] = {
                name = ingredient:get_name(),
                pos = vector(ingredient:get_position())
            }
        end
    end

    if ui.get(elements["Mobs ESP"]) then
        local live = workspace_folder:find_first_child("Live")
        g_mobs = {}
        for _, mob in pairs(live:get_children()) do
            local root = mob:find_first_child("HumanoidRootPart")
            if root then
                g_mobs[#g_mobs + 1] = {
                    name = mob:get_name(),
                    pos = vector(root:get_position())
                }
            end
        end
    end
end

local function get_closest(items, local_position)
    local closest_item = nil
    local min_distance = math.huge
    for _, item in pairs(items) do
        local distance = local_position:dist_to(item.pos)
        if distance < min_distance then
            min_distance = distance
            closest_item = item
        end
    end
    return closest_item
end

local function on_paint()
    local local_player = entity.get_local_player()
    local local_position = vector(local_player:get_position())
    local local_name = local_player:get_name()
    
    if ui.get(elements["AreaMarkers ESP"]) then
        for _, areamarker in pairs(g_aremarkers) do

            local distance = local_position:dist_to(areamarker.pos)
            distance = math.floor(distance + 0.5)

            local areamarker_slider_dist = (ui.get(elements["AreaMarkers Distance"]))
            if areamarker_slider_dist < distance then goto continue end    

            local clean_name = areamarker.name:match("([^_]+)")
            local screen_pos = vector(utility.world_to_screen(areamarker.pos:unpack()))
            if screen_pos:is_zero() then goto continue end

            local clr = ui.get(elements["AreaMarkers Color"])
            local w, h = render.measure_text(0, false, areamarker.name) 

            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, areamarker.name)
            if ui.get(elements["AreaMarkers Distance ESP"]) then
                render.text(screen_pos.x - w / 2, screen_pos.y - h / 2 + 7, clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance) .. "M")
            end
            if ui.get(elements["AreaMarkers Tracers"]) then
                render.line(window_width / 2, 0, screen_pos.x, screen_pos.y, clr[1], clr[2], clr[3], clr[4], 1)
            end
            ::continue::
        end
    end

    if ui.get(elements["NPCs ESP"]) then
        for _, npc in pairs(g_npcs) do
            local distance = local_position:dist_to(npc.pos)
            distance = math.floor(distance + 0.5)

            local npc_slider_dist = (ui.get(elements["NPCs Distance"]))
            if npc_slider_dist < distance then goto continue end     

            local clean_name = npc.name:match("([^_]+)")
            local screen_pos = vector(utility.world_to_screen(npc.pos:unpack()))
            if screen_pos:is_zero() then goto continue end

            local clr = ui.get(elements["NPCs Color"])
            local w, h = render.measure_text(0, false, npc.name)

            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, npc.name)
            if ui.get(elements["NPCs Distance ESP"]) then
                render.text(screen_pos.x - w / 2, screen_pos.y - h / 2 + 7, clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance) .. "M")
            end
            if ui.get(elements["NPCs Tracers"]) then
                render.line(window_width / 2, 0, screen_pos.x, screen_pos.y, clr[1], clr[2], clr[3], clr[4], 1)
            end
            ::continue::
        end
    end

    if ui.get(elements["Ingredients ESP"]) then
        local anti_clutter_enabled = ui.get(elements["Anti-Clutter (For Ingredients)"])
        local ingredients_to_draw = g_ingredients

        local ingredient_types = {}
        if (anti_clutter_enabled) then
            for _, ingredient in pairs(ingredients_to_draw) do
                local ingredient_type = ingredient.name:match("^[^_]+")
                if not ingredient_types[ingredient_type] then
                    ingredient_types[ingredient_type] = get_closest(
                        { ingredient }, 
                        local_position
                    )
                else
                    local current_closest = ingredient_types[ingredient_type]
                    local current_distance = local_position:dist_to(current_closest.pos)
                    local new_distance = local_position:dist_to(ingredient.pos)
                    if new_distance < current_distance then
                        ingredient_types[ingredient_type] = ingredient
                    end
                end
            end
        else ingredient_types = g_ingredients
        end

        for _, ingredient in pairs(ingredient_types) do
            local distance = local_position:dist_to(ingredient.pos)
            distance = math.floor(distance + 0.5)

            local ingredients_slider_dist = (ui.get(elements["Ingredients Distance"]))
            if ingredients_slider_dist < distance then goto continue end     

            local screen_pos = vector(utility.world_to_screen(ingredient.pos:unpack()))
            if screen_pos:is_zero() then goto continue end

            local clr = ui.get(elements["Ingredients Color"])
            local w, h = render.measure_text(0, false, ingredient.name)


            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, ingredient.name)
            if ui.get(elements["Ingredients Distance ESP"]) then
                render.text(screen_pos.x - w / 2, screen_pos.y - h / 2 + 7, clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance) .. "M")
            end
            if ui.get(elements["Ingredients Tracers"]) then
                render.line(window_width / 2, 0, screen_pos.x, screen_pos.y, clr[1], clr[2], clr[3], clr[4], 1)
            end
            ::continue::
        end
    end

    if ui.get(elements["Mobs ESP"]) then
        for _, mob in pairs(g_mobs) do

            local distance = local_position:dist_to(mob.pos)
            distance = math.floor(distance + 0.5)

            local mobs_slider_dist = (ui.get(elements["Mobs Distance"]))
            if mobs_slider_dist < distance then goto continue end     

            local clean_name = mob.name:match("([^_]+)")
            if local_name == clean_name then goto continue end
            local screen_pos = vector(utility.world_to_screen(mob.pos:unpack()))
            if screen_pos:is_zero() then goto continue end

            local clr = ui.get(elements["Mobs Color"])
            local w, h = render.measure_text(0, false, mob.name)

            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, mob.name)
            if ui.get(elements["Mobs Distance ESP"]) then
                render.text(screen_pos.x - w / 2, screen_pos.y - h / 2 + 7, clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance) .. "M")
            end
            if ui.get(elements["Mobs Tracers"]) then
                render.line(window_width / 2, 0, screen_pos.x, screen_pos.y, clr[1], clr[2], clr[3], clr[4], 1)
            end

            ::continue::
        end
    end
end

print("free xix")
cheat.set_callback("update", on_update)
cheat.set_callback("paint", on_paint)
