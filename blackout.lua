local game = game.get_data_model()
local workspace_folder = game:find_first_child_of_class("Workspace")
local npcs = workspace_folder and workspace_folder:find_first_child("NPCs")
local hostiles = npcs and npcs:find_first_child("Hostile")

local elements = {
    ["NPCs"] = ui.new_checkbox("Scripts", "Elements", "NPCs"),
    ["NPC Types"] = ui.new_multiselect("Scripts", "Elements", "NPC Types", {"Military Scout", "Military Guard", "Military Commander", "Vulture Scout", "Vulture Guard", "Rebel Scout", "Rebel Guard"}),
    ["Box"] = ui.new_checkbox("Scripts", "Elements", "Box"),
    ["Box Color"] = ui.new_colorpicker("Scripts", "Elements", "Box Color", 210, 107, 255, 255, true),
    ["Name"] = ui.new_checkbox("Scripts", "Elements", "Name"),
    ["Name Color"] = ui.new_colorpicker("Scripts", "Elements", "Name Color", 253, 251, 12, 255, true),
    ["Distance Text"] = ui.new_checkbox("Scripts", "Elements", "Distance Text"),
    ["Distance Color"] = ui.new_colorpicker("Scripts", "Elements", "Distance Color", 210, 107, 255, 255, true),
    ["Weapon"] = ui.new_checkbox("Scripts", "Elements", "Weapon"),
    ["Weapon Color"] = ui.new_colorpicker("Scripts", "Elements", "Weapon Color", 210, 107, 255, 255, true),
    ["Healthbar"] = ui.new_checkbox("Scripts", "Elements", "Healthbar"),
    ["Render Distance"] = ui.new_slider_int("Scripts", "Elements", "Render Distance", 0, 1500, 500),
}

local g_npcs = {}

function get_weapon_name(npc)
    local ray = npc:find_first_child_of_class("RayValue")
    if ray then 
        return ray:get_name()
    end
    return ""
end

local function contains(items, thing)
    for _, v in pairs(items) do
        if v == thing then
            return true
        end
    end
    return false
end

function getnpcbbox(npc)
    if not npc.bones or not npc.bones["HumanoidRootPart"] then
        return 0, 0, 0, 0
    end

    local screen_bottom = vector(utility.world_to_screen(npc.bones["HumanoidRootPart"]:unpack()))
    local screen_top = vector(utility.world_to_screen(npc.bones["HumanoidRootPart"]:unpack()))

    if screen_bottom:is_zero() or screen_top:is_zero() then
        return 0, 0, 0, 0
    end

    local height = math.abs(screen_bottom.y - 20 - screen_top.y)
    local width = height * 1.25
    height = width * 1.50
    local x = screen_top.x
    local y = screen_top.y - 20
    x = x - (width / 2)
    y = y - (height / 8)
    return x, y, width, height
end

local function on_update()
    if ui.get(elements["NPCs"]) then
        g_npcs = {}
        local selected_types = ui.get(elements["NPC Types"])

        if hostiles then
            for _, npc in pairs(hostiles:get_children()) do
                local bones = {}
                local npc_name = npc:get_name()
                local weapon_name = ""
                local maxhealth = 100
                local health = 0

                if ui.get(elements["Weapon"]) then
                    weapon_name = get_weapon_name(npc)
                end

                if ui.get(elements["Healthbar"]) then
                    local humanoid = npc:find_first_child("Humanoid")
                    if humanoid then
                        health = humanoid:get_health()
                        maxhealth = humanoid:get_max_health()
                    end
                end

                if contains(selected_types, npc_name) then
                    for _, bone in pairs(npc:get_children()) do
                        if bone then
                            local bone_name = bone:get_name()
                            if bone_name == "HumanoidRootPart" or bone_name == "Head" then
                                local bone_pos = vector(bone:get_position())
                                bones[bone_name] = bone_pos
                            end
                        end
                    end

                    g_npcs[#g_npcs + 1] = {
                        name = npc_name,
                        bones = bones,
                        weapon = weapon_name,
                        current_health = health,
                        max_health = maxhealth,
                    }
                end
            end
        end
    end
end

local function on_paint()
    local local_player = entity.get_local_player()
    local local_position = vector(local_player:get_position())

    if ui.get(elements["NPCs"]) then
        for _, npc in pairs(g_npcs) do
            if npc.bones and npc.bones["HumanoidRootPart"] then
                local distance = local_position:dist_to(npc.bones["HumanoidRootPart"])
                distance = math.floor(distance + 0.5)

                local vehicle_slider_dist = ui.get(elements["Render Distance"])
                if vehicle_slider_dist < distance then goto continue end     

                local x3, y3, w3, h3 = getnpcbbox(npc)

                if ui.get(elements["Name"]) then
                    local clr = ui.get(elements["Name Color"])
                    local w, h = render.measure_text(0, false, npc.name)
                    render.text(x3 + w3 / 2 - w / 2, y3 - h - 2, clr[1], clr[2], clr[3], clr[4], 0, false, npc.name)
                end

                local weapon_y_offset = 0

                if ui.get(elements["Weapon"]) then
                    local clr4 = ui.get(elements["Weapon Color"])
                    local w4, h4 = render.measure_text(0, false, npc.weapon)
                    weapon_y_offset = h4 + 1
                    render.text(x3 + w3 / 2 - w4 / 2, y3 + h3 + 2, clr4[1], clr4[2], clr4[3], clr4[4], 0, false, npc.weapon)
                end

                if ui.get(elements["Distance Text"]) then
                    local clr1 = ui.get(elements["Distance Color"])
                    local w1, h1 = render.measure_text(0, false, tostring(distance))
                    render.text(x3 + w3 / 2 - w1 / 2, y3 + h3 + weapon_y_offset + 2, clr1[1], clr1[2], clr1[3], clr1[4], 0, false, tostring(distance) .. "m")
                end

                if ui.get(elements["Box"]) then
                    local clr3 = ui.get(elements["Box Color"])
                    render.rect_outline(x3 - 1, y3 - 1, w3 + 2, h3 + 2, 0, 0, 0, 127)
                    render.rect_outline(x3 + 1, y3 + 1, w3 - 2, h3 - 2, 0, 0, 0, 127)
                    render.rect_outline(x3, y3, w3, h3, clr3[1], clr3[2], clr3[3], clr3[4])
                end

                if ui.get(elements["Healthbar"]) then
                    local healthbar_x = x3 - 4
                    local healthbar_y_start = y3
                    local healthbar_y_end = y3 + h3
                    render.rect_outline(healthbar_x - 1, healthbar_y_start - 1, 2, h3 + 2, 0, 0, 0, 255)

                    local health_percentage = npc.current_health / npc.max_health
                    local health_height = h3 * health_percentage  
                    render.rect(healthbar_x, healthbar_y_end - health_height, 2, health_height, 0, 255, 0, 255)
                end
            end

            ::continue::
        end
    end
end

cheat.set_callback("update", on_update)
cheat.set_callback("paint", on_paint)
