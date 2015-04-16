
SpriteEnemy = class("SpriteEnemy", function()
    return cc.Sprite:create()
end)
SpriteEnemy.HP = nil           -- 血量
SpriteEnemy.power = nil        -- 战力大小
SpriteEnemy.moveType = nil     -- 移动方式
SpriteEnemy.scoreValue = nil   -- 获得分数
SpriteEnemy.bulletType = nil   -- 子弹类型
SpriteEnemy.textureName = nil  -- 敌人图片资源
SpriteEnemy.active = nil
SpriteEnemy.speed = nil
SpriteEnemy.bulletSpeed = nil
SpriteEnemy.bulletPowerValue = nil
SpriteEnemy.delayTime = nil    -- 射击延迟
SpriteEnemy.size = nil


function SpriteEnemy:create(enemytype)
    local SpriteEnemy = SpriteEnemy.new()
    SpriteEnemy:init(enemytype)
    return SpriteEnemy
end


function SpriteEnemy:init(enemytype)
    self.HP = enemytype.HP                      -- 血量
    self.power = enemytype.power                -- 战力大小
    self.moveType = enemytype.moveType          -- 移动方式
    self.scoreValue = enemytype.scoreValue      -- 获得分数
    self.bulletType = enemytype.bulletType      -- 子弹类型
    self.textureName = enemytype.textureName    -- 敌人图片资源

    self.active = true
    self.speed = 220
    self.bulletSpeed = -200
    self.bulletPowerValue = 1
    self.delayTime = 1 + 1.2 * math.random()    -- 射击延迟

    -- 加载敌机图片
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(self.textureName)
    self:setSpriteFrame(frame)
    
    self.size = self:getContentSize()
    
    -- 射击子弹
    local function shoot()
         self:shoot()
    end
    schedule(self, shoot, self.delayTime)
    
    self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    self:getPhysicsBody():setCategoryBitmask(ENEMY_CATEGORY_MASK)
    self:getPhysicsBody():setCollisionBitmask(ENEMY_COLLISION_MASK)
    self:getPhysicsBody():setContactTestBitmask(ENEMY_CONTACTTEST_MASK)
end


-- 射击子弹
function SpriteEnemy:shoot()   
    if enemy_bullet == nil then
        return
    end
    
    local pos = cc.p(self:getPosition())
    local bullet = Bullet:create(self.bulletSpeed,self.bulletType,1, ENEMY_BULLET_TYPE)
    
    table.insert(enemy_bullet,bullet)
    self:getParent():addChild(bullet, 5, 902)
    bullet:setPosition(cc.p(pos.x, pos.y - self.size.height * 0.2))
end


-- 销毁
function SpriteEnemy:destroy()
    -- 播放音效
    if Global:getInstance():getAudioState() == true then
        cc.SimpleAudioEngine:getInstance():playEffect("Music/explodeEffect.mp3")
    end

    -- 爆炸+闪烁特效
    Effect:getInstance():explode(self:getParent(), cc.p(self:getPosition()), self.power)
    Effect:getInstance():spark(self:getParent(), cc.p(self:getPosition()), self.power*3.0, 0.7)

    -- 得分
    Global:getInstance():setScore(self.scoreValue)

    -- 移除
    for _, v in pairs(enemy_items) do
        if v == self then
            table.remove(enemy_items, _)
        end
    end
    self:removeFromParent()
end


-- 受伤
function SpriteEnemy:hurt(damageValue)
    print("######### SpriteEnemy hurt")
    self.HP = self.HP - damageValue
    if self.HP <= 0 then
        self.active = false
    end
end


-- 是否活跃
function SpriteEnemy:isActive()
    return self.active
end

