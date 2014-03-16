MainMenuScreen = MainMenuScreen or BaseClass(BaseScreen)

function MainMenuScreen:__init()
	self.btn_start = nil
	
	self.shine_objs = {}
	self.shine_index = 0
	self.last_create_shine_time = -10
	self.create_shine_interval = 1.6

end

function MainMenuScreen:__delete()
	self:Exit()
end

function MainMenuScreen:Enter()
	print("= = =MainMenuScreen:Enter= = =")
	BaseScreen.Enter(self)

	-- --创建浮游
	-- for i = 1, 20 do
	-- 	local x = math.random() * g_real_visible_sz.width 
	-- 	local y = math.random() * g_real_visible_sz.height
	-- 	local pos = cc.p(x, y)
	-- 	local angle = math.random() * 360
	-- 	ShineObjManager.Instance:CreateObj(pos, angle, Config.ZOrder.Squirm+1)
	-- end

	local btn = ccui.Button:create()
	btn:loadTextures("btn1_nor.png", "btn1_sel.png", "", ccui.TextureResType.plistType)
	btn:setPosition(g_real_visible_sz.width/2, g_real_visible_sz.height/2)
	btn:setPressedActionEnabled(true)
	btn:setTouchEnabled(true)
	btn:setTitleFontName("Marker Felt")
	btn:setTitleFontSize(32)
	btn:setTitleText("PLAY")
	btn:setTitleColor(cc.c3b(255, 155, 13))
	g_game_scene:addChild(btn, Config.ZOrder.UI)

	local btn_start_func = function (target, event_type)
		print("!!!!!!!!Btn_Click!!!!!!!", event_type, ccui.TouchEventType.ended, ccui.TouchEventType.ended)
		-- GlobalEventSystem:Fire(EventName.GoSelectMap)
		if event_type == ccui.TouchEventType.began then
			btn:setTitleColor(cc.c3b(255, 195, 13))
			btn:setTitleFontSize(36)
		elseif event_type == ccui.TouchEventType.canceled or event_type == ccui.TouchEventType.ended then
			btn:setTitleColor(cc.c3b(255, 155, 13))
			btn:setTitleFontSize(32)
		end
	end
	self.btn_start = btn
	self.btn_start:addTouchEventListener(btn_start_func)
end

function MainMenuScreen:Exit()
	print("= = =MainMenuScreen:Exit= = =")
	BaseScreen.Exit(self)
	
	if self.btn_start ~= nil then
		self.btn_start:removeFromParentAndCleanup(true)
		self.btn_start = nil
	end

	if self.squirm_bg2 then
		self.squirm_bg2:removeFromParentAndCleanup(true)
		self.squirm_bg2 = nil
	end

	ShineObjManager.Instance:Clear()
end

function MainMenuScreen:Update(delta_time, running_time)

end
