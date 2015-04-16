--------------------------------------------------------------------------------
-- EventDispatchManager.lua
-- @see
-- @release 2015/01/15
-- @author 

EventDispatchManager = class("EventDispatchManager")
--------------------------------------------------------------------------------
--Event Dispatcherを作成する
function EventDispatchManager:createEventDispatcher(node,key,callback)
  local eventDispatcher = node:getEventDispatcher()
  local listener = nil
  local function eventCustomListener(event)
    eventDispatcher:removeEventListener(listener)
    callback(event)
  end
  local listener = cc.EventListenerCustom:create(key, eventCustomListener)
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end
--------------------------------------------------------------------------------
--Event Dispatcherをブロードキャストする
function EventDispatchManager:broadcastEventDispatcher(key,data)
  local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
  local event = cc.EventCustom:new(key)
  event._data = data
  eventDispatcher:dispatchEvent(event)
end
