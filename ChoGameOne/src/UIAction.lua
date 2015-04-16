--------------------------------------------------------------------------------
-- UIAction.lua
-- @author Cho Rai
--------------------------------------------------------------------------------
UIAction = class("UIAction")
--------------------------------------------------------------------------------
-- const変数
local CONST = {
    POPUP = {
        SCALE_TIME1 = 0.1,
        SCALE_TIME2 = 0.1,
    }
}
--------------------------------------------------------------------------------
-- @function
-- #PopUp show 
function UIAction:showPopUp(parent,popup)
    local winSize = cc.Director:getInstance():getWinSize()
    local bg = cc.LayerColor:create(cc.c4b(0,0,0,0))
    bg:setOpacity(100)
    bg:setContentSize(cc.size(winSize.width * 2,winSize.height * 2))
    bg:setAnchorPoint(0.5,0.5)
    bg:setPosition(-winSize.width / 2,-winSize.height / 2)
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(winSize.width * 2,winSize.height * 2))
    local menu = cc.Menu:create()
    menu:addChild(item)
    bg:addChild(menu)
    popup.bg = bg

    parent:addChild(bg)
    parent:addChild(popup)

    local scale_from = popup:getScale()
    local scale_to = scale_from + 0.05
    popup:setScale(0,0)
    popup:setAnchorPoint(0.5,0.5)
    local size = popup:getContentSize()
    popup:setPosition(size.width/2,size.height/2)
    local action1 = cc.ScaleTo:create(CONST.POPUP.SCALE_TIME1, scale_to)
    local action2 = cc.ScaleTo:create(CONST.POPUP.SCALE_TIME2, scale_from)
    popup:runAction(cc.Sequence:create(action1, action2))
end
--------------------------------------------------------------------------------
-- @function
-- #PopUp hide

function UIAction:hidePopUp(popup)
    local obj = popup.obj
    local scale_from = popup:getScale()
    local scale_to = scale_from + 0.05
    local parent = popup:getParent()
    
    if obj then
        obj:removeWebView()
        obj = nil
    end

    local function callBack()
        parent:removeChild(popup.bg)
        parent:removeChild(popup)
    end

    local action1 = cc.ScaleTo:create(CONST.POPUP.SCALE_TIME1, scale_to)
    local action2 = cc.ScaleTo:create(CONST.POPUP.SCALE_TIME2, 0)
    popup:runAction(cc.Sequence:create(action1, action2,cc.CallFunc:create(callBack)))
end
--------------------------------------------------------------------------------
-- @function
-- #PopUp hide and remove
function UIAction:removePopUp(popup)
    UIAction:hidePopUp(popup) 
end
