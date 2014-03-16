GameScreen = GameScreen or BaseClass(BaseScreen)

function GameScreen:__init()
	self.map = nil
	self.touch_layer = nil
end

function GameScreen:__delete()
	self:Exit()
end

function GameScreen:Enter(map_info)
	BaseScreen.Enter(self)

	if map_info == nil then
		GlobalEventSystem:Fire(EventName.GoMainMenu)
		return
	end

	self.cur_map_info = map_info

	local scene_touched_func = function (event_type, x, y)	
		-- print("GameScreen:SceneTouched!!!!!!!!!!!!!!", event_type, x, y)	
		if event_type == CCTOUCHBEGAN then
			self:OnSceneTouchBegan(x, y)
			return true
		elseif event_type == CCTOUCHMOVED then
			self:OnSceneTouchMoved(x, y)
		elseif event_type == CCTOUCHENDED then
			self:OnSceneTouchEnded(x, y)
		end
	end
	self.touch_layer = CCLayer:create()
	self.touch_layer:registerScriptTouchHandler(scene_touched_func, false, 5, true)
	self.touch_layer:setAnchorPoint(cc.p(0.5, 0.5))
	self.touch_layer:setTouchEnabled(true)

	g_game_scene:addChild(self.touch_layer, Config.ZOrder.Touch)

	self.game_info_view = GameInfoView.New()

	if self.map then
		self.map:DeleteMe()
		self.map = nil
	end
	self.map = Map.New(map_info.map_name)
	self.map:Init()

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

	if self.game_info_view then
		self.game_info_view:DeleteMe()
		self.game_info_view = nil
	end

	if self.touch_layer then
		self.touch_layer:removeFromParentAndCleanup(true)
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
	-- print("!!!!!!!!", string.format("PixelPos:%.2f, %.2f    tilePos:%.2f, %.2f", x, y, tile.x, tile.y))
	local t = {}

	local cur_tile_state = self.map:GetTileState(tile.x, tile.y)
	if cur_tile_state == Map.TileState.EMPTY then
		--填充生长基
		local icon_info = {}
		icon_info.frame_name = "icon_build_base"
		icon_info.press_func = function()
			self.map:FillTile(tile.x, tile.y, Map.TileState.BUILD_TILE)
		end
		table.insert(t, icon_info)

		--填充废弃基
		icon_info = {}
		icon_info.frame_name = "icon_rubbish_base"
		icon_info.press_func = function()
			self.map:FillTile(tile.x, tile.y, Map.TileState.INVALID_TILE)
		end
		table.insert(t, icon_info)
	elseif cur_tile_state == Map.TileState.BUILD_TILE then
		--建塔1
		local icon_info = {}
		icon_info.frame_name = "icon_tower_1_1"
		icon_info.press_func = function ()
			self.map:CreateTower(tile.x, tile.y, "Base")
		end
		table.insert(t, icon_info)

		--建塔2
		local icon_info = {}
		icon_info.frame_name = "icon_tower_2_1"
		icon_info.press_func = function ()
			-- self.map:CreateTower(tile.x, tile.y, "Base")
		end
		table.insert(t, icon_info)

		--建塔3
		local icon_info = {}
		icon_info.frame_name = "icon_tower_3_1"
		icon_info.press_func = function ()
			-- self.map:CreateTower(tile.x, tile.y, "Base")
		end
		table.insert(t, icon_info)

		--拆除按钮
		local icon_info = {}
		icon_info.frame_name = "icon_destroy"
		icon_info.press_func = function ()
			self.map:FillTile(tile.x, tile.y, Map.TileState.EMPTY)
		end
		table.insert(t, icon_info)
	elseif cur_tile_state == Map.TileState.INVALID_TILE then
		self:HidePopupMenu()
		return
	elseif cur_tile_state == Map.TileState.TOWER_BUILT then
		--升级按钮
		local icon_info = {}
		icon_info.frame_name = "icon_tower_upgrade"
		icon_info.press_func = function ()
			-- self.map:FillTile(tile.x, tile.y, Map.TileState.EMPTY)
		end
		table.insert(t, icon_info)

		--拆除按钮
		local icon_info = {}
		icon_info.frame_name = "icon_destroy"
		icon_info.press_func = function ()
			self.map:RemoveTower(tile.x, tile.y)
		end
		table.insert(t, icon_info)
	end

	
	self:ShowPopupMenu(tile, t)

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
		if ccpDistance(cc.p(x, y), self.touch_began_pos) > 30 then
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
