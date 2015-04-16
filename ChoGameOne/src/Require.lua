-- FileUtils
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
cc.FileUtils:getInstance():addSearchPath("res/Font")
cc.FileUtils:getInstance():addSearchPath("res/Music")


-- addSpriteFramesWithFile -> addSpriteFrames
cc.SpriteFrameCache:getInstance():addSpriteFrames("bullet.plist")
cc.SpriteFrameCache:getInstance():addSpriteFrames("Enemy.plist")
cc.SpriteFrameCache:getInstance():addSpriteFrames("explosion.plist")

-- Require
require("AboutScene")
require("Effect")
require("EnemyManager")
require("SpritePlayer")
require("SpritePlayerRight")
require("SpriteArmy")
require("SpriteEnemy")

require("GameLayer")
require("GameOverScene")
require("GameScene")
require("Global")
require("HelloScene")
require("Helper")
require("LoadingScene")
require("OptionsScene")
require("PauseLayer")
require("PhysicsTest")
require("EventDispatchManager")


