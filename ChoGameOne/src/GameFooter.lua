--------------------------------------------------------------------------------
-- GameFooter
-- 【クラス】Player
-- @date 2014/12/24
-- @author  Cho Rai
local SpriteCard = require("SpriteCard")
local GameFooter = class("GameFooter", function()
    return cc.Layer:create()
end)
GameFooter.active = nil
GameFooter.card = nil
GameFooter.mana = 0

--UI
GameFooter.label_mana = nil
GameFooter.name = nil
--------------------------------------------------------------------------------
-- ctor
function GameFooter:ctor()
    self.name = self.class.__cname
end
--------------------------------------------------------------------------------
-- create
function GameFooter:create()
    local layer = GameFooter.new()
    layer:init()
    layer:addSchedule()
    return layer
end
--------------------------------------------------------------------------------
-- init
function GameFooter:init()
    self.label_mana=cc.Label:createWithBMFont("Font/arial-14.fnt", self.mana)
    self.label_mana:setPosition(30,60)


    local listView = ccui.ListView:create()
    -- set list view ex direction
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setBounceEnabled(true)
    --    listView:setBackGroundImage("slider_gray.png")
    listView:setBackGroundImageScale9Enabled(true)
    
    listView:setAnchorPoint(cc.p(0,0))
    listView:setPosition(cc.p(0,0))
    --    listView:addEventListener(listViewEvent)
    --    listView:addScrollViewEventListener(scrollViewEvent)
    self:addChild(listView)

    self:addChild(self.label_mana)

    --TODO Card DBからCard情報を設定し、Cardを生成する
    local cardDb = {
        --        [1] = {
        --            kind         = Global.KIND.FOOTER_SPRITE,
        --            type         = 1,       -- タイプ：地面　＆　飛行
        --            atk          = 4,       -- 攻撃力
        --            hp           = 1,       -- HP
        --            cost         = 2,
        --        },
        --        [2] = {
        --            kind         = Global.KIND.FOOTER_SPRITE,
        --            type         = 1,       -- タイプ：地面　＆　飛行
        --            atk          = 5,       -- 攻撃力
        --            hp           = 4,       -- HP
        --            cost         = 3,
        --        },
        --        [3] = {
        --            kind         = Global.KIND.FOOTER_SPRITE,
        --            type         = 1,       -- タイプ：地面　＆　飛行
        --            atk          = 5,       -- 攻撃力
        --            hp           = 6,       -- HP
        --            cost         = 4,
        --        },
        --        [4] = {
        --            kind         = Global.KIND.FOOTER_SPRITE,
        --            type         = 1,       -- タイプ：地面　＆　飛行
        --            atk          = 7,       -- 攻撃力
        --            hp           = 8,       -- HP
        --            cost         = 5,
        --        }
        }

    for var=1, 20 do
        local tb = {
            kind         = Global.KIND.FOOTER_SPRITE,
            type         = 1,       -- タイプ：地面　＆　飛行
            atk          = math.random(8),       -- 攻撃力
            hp           = math.random(8),       -- HP
        }
        if tb.atk / 1.5 >= tb.hp / 1.5 then
            tb.cost = math.floor(tb.atk / 1.5)
        else
            tb.cost =  math.floor(tb.hp / 1.5)
        end
        if tb.cost <= 0 then
            tb.cost = 1
        end

        table.insert(cardDb,var,tb)
        table.sort(cardDb,function( a, b ) return ( a.cost < b.cost )end)
    end
    
--    listView:setClippingEnabled(false)

    listView:removeAllItems()
    for key, var in ipairs(cardDb) do
        local card = SpriteCard:createSprite(var,self)
        local custom_item = ccui.Layout:create()
        custom_item:setContentSize(card:getContentSize())
        card:setAnchorPoint(0.5,0.5)
        card:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
        custom_item:addChild(card)
       
        custom_item:setTag(key)
        card:setTag(key)
        listView:setContentSize(cc.size(WIN_SIZE.width , card:getContentSize().height))
        listView:pushBackCustomItem(custom_item)
    end

    local function callBack(event)
        local data = event._data.data
        local fadeTo = cc.FadeTo:create(1,0)
        local function callBack()
            listView:removeChildByTag(data.tag)
        end
        local func = cc.CallFunc:create(callBack)
        listView:getChildByTag(data.tag):runAction(cc.Sequence:create(fadeTo, func))

    end
    EventDispatchManager:createEventDispatcher(self,"SELECT_CARD_FROM_FOOTER",callBack)
    
end


function GameFooter:addSchedule()
    local function updateGame()
        self.label_mana:setString(Global:getInstance():getMana())
    end
    schedule(self, updateGame,0)
end


--------------------------------------------------------------------------------
-- hide
function GameFooter:hide()
    self:setVisible(false)
end
--------------------------------------------------------------------------------
-- show
function GameFooter:show()
    self:setVisible(true)
end

return GameFooter