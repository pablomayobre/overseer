local lume = require('libs.lume')

local currentId = 0

local entities = {}
local references = {}

local callBacks = {}

local test = {}

-- local function registerReference(callBack)
--   table.insert(callBacks, callBack)
-- end

-- local function initializeReferences()
--   for _, callBack in ipairs(callBacks) do
--     callBack(entities)
--   end
-- end

-- local function set(id, entity)
--   -- if id > currentId then
--   --   currentId = id + 1
--   -- end
--   print(id)
--   local compstring = ''
--   for cid, component in pairs(entity:getComponents()) do
--     compstring = compstring ..  component:getName() .. " | "
--   end
--   if entities[id] then
--     error ("Id already exists in entityReferenceManager, id: " .. tostring(id) .. " / " .. tostring(entity))
--   end
--   entities[id] = entity
--   print("Adding", id, entities[id], entity)
-- end

-- local function removeById(id)
--   table.remove(entities, id)
-- end
-- 
local function onEntityRemoved(entity)
  local id = entity:get(ECS.Components.id).id
  if not id or not references[id] then return end

  for _, onRemove in ipairs(references[id]) do
    onRemove(id)
  end

  table.remove(references, id)
  table.remove(entities, id)
end

local function onEntityAdded(entity)
  local id = entity:get(ECS.Components.id).id
  if not id then error "No ID for entity on removal" end
  print("Adding entity", id, entity)
  print("entities table", entities)
  entities[id] = entity
end

local function registerReference(referenceId, onRemove)
  references[referenceId] = references[referenceId] or {}
  table.insert(references[referenceId], onRemove)
end

local function getEntity(referenceId)
  return entities[referenceId]
end

-- local function removeByEntity(entity, id)
--   print("Removing", entity, lume.find(entities, entity))
--   lume.remove(entities, entity)
-- 
--   -- TODO: Still sorting this out
--   for refId, reference in references do
--     if refId == id then
--       if reference["removeCallBack"] then
--         reference.removeCallBack()
--       end
--     end
--   end
-- end

local function generateId()
  --currentId = currentId + 1
  return lume.uuid()
end

local function clear()
  for k,_ in pairs(entities) do
    entities[k] = nil
  end

  for k,_ in pairs(references) do
    references[k] = nil
  end
end

return {
  registerReference = registerReference,
  onEntityAdded = onEntityAdded,
  onEntityRemoved = onEntityRemoved,
  getEntity = getEntity,
  clear = clear,
  generateId = generateId,
  getEntities = function()
  --  print("All entities!")
  --  for id, entity in pairs(entities) do
  --    local jobtext = ""
  --    if entity:has(ECS.Components.job) then
  --      jobtext = entity:get(ECS.Components.job).jobType
  --    end
  --    print("Entity:", id, entity, jobtext)
  --  end
    return entities
  end,
}
