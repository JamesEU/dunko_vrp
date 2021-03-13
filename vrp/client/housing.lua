local cfg = module("cfg/homes")
local entry_points = cfg.homes
local inHouseMarker = false;
local ownedHouse = false;
local isHouseForSale = false;
local ownerOfHouse = "";

RMenu.Add('vRPHouse', 'main', RageUI.CreateMenu("Real Estate", "~b~Housing",1250,100))



RageUI.CreateWhile(1.0, true, function()

    if RageUI.Visible(RMenu:Get('vRPHouse', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
            if ownedHouse then 
                RageUI.Button("Enter House", "", {}, true, function(Hovered, Active, Selected) 
                end)
                RageUI.Button("Sell House", "", {}, true, function(Hovered, Active, Selected) 
                end)
            end
            if isHouseForSale then 
                RageUI.Button("Buy House", "", {}, true, function(Hovered, Active, Selected) 
                end)
            end
            if not isHouseForSale then 
                RageUI.Button("Request to Enter House", "", {}, true, function(Hovered, Active, Selected) 
                end) 
            end
            if not ownedHouse then 
                
                RageUI.Button("Owner", "The Owner Is: " .. ownerOfHouse, {}, true, function(Hovered, Active, Selected) 
                end)
            end
        end)
    end
end)




Citizen.CreateThread(function()
    while true do 
        Wait(250)
        local plrCoord = GetEntityCoords(PlayerPedId())
        inHouseMarker = false;
        for i,v in pairs(entry_points) do 
            local name = i
            local enternacex,enterancey,enterancez = v.entry_point[1], v.entry_point[2], v.entry_point[3]
            if #(plrCoord - vec3(enternacex,enterancey,enterancez)) <= 3.0 then 
                inHouseMarker = true; 
                break
            end
        end
    end
end)

local MenuOpen = false;
Citizen.CreateThread(function()
    while true do 
        Wait(0)
        if inHouseMarker and not MenuOpen then 
            RageUI.Visible(RMenu:Get('vRPHouse', 'main'), true) 
            MenuOpen = true;
        elseif not inHouseMarker and  MenuOpen then 
            RageUI.ActuallyCloseAll()
            MenuOpen = false;
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