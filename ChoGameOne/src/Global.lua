
Global = class("Global")
Global.audioState = true
Global.score = 0
Global.highScore = 0
Global.enemies = {}
Global.enemyTypes = {}

Global.mana = 0

Global.KIND = {
    PLAYER_A_SPRITE = 0,
    PLAYER_B_SPRITE = 1,
    FOOTER_SPRITE = 2,
    ATK_A_SPRITE = 3,
    ATK_B_SPRITE = 4,
}

local _global = Global
_global = nil
function Global:getInstance()
    if nil == _global then
        _global = Global.new()
        _global:init()
    end
    return _global
end

function Global:init()
    self.mana = 0
    self:recoverMana()
end

function Global:getMana()
    return self.mana
end

function Global:setMana(value)
    self.mana = value
end

function Global:recoverMana()
    local function func(dt)
        self.mana = self.mana + 1
        if self.mana > 10 then
            self.mana = 10
        end
        self:setMana(self.mana)
    end
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(func, 2, false)
end

-- 设置声音
function Global:setAudioState(state)
    self.audioState = state
end
function Global:getAudioState()
    return self.audioState
end

-- 历史分数
function Global:setHighScore(score)
    cc.UserDefault:getInstance():setIntegerForKey("score", score)
    cc.UserDefault:getInstance():flush()
    self.highScore = score
end
function Global:getHighScore()
    self.highScore = cc.UserDefault:getInstance():getIntegerForKey("score")
    return self.highScore
end

-- 重置游戏
function Global:resetGame()
end

-- 退出游戏,释放资源
function Global:ExitGame()
end

