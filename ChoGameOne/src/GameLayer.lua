local SpriteCard = require("SpriteCard")
local GameFooter = require("GameFooter")
GameLayer = class("GameLayer", function()
    return cc.Layer:create()
end)
GameLayer.stateGamePlaying = 0
GameLayer.stateGameOver = 1

GameLayer.gameState = nil
GameLayer.gameTime = nil                -- 
GameLayer.lbScore = nil                 -- 分数
GameLayer.lbLifeCount = nil             -- 显示生命值

GameLayer.player = nil                  -- Player (自分)
GameLayer.playerRight = nil             -- PlayerRight (相手)

GameLayer.footer = nil
GameLayer.name = nil

function GameLayer:ctor()
    self.name = self.class.__cname
end


function GameLayer:create()
    local layer = GameLayer.new()
    layer:init()
    return layer
end


function GameLayer:init()
    self:loadingMusic() -- 背景音乐
    self:addBG()        -- 初始化背景
    --    self:moveBG()       -- 背景移动
    self:addBtn()       -- 游戏暂停按钮
    self:addFooter()
    self:addSchedule()  -- 更新
--    self:addTouch()     -- 触摸
    self:addContact()   -- 碰撞检测
    self:addATKSprite()
    
    
    Global:getInstance():resetGame()    -- 初始化全局变量
    self:initGameState()                -- 初始化游戏数据状态
    self:initSpritePlayer()             -- 初期化（自分）
    self:initSpritePlayerRight()        -- 初期化（相手）
    
    
end

function GameLayer:addATKSprite()
    local function callBack(event)
        local data = event._data.data
        local card = SpriteCard:createSprite(data,self)
--        card:setPosition(30,120)
        self:addChild(card,1002)
        
        print("############# ADD_CARD_TO_GAME_LAYER "..data.atk)
    end
    EventDispatchManager:createEventDispatcher(self,"ADD_CARD_TO_GAME_LAYER",callBack)
end

-- 播放音乐
function GameLayer:loadingMusic()
    if Global:getInstance():getAudioState() == true then
        -- playMusic
        cc.SimpleAudioEngine:getInstance():stopMusic()
        cc.SimpleAudioEngine:getInstance():playMusic("Music/bgMusic.mp3", true)
    else
        cc.SimpleAudioEngine:getInstance():stopMusic()
    end
end


-- 添加背景
function GameLayer:addBG()
    self.bg1 = cc.Sprite:create("bg_01.jpg")
    --    self.bg2 = cc.Sprite:create("bg_01.jpg")
    self.bg1:setAnchorPoint(cc.p(0, 0))
    --    self.bg2:setAnchorPoint(cc.p(0, 0))
    self.bg1:setPosition(0, 0)
    self.bg1:setScale(0.35)
    --    self.bg2:setPosition(0, self.bg1:getContentSize().height)
    self:addChild(self.bg1, -10)
    --    self:addChild(self.bg2, -10)
end

-- 添加背景
function GameLayer:addFooter()
    self.footer = GameFooter:create()
    self:addChild(self.footer, 0, 1001)
end


-- 背景滚动
function GameLayer:moveBG()
    local height = self.bg1:getContentSize().height
    local function updateBG()
        self.bg1:setPositionY(self.bg1:getPositionY() - 1)
        self.bg2:setPositionY(self.bg1:getPositionY() + height)
        if self.bg1:getPositionY() <= -height then
            self.bg1, self.bg2 = self.bg2, self.bg1
            self.bg2:setPositionY(WIN_SIZE.height)
        end
    end
    schedule(self, updateBG, 0)
end


-- 添加按钮
function GameLayer:addBtn()
    local function PauseGame()
        self:PauseGame()
    end
    local pause = cc.MenuItemImage:create("pause.png", "pause.png")
    pause:setAnchorPoint(cc.p(1, 0))
    pause:setPosition(cc.p(WIN_SIZE.width, 0))
    pause:registerScriptTapHandler(PauseGame)

    local menu = cc.Menu:create(pause)
    menu:setPosition(cc.p(0, 0))
    --    self:addChild(menu, 1, 10)
end


-- 更新
function GameLayer:addSchedule()
    -- 更新UI
    local function updateGame()
        self:updateGame()
    end
    schedule(self, updateGame, 0)

    -- 更新时间
    local function updateTime()
        self:updateTime()
    end
    schedule(self, updateTime, 1)
end


-- 触摸事件
function GameLayer:addTouch()
    -- 触屏开始
    local function onTouchBegan(touch, event)
        -- print("touchBegan")
        return true
    end

    -- 触屏移动
    local function onTouchMoved(touch, event)
        -- print("touchMoved")
        if self.gameState == self.stateGamePlaying then
            if nil ~= self.player then
                local pos = touch:getDelta()
                --                local currentPos = cc.p(self.player:getPosition())
                --                currentPos = cc.pAdd(currentPos, pos)
                --                currentPos = cc.pGetClampPoint(currentPos, cc.p(0, 0), cc.p(WIN_SIZE.width, WIN_SIZE.height))
                --                self.player:setPosition(currentPos)
            end
        end
    end

    -- 触屏结束
    local function onTouchEnded(touch, event)
    -- print("touchEnded")
    end

    -- 注册单点触摸
    local dispatcher = self:getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end


-- 初始化游戏数据状态
function GameLayer:initGameState()
    -- 游戏状态
    self.gameState = self.stateGamePlaying
    -- 游戏时间
    self.gameTime = 0
end


-- Playerをinitする
function GameLayer:initSpritePlayer()
    self.player = SpritePlayer:create()
    self:addChild(self.player, 0, 1001)
end

-- PlayerRightをinitする
function GameLayer:initSpritePlayerRight()
    self.playerRight = SpritePlayerRight:create(true)
    self:addChild(self.playerRight, 0, 1001)
end




-- 更新时间
function GameLayer:updateTime()
    if self.gameState == self.stateGamePlaying then
        self.gameTime = self.gameTime + 1
    end
end


-- 更新游戏
function GameLayer:updateGame()
    if self.gameState == self.stateGamePlaying then
        self:checkGameOver()        -- 战机重生,或游戏结束
        self:updateUI()             -- 刷新界面
    end
end

-- 战机重生,或游戏结束
function GameLayer:checkGameOver()
    if self.player:isActive() == false or self.playerRight:isActive() == false then
        self.gameState = self.stateGameOver
        self:gameOver()
    end
end

-- 刷新界面
function GameLayer:updateUI()
end

-- 游戏暂停
function GameLayer:PauseGame()
    cc.Director:getInstance():pause()
    cc.SimpleAudioEngine:getInstance():pauseMusic()
    cc.SimpleAudioEngine:getInstance():pauseAllEffects()

    local pauseLayer = PauseLayer:create()
    self:addChild(pauseLayer, 9999)
end


-- 游戏继续
function GameLayer:resumeGame()
    cc.Director:getInstance():resume()
    cc.SimpleAudioEngine:getInstance():resumeMusic()
    cc.SimpleAudioEngine:getInstance():resumeAllEffects()
end


-- 游戏结束
function GameLayer:gameOver()
    Global:getInstance():ExitGame()
    local scene = GameOverScene:createScene()
    local tt = cc.TransitionCrossFade:create(1.0, scene)
    cc.Director:getInstance():replaceScene(tt)
end


-- 获取飞机
function GameLayer:getShip()
    return self.player
end


function GameLayer:addContact()
    local function onContactBegin(contact)
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()
        if a ~= nil and b ~= nil then
            if a:isActive() and b:isActive() then
                a:hurt(b.atk)
                b:hurt(a.atk)
            end
            
        end
        return true
    end

    local dispatcher = self:getEventDispatcher()
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    dispatcher:addEventListenerWithSceneGraphPriority(contactListener, self)
end


