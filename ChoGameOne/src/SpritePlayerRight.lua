--------------------------------------------------------------------------------
-- SpritePlayerRight
-- 【クラス】PlayerRight
-- @date 2014/12/24
-- @author  Cho Rai
SpritePlayerRight = class("SpritePlayerRight", function()
    return cc.Sprite:create()
end)
SpritePlayerRight.active            = nil
SpritePlayerRight.canBeAttack       = nil
SpritePlayerRight.atk               = nil      
SpritePlayerRight.hp                = nil
SpritePlayerRight.power             = nil
SpritePlayerRight.speed             = nil
SpritePlayerRight.bulleSpeed        = nil
SpritePlayerRight.bulletPowerValue  = nil
SpritePlayerRight.delayTime = nil
SpritePlayerRight.size = nil

SpritePlayerRight.isAI = false

SpritePlayerRight.label_hp = nil
SpritePlayerRight.slider_hp = nil

SpritePlayer.action     = nil
--------------------------------------------------------------------------------
-- ctor
function SpritePlayerRight:ctor()
    self.active = true
    self.canBeAttack = false
    self.hp = 20
    self.atk = 100000
    self.power = 1.0
    self.speed = 220
    self.bulleSpeed = 900
    self.bulletPowerValue = 1
    self.delayTime = 0.1
end
--------------------------------------------------------------------------------
-- create
function SpritePlayerRight:create(isAI)
    local plane = SpritePlayerRight.new()
    plane.isAI = isAI
    plane:init()
    plane:addAttack()
    return plane
end

function SpritePlayerRight:addArmature()
    local node = cc.CSLoader:createNode("generalshark.csb")
    self.action = cc.CSLoader:createTimeline("generalshark.csb")
    node:runAction(self.action)
    self.action:play("idel", true)
    node:setScale(0.3)
    node:setPosition(node:getContentSize().width + 20,0)
    self:addChild(node)

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "hurted" then
            self.action:play("idel", true)
        elseif(str == "atked") then
            self.action:play("idel", true)
        end
    end
    self.action:setFrameEventCallFunc(onFrameEvent)

    local function callBack(event)
        self.action:play("atk", false)
    end
    EventDispatchManager:createEventDispatcher(self,"SPRITE_PLAYER_RIGHT_ATKED",callBack)
end
--------------------------------------------------------------------------------
-- init
function SpritePlayerRight:init()
    self:addArmature()
    local texture = cc.Director:getInstance():getTextureCache():addImage("fireball_2.png")
    local sp0 = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, 50, 50))
    self:setSpriteFrame(sp0)
    self.size = self:getContentSize()
    self:setPosition(cc.p(WIN_SIZE.width - 30, 120))

    -- hp value
    self.label_hp = cc.Label:createWithBMFont("Font/arial-14.fnt", self.hp)
    self.label_hp:setSystemFontSize(30)
    self.label_hp:setColor(cc.c3b(255,255, 255))

    local hp = ccui.ImageView:create()
    hp:setScale(0.3)
    hp:setPosition(self.size.width/2 ,self.size.height + 20)
    hp:loadTexture("status_hp.png")
    hp:addChild(self.label_hp)
    self:addChild(hp)
    self.label_hp:setPosition(hp:getContentSize().width/2,hp:getContentSize().height/2)

    self:setOpacity(0)
    hp:setCascadeOpacityEnabled(false)
    
    self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    self:getPhysicsBody():setCategoryBitmask(CATEGORY_MASK_PLAYER_B)
    self:getPhysicsBody():setCollisionBitmask(COLLISION_MASK_PLAYER_B)
    self:getPhysicsBody():setContactTestBitmask(CONTACTTEST_MASK_PLAYER_B)
end
--------------------------------------------------------------------------------
-- attack
function SpritePlayerRight:addAttack()
    local function attacking()
        print("################## attcak ")
        local param = {}
        
        param.data = {
            kind         = Global.KIND.ATK_B_SPRITE,
            type         = 1,
            atk          = math.random(5),
            hp           = math.random(20),
        }
        
        if param.data.atk / 1.5 >= param.data.hp / 1.5 then
            param.data.cost = math.floor(param.data.atk / 1.5)
        else
            param.data.cost =  math.floor(param.data.hp / 1.5)
        end
        if param.data.cost <= 0 then
            param.data.cost = 1
        end
        self.action:play("atk", false)
        EventDispatchManager:broadcastEventDispatcher("ADD_CARD_TO_GAME_LAYER",param)
    end
    if self.isAI then
        local delay = cc.DelayTime:create(10.0)
        local func = cc.CallFunc:create(attacking)
        local seq = cc.Sequence:create(delay, func)
        self:runAction(cc.RepeatForever:create(seq))
    end
end
--------------------------------------------------------------------------------
-- hurt
function SpritePlayerRight:hurt(damageValue)
    print("######### SpritePlayerRight hurt")
    self.hp = self.hp - damageValue
    self.label_hp:setString(self.hp)
    self.action:play("hurt",false)
    if self.hp <= 0 then
        self.active = false
    end
end
--------------------------------------------------------------------------------
-- isCanAttack
function SpritePlayerRight:isCanAttack()
    return self.canBeAttack
end
--------------------------------------------------------------------------------
-- isActive
function SpritePlayerRight:isActive()
    return self.active
end
--------------------------------------------------------------------------------
-- destroy
function SpritePlayerRight:destroy()
    if Global:getInstance():getAudioState() == true then
        cc.SimpleAudioEngine:getInstance():playEffect("Music/shipDestroyEffect.mp3")
    end
    self:removeFromParent()
end