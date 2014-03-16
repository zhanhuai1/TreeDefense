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
-- require("scripts.Utils.TextureLoader")
require("scripts.Utils.AssetsHelper")



-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	print("----------------------------------------")
	print("LUA ERROR: " .. tostring(msg) .. "\n")
	print(debug.traceback())
	print("----------------------------------------")
end

g_game_scene = nil
g_running_time = 0 				--秒
g_running_frame = 0
g_real_visible_rct = cc.rect(0, 0, 0, 0)
g_real_visible_sz = cc.size(0,0)


GlobalEventSystem = EventSystem.New()

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
		print("!!!!!!!!d 1   design_w:", design_w)
		if design_w > frame_sz.width then
			design_w = frame_sz.width
			print("!!!!!!!!d 2   design_w:", design_w)
			if design_w < Config.TileSize.width * 16 then
				design_w = Config.TileSize.width * 16
				print("!!!!!!!!d 3   design_w:", design_w)
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
	g_real_visible_sz.width = design_w
	g_real_visible_sz.height = design_h
	g_real_visible_rct = cc.rect(-design_w/2, -design_h/2, design_w, design_h)
	-- print(string.format("g_real_visible_rct:%.2f, %.2f, %.2f, %.2f", g_real_visible_rct.origin.x, g_real_visible_rct.origin.y, design_w, design_h))
	print(string.format("final real_visible:%.2f, %.2f", g_real_visible_sz.width, g_real_visible_sz.height))
	glview:setDesignResolutionSize(g_real_visible_sz.width, g_real_visible_sz.height, cc.ResolutionPolicy.SHOW_ALL)

	SinHelper.New()
	SinAnimManager.New()
	ShineObjManager.New()
	ScreenManager.New()
	-- TextureLoader.New()

	--初始化所有Frames
	AssetsHelper.RegisterAllFrames()

	--创建Scene
	g_game_scene = CCScene:create()
	cc.Director:getInstance():runWithScene(g_game_scene)

	--进入主菜单界面
	GlobalEventSystem:Fire(EventName.GoMainMenu)
end

function Update(delta_time)
	g_running_time = g_running_time + delta_time
	g_running_frame = g_running_frame + 1
	-- print(g_running_time)
	-- TextureLoader.Instance:Update(delta_time, g_running_time)
	ScreenManager.Instance:Update(delta_time, g_running_time)
	SinAnimManager.Instance:Update(delta_time, g_running_time)
	ShineObjManager.Instance:Update(delta_time, g_running_time)
	return 1
end

function EnterForeground()
	print("EnterForeground!!!!!!!!!!!!!!!")
end

function EnterBackground()
	print("EnterBackground!!!!!!!!!!!!!!!!!!!")
end


xpcall(Start, __G__TRACKBACK__)
