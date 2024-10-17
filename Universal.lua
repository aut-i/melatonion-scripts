local current_place_id = nil
local current_scripts = {}
local loading_scripts = false
local sleep_start = 0

local function load_scripts(urls)
    for _, url in ipairs(urls) do
        http.get(url, {}, function(response)
            if response then
                local success, err = loadstring(response)
                if success then
                    local script = success()
                    table.insert(current_scripts, script)
                else
                    utility.log("Error loading script: " .. err)
                end
            else
                utility.log("Failed to fetch script from URL: " .. url)
            end
        end)
    end
end

local function main()
    local place_id = game.get_place_id()
    
    local scripts = {
        [15327728308] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/Aftermath.lua", -- aftermath
        },
        [863266079] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/APOC%202%20SCRIPT.lua", -- apoc rising 2
        },
        [2788229376] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/Dahood%20Script.lua", -- dahood
            "https://raw.githubusercontent.com/stxchox/melatonin_scripts/refs/heads/main/money_esp.lua", -- dahood
        },
        [16033173781] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/Dahood%20Script.lua", -- dahood (macro server)
            "https://raw.githubusercontent.com/stxchox/melatonin_scripts/refs/heads/main/money_esp.lua", -- dahood(macro server)
        },
        [13800717766] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/fallen.lua", -- fallen
        },
        [15432890326] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/blackout.lua", -- blackout: revival
        },
        [4111023553] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/Deepwoken.lua", -- deepwoken
        },
        [328028363] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/TC2%20ESP.lua", -- typical colors 2
        },
        [3233893879] = {
            "https://raw.githubusercontent.com/setofcards/melatonin/refs/heads/main/grenades%20bb.lua", -- bad business
        },
        [8343259840] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/Criminality%20Lua.lua", -- criminality
        },
        [292439477] = {
            "https://raw.githubusercontent.com/setofcards/melatonin/refs/heads/main/grenades%20pf.lua", -- phantom forces
        },
        [301549746] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/CBRO.lua", -- CB:RO
        },
        [286090429] = {
            "https://raw.githubusercontent.com/aut-i/melatonion-scripts/refs/heads/main/Arsenal%20Mods.lua", -- Arsenal
        },
    }

    if place_id ~= current_place_id then
        current_place_id = place_id
        loading_scripts = true
        sleep_start = utility:get_tickcount()
    end

    if loading_scripts then
        if (utility:get_tickcount() - sleep_start) >= 5000 then
            loading_scripts = false
            local script_urls = scripts[place_id]
            if script_urls then
                load_scripts(script_urls)
            else
                utility.log("No script available for this PlaceId: " .. place_id)
            end
        end
    end
end

cheat.set_callback("update", main)
