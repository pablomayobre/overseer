local universe = require('models.universe')
local entityManager = require('models.entityManager')
local inspect = require('libs.inspect') --luacheck: ignore
local Vector = require('libs.brinevector') --luacheck: ignore

local MapSystem = ECS.System({ECS.c.collision, "collision"},
  {ECS.c.onMap, ECS.c.position, "onMap"},
  {ECS.c.onMap, ECS.c.position, ECS.c.selector, "onMapItem"},
  {ECS.c.onMap, ECS.c.position, ECS.c.occluder, "occluder"}
  )

function MapSystem:init()
  self.collision.onEntityAdded = universe.onCollisionEntityAdded
  self.collision.onEntityRemoved = universe.onCollisionEntityRemoved
  self.occluder.onEntityAdded = universe.onOccluderEntityAdded
  self.occluder.onEntityRemoved = universe.onOccluderEntityRemoved
  self.onMap.onEntityAdded = universe.onOnMapEntityAdded
  self.onMap.onEntityRemoved = universe.onOnMapEntityRemoved
  self.onMapItem.onEntityAdded = universe.onOnMapItemAdded
  self.onMapItem.onEntityRemoved = universe.onOnMapItemRemoved
end

function MapSystem:update(dt) --luacheck: ignore
  universe.update(dt)
end

function MapSystem:customDraw(l, t, w, h) --luacheck: ignore
  --local draw = universe.draw(l, t, w, h)
  --love.graphics.push()
  --local transform = love.math.newTransform()
  --love.graphics.replaceTransform(transform)
  --love.graphics.origin()
  --love.graphics.draw(draw, 32, 32)
  --love.graphics.draw(draw, 100, 100)
  --love.graphics.draw(draw, -300, -600)
  --love.graphics.pop()
end

function recursiveDelete(self, entity)
  if entity:has(ECS.c.children) then
    for _, childId in ipairs(entity:get(ECS.c.children).children) do
      local child = entityManager.get(childId)
      recursiveDelete(self, child)
    end
  end

  if entity:has(ECS.c.inventory) then
    local inventory = entity:get(ECS.c.inventory)
    --local currentGridPosition = universe.pixelsToGridCoordinates(entity:get(ECS.c.position).vector)

    for _, itemId in ipairs(inventory.inventory) do
      print("itemId", itemId)
      local item = entityManager.get(itemId)
      print("item", item)
      item:give(ECS.c.onMap)
      -- TODO: If no space then randomize nearby position
      --local itemPosition = currentGridPosition
      item:give(ECS.c.position, entity:get(ECS.c.position).vector.copy)
    end
  end

  self:getWorld():removeEntity(entity)
end

function MapSystem:cancelConstruction(entities)
  for _, entity in ipairs(entities) do
      if entity:has(ECS.c.construction) then
        if not entity:has(ECS.c.job) or not entity:get(ECS.c.job).type == "destruct" then
          entity:give(ECS.c.job, "destruct")
        end
      else
        recursiveDelete(self, entity)
      end
  end
end

function MapSystem:immediateDestroy(entity)
  recursiveDelete(self, entity)
end

local destructSpeedModifier = 5
function MapSystem:destructProgress(constructionComponent, amount)
  constructionComponent.durability = constructionComponent.durability - amount * destructSpeedModifier
  print("durability now", constructionComponent.durability)
end

return MapSystem
