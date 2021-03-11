local cfg = module("cfg/homes")
local entry_points = cfg.homes
local inHouseMarker = false;







Citizen.CreateThread(function()
    while true do 
        Wait(250)
        local plrCoord = GetEntityCoords(PlayerPedId())
        for i,v in pairs(entry_points) do 
            local name = i
            local enternacex,enterancey,enterancez = v.entry_point[1], v.entry_point[2], v.entry_point[3]
            if #(plrCoord - vec3(enternacex,enterancey,enterancez)) <= 5.0 then 
                inHouseMarker = true; 
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        local plrCoord = GetEntityCoords(PlayerPedId())
        for i,v in pairs(entry_points) do 
            local name = i
            local enternacex,enterancey,enterancez = v.entry_point[1], v.entry_point[2], v.entry_point[3]
            if #(plrCoord - vec3(enternacex,enterancey,enterancez)) <= 50.0 then 
                if not HasStreamedTextureDictLoaded("houses") then
                    RequestStreamedTextureDict("houses", true)
                    while not HasStreamedTextureDictLoaded("houses") do
                        Wait(1)
                    end
                else
                    DrawMarker(9, enternacex, enterancey, enterancez, 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 51, 153, 255, 1.0,false, false, 2, true, "houses", "house", false)
                end 
            end
        end
    end
end)