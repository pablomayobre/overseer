local Vector = require('libs.brinevector')
local universe = require('models.universe')
local camera = require('models.camera')

local ZoneSystem = ECS.System({ECS.c.zone, ECS.c.rect})

local lastZoneUpdate = love.timer.getTime()
local zoneUpdateInterval = 2

local zoneHandlers = {
  deconstruct = {
    run = function(self, zone, params, dt)
      local rect = zone:get(ECS.c.rect)

      local coords = universe.getOuterBorderCoordinates(
      math.min(rect.x1, rect.x2),
      math.min(rect.y1, rect.y2),
      math.max(rect.x1, rect.x2),
      math.max(rect.y1, rect.y2),
      true)

      local entities = universe.getEntitiesInCoordinates(coords, params.selector, params.componentRequirements)
      self:getWorld():emit("cancelConstruction", entities)
    end
  }
}

function ZoneSystem:init()

end

function ZoneSystem:update(dt)
  local currentTime = love.timer.getTime()
  if zoneUpdateInterval > currentTime - lastZoneUpdate then
    lastZoneUpdate = love.timer.getTime()
    self:tickZones(dt)
  end
end

function ZoneSystem:tickZones()
  for _, zone in ipairs(self.pool) do
    local zoneC = zone:get(ECS.c.zone)
    local type = zoneC.type
    local params = zoneC.params
    assert(zoneHandlers[type], "No such zone handler exists: " .. (type or "nil"))
    zoneHandlers[type].run(self, zone, params, dt)
  end
end

function ZoneSystem:generateGUIDraw()
  -- TODO: Optimize the _heck_ out of this. Possibly store pixel coords in rect component and then just draw here
  for _, entity in ipairs(self.pool) do
    local rect = entity:get(ECS.c.rect)

    local left = math.min(rect.x1, rect.x2)
    local top = math.min(rect.y1, rect.y2)
    local right = math.max(rect.x1, rect.x2)
    local bottom = math.max(rect.y1, rect.y2)
    local startPoint = universe.gridPositionToPixels(Vector(left, top), "left_top", 0)
    local endPoint = universe.gridPositionToPixels(Vector(right, bottom), "right_bottom", 0)

    if entity:has(ECS.c.color) then
      love.graphics.setColor(unpack(entity:get(ECS.c.color).color))
    else
      love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.rectangle("line",
      startPoint.x,
      startPoint.y,
      endPoint.x - startPoint.x,
      endPoint.y - startPoint.y
    )

    if entity:has(ECS.c.color) then
      local color = { unpack(entity:get(ECS.c.color).color) }
      color[4] = 0.1
      love.graphics.setColor(color)
    else
      love.graphics.setColor(1, 1, 1, 0.1)
    end

    love.graphics.rectangle("fill",
      startPoint.x,
      startPoint.y,
      endPoint.x - startPoint.x,
      endPoint.y - startPoint.y
    )
  end
end

return ZoneSystem
