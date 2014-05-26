require("scripts.cc.Cocos2d")
require("scripts.cc.Cocos2dConstants")
require("scripts.cc.GuiConstants")
require("scripts.cc.AudioEngine")

require("scripts.BaseClass.BaseClass")
require("scripts.Screen.MovableObj")

require("scripts.Config.Config")
require("scripts.Config.BuildConfig")
require("scripts.Config.BulletConfig")
require("scripts.Config.EnemyConfig")
require("scripts.Config.MapsConfig.AllMaps")

require("scripts.Bullets.BaseBullet")
require("scripts.Bullets.BulletTypesConfig")
require("scripts.Enemys.BaseEnemy")
require("scripts.Enemys.EnemyTypesConfig")
require("scripts.Towers.BaseTower")
require("scripts.Towers.TowerTypesConfig")

require("scripts.Screen.Scene.Scene")
require("scripts.Screen.Scene.TileObj")
require("scripts.Screen.Scene.BuildObj")
require("scripts.Screen.Scene.BulletTower")
require("scripts.Screen.Scene.RazerTower")
require("scripts.Screen.Scene.MovableObj")
require("scripts.Screen.Scene.Bullet")
require("scripts.Screen.Scene.Enemy")
require("scripts.Screen.Scene.PathFinder")
-- require("scripts.Screen.Map")
require("scripts.Screen.BaseScreen")
require("scripts.Screen.GameScreen")
require("scripts.Screen.MainMenuScreen")
require("scripts.Screen.SelectMapScreen")
require("scripts.Screen.ScreenManager")
require("scripts.Screen.ShineObjManager")

require("scripts.UI.BaseView")
require("scripts.UI.PopupMenu")
require("scripts.UI.PopupIconInfo")
require("scripts.UI.GameInfoView")
require("scripts.UI.FailedView")
require("scripts.UI.SucceedView")
require("scripts.UI.SelectLevelIcon")
require("scripts.UI.CountDownView")

require("scripts.Utils.Utils")
require("scripts.Utils.SinHelper")
require("scripts.Utils.SinAnimManager")
require("scripts.Utils.EventSystem")
require("scripts.Utils.EventName")
require("scripts.Utils.AssetsHelper")
require("scripts.Utils.TimerQuest")



-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	print("----------------------------------------")
	print("LUA ERROR: " .. tostring(msg) .. "\n")
	print(debug.traceback())
	print("----------------------------------------")
end


function Start()
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	math.randomseed(os.time())

	--是否显示帧信息
	cc.Director:getInstance():setDisplayStats(false)
	--注册update函数
	cc.Director:getInstance():getScheduler():scheduleScriptFunc(Update, 0, false)

	-- local dir_v = cc.p(math.sin(0.5 * math.pi), math.cos(0.5 * math.pi))
	-- local p = cc.p(0, 50)
	-- local p = cc.pRotateByAngle(p, cc.p(0,0), 0.5 * math.pi)
	-- print("= = = PPPPPP:", string.format("dir_v:%.2f,%.2f  p:%.2f,%.2f", dir_v.x, dir_v.y, p.x, p.y))

	-------------------------------------------------------------------
	--根据设备分辨率计算合适的设计分辨率
	local glview = cc.EGLView:getInstance()
	local frame_sz = glview:getFrameSize()
	
	local tiles_p = Config.MapTilesX / Config.MapTilesY
	local device_p = frame_sz.width / frame_sz.height
	local design_w = frame_sz.width
	local design_h = frame_sz.height
	print(string.format("frame_sz:%d, %d   tiles_p:%.4f,  device_p:%.4f", frame_sz.width, frame_sz.height, tiles_p, device_p))
	if tiles_p < device_p then
		design_w = Config.MapTilesX * Config.TileSize
		if design_w > frame_sz.width then
			design_w = frame_sz.width
			if design_w < Config.TileSize * 16 then
				design_w = Config.TileSize * 16
			end
		end
		design_h = design_w / device_p
	else
		design_h = Config.MapTilesY * Config.TileSize
		if design_h > frame_sz.height then
			design_h = frame_sz.height
			if design_h < Config.TileSize * 9 then
				design_h = Config.TileSize * 9
			end
		end
		design_w = design_h * device_p
	end	
	Glo.VisibleSize.width = design_w
	Glo.VisibleSize.height = design_h
	print(string.format("final real_visible:%.2f, %.2f", Glo.VisibleSize.width, Glo.VisibleSize.height))
	glview:setDesignResolutionSize(Glo.VisibleSize.width, Glo.VisibleSize.height, cc.ResolutionPolicy.SHOW_ALL)

	--事件系统
	GlobalEventSystem = EventSystem.New()
	GlobalTimerQuest = TimerQuest.New()
	SinHelper.New()
	SinAnimManager.New()
	ShineObjManager.New()
	ScreenManager.New()

	cc.Director:getInstance():setDisplayStats(true)
	-------------------------------------
	--创建Scene
	Glo.Scene = CCScene:create()
	cc.Director:getInstance():runWithScene(Glo.Scene)

	--背景层
	local layer = cc.Node:create()
	Glo.Scene:addChild(layer, Config.ZOrder.Bg)
	Glo.LayerBg = layer
	--游戏地图层
	layer = cc.Node:create()
	Glo.Scene:addChild(layer, Config.ZOrder.Map)
	Glo.LayerMap = layer
	--用于响应用户点击的layer
	layer = cc.Node:create()
	Glo.Scene:addChild(layer, Config.ZOrder.Touch)
	Glo.LayerTouch = layer
	--UI层
	layer = cc.Node:create()
	Glo.Scene:addChild(layer, Config.ZOrder.UI)
	Glo.LayerUI = layer

	--初始化所有Frames
	AssetsHelper.RegisterAllFrames()
	AssetsHelper.PreloadAllMusic()
	-------------------------------------

	--进入主菜单界面
	GlobalEventSystem:Fire(EventName.GoMainMenu)


end

function Update(delta_time)
	-- delta_time = 1 / Config.DefaultFPS --每帧按设计的帧率增加时间 
	Glo.RunningTime = Glo.RunningTime + delta_time

	-- -- print(Glo.RunningTime)
	ScreenManager.Instance:Update(delta_time, Glo.RunningTime)
	-- SinAnimManager.Instance:Update(delta_time, Glo.RunningTime)
	-- ShineObjManager.Instance:Update(delta_time, Glo.RunningTime)
	GlobalTimerQuest:Update(delta_time, Glo.RunningTime)
	return 1
end

function EnterForeground()
	print("EnterForeground!!!!!!!!!!!!!!!")
end

function EnterBackground()
	print("EnterBackground!!!!!!!!!!!!!!!!!!!")
end


xpcall(Start, __G__TRACKBACK__)
