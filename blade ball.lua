local ball_dist = ui.new_slider_int("Scripts", "Elements", "Distance", 0, 60, 35)

cheat.set_callback("paint", function()
    local workspace = game:get_workspace()
    local players = entity.get_players(true)
    local localPlayer = entity.get_local_player()
    local localPosition = vector(localPlayer:get_position())
    local balls = workspace:find_first_child("Balls")

    local playerAlive = workspace:find_first_child("Alive"):find_first_child(localPlayer:get_name())

    if playerAlive then
        local highlight = playerAlive:find_first_child("Highlight")
        if highlight and balls then

            for _, ball in pairs(balls:get_children()) do

                if (ball:get_class_name() == "Part") then
                    local ballPos = vector(ball:get_position())
    
                    if ballPos.x == 0 then goto continue end
                    local distance = localPosition:dist_to(ballPos)
                    distance = math.floor(distance + 0.5)
        
                    local threshold = (ui.get(ball_dist))
                    if distance < threshold then
                        input.mouse_click(1)
                    end
                end

                if (ball:get_name() == "Ball") then

                    local center = ball:find_first_child("Body"):find_first_child("Center")
                    local ballPos = vector(center:get_position())
    
                    if ballPos.x == 0 then goto continue end
                    local distance = localPosition:dist_to(ballPos)
                    distance = math.floor(distance + 0.5)
        
                    local threshold = (ui.get(ball_dist))
                    if distance < threshold then
                        input.mouse_click(1)
                    end
                end
            end
            ::continue::
        end
    end
end)