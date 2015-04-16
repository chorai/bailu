--------------------------------------------------------------------------------
-- SpritePlayer
-- 【クラス】Player
-- @date 2014/12/24
-- @author  Cho Rai
SpritePlayer = class("SpritePlayer", function()
    return cc.Sprite:create()
end)
SpritePlayer.active             = nil
SpritePlayer.canBeAttack        = nil
SpritePlayer.hp                 = nil
SpritePlayer.atk                = nil
SpritePlayer.power              = nil
SpritePlayer.speed              = nil
SpritePlayer.bulleSpeed         = nil
SpritePlayer.bulletPowerValue   = nil
SpritePlayer.delayTime          = nil
SpritePlayer.size               = nil
SpritePlayer.label_hp           = nil
SpritePlayer.slider_hp          = nil

SpritePlayer.action     = nil
--------------------------------------------------------------------------------
-- ctor
function SpritePlayer:ctor()
    self.active = true
    self.canBeAttack = false
    self.hp = 20
    self.atk = 10000
    self.power = 1.0
    self.speed = 220
    self.bulleSpeed = 900
    self.bulletPowerValue = 1
    self.delayTime = 0.1
end
--------------------------------------------------------------------------------
-- create
function SpritePlayer:create()
    local player = SpritePlayer.new()
    player:init()
    return player
end

function SpritePlayer:addArmature()
    local node = cc.CSLoader:createNode("huchey.csb")
    self.action = cc.CSLoader:createTimeline("huchey.csb")
    node:runAction(self.action)
    self.action:play("idel", true)
    node:setScale(0.5)
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
    EventDispatchManager:createEventDispatcher(self,"SELECT_CARD_FROM_FOOTER",callBack)
end
--------------------------------------------------------------------------------
-- init
function SpritePlayer:init()
    self:addArmature()
    local texture = cc.Director:getInstance():getTextureCache():addImage("fireball_1.png")
    local sp0 = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, 50, 50))
    self:setSpriteFrame(sp0)
    self.size = self:getContentSize()
    self:setPosition(cc.p(30, 120))

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
    --    self.action:setCascadeOpacityEnabled(false)
    hp:setCascadeOpacityEnabled(false)

    self:setPhysicsBody(cc.PhysicsBody:createCircle(self:getContentSize().width/2))
    self:getPhysicsBody():setCategoryBitmask(CATEGORY_MASK_PLAYER_A)
    self:getPhysicsBody():setCollisionBitmask(COLLISION_MASK_PLAYER_A)
    self:getPhysicsBody():setContactTestBitmask(CONTACTTEST_MASK_PLAYER_A)
end
--------------------------------------------------------------------------------
-- attack
function SpritePlayer:attack()
end
--------------------------------------------------------------------------------
-- hurt
function SpritePlayer:hurt(damageValue)
    self.hp = self.hp - damageValue
    self.label_hp:setString(self.hp)

    self.action:play("hurt",false)
    if self.hp <= 0 then
        self.active = false
    end
end
--------------------------------------------------------------------------------
-- isCanAttack
function SpritePlayer:isCanAttack()
    return self.canBeAttack
end
--------------------------------------------------------------------------------
-- isActive
function SpritePlayer:isActive()
    return self.active
end
--------------------------------------------------------------------------------
-- destroy
function SpritePlayer:destroy()
    if Global:getInstance():getAudioState() == true then
        cc.SimpleAudioEngine:getInstance():playEffect("Music/shipDestroyEffect.mp3")
    end
    self:removeFromParent()
end