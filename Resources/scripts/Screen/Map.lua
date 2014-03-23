Map = Map or BaseClass()

Map.LayersConfig = 
{
	BackgroundLayer = 1,
	TileLayer = 2,
	EnemyLayer = 3,
	TowerLayer = 4,
	BulletLayer = 5,
	PopupLayer = 6,
	LayerCount = 6,

}
Map.ObjTypeConfig = 
{
	ObjType_Enemy = 0x10000000,
	ObjType_Tower = 0x20000000,
	ObjType_Bullet= 0x40000000,
	ObjType_Block = 0x80000000,
}
Map.ObjTypeMask = 0xF0000000

Map.SAPType = 
{
	SAP_Enemy = 0x1,
	SAP_Tower = 0x2,
	SAP_Bullet = 0x4,
	SAP_Block = 0x8,

	SAP_CanHit	= 0x1 + 0x8,
	SAP_EnemyFlag = 0x2 + 0x4,
}

Map.TileState = 
{
	EMPTY = 0,		--空格子，可填充生长基
	BUILD_TILE=1,	--填充了生长基
	INVALID_TILE = 2,	--废弃，不可用，被障碍占据
	TOWER_BUILT=3,		--已经建了塔
}


function Map:__init(name)
	self.map_info = g_maps_config[name]
	self.width = #(self.map_info.tile_filled[1])
	self.height = #(self.map_info.tile_filled)
	self.start_pt = cc.p(self.map_info.start_pt.x, self.map_info.start_pt.y)				--起点格子{x,y}
	self.end_pt   = cc.p(self.map_info.end_pt.x, self.map_info.end_pt.y)					--终点格子{x,y}

	self.pixel_width = self.width * Config.TileSize.width
	self.pixel_height = self.height * Config.TileSize.height

	--由于引擎里的索引是从0开始，而脚本从1开始，所以把寻路器创建大一格
	--然后把0行和0列设为障碍区，就能保持索引一致
	self.path_finder = PathFinder(self.width+1, self.height+1)

	self.is_paused = false
	
	-- --tile(0,0)的中心点坐标
	-- self.first_tile_pt = {	x= Config.TileSize.width * 0.5,
	-- 						y= Config.TileSize.height * 0.5 }
	-- -- self.first_tile_pt = {	x=	-(Config.TileSize.width * self.width * 0.5) + Config.TileSize.width * 0.5, 		
	-- -- 						y=	-(Config.TileSize.height * self.height * 0.5) + Config.TileSize.height * 0.5 }

	-- print("Map:__init() : fist_tile_pt:", self.first_tile_pt.x, self.first_tile_pt.y)

	--分层管理结点---------------------------------------
	self.layers_node = {}
	for i = 1, Map.LayersConfig.LayerCount-1 do
		self:EnsureRenderGroup(i)
	end

	--生长基地块的管理器
	self.tile_info_list = {}
	self:InitTiles()

	--寻路器相关
	self:InitPathFinder()

	--初始化摄像机
	self:InitCamera()

	--塔列表，每格允许有一个塔
	self.tower_id = 0
	self.tower_list = {}
	for i=1,self.height do
		self.tower_list[i] = {}
	end

	--子弹等
	self.bullet_id = 0
	self.bullet_list = {}

	-- enemy相关
	self.enemy_id = 0
	self.enemy_list = {}

	--生成怪物的信息
	self.preparing_frames = 300
	self.wave_start_frame = nil
	self.waves_data = self.map_info.waves_data
	self.wave_count = #self.waves_data
	self.cur_wave = 0
	self.cur_wave_info = nil --{enemy_index = 1, start_frame = 0, enemy_count = 0, enemy_list = {}}
	self.succeeded = false
	self.failed = false

	self.arrived_enemis = 0 	--逃跑怪物数量
	self.arrived_enemy_max = 10 --逃跑怪物数量的上限
	self.death_num = self.map_info.death_num or 10

	GlobalEventSystem:Fire(EventName.EnemyArrived, self.arrived_enemis, self.arrived_enemy_max)
end

function Map:__delete()
	--清空怪物
	for _, enemy in pairs(self.enemy_list) do
		enemy:DeleteMe()
	end
	self.enemy_list = {}

	--清空每格塔对象
	for y=1,self.height do
		for x=1,self.width do
			local obj = self.tower_list[y][x]
			if obj then
				obj:DeleteMe()
				self.tower_list[y][x] = nil
			end
		end 
	end
	self.tower_list = {}

	--清空子弹
	for _, bullet in pairs(self.bullet_list) do
		bullet:DeleteMe()
	end
	self.bullet_list = {}
	
	--清空所有地块对象
	for i, t in pairs(self.tile_info_list) do
		for _, tile_obj in pairs(t) do
			tile_obj:DeleteMe()
		end
	end
	self.tile_info_list = nil

	--清空所有层
	for _,layer in pairs(self.layers_node) do
		layer:removeFromParentAndCleanup(true)
	end
	self.layers_node = nil
end

function Map:Update(delta_time, running_time)	
	if self.failed or self.succeeded then
		return
	end
	
	if self.is_paused then
		if self.cur_wave_info then
			self.cur_wave_info.start_frame = self.cur_wave_info.start_frame + 1
		end
		return
	end

	cc.Director:getInstance():dumpSAP()

	--刷新敌人
	local dead_enemys = {}
	local old_arrived = self.arrived_enemis
	local living_enemys = 0
	for _, enemy in pairs(self.enemy_list) do
		enemy:Update(delta_time, running_time)
		if enemy:IsDead() then
			table.insert(dead_enemys, enemy)
		elseif enemy:IsArrived() then
			table.insert(dead_enemys, enemy)
			self.arrived_enemis = self.arrived_enemis + 1
		else
			living_enemys = living_enemys + 1
		end
	end
	if self.arrived_enemis ~= old_arrived then
		GlobalEventSystem:Fire(EventName.EnemyArrived, self.arrived_enemis, self.arrived_enemy_max)

		--跑掉的怪物数量够数，游戏失败
		if self.arrived_enemis >= self.arrived_enemy_max then
			self.failed = true
			GlobalEventSystem:Fire(EventName.Failed)
			return
		end
	end


	--刷新子弹
	local dead_bullets = {}
	for _, bullet in pairs(self.bullet_list) do
		bullet:Update(delta_time, running_time)
		local pos = bullet:GetPixelPos()
		if bullet:IsDead() or not self:IsPixelInMap(pos) then
			table.insert(dead_bullets, bullet)
		end
	end	

	--刷新每格塔对象
	for y=1,self.height do
		for x=1,self.width do
			local obj = self.tower_list[y][x]
			if obj then
				obj:Update(delta_time, running_time)
			end
		end 
	end

	--移除子弹
	for _, bullet in pairs(dead_bullets) do
		self:RemoveBullet(bullet)
	end

	--移除敌人
	for _, enemy in pairs(dead_enemys) do
		self:RemoveEnemy(enemy)
	end

	--第一波初始化
	if self.cur_wave == 0 then
		self:IncreaseWave()
	--后续波
	elseif self.cur_wave_info and self.cur_wave_info.enemy_index > self.cur_wave_info.enemy_count and #self.enemy_list == 0 then
		self:IncreaseWave()
	end
	
	--刷新当前波的怪物
	if self.cur_wave_info ~= nil then
		local wave_frame = Glo.RunningFrame - self.cur_wave_info.start_frame - self.preparing_frames
		if wave_frame >= 0 then
			for i=self.cur_wave_info.enemy_index, self.cur_wave_info.enemy_count do

				local enemy_data = self.cur_wave_info.enemy_list[i]
				if wave_frame == enemy_data.born_frame then
					self:CreateEnemy(enemy_data.type)
					self.cur_wave_info.enemy_index = i + 1
				else
					break
				end
			end
		end
	--如果没有了后续波，并且场景上没有了其他怪物，就说明防守成功
	else
		if living_enemys == 0 then
			self.succeeded = true
			GlobalEventSystem:Fire(EventName.Succeed)
		end
	end
end

function Map:SetPause(b)
	self.is_paused = b
end

function Map:InitTiles()
	self.tile_info_list = {}
	for y=1, self.height do
		local t = {}
		self.tile_info_list[y] = t
		for x=1, self.width do
			self:FillTile(x, y, self.map_info.tile_filled[y][x])
		end
	end
end

function Map:InitPathFinder()
	self.path_finder:Reset()
	self.path_finder:AddDestination(self.end_pt.x, self.end_pt.y)
	--由于引擎里的索引是从0开始，而脚本从1开始，所以把0行和0列设为障碍区
	for j = 0, self.height do
		for i = 0, self.width do
			if i==0 or j==0 then
				self.path_finder:SetBlock(i, j, true)
			else
				if self:IsBlocked(i, j) then
					self.path_finder:SetBlock(i, j, true)
				end
			end
		end
	end
end

function Map:InitCamera()
	local x = self.pixel_width / 2
	local y = self.pixel_height / 2
	self:SetCameraPos(cc.p(x, y))	
end

function Map:Init()
end

function Map:EnsureRenderGroup(layer_id)
	--背景结点和主要结点区别开来，因为可能要设置不同的摄像机
	if layer_id ~= Map.LayersConfig.BackgroundLayer then
		if self.main_node == nil then
			self.main_node = CCNode:create()
			Glo.Scene:addChild(self.main_node, Config.ZOrder.Map)
		end

		local node = self.layers_node[layer_id]
		if node == nil then
			node = CCNode:create()
			self.layers_node[layer_id] = node
			self.main_node:addChild(node, layer_id)
		end
		return node
	else
		if self.bg_node == nil then
			self.bg_node = CCNode:create()
			Glo.Scene:addChild(self.bg_node, Config.ZOrder.Bg)
		end
		
		local node = self.layers_node[layer_id]
		if node == nil then
			node = CCNode:create()
			self.layers_node[layer_id] = node
			self.bg_node:addChild(node, layer_id)
		end
		return node
	end
end

function Map:SetCameraPos(pos)
	if self.main_node == nil then
		return
	end
	local main_camera = self.main_node:getCamera()
	local x, y, z = 0,0,0
	x,y,z = main_camera:getEyeXYZ(x, y, z)

	local min_x = Glo.VisibleRct.width/2
	local max_x = self.pixel_width - min_x
	local min_y = Glo.VisibleRct.height/2
	local max_y = self.pixel_height - min_y
	if pos.x < min_x then
		pos.x = min_x
	elseif pos.x > max_x then
		pos.x = max_x
	end
	if pos.y < min_y then
		pos.y = min_y
	elseif pos.y > max_y then
		pos.y = max_y
	end

	main_camera:setEyeXYZ(pos.x, pos.y, z)
	main_camera:setCenterXYZ(pos.x, pos.y, 0)
end

function Map:MoveCamera(offset)
	if self.main_node == nil then
		return
	end
	local main_camera = self.main_node:getCamera()
	local x, y, z = 0,0,0
	x,y,z = main_camera:getEyeXYZ(x, y, z)
	x = x + offset.x
	y = y + offset.y
	self:SetCameraPos(cc.p(x,y))
end

function Map:GetCameraPos()
	if self.main_node == nil then
		return cc.p(0,0)
	end
	local main_camera = self.main_node:getCamera()
	local x, y, z = 0,0,0
	x,y,z = main_camera:getEyeXYZ(x, y, z)
	return cc.p(x, y)
end

function Map:IsPixelInMap(pixel_pos)
	local half_w = Glo.VisibleRct.width/2
	local half_h = Glo.VisibleRct.height/2
	return (pixel_pos.x >= -half_w-50) and 
		(pixel_pos.x <= half_w+50) and 
		(pixel_pos.y >= -half_h-50) and
		(pixel_pos.y <= half_h+50)
end

--判断格子坐标是否有效
function Map:IsTileValid(x, y)
	return (x>=1 and x<=self.width and y >=1 and y <= self.height)
end

--获取指定格子是否被障碍，x,y从1开始计
function Map:IsBlocked(x, y)
	if not self:IsTileValid(x, y) then
		return true
	end

	return (self.tile_info_list[y][x]:GetTileState() ~= Map.TileState.EMPTY)	
end

--获取指定格子的当前状态
function Map:GetTileState(x, y)
	if not self:IsTileValid(x, y) then
		return Map.TileState.INVALID_TILE
	end
	
	local tower = self:GetTowerByTile(x, y)
	if tower then
		return Map.TileState.TOWER_BUILT
	else
		return self.tile_info_list[y][x]:GetTileState() 
	end
end

--起点从1开始
--获取从指定点到终点的路径，返回CCPoint列表，
--每个CCPoint表示一个拐点格子，格子
function Map:GetPathInTile(start_tile_x, start_tile_y)
	local have_path, path_split = self.path_finder:GetPath(start_tile_x, start_tile_y, 0)
	local ret = {}
	if have_path then
		local pt_count = (#path_split) / 2
		for i = 1, pt_count do
			local x = path_split[i*2-1] 	-- 因为path_finder返回的格子是从0开始的，所以在这加1
			local y = path_split[i*2]
			ret[i] = cc.p(x,y)
		end
	else
		ret[1] = cc.p(start_tile_x, start_tile_y)
		ret[2] = cc.p(self.end_pt.x, self.end_pt.y)
	end
	return ret
end

--起点从1开始
--获取从指定点到终点的路径，返回CCPoint列表，
--每个CCPoint表示一个拐点的像素坐标
function Map:GetPathInPixel(start_tile_x, start_tile_y)
	local path = self:GetPathInTile(start_tile_x, start_tile_y)
	for i=1, #path do
		local pixel_pos = Utils.TileToPixel(path[i])
		path[i] = pixel_pos
	end
	return path
end

function Map:IsObjEnemy(id)
	return bit.band(id, Map.ObjTypeMask) == Map.ObjTypeConfig.ObjType_Enemy
end
function Map:IsObjBullet(id)
	return bit.band(id, Map.ObjTypeMask) == Map.ObjTypeConfig.ObjType_Bullet
end
function Map:IsObjBlock(id)
	return bit.band(id, Map.ObjTypeMask) == Map.ObjTypeConfig.ObjType_Block
end
function Map:IsObjTower(id)
	return bit.band(id, Map.ObjTypeMask) == Map.ObjTypeConfig.ObjType_Tower
end

function Map:GetEnemy(id)
	return self.enemy_list[id]
end


--创建怪物
function Map:CreateEnemy(enemy_type)
	local enemy_config = g_enemy_types[enemy_type]
	if enemy_config == nil then
		return
	end

	self.enemy_id = self.enemy_id + 1
	local enemy = BaseEnemy.New()
	enemy:Init(self, self.start_pt, bit.bor(Map.ObjTypeConfig.ObjType_Enemy, self.enemy_id), enemy_config)

	--初始化移动路径
	local pixel_points = self:GetPathInPixel(self.start_pt.x, self.start_pt.y)
	enemy:SetPath(pixel_points)

	self.enemy_list[enemy.obj_id] = enemy

	local render_group = self:EnsureRenderGroup(Map.LayersConfig.EnemyLayer)
	render_group:addChild(enemy:GetBaseNode())

	return enemy
end

--移除怪物
function Map:RemoveEnemy(enemy)
	self.enemy_list[enemy.obj_id] = nil
	-- 析构时会从场景树中移除结点
	enemy:DeleteMe()
end


--在指定Tile位置创建指定类型的塔
function Map:CreateTower(tile_x, tile_y, tower_type)
	print("= = = Map:CreateTower", tile_x, tile_y)
	self.tower_id = self.tower_id + 1
	local tower = nil
	local config = g_tower_types[tower_type]
	tower = BaseTower.New(self, bit.bor(Map.ObjTypeConfig.ObjType_Tower, self.tower_id), tile_x, tile_y, config)
	self.tower_list[tile_y][tile_x] = tower

	local render_group = self:EnsureRenderGroup(Map.LayersConfig.TowerLayer)
	render_group:addChild(tower:GetBaseNode())

	return tower
end

--移除Tower
function Map:RemoveTower(tile_x, tile_y)
	local tower = self.tower_list[tile_y][tile_x]
	tower:DeleteMe()
	self.tower_list[tile_y][tile_x] = nil
end

--获取指定格子上的塔
function Map:GetTowerByTile(x, y)
	if y >= 1 and y <= self.height then
		return self.tower_list[y][x]
	end
	return nil
end

--创建子弹
function Map:CreateBullet(type, pixel_pos, dir, damage)
	self.bullet_id = self.bullet_id + 1
	local bullet_config = g_bullet_types[type]
	if bullet_config ~= nil then
		local bullet = BaseBullet.New()
		bullet:Init(self, bit.bor(Map.ObjTypeConfig.ObjType_Bullet, self.bullet_id), pixel_pos, dir, bullet_config, damage)
		self.bullet_list[bullet.obj_id] = bullet

		local render_group = self:EnsureRenderGroup(Map.LayersConfig.EnemyLayer)
		render_group:addChild(bullet:GetBaseNode())

		return bullet
	end
end

--移除子弹
function Map:RemoveBullet(bullet)
	bullet:DeleteMe()
	self.bullet_list[bullet.obj_id] = nil
end


--x,y从1开始
--sign值0:空格子，1:培养基格子，2：废弃格子
function Map:FillTile(x, y, state)
	if not self:IsTileValid(x, y) then
		return
	end
	local tile_obj = self.tile_info_list[y][x]

	--初始化过程
	if tile_obj == nil then
		tile_obj = TileObj.New(state, cc.p(x, y))
		self.tile_info_list[y][x] = tile_obj
		local render_group = self:EnsureRenderGroup(Map.LayersConfig.TileLayer)
		render_group:addChild(tile_obj:GetBaseNode())

	--游戏过程中
	else
		local old_block = self:IsBlocked(x, y)
		tile_obj:SetTileState(state)
		local now_block = self:IsBlocked(x, y)

		if old_block ~= now_block then
			--刷新寻路器
			self.path_finder:SetBlock(x, y, now_block)

			--刷新所有怪物的路径
			for id, enemy in pairs(self.enemy_list) do
				local pixel_pos = enemy:GetPixelPos()
				local tile_pos = Utils.PixelToTile(pixel_pos)
				local pixel_points = self:GetPathInPixel(tile_pos.x, tile_pos.y)
				enemy:SetPath(pixel_points)
			end
		end
	end

	-- local old_block = self:IsBlocked(x, y)
	-- local cur_info = self.tile_info_list[y][x]
	-- if cur_info.fill_sign ~= sign then
	-- 	local old_fill = cur_info.fill_sign
	-- 	cur_info.fill_sign = sign

	-- 	--刷新寻路器，如果把路封死了，就返回
	-- 	local now_block = self:IsBlocked(x, y)
	-- 	print("= = Map:FillTile, now_block:", now_block, old_block)
	-- 	if now_block ~= old_block then
	-- 		self.path_finder:SetBlock(x, y, now_block)
	-- 		if not self:CalcPath() then
	-- 			cur_info.fill_sign = old_fill
	-- 			self.path_finder:SetBlock(x, y, old_block)
	-- 			print("= = = You can't block the path = =")
	-- 			return
	-- 		end
	-- 	end


	-- 	--刷新它自己和四个相邻格子		
	-- 	local pts = {}
	-- 	self:UpdateTile(x, 	 y)
	-- 	self:UpdateTile(x-1, y)
	-- 	self:UpdateTile(x+1, y)
	-- 	self:UpdateTile(x, 	 y-1)
	-- 	self:UpdateTile(x, 	 y+1)

	-- end
end

--x,y从1开始
--根据格子和它周围相邻格子的状态来显示对应的tile sprite
function Map:UpdateTile(x, y)
	if true then return end
	-- if not self:IsTileValid(x, y) then
	-- 	return 
	-- end

	-- local pts = {}
	-- pts[1] = {["x"]=x-1, ["y"]=y}	--左
	-- pts[2] = {["x"]=x, ["y"]=y+1}	--上
	-- pts[4] = {["x"]=x+1, ["y"]=y}	--右
	-- pts[8] = {["x"]=x, ["y"]=y-1}	--下
	
	-- local value = -1
	-- local cur_info = self.tile_info_list[y][x]
	-- if cur_info.fill_sign == Map.TileState.BUILD_TILE then
	-- 	value = 0
	-- else
	-- 	--如果该格子没有填充生长基，就清除它并返回
	-- 	if cur_info.tile_sprite then
	-- 		cur_info.tile_sprite:removeFromParentAndCleanup(true)
	-- 		cur_info.tile_sprite = nil
	-- 		cur_info.tile_sprite_id = -1
	-- 	end
	-- 	return
	-- end

	-- --如果该格子有填充生长基，那就还要检查它周围四个方向的格子，并决定它的最终值
	-- for i, pt in pairs(pts) do
	-- 	if self:IsTileValid(pt.x, pt.y) then
	-- 		local info = self.tile_info_list[pt.y][pt.x]
	-- 		if info.fill_sign == Map.TileState.BUILD_TILE then
	-- 			value = value + i
	-- 		end
	-- 	end
	-- end

	-- --显示正确的sprite
	-- if cur_info.tile_sprite_id ~= value then
	-- 	--把旧的清除	
	-- 	if cur_info.tile_sprite then
	-- 		cur_info.tile_sprite:removeFromParentAndCleanup(true)
	-- 		cur_info.tile_sprite = nil
	-- 	end

	-- 	--创建新tile
	-- 	-- local sprite = AssetsHelper.CreateFrameSprite(string.format("build_tile_%d", value))
	-- 	local sprite = AssetsHelper.CreateFrameSprite("build_base")
	-- 	local pixel_pos = Utils.TileToPixel(cc.p(x, y))
	-- 	sprite:setPosition(pixel_pos)
	-- 	cur_info.tile_sprite = sprite
	-- 	cur_info.tile_sprite_id = value
	-- 	Glo.Scene:addChild(sprite, Map.LayersConfig.TileLayer)
	-- end
end

--构造当前波的信息
function Map:IncreaseWave()
	self.cur_wave = self.cur_wave + 1
	if self.cur_wave > self.wave_count then
		self.cur_wave_info = nil
		return
	end

	--把所有怪物出生信息取出来
	local t = {}
	local wave_data = self.waves_data[self.cur_wave]
	for _, enemy_data in pairs(wave_data) do
		for i = 1, enemy_data.number do
			local born_f = enemy_data.born_frame + (i-1) * enemy_data.born_delta_frame
			local t1 = {}
			t1.type = enemy_data.type
			t1.born_frame = born_f
			table.insert(t, t1)
		end
	end

	--把所有怪物按出生时间排序
	local sort_func = function(a, b)
		return a.born_frame < b.born_frame
	end
	table.sort(t, sort_func)

	------------------
	-- {enemy_index = 1, start_frame = 0, enemy_count = 0, enemy_list = {}}
	self.cur_wave_info = {}
	self.cur_wave_info.enemy_index = 1
	self.cur_wave_info.start_frame = Glo.RunningFrame
	self.cur_wave_info.enemy_count = #t
	self.cur_wave_info.enemy_list  = t
end