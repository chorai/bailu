
SpriteArmy = class("SpriteArmy", function()
    return cc.Sprite:create()
end)
SpriteArmy.active = nil
SpriteArmy.HP = nil
SpriteArmy.power = nil
SpriteArmy.vx = nil
SpriteArmy.vy = nil
SpriteArmy.attackmode = nil


function SpriteArmy:ctor()

end


function SpriteArmy:create(speed, weapon, attackMode, type)
    local SpriteArmy = SpriteArmy.new()
    SpriteArmy:init(speed, weapon, attackMode, type)
    return SpriteArmy
end


function SpriteArmy:init(speed, weapon, attackMode, type)
    
    self.active = true
    self.HP = 1
    self.power = 0.5    -- 战力大小

    self.vx = 0
    self.vy = -speed

    self.attackmode = attackMode
    
    -- 设置子弹图片
    -- 通过精灵帧设置
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(weapon)
    self:setSpriteFrame(frame)

    -- 混合模式
    self:setBlendFunc(GL_SRC_ALPHA, GL_ONE)
    
    -- 射击子弹
--    local function shoot(dt)
--        self:shoot(dt) 
--    end
--    self:scheduleUpdateWithPriorityLua(shoot,0)
    
    self:setPhysicsBody(cc.PhysicsBody:createCircle(3, cc.PhysicsMaterial(0.1, 1, 0), cc.p(0, 16)))
    if type == PLANE_SpriteArmy_TYPE then   -- 玩家子弹
        self:getPhysicsBody():setCategoryBitmask(PLANE_SpriteArmy_CATEGORY_MASK)
        self:getPhysicsBody():setCollisionBitmask(PLANE_COLLISION_MASK)
        self:getPhysicsBody():setContactTestBitmask(PLANE_CONTACTTEST_MASK)
    else    -- 敌人子弹
        self:getPhysicsBody():setCategoryBitmask(ENEMY_SpriteArmy_CATEGORY_MASK)
        self:getPhysicsBody():setCollisionBitmask(ENEMY_SpriteArmy_COLLISION_MASK)
        self:getPhysicsBody():setContactTestBitmask(ENEMY_SpriteArmy_CONTACTTEST_MASK)        
    end
end


-- 射击子弹
function SpriteArmy:shoot(dt)
    if self.HP <= 0 then
        self.active = false
    end

    local pos = cc.p(self:getPosition())
    pos.x = pos.x - self.vx * dt
    pos.y = pos.y - self.vy * dt
    self:setPosition(pos)
    
    if pos.y < -10 or pos.y > WIN_SIZE.height + 10 then
        self:unscheduleUpdate()
        self:destroy()
    end
end


--销毁
function SpriteArmy:destroy()
    if play_SpriteArmy == nil and enemy_SpriteArmy == nil then
    	return
    end
    
    -- 击中飞机特效
    Effect:getInstance():hit( self:getParent() , cc.p(self:getPosition()) )

    -- 移除
    for _,v in pairs(play_SpriteArmy) do
        if v == self then
            table.remove(play_SpriteArmy, _)
        end
    end
    for _,v in pairs(enemy_SpriteArmy) do
        if v == self then
            table.remove(enemy_SpriteArmy, _)
        end
    end
    self:removeFromParent()
end


-- 受伤
function SpriteArmy:hurt(damageValue)
    self.HP = self.HP - damageValue
    if self.HP <= 0 then
        self.active = false
    end
end


-- 是否活跃
function SpriteArmy:isActive()
    return self.active
end

