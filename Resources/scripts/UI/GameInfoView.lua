GameInfoView = GameInfoView or BaseClass()


function GameInfoView:__init( )
	self.root_wnd = AssetsHelper.CreateUIScaleSprite("img_ui_bg")
	self.root_wnd:setContentSize(cc.size(g_real_visible_rct.size.width, 64))
	self.root_wnd:retain()
	self.root_wnd:setPosition(0, g_real_visible_rct:getMinY()+32)


	local right = g_real_visible_rct.size.width
	local pause_btn_x 	= right - 336
	local speedup_btn_x = pause_btn_x + 64
	--暂停
	if self.btn_pause == nil then		
		self.btn_pause = AssetsHelper.CreateButton("btn_pause")
		self.btn_pause:setPosition(cc.p(pause_btn_x, 32))
		self.btn_pause:retain()
		self.root_wnd:addChild(self.btn_pause)
		self.show_pause_btn = true

		local func = function (event_type, x, y)
			GlobalEventSystem:Fire(EventName.Pause)
		end
		self.btn_pause:addScriptCallBackForControlEvent(func, CCControlEventTouchUpInside)
	end

	--继续
	if self.btn_resume == nil then
		self.btn_resume = AssetsHelper.CreateButton("btn_goon")
		self.btn_resume:setPosition(cc.p(pause_btn_x, 32))
		self.btn_resume:retain()

		local func = function (event_type, x, y)
			GlobalEventSystem:Fire(EventName.Resume)
		end
		self.btn_resume:addScriptCallBackForControlEvent(func, CCControlEventTouchUpInside)
	end

	--加速
	if self.btn_speedup == nil then
		self.btn_speedup = AssetsHelper.CreateButton("btn_speedup")
		self.btn_speedup:setPosition(cc.p(speedup_btn_x, 32))
		self.btn_speedup:retain()
		self.root_wnd:addChild(self.btn_speedup)
		self.show_speedup_btn = true

		local func = function (event_type, x, y)
			GlobalEventSystem:Fire(EventName.Speedup)
		end
		self.btn_speedup:addScriptCallBackForControlEvent(func, CCControlEventTouchUpInside)
	end

	--减速
	if self.btn_speeddown == nil then
		self.btn_speeddown = AssetsHelper.CreateButton("btn_speedup_pressed")
		self.btn_speeddown:setPosition(cc.p(speedup_btn_x, 32))
		self.btn_speeddown:retain()

		local func = function (event_type, x, y)
			GlobalEventSystem:Fire(EventName.Speeddown)
		end
		self.btn_speeddown:addScriptCallBackForControlEvent(func, CCControlEventTouchUpInside)
	end

	--血量
	local heart_img = AssetsHelper.CreateFrameSprite("img_heart")
	heart_img:setPosition(cc.p(right-213, 32))
	self.root_wnd:addChild(heart_img)

	self.wave_label = AssetsHelper.CreateLabelTTF("Common14")
	self.wave_label:setString("0 / 10")
	self.wave_label:setColor(ccc3(255, 133, 101))
	self.wave_label:setPosition(cc.p(right-188, 32))
	self.root_wnd:addChild(self.wave_label)

	--金币
	local gold_img = AssetsHelper.CreateFrameSprite("img_coin")
	gold_img:setPosition(cc.p(right-130, 32))
	self.root_wnd:addChild(gold_img)

	self.gold_label = AssetsHelper.CreateLabelTTF("Common14")
	self.gold_label:setString("0")
	self.gold_label:setColor(ccc3(252, 251, 0))
	self.gold_label:setPosition(cc.p(right-106, 32))
	self.root_wnd:addChild(self.gold_label)



	g_game_scene:addChild(self.root_wnd, Config.ZOrder.UI)

	self:InitEvents()
end

function GameInfoView:__delete( )
	if self.btn_pause then
		self.btn_pause:release()
		self.btn_pause = nil
	end
	if self.btn_resume then
		self.btn_resume:release()
		self.btn_resume = nil
	end
	if self.btn_speedup then
		self.btn_speedup:release()
		self.btn_speedup = nil
	end
	if self.btn_speeddown then
		self.btn_speeddown:release()
		self.btn_speeddown = nil
	end
	if self.root_wnd then
		self.root_wnd:release()
		self.root_wnd:removeFromParentAndCleanup(true)
	end
	if self.arrived_enemy_binder then
		GlobalEventSystem:UnBind(self.arrived_enemy_binder)
		self.arrived_enemy_binder = nil
	end
	if self.pause_binder then
		GlobalEventSystem:UnBind(self.pause_binder)
		self.pause_binder = nil
	end
	if self.resume_binder then
		GlobalEventSystem:UnBind(self.resume_binder)
		self.resume_binder = nil
	end
	if self.speedup_binder then
		GlobalEventSystem:UnBind(self.speedup_binder)
		self.speedup_binder = nil
	end
	if self.speeddown_binder then
		GlobalEventSystem:UnBind(self.speeddown_binder)
		self.speeddown_binder = nil
	end
end

function GameInfoView:InitEvents( )
	--怪物逃跑（血量变化)的事件
	if self.arrived_enemy_binder == nil then
		local func = function (arrived, max_arrive)
			arrived = (arrived <= max_arrive) and arrived or max_arrive
			self.wave_label:setString(string.format("%d/%d", arrived, max_arrive))
		end
		self.arrived_enemy_binder = GlobalEventSystem:Bind(EventName.EnemyArrived, func)
	end

	--金币变化的事件
	if self.gold_received_binder == nil then
		local func = function (delta, cur_golds)
			self.gold_label:setString(string.format("%d", cur_golds))
		end
		self.gold_received_binder = GlobalEventSystem:Bind(EventName.GoldChanged, func)
	end

	--点击暂停按钮
	if self.pause_binder == nil then
		local func = function ()
			if self.show_pause_btn then
				self.show_pause_btn = false
				self.btn_pause:removeFromParentAndCleanup(false)
				self.root_wnd:addChild(self.btn_resume)
			end
		end
		self.pause_binder = GlobalEventSystem:Bind(EventName.Pause, func)
	end

	--点击继续按钮
	if self.resume_binder == nil then
		local func = function ()
			if not self.show_pause_btn then
				self.show_pause_btn = true
				self.btn_resume:removeFromParentAndCleanup(false)
				self.root_wnd:addChild(self.btn_pause)
			end
		end
		self.resume_binder = GlobalEventSystem:Bind(EventName.Resume, func)
	end

	--点击加速按钮
	if self.speedup_binder == nil then
		local func = function ()
			if self.show_speedup_btn then
				self.show_speedup_btn = false
				self.btn_speedup:removeFromParentAndCleanup(false)
				self.root_wnd:addChild(self.btn_speeddown)
			end
		end
		self.speedup_binder = GlobalEventSystem:Bind(EventName.Speedup, func)
	end

	--点击减速按钮
	if self.speeddown_binder == nil then
		local func = function ()
			if not self.show_speedup_btn then
				self.show_speedup_btn = true
				self.btn_speeddown:removeFromParentAndCleanup(false)
				self.root_wnd:addChild(self.btn_speedup)
			end
		end
		self.speeddown_binder = GlobalEventSystem:Bind(EventName.Speeddown, func)
	end
end