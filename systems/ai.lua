local entityManager = require('models.entityManager')
local inspect = require('libs.inspect')

local AISystem = ECS.System({ECS.c.ai, "ai"})

local behaviours = {
  --idle = require('models.ai.idleBehaviour').createTree,
  settler = require('models.ai.settlerBehaviour').createTree
}

local attachedBehaviours = {}

local aiTimer = 0
local aiInterval = 1

local function attachBehaviour(entity, type, world)
  local id = entity:get(ECS.c.id).id
  attachedBehaviours[id] = attachedBehaviours[id] or {}

  attachedBehaviours[id][type] = behaviours[type](entity, world, type)
end

local function detachBehaviour(entity, type)
  local id = entity:get(ECS.c.id).id
  attachedBehaviours[id][type] = nil
end

function AISystem:init()
  self.ai.onEntityAdded = function(pool, entity)
    local behaviourType = entity:get(ECS.c.ai).behaviourType
    attachBehaviour(entity, behaviourType, self:getWorld())
  end

  self.ai.onEntityRemoved = function(pool, entity)
    if entity:has(ECS.c.work) then
      local behaviourType = entity:get(ECS.c.ai).behaviourType
      detachBehaviour(entity, behaviourType)
    end
  end
end

function AISystem:treeFinished(entity, jobType)
  detachBehaviour(entity, jobType)
end

function AISystem:update(dt)
  aiTimer = aiTimer + dt
  if aiTimer >= aiInterval then
    --print("AI UPDATE")
    aiTimer = aiTimer - aiInterval

    for _, entity in ipairs(self.ai) do
      local behaviourType = entity:get(ECS.c.ai).behaviourType
      local id = entity:get(ECS.c.id).id
      attachedBehaviours[id][behaviourType]:run()
    end
  end
end

return AISystem
