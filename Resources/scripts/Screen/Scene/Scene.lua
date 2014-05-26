Scene = Scene or BaseClass()

Scene.CamStage = {
	ZoomIn =1,     	--摄像机放大阶段
	ZoomOut = 2,   	--摄像机缩小阶段
	Normal = 3,		--普通状态
}
Scene.CamMinDist = 1e-6

function Scene:__init(map_config)
	Scene.Instance = self
	self.map_config = map_config

	--整个场景的像素大小
	self.pixel_size = cc.size(Config.MapTilesX * Config.TileSize, Config.MapTilesY * Config.TileSize)

	self.camera = nil

	self.cam_stage = Scene.CamStage.Normal
	self.cam_param = nil

	self.tile_batch_node = nil
	self.path_points_node = nil
	self.build_parent_node = nil
	self.bullet_parent_node = nil
	self.enemy_parent_node = nil

	self.count_down_view = nil

	self.game_info_view = nil

	self.popup_menu_view = nil

	self.tile_list = {}
	self.build_list = {}
	self.tower_list = {}
	self.block_list = {}	
	self.bullet_list = {}
	self.enemy_list = {} 			--怪物列表，id:对象
	self.sorted_enemy_list = {} 	--所有怪物按到终点的距离排序，队列
	self.dying_obj_list = {} 		--播放死亡动画的对象列表，刷新时间间隔长一点，当动画播放完了就销毁之
	self.tower_id = 0
	self.bullet_id = 0
	self.enemy_id = 0
	self.dying_obj_id = 0

	self.enemy_pool = {}  		--为了减少node的创建，死亡的enemy并不会销毁，而是放入enemy_pool中等待下次需要时再取出来
	self.bullet_pool = {}		--同上

	


	--路径列表
	self.key_path_list 	= {} --路径拐点列表（含起点）
	self.total_path_list= {} --路径所有格子列表（含起点）

	--用来显示路径的
	self.is_showing_path = false
	self.update_path_points_time = 0
	local path_num = #self.map_config.start_pt
	self.path_points = {}
	for i=1, path_num do
		local t = {}
		t.hilight_i 	= 0
		self.path_points[i] = t
	end

	--初始化地图
	self:InitScene()

	--绑定事件
	self:InitEvents()
end

function Scene:__delete()
	for id, point_sprite in pairs(self.path_points) do
		point_sprite:removeFromParent(true)
	end
	self.path_points = {}

	for x =1, Config.MapTilesX do
		for y = 1, Config.MapTilesY do
			local tile_obj = self.tile_list[x][y]
			tile_obj:DeleteMe()

			local build_obj = self.build_list[x][y]
			if build_obj then
				build_obj:DeleteMe()
			end
		end
	end
	for _, enemy in pairs(self.enemy_list) do
		enemy:DeleteMe()
	end

	for _, bullet in pairs(self.bullet_list) do
		bullet:DeleteMe()
	end
	--濒死对象
	for id, obj in pairs(self.dying_obj_list) do
		obj:DeleteMe()
	end
	self.tile_list = {}
	self.build_list = {}
	self.tower_list = {}
	self.block_list = {}
	self.enemy_list = {}
	self.sorted_enemy_list = {}
	self.bullet_list = {}
	self.dying_obj_list = {}

	--各层次的主Node
	if self.tile_batch_node then
		self.tile_batch_node:removeFromParent(true)
		self.tile_batch_node = nil
	end
	if self.path_points_node then
		self.path_points_node:release()
		self.path_points_node:removeFromParent(true)
		self.path_points_node = nil
	end
	if self.build_parent_node then
		self.build_parent_node:removeFromParent(true)
		self.build_parent_node = nil
	end
	if self.bullet_parent_node then
		self.bullet_parent_node:removeFromParent(true)
		self.bullet_parent_node = nil
	end
	if self.enemy_parent_node then
		self.enemy_parent_node:removeFromParent(true)
		self.enemy_parent_node = nil
	end
	
	--摄像机要复位
	local action = Glo.LayerMap:getActionByTag(Config.ActionTag.Camera)
	if action then
		Glo.LayerMap:stopAction(action)
	end
	self.camera = nil

	--各种界面
	if self.count_down_view then
		self.count_down_view:DeleteMe()
		self.count_down_view = nil
	end	
	if self.popup_menu_view then
		self.popup_menu_view:DeleteMe()
		self.popup_menu_view = nil
	end
	if self.move_cam_handler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.move_cam_handler)
		self.move_cam_handler = nil
	end

	--解绑事件
	if self.create_build_binder then
		GlobalEventSystem:UnBind(self.create_build_binder)
		self.create_build_binder = nil
	end
end

--点击事件是否有效（游戏刚开始倒数或摄像机缩放时就处于无效状态）
function Scene:IsTouchEnable()
	return self.cam_stage == Scene.CamStage.Normal
end

--读取配置初始化地图
function Scene:InitScene()
	local width = Config.MapTilesX
	local height = Config.MapTilesY

	--初始化SpriteBatchNode
	local tile_texture = cc.Director:getInstance():getTextureCache():addImage("media/sheet_blocks.png")
	self.tile_batch_node = cc.SpriteBatchNode:createWithTexture(tile_texture, width * height)
	Glo.LayerMap:addChild(self.tile_batch_node, Config.ZOrder.MapTile)

	--路径提示
	self.path_points_node = cc.Node:create()
	self.path_points_node:retain() --由于需要切换显示隐藏，所以retain一次
	-- Glo.LayerMap:addChild(self.path_points_node, Config.ZOrder.MapPath)

	--初始化塔和障碍的父Node
	self.build_parent_node = cc.Node:create()
	Glo.LayerMap:addChild(self.build_parent_node, Config.ZOrder.MapTower)

	--初始化子弹结点
	self.bullet_parent_node = cc.Node:create()
	Glo.LayerMap:addChild(self.bullet_parent_node, Config.ZOrder.MapBullet)

	--初始化怪物结点
	self.enemy_parent_node = cc.Node:create()
	Glo.LayerMap:addChild(self.enemy_parent_node, Config.ZOrder.MapEnemy)

	--创建路径查找器
	local path_num = #self.map_config.start_pt
	self.path_finder = PathFinder.New(path_num)
	for i=1, path_num do
		self.path_finder:SetDest(i, self.map_config.end_pt[i])
	end

	--设置格子状态	
	for x = 1, width do
		self.tile_list[x] = {}
		self.build_list[x] = {}
		for y = 1, height do
			local tile_type = self.map_config.tiles[y][x]
			local tile_obj = TileObj.New(x, y, tile_type, self.tile_batch_node)
			self.tile_list[x][y] = tile_obj
			self.build_list[x][y] = nil

			self.path_finder:SetBlock(cc.p(x, y), (tile_type~=0), true)
		end
	end
	self.path_finder:CalcPath()

	--获取各个起点到终点的路径，并计算出pixel_pos
	for i=1, path_num do
		local start_pt = self.map_config.start_pt[i]
		local path, tiles = self.path_finder:GetPath(start_pt, i)
		self.key_path_list[i] = path
		self.total_path_list[i] = tiles
	end

	--显示路径点
	self:ShowPathPoints()


	--刚进入场景时缩放摄像机
	local camera = self:_getCamera()
	local cam_x = self.pixel_size.width / 2 - Glo.VisibleSize.width / 2
	local cam_y = self.pixel_size.height / 2 - Glo.VisibleSize.height / 2
	
	local eyex, eyey, eyez = camera:getEye()
	Scene.CamMinDist = eyez --摄像机坐标的最小值，不能为0，为0时会黑屏
	camera:setEye(cam_x, cam_y, Scene.CamMinDist)
	camera:setCenter(cam_x, cam_y, 0)
	

	self:CameraZoomIn()

	--显示倒计时
	self.count_down_view = CountDownView.New()
	self.count_down_view:Open()

	self.popup_menu_view = PopupMenu.New()

	--test
	-- self:CreateEnemy(1)

end

--监听事件
function Scene:InitEvents()
	local build_func = function (type_id, tile_pos)
		self:CreateBuild(type_id, tile_pos)
	end
	self.create_build_binder = GlobalEventSystem:Bind(EventName.Build, build_func)

end

function Scene:Update(delta_time, running_time)
	--测试
	if self.create_monster_time == nil or running_time - self.create_monster_time > 1 then
		self.create_monster_time = running_time
		local path_i = 1
		if self.is_enemy_path_i == nil then
			path_i = 1
			self.is_enemy_path_i = true
		else
			path_i = 2
			self.is_enemy_path_i = nil
		end
		local monster = self:CreateEnemy(1, path_i)
	end

	--路径点
	if self.is_showing_path then
		local time_len = 0.1
		if running_time - self.update_path_points_time > time_len then
			self.update_path_points_time = running_time
			-- print("running_time:", running_time, self.update_path_points_time, running_time - self.update_path_points_time)

			--多条路径分别刷新
			for i=1, #self.path_points do
				local sprite_list = self.path_points[i]
				local sprite_num = #sprite_list
				local now_hilight = math.floor(running_time / time_len) % sprite_num + 1 
				local old_hilight = sprite_list.hilight_i
				
				-- print("now_hilight:", now_hilight, "old_hilight:", old_hilight)
				if old_hilight ~= now_hilight then
					local sprite = sprite_list[old_hilight]
					if sprite then
						-- print("设置白色", now_hilight)
						sprite:setColor(cc.c3b(255, 255, 255))
					end
					
					sprite = sprite_list[now_hilight]
					if sprite then
						-- print("设置蓝色色", now_hilight)
						sprite:setColor(cc.c3b(100,100,100))
					end
					sprite_list.hilight_i = now_hilight
				end
			end
		end
	end

	--缩放摄像机
	if self.cam_param ~= nil and self.cam_param.playing then
		local delta_t = running_time - self.cam_param.start_time
		local p = delta_t / self.cam_param.total_time
		if p >= 1 then
			p = 1
			self.cam_param.playing = false
		end
		local p1 = self.cam_param.start_eye_pos
		local p2 = self.cam_param.end_eye_pos
		local x = Utils.P1ToP2(p1.x, p2.x, p)
		local y = Utils.P1ToP2(p1.y, p2.y, p)
		local z = Utils.P1ToP2(p1.z, p2.z, p)
		local camera = self:_getCamera()

		-- print("CamUpdating:", self.cam_param.start_eye_pos.z, self.cam_param.end_eye_pos.z, p, x, y, z)
		camera:setEye(x, y, z)
		camera:setCenter(x, y, 0)

		--缩小阶段结束后就进入普通状态
		if p>=1 and self.cam_stage == Scene.CamStage.ZoomOut then
			self.cam_stage = Scene.CamStage.Normal
			self.cam_param = nil
		end
	end

	--倒计时
	if self.count_down_view then
		if self.count_down_view:Update(delta_time, running_time) then			
			self.count_down_view:DeleteMe()
			self.count_down_view = nil
			
			--缩回视野
			self:CameraZoomOut()

			--打开GameInfoView
			if self.game_info_view == nil then
				self.game_info_view = GameInfoView.New()
			end
		else
			return
		end
	end

	-----------------------------------------
	--刷新场景对象
	for _, enemy in pairs(self.enemy_list) do
		enemy:Update(delta_time, running_time)
		if enemy:IsDead() or enemy:IsArrived() then
			self:DestroyEnemy(enemy)
		end
	end
	--刷新完enemy后对它们排序
	self:SortAllEnemy()

	for _, tower in pairs(self.tower_list) do
		tower:Update(delta_time, running_time)
	end
	
	for _, bullet in pairs(self.bullet_list) do
		bullet:Update(delta_time, running_time)
		if bullet:IsHitted() then
			self:DestroyBullet(bullet)
		end
	end

	--濒死对象
	local update_dying_obj_time = self.update_dying_obj_time
	if update_dying_obj_time == nil or running_time - update_dying_obj_time >= 0.3 then
		self.update_dying_obj_time = running_time
		for id, obj in pairs(self.dying_obj_list) do
			obj:Update(delta_time, running_time)
			if obj:IsDestroy() then
				self:DestroyDyingObj(obj)
				self.dying_obj_list[id] = nil
			end
		end
	end
	-----------------------------------------

end

--获取场景摄像机的ActionCamera
function Scene:_getCamera()
	if self.camera == nil then
		local action = Glo.LayerMap:getActionByTag(Config.ActionTag.Camera)
		if action then
			Glo.LayerMap:stopAction(action)
		end

		self.camera = cc.ActionCamera:create()
		action = cc.RepeatForever:create(self.camera)
		action:setTag(Config.ActionTag.Camera)
		Glo.LayerMap:runAction(action)
	end
	return self.camera
end

--放大视野（拉远摄像机）
function Scene:CameraZoomIn()
	if self.cam_stage == Scene.CamStage.ZoomIn then
		return
	end
	local time = 0.25
	local camera = self:_getCamera()
	local cam_x, cam_y, cam_z = camera:getEye()

	local scale_x = self.pixel_size.width / Glo.VisibleSize.width
	local scale_y = self.pixel_size.height / Glo.VisibleSize.height
	scale = math.max(scale_x, scale_y)
	
	local origin_z = cc.Director:getInstance():getZEye()
	local end_z = (scale-1) * origin_z
	local end_x = self.pixel_size.width / 2 - Glo.VisibleSize.width / 2
	local end_y = self.pixel_size.height / 2 - Glo.VisibleSize.height / 2

	self.cam_param = self.cam_param or {}
	self.cam_param.start_eye_pos 	= cc.Vertex3F(cam_x, cam_y, cam_z) --缩放开始时的坐标
	self.cam_param.end_eye_pos 		= cc.Vertex3F(end_x, end_y, end_z) --缩放的目标坐标
	self.cam_param.start_time = Glo.RunningTime
	self.cam_param.total_time = time
	self.cam_param.playing = true

	self.cam_stage = Scene.CamStage.ZoomIn

	--拉远摄像机时要关闭popup_menu和其他一些内容
	if self.move_cam_handler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.move_cam_handler)
		self.move_cam_handler = nil
	end
	if self.popup_menu_view and self.popup_menu_view:IsOpen() then
		self.popup_menu_view:Close()
	end
end

--缩小视野（拉近摄像机）
function Scene:CameraZoomOut()
	if self.cam_stage == Scene.CamStage.ZoomOut then
		return
	end
	local time = 0.25
	local camera = self:_getCamera()
	local cam_x, cam_y, cam_z = camera:getEye()

	self.cam_param = self.cam_param or {}
	--通常情况下，视野缩小时的目标坐标应该是之前视野这么大时的起点坐标，因为视野缩放不一定是从场景中心点开始的
	if self.cam_param.start_eye_pos ~= nil then
		self.cam_param.end_eye_pos = self.cam_param.start_eye_pos
	else
		self.cam_param.end_eye_pos = cc.Vertex3F(cam_x, cam_y, Scene.CamMinDist)
	end
	self.cam_param.start_eye_pos	= cc.Vertex3F(cam_x, cam_y, cam_z)
	self.cam_param.start_time = Glo.RunningTime
	self.cam_param.total_time = time
	self.cam_param.playing = true
	self.cam_stage = Scene.CamStage.ZoomOut
end

--设置场景摄像机的坐标，会进行边界限定
function Scene:SetCameraPos(x, y, z)
	local main_camera = self:_getCamera()
	
	local max_x = self.pixel_size.width - Glo.VisibleSize.width
	local max_y = self.pixel_size.height - Glo.VisibleSize.height
	if x < 0 then
		x = 0
	elseif x > max_x then
		x = max_x
	end
	if y < 0 then
		y = 0
	elseif y > max_y then
		y = max_y
	end
	
	-- print("= = =SetCameraPos",x, y)
	main_camera:setEye(x, y, z)
	main_camera:setCenter(x, y, 0)
end

--移动场景摄像机
function Scene:MoveCamera(offset)
	if self.cam_stage ~= Scene.CamStage.Normal then
		return
	end
	local main_camera = self:_getCamera()
	local x,y,z = main_camera:getEye()
	-- print("= = = =MoveCamera:", x, y, offset.x, offset.y)
	x = x + offset.x
	y = y + offset.y
	self:SetCameraPos(x, y, z)
end

--获取场景摄像机的坐标
function Scene:GetCameraPos()
	local main_camera = self:_getCamera()
	local x,y,z = main_camera:getEye()
	return cc.p(x, y)
end

--获取摄像机可见的范围（无视缩放）
function Scene:GetViewRectWithoutScale()	
	local main_camera = self:_getCamera()
	local x,y,z = main_camera:getEye()
	return cc.rect(x, y, Glo.VisibleSize.width, Glo.VisibleSize.height)
end

function Scene:OnClick(tile_pos)
	if self.cam_stage ~= Scene.CamStage.Normal then
		return
	end
	if tile_pos.y <= 1 or tile_pos.y >= Config.MapTilesY or tile_pos.x <= 1 or tile_pos.x >= Config.MapTilesX then
		if self.popup_menu_view:IsOpen() then
			self.popup_menu_view:Close()
		end
		return
	end

	--检查是否需要移动摄像机，以便完整显示popup_menu
	local pp 	 	= Utils.TileToPixel(tile_pos)
	local pw 		= 64 + 32
	local pop_rect 	= cc.rect(pp.x-pw, pp.y-pw, pw*2, pw*2)
	local view_rect = self:GetViewRectWithoutScale()
	local cam_move 	= cc.p(0,0)
	if cc.rectGetMinX(pop_rect) < cc.rectGetMinX(view_rect) then
		cam_move.x = cc.rectGetMinX(pop_rect) - cc.rectGetMinX(view_rect)
	elseif cc.rectGetMaxX(pop_rect) > cc.rectGetMaxX(view_rect) then
		cam_move.x = cc.rectGetMaxX(pop_rect) - cc.rectGetMaxX(view_rect)
	end
	if cc.rectGetMinY(pop_rect) < cc.rectGetMinY(view_rect) then
		cam_move.y = cc.rectGetMinY(pop_rect) - cc.rectGetMinY(view_rect)
	elseif cc.rectGetMaxY(pop_rect) > cc.rectGetMaxY(view_rect) then
		cam_move.y = cc.rectGetMaxY(pop_rect) - cc.rectGetMaxY(view_rect)
	end
	if cam_move.x ~= 0 or cam_move.y ~= 0 then
		local now_pos = self:GetCameraPos()
		local tar_pos = cc.pAdd(now_pos, cam_move)
		local start_t = Glo.RunningTime
		local move_cam_func = function ()
			local p = (Glo.RunningTime - start_t) / 0.13
			local cam = self:_getCamera()
			local x,y,z = cam:getEye()
			if p <= 1 then
				local pos = cc.pLerp(now_pos, tar_pos, p)
				self:SetCameraPos(pos.x, pos.y, z)
			else
				self:SetCameraPos(tar_pos.x, tar_pos.y, z)
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.move_cam_handler)
				self.move_cam_handler = nil
			end
		end
		self.move_cam_handler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(move_cam_func, 0.03, false)
		-- self:MoveCamera(cam_move)
	end

	self:OpenPopupMenu(tile_pos)
end

function Scene:OpenPopupMenu(tile_pos)
	local icon_info_list = {}
	local build_obj = self.build_list[tile_pos.x][tile_pos.y]

	--如果格子上已经有建造对象
	if build_obj ~= nil then
		local build_type = build_obj:GetBuildType()
		local level = build_obj:GetBuildLevel()
		local max_level = build_obj:GetBuildMaxLevel()
		
		--如果是塔，要判断各种情况
		if build_type ~= BuildConfig.Types.Block then
			--如果还没到顶级就显示升级按钮
			if level < max_level then
				table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.Upgrade, 0, build_obj:GetUpgradePrice()))
			
			else
				--如果到顶级了而且没有次级，就显示一个顶级按钮
				local next_generations = build_obj:GetNextGenerations()
				if next_generations == nil or #next_generations == 0 then
					table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.MaxLevel))

				--如果有次级塔，就显示建造按钮
				else
					for i=1, #next_generations do
						local next_gen_type_id = next_generations[i]
						local price = BuildConfig.GetBuildPrice(next_gen_type_id)
						table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.Build, next_gen_type_id, price))
					end
				end
			end
		end

		--显示摧毁按钮
		table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.Sell, 0, build_obj:GetTotalPrice()))
	
	--如果格子上还没建东西，就显示建造按钮
	else		
		local price = BuildConfig.GetBuildPrice(1)
		table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.Build, 1, price))

		price = BuildConfig.GetBuildPrice(2)
		table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.Build, 2, price))

		price = BuildConfig.GetBuildPrice(3)
		table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.Build, 3, price))

		price = BuildConfig.GetBuildPrice(4)
		table.insert(icon_info_list, PopupIconInfo.New(PopupIconInfo.IconTypes.Build, 4, price))
	end

	-- for i=1, #icon_info_list do
	-- 	local info = icon_info_list[i]
	-- 	print("= = =:", info.type, info.build_type_id, info.price)
	-- end
	self.popup_menu_view:Open(tile_pos, icon_info_list)
end

--创建BuildObj
function Scene:CreateBuild(type_id, tile_pos)
	print("= = =Scene:CreateBuild: ", type_id, tile_pos.x, tile_pos.y)
	local old_obj = self.build_list[tile_pos.x][tile_pos.y]
	if old_obj then
		old_obj:DeleteMe()
		self.build_list[tile_pos.x][tile_pos.y] = nil
	end
	
	local obj = nil
	local cfg = BuildConfig[type_id]
	if cfg.type == BuildConfig.Types.Block then

	elseif cfg.type == BuildConfig.Types.BulletTower then
		self.tower_id = self.tower_id + 1
		obj = BulletTower.New(type_id, self.tower_id, tile_pos, self.build_parent_node)		
		self.tower_list[self.tower_id] = obj

	elseif cfg.type == BuildConfig.Types.RazerTower then
		self.tower_id = self.tower_id + 1
		obj = RazerTower.New(type_id, self.tower_id, tile_pos, self.build_parent_node)		
		self.tower_list[self.tower_id] = obj

	end
	self.build_list[tile_pos.x][tile_pos.y] = obj
end

function Scene:DestroyBuild(obj)
	local build_type = obj:GetBuildType()
	local instance_id = obj:GetBuildInstanceId()
	local tile_pos = obj:GetBuildTilePos()

	obj:DeleteMe()
	
	if build_type == BuildConfig.Types.Block then
		self.block_list[instance_id] = nil
	elseif build_type == BuildConfig.Types.BulletTower or build_type == BuildConfig.Types.RazerTower then
		self.tower_list[instance_id] = nil
	end
	self.build_list[tile_pos.x][tile_pos.y] = nil
end

--从bullet_pool中取bullet
function Scene:_ensureBullet()
	local c = #self.bullet_pool
	local ret = nil
	if c > 0 then
		-- print("= = = = Pool Bullet  = = = =")
		ret = self.bullet_pool[c]
		self.bullet_pool[c] = nil
	else
		-- print("= = = = New Bullet  = = = =")
		ret = Bullet.New()
	end
	return ret
end

--创建子弹
function Scene:CreateBullet(type, pos)
	self.bullet_id = self.bullet_id + 1
	local bullet = nil
	bullet = self:_ensureBullet()
	bullet:Init(type, self.bullet_id, pos, self.bullet_parent_node)
	self.bullet_list[self.bullet_id] = bullet
	return bullet
end

--删除Bullet，放入濒死队列，因为它还需要播放死亡动作
function Scene:DestroyBullet(obj)
	local type_id = obj:GetMovableType()
	local instance_id = obj:GetMovableInstanceId()

	-- print("= = = 销毁子弹：", instance_id)
	self.bullet_list[instance_id] = nil

	--放进濒死队列
	self.dying_obj_id = self.dying_obj_id + 1
	self.dying_obj_list[self.dying_obj_id] = obj
end

--从enemy_pool中取enemy
function Scene:_ensureEnemy()
	local c = #self.enemy_pool
	local ret = nil
	if c > 0 then
		-- print("= = = = Pool Enemy  = = = =")
		ret = self.enemy_pool[c]
		self.enemy_pool[c] = nil
	else
		-- print("= = = = New Enemy  = = = =")
		ret = Enemy.New()
	end
	return ret
end

--创建怪物
function Scene:CreateEnemy(type, path_i)
	path_i = path_i or 1
	local start_pt = self.map_config.start_pt[path_i]
	self.enemy_id = self.enemy_id + 1
	local pos = Utils.TileToPixel(start_pt)
	local enemy = self:_ensureEnemy()
	enemy:Init(type, self.enemy_id, pos, self.enemy_parent_node)
	enemy:SetPath(self.key_path_list[path_i])

	self.enemy_list[self.enemy_id] = enemy
	table.insert(self.sorted_enemy_list, enemy)

	return enemy
end

--删除Enemy，放入濒死队列，因为它还需要播放死亡动作
function Scene:DestroyEnemy(obj)
	local instance_id = obj:GetMovableInstanceId()
	
	--先从排序队列中删除该对象（找到对象，然后把队列尾部的对象覆盖它）
	local num = #self.sorted_enemy_list
	for i=1, num do
		local enemy = self.sorted_enemy_list[i]
		if enemy == obj then
			self.sorted_enemy_list[i] = self.sorted_enemy_list[num]
			self.sorted_enemy_list[num] = nil
		end
	end

	self.enemy_list[instance_id] = nil

	--放进濒死队列
	self.dying_obj_id = self.dying_obj_id + 1
	self.dying_obj_list[self.dying_obj_id] = obj
end

function Scene:DestroyDyingObj(obj)
	local t = obj:GetType()
	-- print("DestroyDyingObj Obj:", t)
	if t == Config.ObjType.Enemy then
		obj:Destroy()
		table.insert(self.enemy_pool, obj)
	elseif t == Config.ObjType.Bullet then
		obj:Destroy()
		table.insert(self.bullet_pool, obj)
	else
		obj:DeleteMe()
	end
end

function Scene:ShowPathPoints()	
	--获取（或创建）指定队列的指定索引位置的路径点sprite
	local function _ensure_path_sprite(sprite_list, i)
		local sprite = sprite_list[i]
		if sprite == nil then
			sprite = AssetsHelper.CreateAnimSprite("red_bullet_stat")
			sprite_list[i] = sprite
			self.path_points_node:addChild(sprite)
		end
		return sprite
	end

	local path_num = #self.total_path_list
	for i=1, path_num do
		--获取路径格子
		-- local start_pt = self.map_config.start_pt[i]
		-- local path, tiles = self.path_finder:GetPath(start_pt, i)
		local tiles = self.total_path_list[i]
		local sprite_list = self.path_points[i]
		local visible_num = 0

		--每隔半个格子创建一个sprite
		for j=1, #tiles do
			local info = tiles[j]
			local pixel_pos = Utils.TileToPixel(cc.p(info.x, info.y))
			visible_num = visible_num + 1
			local sprite = _ensure_path_sprite(sprite_list, visible_num)
			sprite:setPosition(pixel_pos)

			if info.direction ~= PathFinder.Dirs.None then
				local dir_vec = PathFinder.DirVecs[info.direction]
				visible_num = visible_num + 1
				local sprite = _ensure_path_sprite(sprite_list, visible_num)
				local pixel_pos = cc.pAdd( pixel_pos, cc.pMul(dir_vec, Config.TileSize/2))
				sprite:setPosition(pixel_pos)
			end
		end

		--把多余的sprite删掉
		local list_len = #sprite_list
		if visible_num < list_len then
			for j=visible_num+1, list_len do
				local sprite = sprite_list[j]
				sprite:removeFromParent(true)
				sprite_list[j] = nil
			end
		end
	end

	Glo.LayerMap:addChild(self.path_points_node, Config.ZOrder.MapPath)
	self.is_showing_path = true
end

function Scene:HidePathPoints()
	self.is_showing_path = false
	self.path_points_node:removeFromParent(false)
end

function Scene:GetEnemyInRange(pixel_pos, range, nearst)
	local ret = nil
	local ret_list = {}
	for i=1, #self.sorted_enemy_list do
		local enemy = self.sorted_enemy_list[i]
		local e_pos = enemy:GetPixelPos()
		local radius= enemy:GetRadius()
		local bound = radius + range

		--用enemy坐标、enemy半径和range在pixel_pos周围设定一个最大距离方框，在这个方框内才进行进一步判断
		if math.abs(pixel_pos.x - e_pos.x) - radius <= range or
			math.abs(pixel_pos.y - e_pos.y) - radius <= range then
			local dist = cc.pGetDistance(e_pos, pixel_pos)
			if dist - radius <= range then
				if not nearst then
					ret = enemy
					break
				else
					local t = {}
					t.obj = enemy
					t.dist = dist
					table.insert(ret_list, t)
				end
			end
		end		
	end
	if not nearst then
		return ret
	else
		if #ret_list > 0 then
			if #ret_list > 1 then
				local sort_func = function (a, b)
					return a.dist < b.dist
				end
				table.sort(ret_list, sort_func)
			end
			local t = ret_list[1]
			return t.obj
		end
	end
end

function Scene:SortAllEnemy()
	local sort_func = function (a, b)
		return a.enemy_path_left_dist < b.enemy_path_left_dist
	end
	table.sort(self.sorted_enemy_list, sort_func)
end

