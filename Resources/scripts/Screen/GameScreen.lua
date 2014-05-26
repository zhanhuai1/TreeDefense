GameScreen = GameScreen or BaseClass(BaseScreen)

function GameScreen:__init()
	self.map = nil
	self.touch_layer = nil
end

function GameScreen:__delete()
	self:Exit()
end

function GameScreen:Enter(chapter, level)
	BaseScreen.Enter(self)
	local map_info = g_maps_config[chapter][level]

	self.cur_map_info = map_info

	local scene_touched_func = function (event_type, x, y)	
		-- print("GameScreen:SceneTouched!!!!!!!!!!!!!!", event_type, x, y)	
		if event_type == "began" then
			self:OnSceneTouchBegan(x, y)
			return true
		elseif event_type == "moved" then
			self:OnSceneTouchMoved(x, y)
		elseif event_type == "ended" then
			self:OnSceneTouchEnded(x, y)
		end
	end
	self.touch_layer = cc.Layer:create()
	self.touch_layer:registerScriptTouchHandler(scene_touched_func, false, 5, true)
	self.touch_layer:setAnchorPoint(cc.p(0.5, 0.5))
	self.touch_layer:setTouchEnabled(true)

	Glo.LayerTouch:addChild(self.touch_layer)

	if self.map then
		self.map:DeleteMe()
		self.map = nil
	end
	self.map = Scene.New(map_info)

	self:InitEvents()
end

function GameScreen:Exit()
	BaseScreen.Exit(self)

	if self.popup_menu then
		self.popup_menu:DeleteMe()
		self.popup_menu = nil
	end

	if self.map ~= nil then
		self.map:DeleteMe()
		self.map = nil
	end

	if self.failed_view then
		self.failed_view:DeleteMe()
		self.failed_view = nil
	end

	if self.touch_layer then
		self.touch_layer:removeFromParent(true)
		self.touch_layer = nil
	end

	if self.failed_binder then
		GlobalEventSystem:UnBind(self.failed_binder)
		self.failed_binder = nil
	end

	if self.retry_binder then
		GlobalEventSystem:UnBind(self.retry_binder)
		self.retry_binder = nil
	end

	if self.pause_binder then
		GlobalEventSystem:UnBind(self.pause_binder)
		self.pause_binder = nil
	end

	if self.resume_binder then
		GlobalEventSystem:UnBind(self.resume_binder)
		self.resume_binder = nil
	end
end

function GameScreen:InitEvents()
	--游戏失败的事件 
	if self.failed_binder == nil then
		local func = function ( ... )
			self:OnFailed()
		end
		self.failed_binder = GlobalEventSystem:Bind(EventName.Failed, func)
	end

	if self.succeed_binder == nil then
		local func = function ( ... )
			self:OnSucceed()
		end
		self.succeed_binder = GlobalEventSystem:Bind(EventName.Succeed, func)
	end
	
	--失败后重试
	if self.retry_binder == nil then
		local func = function ( ... )
			self:Retry()
		end
		self.retry_binder = GlobalEventSystem:Bind(EventName.Retry, func)
	end

	--暂停、恢复
	if self.pause_binder == nil then
		local func = function ( ... )
			self.map:SetPause(true)
		end
		self.pause_binder = GlobalEventSystem:Bind(EventName.Pause, func)
	end
	if self.resume_binder == nil then
		local func = function ( ... )
			self.map:SetPause(false)
		end
		self.resume_binder = GlobalEventSystem:Bind(EventName.Resume, func)
	end
end

function GameScreen:Retry()
	if self.map then
		self.map:DeleteMe()
	end
	self.map = Map.New(self.cur_map_info.map_name)
	self.map:Init()
end

--点击屏幕
function GameScreen:OnSceneClicked(x, y)
	local camera_pos = self.map:GetCameraPos()
	local tile = Utils.PixelToTile(cc.pAdd(cc.p(x,y), camera_pos))
	self.map:OnClick(tile)
	-- print("GameScreen:OnSceneClicked", string.format("PixelPos:%.2f, %.2f    tilePos:%.2f, %.2f", x, y, tile.x, tile.y))
	return true
end

function GameScreen:OnSceneTouchBegan(x, y)
	-- body
	self.is_touching = true
	self.is_touch_moving = false
	self.touch_began_pos = cc.p(x, y)
	self.last_touch_pos = cc.p(x, y)
end

function GameScreen:OnSceneTouchMoved(x, y)
	if not self.is_touch_moving then
		if cc.pGetDistance(cc.p(x, y), self.touch_began_pos) > 30 then
			self.is_touch_moving = true
		end
	end
	if self.is_touch_moving then
		--注意摄像机的移动和Touch的移动是反向的才对
		local offset = cc.p(self.last_touch_pos.x-x, self.last_touch_pos.y-y)
		if self.map then
			self.map:MoveCamera(offset)
		end
		self.last_touch_pos = cc.p(x, y)
	end
end

function GameScreen:OnSceneTouchEnded(x, y)
	if not self.is_touch_moving then
		self:OnSceneClicked(x, y)
	end
	self.is_touching = false
	self.is_touch_moving = false
	self.touch_began_pos = nil
	self.last_touch_pos = nil
end

function GameScreen:Update(delta_time, running_time)
	if self.map then
		self.map:Update(delta_time, running_time)
	end
end

--显示弹出菜单
function GameScreen:ShowPopupMenu(tile_pos, icon_info_list)
	if self.popup_menu == nil then
		self.popup_menu = PopupMenu.New()
	end
	self.popup_menu:Open(tile_pos, self.map, icon_info_list)
end

function GameScreen:HidePopupMenu()
	if self.popup_menu then
		self.popup_menu:Close()
	end
end

--游戏失败的事件
function GameScreen:OnFailed()
	if self.failed_view == nil then
		self.failed_view = FailedView.New()
	end
	self.failed_view:Open()
	self.map:SetPause(true)
end

--本关成功结束的事件
function GameScreen:OnSucceed()
	if self.succeed_view == nil then
		self.succeed_view = SucceedView.New()
	end
	self.succeed_view:Open()
	self.map:SetPause(true)
end
