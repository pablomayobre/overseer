local Vector = require('libs/brinevector/brinevector')
local lume = require('libs/lume')
local inspect = require('libs/inspect')
local commonComponents = require('components/common')
local constructionTypes = require('data/constructionTypes')

local ItemSystem = ECS.System({commonComponents.Item})


local function initializeItemsOnGroundTable(size)
  local array = {}
  for y = 1,size.y,1 do
    local row = {}
    for x = 1,size.x,1 do
      row[x] = {}
    end
    array[y] = row
  end

  return array
end

function ItemSystem:initializeTestItems()
  local mapSize = self.mapSystem:getSize()
  local randomTable = {
    walls = { "wooden_wall", "iron_wall" },
    raw_materials = { "wood", "iron", "stone", "steel" }
  }

  for i=1,40,1 do  --luacheck: ignore
    local item = ECS.Entity()
    local position = Vector(math.random(mapSize.x), math.random(mapSize.y))
    local keys1 = lume.keys(randomTable)
    local key = keys1[math.random(#keys1)]
    local category = randomTable[key]
    local itemName = category[math.random(#category)]
    local selector = key .. "." .. itemName
    local itemData = constructionTypes.getBySelector(selector)
    local color = itemData.color or { 0.5, 0.5, 0.5 }
    item:give(commonComponents.Position, self.mapSystem:gridPositionToPixels(position))
    :give(commonComponents.Selector, selector)
    :give(commonComponents.Item, itemData)
    :give(commonComponents.Draw, color)
    :give(commonComponents.Amount, 100)
    :apply()
    self:getInstance():addEntity(item)
    self:placeItemOnGround(item, position)
  end
end

function ItemSystem:init(mapSystem)  --luacheck: ignore
  self.mapSystem = mapSystem
  self.itemsOnGround = initializeItemsOnGroundTable(mapSystem:getSize())
  self.itemPositionsInGridIndexedBySelector = {}
end

function ItemSystem:placeSelectorIndexedItem(item, position)
  local selector = item:get(commonComponents.Selector).selector
  if not self.itemPositionsInGridIndexedBySelector[selector] then
    self.itemPositionsInGridIndexedBySelector[selector] = {}
  end

  table.insert(self.itemPositionsInGridIndexedBySelector[selector], position)
end

function ItemSystem:placeItemOnGround(item, gridPosition) --luacheck: ignore
  local pixelPosition = self.mapSystem:gridPositionToPixels(gridPosition)
  print("Item", item)
  item:give(commonComponents.Position, pixelPosition)
  item:apply()
  table.insert(self.itemsOnGround[gridPosition.y][gridPosition.x], item)
  self:placeSelectorIndexedItem(item, gridPosition)
end

function ItemSystem:getItemFromGround(itemSelector, gridPosition) --luacheck: ignore
  local itemsInPosition = self.itemsOnGround[gridPosition.y][gridPosition.x]
  for _, item in ipairs(itemsInPosition) do
    local selector = item:get(commonComponents.Selector).selector
    if itemSelector == selector then
      return item
    end
  end

  return nil -- Could not find item on ground
end

function ItemSystem:getItemPositionsFromGroundBySelector(itemSelector) --luacheck: ignore
  return self.itemPositionsInGridIndexedBySelector[itemSelector]
end

function ItemSystem:getItemsFromGroundBySelector(itemSelector) --luacheck: ignore
  local items = {}
  local positions = self:getItemPositionsFromGroundBySelector(itemSelector)
  if positions and #positions > 0 then
    for _, position in ipairs(positions) do
      local selectorItems = lume.filter(self.itemsOnGround[position.y][position.x], function(item)
        local selector = item:get(commonComponents.Selector).selector
        return selector == itemSelector
      end)
      for _, item in ipairs(selectorItems) do
        table.insert(items, item)
      end
    end
  end

  return items
end

function ItemSystem:removeItemFromGround(item)
  print("Removing item from ground", item:has(commonComponents.Position))
  if item:has(commonComponents.Position) then
    local position = item:get(commonComponents.Position).vector
    local gridPosition = self.mapSystem:pixelsToGridCoordinates(position)
    local items = self.itemsOnGround[gridPosition.y][gridPosition.x]
    local potentialItem = lume.match(items, function(it) return it == item end)

    if potentialItem then
      print("Actually removing", potentialItem)
      potentialItem:remove(commonComponents.Position)
      potentialItem:apply()
      lume.remove(items, potentialItem)
    end
  end
end

function ItemSystem:update(dt) --luacheck: ignore
  -- for _, entity in ipairs(self.pool.objects) do
  -- end
end

return ItemSystem
