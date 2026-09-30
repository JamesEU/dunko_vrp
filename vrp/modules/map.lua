
local client_areas = {}
local area_context = {}
local area_enter_tolerance = 3.0
local area_leave_tolerance = 6.0

-- free client areas when leaving
AddEventHandler("vRP:playerLeave",function(user_id,source)
  client_areas[source] = nil 
  area_context[source] = nil
end)

local function getPlayerCoords(source)
  local ped = GetPlayerPed(source)
  if ped == nil or ped == 0 or not DoesEntityExist(ped) then
    return nil
  end
  return GetEntityCoords(ped)
end

local function isNearArea(source, area, tolerance)
  local coords = getPlayerCoords(source)
  if coords == nil then
    return true
  end
  local dx, dy, dz = coords.x - area.x, coords.y - area.y, coords.z - area.z
  return math.sqrt(dx*dx + dy*dy + dz*dz) <= area.radius + tolerance and math.abs(dz) <= area.height + tolerance
end

local function callInAreaContext(source, name, cb, ...)
  local previous = area_context[source]
  area_context[source] = name
  local ok, err = pcall(cb, ...)
  area_context[source] = previous
  if not ok then
    error(err, 0)
  end
end

function vRP.getAreaContext(source)
  return area_context[source]
end

function vRP.callInAreaContext(source, name, cb, ...)
  if name == nil then
    return cb(...)
  end
  callInAreaContext(source, name, cb, ...)
end

function vRP.isInArea(source, name)
  local areas = client_areas[source]
  local area = areas and areas[name]
  return area ~= nil and area.inside == true and isNearArea(source, area, area_leave_tolerance)
end

-- create/update a player area
function vRP.setArea(source,name,x,y,z,radius,height,cb_enter,cb_leave)
  local areas = client_areas[source] or {}
  client_areas[source] = areas

  areas[name] = {enter=cb_enter,leave=cb_leave,x=tonumber(x) or 0,y=tonumber(y) or 0,z=tonumber(z) or 0,radius=tonumber(radius) or 1,height=tonumber(height) or 6,inside=false}
  vRPclient.setArea(source,{name,x,y,z,radius,height})
end

-- delete a player area
function vRP.removeArea(source,name)
  -- delete remote area
  vRPclient.removeArea(source,{name})

  -- delete local area
  local areas = client_areas[source]
  if areas then
    areas[name] = nil
  end
end

-- TUNNER SERVER API

function tvRP.enterArea(name)
  local source = source
  local areas = client_areas[source]
  if areas then
    local area = areas[name] 
    if area and not area.inside then
      if not isNearArea(source, area, area_enter_tolerance) then
        Wait(1000)
        if client_areas[source] ~= areas or areas[name] ~= area or area.inside or not isNearArea(source, area, area_enter_tolerance) then
          return
        end
      end
      area.inside = true
      area.outside_ticks = 0
      if area.enter then
        callInAreaContext(source, name, area.enter, source, name)
      end
    end
  end
end

function tvRP.leaveArea(name)
  local source = source
  local areas = client_areas[source]

  if areas then
    local area = areas[name] 
    if area and area.inside then
      area.inside = false
      if area.leave then
        area.leave(source,name)
      end
    end
  end
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000)
    local left = {}
    for source, areas in pairs(client_areas) do
      for name, area in pairs(areas) do
        if area.inside then
          if isNearArea(source, area, area_leave_tolerance) then
            area.outside_ticks = 0
          else
            area.outside_ticks = (area.outside_ticks or 0) + 1
            if area.outside_ticks >= 2 then
              area.inside = false
              area.outside_ticks = 0
              table.insert(left, {source, name, area})
            end
          end
        end
      end
    end
    for _, v in ipairs(left) do
      if v[3].leave then
        local ok, err = pcall(v[3].leave, v[1], v[2])
        if not ok then
          print("[vRP] area leave error: "..tostring(err))
        end
      end
    end
  end
end)


local cfg = module("cfg/blips_markers")

-- add additional static blips/markers
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    for k,v in pairs(cfg.blips) do
      vRPclient.addBlip(source,{v[1],v[2],v[3],v[4],v[5],v[6]})
    end

    for k,v in pairs(cfg.markers) do
      vRPclient.addMarker(source,{v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11]})
    end
  end
end)
