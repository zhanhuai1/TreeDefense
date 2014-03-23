require("scripts.cc.Cocos2d")
require("scripts.cc.Cocos2dConstants")
require("scripts.cc.GuiConstants")
require("scripts.cc.AudioEngine")

require("scripts.BaseClass.BaseClass")
require("scripts.Screen.MovableObj")

require("scripts.Config.Config")
-- require("scripts.Config.EnemyAnimations")
-- require("scripts.Config.BulletAnimations")
-- require("scripts.Config.red")
-- require("scripts.Config.AllUIFrames")
require("scripts.Config.FontsConfig")
require("scripts.Config.MapsConfig.AllMaps")

require("scripts.Bullets.BaseBullet")
require("scripts.Bullets.BulletTypesConfig")
require("scripts.Enemys.BaseEnemy")
require("scripts.Enemys.EnemyTypesConfig")
require("scripts.Towers.BaseTower")
require("scripts.Towers.TowerTypesConfig")

require("scripts.Screen.Map")
require("scripts.Screen.ScreenManager")
require("scripts.Screen.ShineObjManager")
require("scripts.Screen.TileObj")

require("scripts.UI.BaseView")
require("scripts.UI.PopupMenu")
require("scripts.UI.GameInfoView")
require("scripts.UI.FailedView")
require("scripts.UI.SucceedView")

require("scripts.Utils.Utils")
require("scripts.Utils.SinHelper")
require("scripts.Utils.SinAnimManager")
require("scripts.Utils.EventSystem")
require("scripts.Utils.EventName")
require("scripts.Utils.AssetsHelper")



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
		design_w = Config.MapTilesX * Config.TileSize.width
		if design_w > frame_sz.width then
			design_w = frame_sz.width
			if design_w < Config.TileSize.width * 16 then
				design_w = Config.TileSize.width * 16
			end
		end
		design_h = design_w / device_p
	else
		design_h = Config.MapTilesY * Config.TileSize.height
		if design_h > frame_sz.height then
			design_h = frame_sz.height
			if design_h < Config.TileSize.height * 9 then
				design_h = Config.TileSize.height * 9
			end
		end
		design_w = design_h * device_p
	end	
	Glo.VisibleRct.width = design_w
	Glo.VisibleRct.height = design_h
	print(string.format("final real_visible:%.2f, %.2f", Glo.VisibleRct.width, Glo.VisibleRct.height))
	glview:setDesignResolutionSize(Glo.VisibleRct.width, Glo.VisibleRct.height, cc.ResolutionPolicy.SHOW_ALL)

	--事件系统
	GlobalEventSystem = EventSystem.New()
	SinHelper.New()
	SinAnimManager.New()
	ShineObjManager.New()
	ScreenManager.New()

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
	--UI层
	layer = cc.Node:create()
	Glo.Scene:addChild(layer, Config.ZOrder.UI)
	Glo.LayerUI = layer
	--初始化所有Frames
	AssetsHelper.RegisterAllFrames()
	-------------------------------------

	--进入主菜单界面
	GlobalEventSystem:Fire(EventName.GoMainMenu)
end

function Update(delta_time)
	-- Glo.RunningTime = Glo.RunningTime + delta_time
	-- Glo.RunningFrame = Glo.RunningFrame + 1
	-- -- print(Glo.RunningTime)
	-- ScreenManager.Instance:Update(delta_time, Glo.RunningTime)
	-- SinAnimManager.Instance:Update(delta_time, Glo.RunningTime)
	-- ShineObjManager.Instance:Update(delta_time, Glo.RunningTime)
	return 1
end

function EnterForeground()
	print("EnterForeground!!!!!!!!!!!!!!!")
end

function EnterBackground()
	print("EnterBackground!!!!!!!!!!!!!!!!!!!")
end


xpcall(Start, __G__TRACKBACK__)
