local game = game.get_data_model()
local workspace_folder = game:find_first_child_of_class("Workspace")
local military = workspace_folder:find_first_child("Military")
local window_width, window_height = cheat.get_window_size()

local elements = {
    ["Anti-Clutter"] = ui.new_checkbox("Scripts", "Elements", "Anti-Clutter"),
    ["Soldier ESP"] = ui.new_checkbox("Scripts", "Elements", "Soldier ESP"),
    ["Soldier Color"] = ui.new_colorpicker("Scripts", "Elements", "Soldier Color", 255, 0, 0, 255, true),
    ["Soldier Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Soldier Distance ESP"),
    ["Soldier Tracers"] = ui.new_checkbox("Scripts", "Elements", "Soldier Tracers"),
    ["Soldier Distance"] = ui.new_slider_int("Scripts", "Elements", "Soldier Distance", 0, 3000, 500),
    ["Ore ESP"] = ui.new_checkbox("Scripts", "Elements", "Ore ESP"),
    ["Ore Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Ore Distance ESP"),
    ["Ore Tracers"] = ui.new_checkbox("Scripts", "Elements", "Ore Tracers"),
    ["Stone"] = ui.new_checkbox("Scripts", "Elements", "Stone"),
    ["Stone Color"] = ui.new_colorpicker("Scripts", "Elements", "Stone Color", 127, 127, 127, 255, true),
    ["Metal"] = ui.new_checkbox("Scripts", "Elements", "Metal"),
    ["Metal Color"] = ui.new_colorpicker("Scripts", "Elements", "Metal Color", 255, 155, 0, 255, true),
    ["Phosphate"] = ui.new_checkbox("Scripts", "Elements", "Phosphate"),
    ["Phosphate Color"] = ui.new_colorpicker("Scripts", "Elements", "Phosphate Color", 238, 229, 127, 255, true),
    ["Plants"] = ui.new_checkbox("Scripts", "Elements", "Plants"),
    ["Plants Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Plants Distance ESP"),
    ["Plants Tracers"] = ui.new_checkbox("Scripts", "Elements", "Plants Tracers"),
    ["Plants Distance"] = ui.new_slider_int("Scripts", "Elements", "Plants Distance", 0, 4000, 2000),
    ["Wool"] = ui.new_checkbox("Scripts", "Elements", "Wool"),
    ["Wool Color"] = ui.new_colorpicker("Scripts", "Elements", "Wool Color", 0, 255, 0, 255, true),
    ["Raspberry"] = ui.new_checkbox("Scripts", "Elements", "Raspberry"),
    ["Raspberry Color"] = ui.new_colorpicker("Scripts", "Elements", "Raspberry Color", 0, 255, 0, 255, true),
    ["Corn"] = ui.new_checkbox("Scripts", "Elements", "Corn"),
    ["Corn Color"] = ui.new_colorpicker("Scripts", "Elements", "Corn Color", 0, 255, 0, 255, true),
    ["Tomato"] = ui.new_checkbox("Scripts", "Elements", "Tomato"),
    ["Tomato Color"] = ui.new_colorpicker("Scripts", "Elements", "Tomato Color", 0, 255, 0, 255, true),
    ["Blueberry"] = ui.new_checkbox("Scripts", "Elements", "Blueberry"),
    ["Blueberry Color"] = ui.new_colorpicker("Scripts", "Elements", "Blueberry Color", 0, 255, 0, 255, true),
    ["Lemon"] = ui.new_checkbox("Scripts", "Elements", "Lemon"),
    ["Lemon Color"] = ui.new_colorpicker("Scripts", "Elements", "Lemon Color", 0, 255, 0, 255, true),
}

local g_nodes = {}
local g_plants = {}
local g_soldiers = {}

local function on_update()
    if ui.get(elements["Ore ESP"]) then
        local nodes_folder = workspace_folder and workspace_folder:find_first_child("Nodes")
        if nodes_folder then
            g_nodes = {}
            for _, node_folder in pairs(nodes_folder:get_children()) do
                local main = node_folder:find_first_child("Main")
                if main then
                    g_nodes[#g_nodes + 1] = {
                        name = node_folder:get_name(),
                        pos = vector(main:get_position())
                    }
                end
            end
        end
    end

    if ui.get(elements["Soldier ESP"]) and military then
        g_soldiers = {}
        for _, bases in pairs(military:get_children()) do
            for _, soldier_folder in pairs(bases:get_children()) do
                if soldier_folder:get_name() == "Soldier" then
                    local main = soldier_folder:find_first_child("HumanoidRootPart")
                    if main then
                        g_soldiers[#g_soldiers + 1] = {
                            name = "Soldier",
                            pos = vector(main:get_position())
                        }
                    end
                end
            end
        end
    end

    if ui.get(elements["Plants"]) then
        local plants_folder = workspace_folder and workspace_folder:find_first_child("Plants")
        if plants_folder then
            g_plants = {}
            for _, plant_folder in pairs(plants_folder:get_children()) do
                local main = plant_folder:find_first_child("Main")
                if main then
                    g_plants[#g_plants + 1] = {
                        name = plant_folder:get_name(),
                        pos = vector(main:get_position())
                    }
                end
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

    if ui.get(elements["Soldier ESP"]) then
        for _, soldier in pairs(g_soldiers) do
            local distance = local_position:dist_to(soldier.pos)
            distance = math.floor(distance + 0.5)

            local soldier_dist_slider = ui.get(elements["Soldier Distance"])
            if soldier_dist_slider < distance then goto continue end

            local screen_pos = vector(utility.world_to_screen(soldier.pos:unpack()))
            if screen_pos:is_zero() then goto continue end

            local clr = ui.get(elements["Soldier Color"])
            local w, h = render.measure_text(0, false, soldier.name)

            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, soldier.name)
            if ui.get(elements["Soldier Distance ESP"]) then
                render.text(screen_pos.x - w / 2, screen_pos.y - h / 2 + 7, clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance) .. "M")
            end

            if ui.get(elements["Soldier Tracers"]) then
                render.line(window_width / 2, 0, screen_pos.x, screen_pos.y, clr[1], clr[2], clr[3], clr[4], 1)
            end
            ::continue::
        end
    end

    if ui.get(elements["Ore ESP"]) then
        local ore_types = {"Stone", "Metal", "Phosphate"}
        for _, ore_type in ipairs(ore_types) do
            if ui.get(elements[ore_type]) then
                local items_to_draw = {}
                for _, node in pairs(g_nodes) do
                    if node.name:match(ore_type) then
                        table.insert(items_to_draw, node)
                    end
                end

                if ui.get(elements["Anti-Clutter"]) then
                    local closest_item = get_closest(items_to_draw, local_position)
                    if closest_item then
                        items_to_draw = { closest_item }
                    else
                        items_to_draw = {}
                    end
                end

                for _, node in pairs(items_to_draw) do
                    local clean_name = node.name:match("([^_]+)")
                    if not ui.get(elements[clean_name]) then goto continue end

                    local screen_pos = vector(utility.world_to_screen(node.pos:unpack()))
                    if screen_pos:is_zero() then goto continue end

                    local clr = ui.get(elements[clean_name .. " Color"])
                    local w, h = render.measure_text(0, false, clean_name)

                    local distance = local_position:dist_to(node.pos)
                    distance = math.floor(distance + 0.5)

                    render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, clean_name)
                    if ui.get(elements["Ore Distance ESP"]) then
                        render.text(screen_pos.x - w / 2, screen_pos.y - h / 2 + 7, clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance) .. "M")
                    end
                    if ui.get(elements["Ore Tracers"]) then
                        render.line(window_width / 2, 0, screen_pos.x, screen_pos.y, clr[1], clr[2], clr[3], clr[4], 1)
                    end
                    ::continue::
                end
            end
        end
    end

    if ui.get(elements["Plants"]) then
        local plant_types = {"Wool", "Raspberry", "Corn", "Tomato", "Blueberry", "Lemon"}
        for _, plant_type in ipairs(plant_types) do
            if ui.get(elements[plant_type]) then
                local items_to_draw = {}
                for _, plant in pairs(g_plants) do
                    if plant.name:match(plant_type) then
                        table.insert(items_to_draw, plant)
                    end
                end

                if ui.get(elements["Anti-Clutter"]) then
                    local closest_item = get_closest(items_to_draw, local_position)
                    if closest_item then
                        items_to_draw = { closest_item }
                    else
                        items_to_draw = {}
                    end
                end

                for _, plant in pairs(items_to_draw) do
                    local distance = local_position:dist_to(plant.pos)
                    distance = math.floor(distance + 0.5)

                    local plant_slider_dist = ui.get(elements["Plants Distance"])
                    if plant_slider_dist < distance then goto continue end

                    local clean_name = plant.name:match("([^_]+) ")
                    if not ui.get(elements[clean_name]) then goto continue end

                    local screen_pos = vector(utility.world_to_screen(plant.pos:unpack()))
                    if screen_pos:is_zero() then goto continue end

                    local clr = ui.get(elements[clean_name .. " Color"])
                    local w, h = render.measure_text(0, false, clean_name)

                    render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, clean_name)
                    if ui.get(elements["Plants Distance ESP"]) then
                        render.text(screen_pos.x - w / 2, screen_pos.y - h / 2 + 7, clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance) .. "M")
                    end

                    if ui.get(elements["Plants Tracers"]) then
                        render.line(window_width / 2, 0, screen_pos.x, screen_pos.y, clr[1], clr[2], clr[3], clr[4], 1)
                    end
                    ::continue::
                end
            end
        end
    end
end

print("free xix")
cheat.set_callback("update", on_update)
cheat.set_callback("paint", on_paint)
