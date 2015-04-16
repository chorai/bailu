--------------------------------------------------------------------------------
-- SpriteSample
SpriteSample = class("SpriteSample", function()
    return cc.Sprite:create()
end)

--------------------------------------------------------------------------------
-- const変数
local TAG = "SpriteSample:"
--------------------------------------------------------------------------------
-- メンバ変数

--------------------------------------------------------------------------------
-- constructor
function SpriteSample:ctor()
    self:init()
end
--------------------------------------------------------------------------------
-- Init
function SpriteSample:init()
    local texture = cc.Director:getInstance():getTextureCache():addImage("fireball_1.png")
    local sp = cc.SpriteFrame:createWithTexture(texture, cc.rect(0, 0, 50, 50))
    self:setSpriteFrame(sp)
    self.size = self:getContentSize()
end
--------------------------------------------------------------------------------
-- create
function SpriteSample:create()
    local sprite = SpriteSample.new()
    return sprite
end
