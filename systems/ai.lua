local entityManager = require('models.entityManager')
local inspect = require('libs.inspect')

local AISystem = ECS.System({ECS.c.work, "work"})

local behaviours = {
  fetch = require('models.ai.fetchBehaviour').createTree,
  bluePrint = require('models.ai.bluePrintBehaviour').createTree
}

local attachedBehaviours = {}

function attachBehaviour(entity, type, world)
  local id = entity:get(ECS.c.id).id
  attachedBehaviours[id] = attachedBehaviours[id] or {}

  print("type", id, type, entity, entity:get(ECS.c.work), entity:get(ECS.c.work).jobId)
  local job = entityManager.get(entity:get(ECS.c.work).jobId)
  print("job", job, job:get(ECS.c.job), job:get(ECS.c.job).jobType)
  attachedBehaviours[id][type] = behaviours[type](entity, world, type)
end

function detachBehaviour(entity, type)
  local id = entity:get(ECS.c.id).id
  print("Detaching behaviour", id)
  attachedBehaviours[id][type] = nil
end

function AISystem:init()
  self.work.onEntityAdded = function(pool, entity)
    local jobComponent = entityManager.get(entity:get(ECS.c.work).jobId):get(ECS.c.job)
    local jobType = jobComponent.jobType
    --inspect(job:customSerialize())
    attachBehaviour(entity, jobType, self:getWorld())
  end

  self.work.onEntityRemoved = function(pool, entity)
    if entity:has(ECS.c.work) then
      local jobComponent = entityManager.get(entity:get(ECS.c.work).jobId):get(ECS.c.job)
      local jobType = jobComponent.jobType
      detachBehaviour(entity, jobType)
    end
  end
end

function AISystem:treeFinished(entity, jobType)
  detachBehaviour(entity, jobType)
end

function AISystem:update(dt)
  for _, entity in ipairs(self.work) do
    local id = entity:get(ECS.c.id).id
    local jobComponent = entityManager.get(entity:get(ECS.c.work).jobId):get(ECS.c.job)
    local jobType = jobComponent.jobType
    print("Running AI", id, jobType)
    attachedBehaviours[id][jobType]:run()
  end
end

return AISystem
