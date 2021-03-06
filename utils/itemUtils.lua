local lume = require('libs.lume')
local inspect = require('libs.inspect') -- luacheck: ignore
local entityManager = require('models.entityManager')
local constructionTypes = require('data.constructionTypes')

local ItemUtils = {}

function ItemUtils:load(world)
  print("Setting world as", world)
  self.world = world
end


--local itemsOnGround = {}

-- local world
--
-- function ItemUtils.init(newWorld)
--   world = newWorld
-- end

-- Return item, wasSplit
function ItemUtils.splitItemStackIfNeeded(item, amount)
  if not item then error("Trying to split nil item") end
  local currentAmount = item:get(ECS.c.amount).amount
  local diff = currentAmount - amount
  if diff <= 0 then
    return item, false
  end

  local selector = item:get(ECS.c.selector).selector
  item:give(ECS.c.amount, diff)
  local itemCopy = ItemUtils.createItem(selector, amount)
  itemCopy:give(ECS.c.amount, amount)
  return itemCopy, true
end

function ItemUtils.createItem(selector, amount)
  amount = amount or 1

  local item = ECS.Entity()
  local itemData = constructionTypes.getBySelector(selector)
  --local color = itemData.color or { 0.5, 0.5, 0.5 }
  item:give(ECS.c.item, itemData)
  :give(ECS.c.selector, selector)
  :give(ECS.c.amount, amount)
  :give(ECS.c.name, "Item: " .. selector)
  :give(ECS.c.id, entityManager.generateId())

  for _, component in ipairs(itemData.components) do
    item:give(ECS.c[component.name], unpack(component.properties))
  end

  print("Adding to world", item:get(ECS.c.id).id)
  ItemUtils.world:addEntity(item)
  ItemUtils.world:__flush()

  return item
end

-- function ItemUtils.placeItemOnGround(item, gridPosition) --luacheck: ignore
--   local selector = item:get(ECS.c.item).selector
--   if not itemsOnGround[selector] then
--     itemsOnGround[selector] = {}
--   end
-- 
--   item:give(ECS.c.position, universe.gridPositionToPixels(gridPosition))
--   table.insert(itemsOnGround[selector], item)
-- end


-- function ItemUtils.popInventoryItemBySelector(inventory, selector, amount)
--   local originalItem = ItemUtils.getInventoryItemBySelector(inventory, selector)
--   print("Getting selection", selector, originalItem)
--   if not originalItem then return end
--   local item, wasSplit = ItemUtils.splitItemStackIfNeeded(originalItem, amount)
--   if not wasSplit then
--     lume.remove(inventory, item)
--   end
-- 
--   return item
-- end

-- TODO: Take amount away from item? Take away "amount" from parameters
-- function ItemUtils.putItemIntoInventory(inventory, item, amount)
--   local itemEnt = lume.match(inventory, function(itemInInv)
--     return itemInInv:get(ECS.c.item).selector == selector
--   end)
-- 
--   if itemEnt then
--     local existingAmount = itemEnt:get(ECS.c.amount).amount 
--     existingAmount = existingAmount + amount
--     itemEnt:get(ECS.c.amount).amount = existingAmount
--   else
--     table.insert(inventory, item)
--   end
-- end

return ItemUtils
