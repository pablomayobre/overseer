local fetchTask = BehaviourTree.Task:new({
  run = function(task, dog)
    dog:bark()
    task:success()
  end
})

local pickItemUpTask = BehaviourTree.Task:new({
  run = function(task, settler)

  end
})



local moveItemFromTo = BehaviourTree.Task:new({
  start = function(task, vars) 

  end,
  run = function(task, vars) -- vars: settler, target
    local fetch = job:get(ECS.c.fetchJob)
    local selector = fetch.selector
    local job = entityManager.get(settler:get(ECS.c.work).jobId)
    local target = entityManager.get(job:get(ECS.c.fetchJob).targetId)
    settler.searched_for_path = false
    local inventory = settler:get(ECS.c.inventory)
    local invItem = inventory:popItem(selector, amount)
    local targetInventory = target:get(ECS.c.inventory)
    targetInventory:insertItem(invItem:get(ECS.c.id).id)
    print("Putting into the targetInventory, as in job finished")
    -- JOB FINISHED!
  end
})

local fetchTree = BehaviourTree:new({
   tree = BehaviourTree.Sequence:new({
    nodes = {
      hasItem,
      getItem,
      moveItemFromTo,
    }
})


--local moveItemFromTo = function(fromInventory, toInventory, item)
--  targetInventory:insertItem(invItem:get(ECS.c.id).id)
--end
