local game = game.get_data_model()
local workspace_folder = game:find_first_child_of_class("Workspace")

local elements = {
    ["Vehicles"] = ui.new_checkbox("Scripts", "Elements", "Vehicles"),
    ["Vehicles Color"] = ui.new_colorpicker("Scripts", "Elements", "Vehicles Color", 255, 255, 0, 255, true),
    ["Vehicles Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Distance"),
    ["Vehicles Distance"] = ui.new_slider_int("Scripts", "Elements", "Vehicles Distance", 0, 1200, 0),
    ["Landmarks"] = ui.new_checkbox("Scripts", "Elements", "Landmarks"),
    ["Landmarks Color"] = ui.new_colorpicker("Scripts", "Elements", "Landmarks Color", 0, 255, 255, 255, true),
    ["Landmarks Distance ESP"] = ui.new_checkbox("Scripts", "Elements", "Landmarks Distance ESP"),
    ["Landmarks Distance"] = ui.new_slider_int("Scripts", "Elements", "Landmarks Distance", 0, 1200, 0),
}


local g_vehicles = {}
local g_landmarks = {}

local function on_update()

    if (ui.get(elements["Vehicles"])) then
        local vehicles = workspace_folder:find_first_child("Vehicles")
        g_vehicles = {}
        for _, vehicle_folder in pairs(vehicles:get_children()) do

            g_vehicles[#g_vehicles + 1] = {
                name = vehicle_folder:get_name(),
                pos = vector(vehicle_folder:get_position())
            }
        end
    end

    if (ui.get(elements["Landmarks"])) then
        local ignored = workspace_folder:find_first_child("Ignored")
        local shop = ignored:find_first_child("Shop")
        g_landmarks = {}
    
        for _, landmark_folder in pairs(shop:get_children()) do

            local main = landmark_folder:find_first_child("Head")
            if not main then
                main = landmark_folder:find_first_child("ClickDetector")
            end  

            g_landmarks[#g_landmarks + 1] = {
                name = landmark_folder:get_name(),
                pos = vector(main:get_position())
            }
        end  
    end
end

local function on_paint()
    local local_player = entity.get_local_player()
    local local_position = vector(local_player:get_position())

    if (ui.get(elements["Vehicles"])) then
        for _, vehicle in pairs(g_vehicles) do
        
            local distance = local_position:dist_to(vehicle.pos)
            distance = math.floor(distance + 0.5)
    
            local vehicle_slider_dist = (ui.get(elements["Vehicles Distance"]))
            if vehicle_slider_dist < distance then goto continue end    

            local screen_pos = vector(utility.world_to_screen(vehicle.pos:unpack()))
            if (screen_pos:is_zero()) then goto continue end
    
            local clr = ui.get(elements["Vehicles Color"])
            local w, h = render.measure_text(0, false, vehicle.name)
    
            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, vehicle.name)
            if (ui.get(elements["Vehicles Distance ESP"])) then
            render.text(screen_pos.x - w/2, screen_pos.y - h/2 + 7 , clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance).. "M")
            end
            ::continue::
        end
    end


    if (ui.get(elements["Landmarks"])) then
        for _, landmark in pairs(g_landmarks) do
        
            local distance = local_position:dist_to(landmark.pos)
            distance = math.floor(distance + 0.5)
    
            local landmark_distance_slider = (ui.get(elements["Landmarks Distance"]))
            if landmark_distance_slider < distance then goto continue end        
    
            local screen_pos = vector(utility.world_to_screen(landmark.pos:unpack()))
            if (screen_pos:is_zero()) then goto continue end
    
            local clr = ui.get(elements["Landmarks Color"])
            local w, h = render.measure_text(0, false, landmark.name)
    
            render.text(screen_pos.x - w / 2, screen_pos.y - h / 2, clr[1], clr[2], clr[3], clr[4], 0, false, landmark.name)
            if (ui.get(elements["Landmarks Distance ESP"])) then
                render.text(screen_pos.x - w/2, screen_pos.y - h/2 + 7 , clr[1], clr[2], clr[3], clr[4], 0, false, tostring(distance).. "M")
             end
            ::continue::
        end
    end
end

cheat.set_callback("update", on_update)
cheat.set_callback("paint", on_paint)