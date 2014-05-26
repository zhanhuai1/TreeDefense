GameInfoView = GameInfoView or BaseClass()


function GameInfoView:__init( )
	self.root_node = cc.Node:create()
	self.root_node:setPosition(cc.p(0, 0))
	Glo.LayerUI:addChild(self.root_node)

	local frame = AssetsHelper.GetFrame("state_panel_bg.png")
	self.bg_height = frame:getRect().height
	self.bg = AssetsHelper.CreateScale9Sprite("state_panel_bg.png")
	self.bg:setContentSize(cc.size(Glo.VisibleSize.width, self.bg_height))
	self.bg:setAnchorPoint(cc.p(0, 0))
	self.bg:setPosition(cc.p(0, 0))
	self.root_node:addChild(self.bg)

	local x = 96
	local y = 36
	local x_step = 74
	--后退
	local btn = AssetsHelper.CreateButton("back_btn_nor.png", "back_btn_sel.png", "")
	btn:setPosition(x, y)
	btn:setTouchEnabled(false)
	self.root_node:addChild(btn)
	self.btn_back = btn
	
	x = x + x_step
	--暂停
	local btn = AssetsHelper.CreateButton("pause_btn_nor.png", "pause_btn_sel.png", "")
	btn:setPosition(x, y)
	self.root_node:addChild(btn)
	self.btn_pause = btn

	--继续
	local btn = AssetsHelper.CreateButton("goon_btn_nor.png", "goon_btn_sel.png", "")
	btn:setPosition(x, y)
	btn:setTouchEnabled(false)
	self.root_node:addChild(btn)
	self.btn_go_on = btn
	self.btn_go_on:setEnabled(false)

	x = x + x_step
	--加速
	local btn = AssetsHelper.CreateButton("speedup_btn_nor.png", "speedup_btn_sel.png", "")
	btn:setPosition(x, y)
	btn:setTouchEnabled(false)
	self.root_node:addChild(btn)
	self.btn_speed_up = btn

	--减速
	local btn = AssetsHelper.CreateButton("speedup_btn_sel.png", "speedup_btn_nor.png", "")
	btn:setPosition(x, y)
	btn:setTouchEnabled(false)
	self.root_node:addChild(btn)
	self.btn_speed_down = btn
	self.btn_speed_down:setEnabled(false)


	-- self:InitEvents()

	self:PlayOpenAnim()
end

function GameInfoView:__delete( )
	if root_node then
		root_node:removeFromParent(true)
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

--打开过程是否播放完成了
function GameInfoView:IsOpenFinished()
	return self.open_finished
end

function GameInfoView:PlayOpenAnim()
	self.open_finished = false

	if self.root_node then
		self.root_node:setPosition(cc.p(0, -self.bg_height))
		local move_act = cc.MoveTo:create(0.25, cc.p(0, 0))
		self.root_node:runAction(move_act)
	end

	--把按钮依次弹出
	self.btn_back:setScale(0)
	self.btn_pause:setScale(0)
	self.btn_speed_up:setScale(0)

	local scale1 = cc.ScaleTo:create(0.2, 1.2)
	local scale2 = cc.ScaleTo:create(0.05, 1)
	self.btn_back:runAction( cc.Sequence:create( cc.DelayTime:create(0.2), scale1, scale2))
	self.btn_pause:runAction( cc.Sequence:create( cc.DelayTime:create(0.3), scale1:clone(), scale2:clone()))
	self.btn_speed_up:runAction( cc.Sequence:create( cc.DelayTime:create(0.4), scale1:clone(), scale2:clone()))
	local total_t = 0.4 + 0.25

	--当所有按钮都弹出后，再绑定它们的点击事件
	local bind_touch_events_func = function ()
		local back_func = function(target, event_type)
			if event_type == ccui.TouchEventType.ended then
				print("back_func")
			end
			return true
		end
		local pause_func = function(target, event_type)
			if event_type == ccui.TouchEventType.ended then
				print("pause_func")

				self.btn_pause:setEnabled(false)
				self.btn_go_on:setEnabled(true)
				local jump_act = cc.JumpBy:create(0.7, cc.p(0,0), 6, 1)
				self.btn_go_on:runAction( cc.RepeatForever:create( jump_act))
			end
			return true
		end
		local goon_func = function (target, event_type)
			if event_type == ccui.TouchEventType.ended then
				print("goon_func")

				self.btn_pause:setEnabled(true)
				self.btn_go_on:setEnabled(false)
				self.btn_go_on:stopAllActions()
			end
			return true		
		end
		local speed_up_func = function (target, event_type)
			if event_type == ccui.TouchEventType.ended then
				print("speed_up_func")
				self.btn_speed_up:setEnabled(false)
				self.btn_speed_down:setEnabled(true)
				local jump_act = cc.JumpBy:create(0.7, cc.p(0,0), 6, 1)
				self.btn_speed_down:runAction( cc.RepeatForever:create( jump_act))
			end
			return true		
		end
		local speed_down_func = function (target, event_type)
			if event_type == ccui.TouchEventType.ended then
				print("speed_down_func")
				self.btn_speed_up:setEnabled(true)
				self.btn_speed_down:setEnabled(false)
				self.btn_speed_down:stopAllActions()
			end
			return true		
		end
		self.btn_back:setTouchEnabled(true)
		self.btn_pause:setTouchEnabled(true)
		self.btn_go_on:setTouchEnabled(true)
		self.btn_speed_up:setTouchEnabled(true)
		self.btn_speed_down:setTouchEnabled(true)

		self.btn_back:addTouchEventListener(back_func)
		self.btn_pause:addTouchEventListener(pause_func)
		self.btn_go_on:addTouchEventListener(goon_func)
		self.btn_speed_up:addTouchEventListener(speed_up_func)
		self.btn_speed_down:addTouchEventListener(speed_down_func)


		self.open_finished = true
	end	

	local call_act = cc.CallFunc:create(bind_touch_events_func) 
	self.bg:runAction( cc.Sequence:create( cc.DelayTime:create(total_t), call_act))
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
				self.btn_pause:removeFromParent(false)
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
				self.btn_resume:removeFromParent(false)
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
				self.btn_speedup:removeFromParent(false)
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
				self.btn_speeddown:removeFromParent(false)
				self.root_wnd:addChild(self.btn_speedup)
			end
		end
		self.speeddown_binder = GlobalEventSystem:Bind(EventName.Speeddown, func)
	end
end