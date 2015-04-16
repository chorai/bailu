-------------------------------------------------------------------------------
-- BaseLayer.lua
local BaseLayer = nil
local function layer()
    local BaseLayer = class("BaseLayer", function()
        return cc.Layer:create()
    end
    )
    function BaseLayer:init(...)
    end
    function BaseLayer:initialize(...)
        cclog("initialize:" .. "BaseLayer")

        self.mainlayer  = cc.Layer:create()
        self:addChild(self.mainlayer, 1, 0)
        self.name = self.class.__cname

        local function onEvent(event)
            if event == "enter" then
                self:onEnter()
            elseif event == "exit" then
                self:onExit()
            end
        end
        self:registerScriptHandler(onEvent)
        self:init(...)
    end

    return BaseLayer
end
BaseLayer = layer
return BaseLayer