SelectMapScreen = SelectMapScreen or BaseClass(BaseScreen)


function SelectMapScreen:__init()
	self.map_info_list = {}
	self.loaded_map_infos = false
end

function SelectMapScreen:__delete()
end

function SelectMapScreen:Enter()
	print("= = =SelectMapScreen:Enter= = =")
	BaseScreen.Enter(self)

	--加载地图信息
	self:InitMapInfos()

	--创建浮游
	for i = 1, 20 do
		local x = (math.random() - 0.5) * g_real_visible_sz.width 
		local y = (math.random() - 0.5) * g_real_visible_sz.height
		local pos = cc.p(x, y)
		local angle = math.random() * 360
		ShineObjManager.Instance:CreateObj(pos, angle, Config.ZOrder.Squirm+1)
	end

	--回退按钮
	if self.btn_back == nil then
		local normal_sprite = AssetsHelper.CreateUIScaleSprite("btn_1_normal")
		local pressed_sprite = AssetsHelper.CreateUIScaleSprite("btn_1_pressed")
		local label = CCLabelTTF:create("Back", "sans", 32)
		local btn = CCControlButton:create(label, normal_sprite)
		btn:setBackgroundSpriteForState(pressed_sprite, CCControlStateHighlighted)
		btn:setContentSize(cc.size(170, 64))
		btn:setTouchEnabled(true)
		btn:setAdjustBackgroundImage(false)
		btn:setPosition(cc.p(-g_real_visible_sz.width/2 + 130, -g_real_visible_sz.height/2 + 60))
		g_game_scene:addChild(btn, Config.ZOrder.UI)

		local btn_start_func = function (event_type, x, y)
			GlobalEventSystem:Fire(EventName.GoMainMenu)
		end
		self.btn_back = btn
		self.btn_back:addScriptCallBackForControlEvent(btn_start_func, CCControlEventTouchUpInside)
	end

	--关卡按钮
	local posx = -g_real_visible_sz.width/2 + 150
	local posy = g_real_visible_sz.height/2 - 50
	for y = 1, 4 do
		for x = 1, 5 do
			local i = 5 * (y-1) + x
			print("== i:", i)
			local map_info = self.map_info_list[i]

			local normal_sprite = AssetsHelper.CreateUIScaleSprite("select_lv_btn_normal")
			local pressed_sprite = AssetsHelper.CreateUIScaleSprite("select_lv_btn_pressed")
			local disable_sprite = AssetsHelper.CreateUIScaleSprite("select_lv_btn_disable")
			local btn = CCControlButton:create(normal_sprite)
			btn:setBackgroundSpriteForState(pressed_sprite, CCControlStateHighlighted)
			btn:setBackgroundSpriteForState(disable_sprite, CCControlStateDisabled)
			btn:setContentSize(cc.size(128, 128))
			btn:setEnabled(not map_info.locked)
			btn:setAdjustBackgroundImage(false)
			btn:setPosition(cc.p(posx, posy))
			
			local func = function(event_type, x, y)
				GlobalEventSystem:Fire(EventName.GoGame, map_info)
			end
			btn:addScriptCallBackForControlEvent(func, CCControlEventTouchUpInside)
			map_info.btn = btn
			g_game_scene:addChild(btn, Config.ZOrder.UI)

			posx = posx + 150
		end
		posx = -g_real_visible_sz.width/2 + 150
		posy = posy - 130
	end
end

function SelectMapScreen:Exit()	
	print("= = =SelectMapScreen:Exit= = =")
	BaseScreen.Exit(self)

	ShineObjManager.Instance:Clear()

	if self.btn_back ~= nil then
		self.btn_back:removeFromParentAndCleanup(true)
		self.btn_back = nil
	end

	for _, map_info in pairs(self.map_info_list) do
		if map_info.btn then
			map_info.btn:removeFromParentAndCleanup(true)
			map_info.btn = nil
		end
	end

end

function SelectMapScreen:Update(delta_time, running_time)

end

function SelectMapScreen:InitMapInfos()
	if self.loaded_map_infos then
		return
	end

	for i=1, 20 do
		local info = {}
		info.locked = (i~=1)
		info.map_name = "map_01_01"
		self.map_info_list[i] = info
	end
	self.loaded_map_infos = true
end
