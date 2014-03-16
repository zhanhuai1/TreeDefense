BaseEnemy = BaseEnemy or BaseClass(MovableObj)

function BaseEnemy:__init()
end

function BaseEnemy:__delete()
	self:RemoveSapHandle()
end

function BaseEnemy:Init(map, tile_pos, id, config)
	local pixel_pos = Utils.TileToPixel(tile_pos)
	MovableObj.Init(self, pixel_pos, config.bounding_size, config.move_speed)

	self.parent_map = map
	

	self.obj_id = id
	self.is_dead = false
	self.is_arrived = false
	self.hp = config.hp

	self.main_sprite = CCSprite:create()
	self.base_node:addChild(self.main_sprite)

	self.main_anim_action = CCRepeatForever:create(AssetsHelper.CreateAnimateAction(config.main_sprite))
	self.main_sprite:runAction(self.main_anim_action)

	--注册SAP
	self.sap_handle = cc.Director:getInstance():addObjToSAP(self.obj_id, self:GetBoundingAABB(), Map.SAPType.SAP_Enemy, Map.SAPType.SAP_EnemyFlag)
end

function BaseEnemy:RemoveSapHandle()	
	if self.sap_handle then
		cc.Director:getInstance():removeObjFromSAP(self.sap_handle)
		self.sap_handle = nil
	end
end

--设置移动路径，并做预处理
function BaseEnemy:SetPath(pixel_points)
	if self:IsDead() or self:IsArrived() then
		return
	end
	
	self.path = {}
	self.left_dist = 0
	--把点列表分割成路径小段
	local pt_count = #pixel_points
	for i=1, pt_count-1 do
		local seg = {}
		seg.start_pt = (i==1) and self.pixel_pos or pixel_points[i]
		seg.end_pt = pixel_points[i+1]
		seg.dist = ccpDistance(seg.end_pt, seg.start_pt)
		seg.dir = ccpNormalize(ccpSub(seg.end_pt, seg.start_pt))
		self.path[i] = seg

		--统计剩余路径
		self.left_dist = self.left_dist + seg.dist
	end
	self.cur_path_index = 1		--当前所处的路线段的索引，0表示还没开始，1表示处在第1个点到第2个点之间
	self.cur_path_seg_moved = 0	--当前路径段上移动的距离
end

function BaseEnemy:Update(delta_time, running_time)
	if self:IsDead() or self:IsArrived() then
		return
	end

	--刷新路径点上的坐标 	
	local seg = self.path[self.cur_path_index]
	local move_dist = self.move_speed
	self.cur_path_seg_moved = self.cur_path_seg_moved + move_dist
	self.pixel_pos = cc.pAdd(seg.start_pt, cc.pMul(seg.dir, self.cur_path_seg_moved))

	--统计剩余路径
	self.left_dist = self.left_dist - move_dist

	if self.cur_path_seg_moved >= seg.dist then
		self.cur_path_index = self.cur_path_index + 1
		self.cur_path_seg_moved = self.cur_path_seg_moved - seg.dist
		self.base_node:setPosition(seg.end_pt)
	else
		self.base_node:setPosition(self.pixel_pos)
	end

	--判断到达目标点
	if self.cur_path_index > #self.path then
		self.is_arrived = true
		self:RemoveSapHandle()
	end

	--刷新SAP包围盒
	if self.sap_handle then
		local bound = self:GetBoundingAABB()
		--print("BaseEnemy AABB:", bound:getMinX(), bound:getMinY(), bound:getMaxX(), bound:getMaxY())
		cc.Director:getInstance():updateObjInSAP(self.sap_handle, self:GetBoundingAABB())
	end
end

function BaseEnemy:IsDead()
	return self.is_dead
end

function BaseEnemy:IsArrived()
	return self.is_arrived
end

function BaseEnemy:Damage(dam)
	self.hp = self.hp - dam
	if self.hp <= 0 then
		self:Die()
	end
end

function BaseEnemy:Die()
	self.is_dead = true
	self:RemoveSapHandle()
end

function BaseEnemy:GetLeftDist()
	return self.left_dist
end