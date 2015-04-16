--------------------------------------------------------------------------------
-- SpriteCard
local SpriteCard = class("SpriteCard", function()
    return ccui.ImageView:create()
end)

SpriteCard.parent = nil
--------------------------------------------------------------------------------
-- const変数
local TAG = "SpriteCard:"
--------------------------------------------------------------------------------
-- メンバ変数
SpriteCard.kind         = nil
SpriteCard.type         = nil       -- タイプ：地面　＆　飛行
SpriteCard.atk          = nil       -- 攻撃力
SpriteCard.hp           = nil       -- HP
SpriteCard.cost         = nil       -- コスト

SpriteCard.armature     = nil

SpriteCard.active     = nil

SpriteCard.gameLayer    = nil
--------------------------------------------------------------------------------
-- UI変数
SpriteCard.label_atk         = nil
SpriteCard.label_hp          = nil
SpriteCard.label_cost        = nil
--------------------------------------------------------------------------------
-- constructor
function SpriteCard:ctor()
    self.active = true
end
--------------------------------------------------------------------------------
-- Init
function SpriteCard:init(data)
    if data then
        self.kind       = data.kind
        self.type       = data.type
        self.atk        = data.atk
        self.hp         = data.hp
        self.cost       = data.cost
    end

    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("Axe/Axe.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Axe/Axe.ExportJson")
    self.armature = ccs.Armature:create("Axe")
    self.armature:setScale(0.3)
    local armSize = self.armature:getContentSize()
    self.armature:setPosition(armSize.width/5,0)
    self.armature:setAnchorPoint(cc.p(0.5,0))
    self:addChild(self.armature)


    local function attackerAnimationEvent(armature,movementType,movementID)
        local id = movementID
        if movementType == ccs.MovementEventType.loopComplete then
            if id == "atk" then
                self.armature:stopAllActions()
                if self.active == false then
                    self.armature:getAnimation():play("Death")
                else
                    self.armature:getAnimation():play("Move")
                end
            elseif id == "idel" then
                self.armature:getAnimation():setMovementEventCallFunc(nil)
            elseif id == "Death" then
                self:removeFromParentAndCleanup(false)
            end
        end
    end
    self.armature:getAnimation():setMovementEventCallFunc(attackerAnimationEvent)


    self:loadTexture("fireball_1.png")
    self.size = self:getContentSize()

    self.label_atk = cc.Label:createWithBMFont("Font/arial-14.fnt", self.atk)
    self.label_atk:setSystemFontSize(30)
    self.label_hp = cc.Label:createWithBMFont("Font/arial-14.fnt", self.hp)
    self.label_hp:setSystemFontSize(30)
    self.label_cost = cc.Label:createWithBMFont("Font/arial-14.fnt", self.cost)
    self.label_cost:setSystemFontSize(30)
    self.label_cost:setAlignment(cc.TEXT_ALIGNMENT_RIGHT)


    local atk = ccui.ImageView:create()
    atk:loadTexture("status_atk.png")
    atk:setScale(0.3)
    atk:setPosition(self.size.width/2 - 10,self.size.height - 10)
    local hp = ccui.ImageView:create()
    hp:setScale(0.3)
    hp:setPosition(self.size.width/2 + 10,self.size.height - 10)
    hp:loadTexture("status_hp.png")
    local cost = ccui.ImageView:create()
    cost:setScale(0.3)
    cost:setPosition(self.size.width/2 + 10,self.size.height - 40)
    cost:loadTexture("status_cost.png")

    self:setOpacity(0)
    atk:setCascadeOpacityEnabled(false)
    hp:setCascadeOpacityEnabled(false)
    cost:setCascadeOpacityEnabled(false)
    self.armature:setCascadeOpacityEnabled(false)

    self.label_atk:setPosition(atk:getContentSize().width/2,atk:getContentSize().height/2)
    self.label_hp:setPosition(hp:getContentSize().width/2,hp:getContentSize().height/2)
    self.label_cost:setPosition(cost:getContentSize().width/2 + 15,cost:getContentSize().height/2 - 10)

    atk:addChild(self.label_atk)
    hp:addChild(self.label_hp)
    cost:addChild(self.label_cost)

    self:addChild(atk)
    self:addChild(hp)
    self:addChild(cost)

    self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    if data.kind == Global.KIND.ATK_A_SPRITE then
        self.armature:getAnimation():playWithIndex(2)
        self.armature:setScaleX(0.3)
        cost:setVisible(false)
        self:addMove(true)
        self:setPosition(30,120)
        self:getPhysicsBody():setCategoryBitmask(CATEGORY_MASK_PLAYER_A_ATK)
        self:getPhysicsBody():setCollisionBitmask(COLLISION_MASK_PLAYER_A_ATK)
        self:getPhysicsBody():setContactTestBitmask(CONTACTTEST_MASK_PLAYER_A_ATK)
    elseif data.kind == Global.KIND.ATK_B_SPRITE  then
        self.armature:getAnimation():playWithIndex(2)
        self.armature:setScaleX(-0.3)
        cost:setVisible(false)
        self:addMove(false)
        self:setPosition(WIN_SIZE.width - 30,120)
        self:getPhysicsBody():setCategoryBitmask(CATEGORY_MASK_PLAYER_B_ATK)
        self:getPhysicsBody():setCollisionBitmask(COLLISION_MASK_PLAYER_B_ATK)
        self:getPhysicsBody():setContactTestBitmask(CONTACTTEST_MASK_PLAYER_B_ATK)
    elseif data.kind == Global.KIND.FOOTER_SPRITE then
        self.armature:getAnimation():playWithIndex(1)
        self.armature:setScaleX(0.3)
        self:addTouch()
    end

end
--------------------------------------------------------------------------------
-- create
function SpriteCard:createSprite(data,parent)
    self.parent = parent
    if self.parent then
        print("############ parent name is "..parent.name)
    end
    local sprite = SpriteCard.new()
    sprite:init(data)
    return sprite
end

-- 碰撞
function SpriteCard:hurt(damageValue)
    print("######### SpriteCard hurt")
    self.hp = self.hp - damageValue
    if self.hp <= 0 then
        self.hp = 0
    end

    self.label_hp:setString(self.hp)

    self.armature:getAnimation():play("atk")
    if self.hp <= 0 then
        self.active = false
    end
end
--------------------------------------------------------------------------------
-- isActive
function SpriteCard:isActive()
    return self.active
end
--------------------------------------------------------------------------------
-- add move
function SpriteCard:addMove(isFromLeft)
    local mvToX
    if isFromLeft then
        mvToX = WIN_SIZE.width
    else
        mvToX = 0
    end
    local delay = cc.DelayTime:create(2.0)
    local mv = cc.MoveTo:create(20.0, cc.p(mvToX,120))
    local function callBack()
        self:removeFromParent()
        print("########### end")
    end
    local func = cc.CallFunc:create(callBack)
    self:runAction(cc.Sequence:create(mv, delay, func))
end
--------------------------------------------------------------------------------
-- add touch
function SpriteCard:addTouch()

    local function callBack(sender,eventType)
        local curMana = Global:getInstance():getMana()
        if curMana < self.cost then
            print("Not enough mana!")
            do return end
        end

        if eventType == ccui.TouchEventType.began then
            return true
        elseif eventType == ccui.TouchEventType.moved then
            return true
        elseif eventType == ccui.TouchEventType.ended then
            self:setVisible(false)
            Global:getInstance():setMana(curMana - self.cost)
            local param2 = {}
            param2.data = {
                tag = self:getTag()
            }
            EventDispatchManager:broadcastEventDispatcher("SELECT_CARD_FROM_FOOTER",param2)
            local param = {}
            param.data = {
                kind     = Global.KIND.ATK_A_SPRITE,
                type     = self.type,
                atk      = self.atk,
                hp       = self.hp,
                cost     = self.cost,
            }
            EventDispatchManager:broadcastEventDispatcher("ADD_CARD_TO_GAME_LAYER",param)

        elseif eventType == ccui.TouchEventType.canceled then
        end
    end

    self:setTouchEnabled(true)
    self:addTouchEventListener(callBack)
end

return SpriteCard