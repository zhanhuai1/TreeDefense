BaseTower = BaseTower or BaseClass(BuildObj)

function BaseTower:__init(parent_map, id, tile_x, tile_y, config)
	self.obj_id = id
	self.parent_map = parent_map
	self.attack_interval = config.attack_interval
	self.attack_pre_time = config.attack_pre_time	--攻击前摇
	self.attack_damage = config.attack_damage
	self.rotate_speed = config.rotate_speed
	self.attack_range = config.attack_range
	self.attack_range_sq = self.attack_range * self.attack_range --攻击距离的平方，用来判断怪物是否在攻击范围 内
	self.bullet_init_pos = config.bullet_init_pos

	self.last_attack_time = -1
	self.attack_start_time = -1
	self.main_target = nil

	self.last_random_rotate_time = -1
	self.random_rotate_target_dir = 0

	self.direction = 0 		--起始攻击方向，0表示（0，1）方向，
	self.bullet_type = config.bullet_type

	-- 创建基本的node和动画
	self.base_node = CCNode:create()

	self.tile_pos = cc.p(tile_x, tile_y)
	self.pixel_pos = Utils.TileToPixel(self.tile_pos)
	self.base_node:setPosition(self.pixel_pos)
	print("towerPos:", self.pixel_pos.x, self.pixel_pos.y)

	if config.main_sprite then
		self.main_sprite = CCSprite:create()
		self.base_node:addChild(self.main_sprite)
		self.main_anim_action = CCRepeatForever:create(AssetsHelper.CreateAnimateAction(config.main_sprite))
		self.main_sprite:runAction(self.main_anim_action)
	end

	--记录不同状态的动画
	self.attack_animation = config.attack_sprite
	self.stat_animation = config.main_sprite

	-- 注册SAP
	self.sap_handle = cc.Director:getInstance():addObjToSAP(self.obj_id, self:GetAttackAABB(), Map.SAPType.SAP_Tower, Map.SAPType.SAP_CanHit)
	print("Register tower into sap, handle:", self.sap_handle, "Type:", Map.SAPType.SAP_Tower, "HitFlag:", Map.SAPType.SAP_CanHit)
end

function BaseTower:__delete()
	self.base_node:removeFromParent(true)
	cc.Director:getInstance():removeObjFromSAP(self.sap_handle)
end

function BaseTower:GetBaseNode()
	return self.base_node
end

function BaseTower:Update(delta_time, running_time)
	cc.Director:getInstance():updateObjInSAP(self.sap_handle, self:GetAttackAABB())
	--先检查当前目标的状态，如果目标太远或已死亡，就抛弃目标
	self:CheckTarget()

	--如果当前没有目标，就尝试从SAP中取一个
	if self.main_target == nil then
		self:TryPickTarget()
	end

	-- 朝向主目标旋转
	if self.main_target ~= nil then
		local tar_pos = self.main_target:GetPixelPos()
		local my_pos = self.pixel_pos
		local tar_angle = Utils.DirToTarget(my_pos, tar_pos)
		local rot_angle = self.rotate_speed * delta_time

		--是否已经朝向目标
		local is_face_target = false
		self.direction, is_face_target = Utils.Rotate(self.direction, tar_angle, rot_angle)
		local node_dir = self.direction
		self.base_node:setRotation(node_dir)

		--print("Tower Update!", self.main_target, running_time, self.last_attack_time)
		
		if (is_face_target and (running_time - self.last_attack_time >= self.attack_interval)) then	
			self.last_attack_time = running_time	
			self.attack_start_time = running_time
			self:PlayAnimation(self.attack_animation)
		end

		--已经开始攻击并且前摇结束才发射子弹
		if self.attack_start_time > 0 then
			if running_time - self.attack_start_time >= self.attack_pre_time then
				--发射子弹
				self.attack_start_time = -1

				local bullet_dir = self.direction
				local bullet_pos = self:GetCreateBulletPos()
				local bullet = self.parent_map:CreateBullet(self.bullet_type, bullet_pos, bullet_dir, self.attack_damage)
				bullet:SetParentTower(self)
			end
		end
	else
		self.attack_start_time = -1
		--朝向随机方向旋转，已经转到角度并停留一小段时间后再取随机方向
		if running_time - self.last_random_rotate_time > 0.5 then
			self.random_rotate_target_dir = math.random() * 360
		end
		local is_face_target = false		
		local rot_angle = self.rotate_speed * delta_time
		self.direction, is_face_target = Utils.Rotate(self.direction, self.random_rotate_target_dir, rot_angle)
		self.base_node:setRotation(self.direction)

		--还在转
		if not is_face_target then
			self.last_random_rotate_time = running_time
		end
	end

end

function BaseTower:GetTilePos()
	return self.tile_pos
end

function BaseTower:GetAttackAABB()
	local lt = cc.p(self.pixel_pos.x - self.attack_range, self.pixel_pos.y - self.attack_range)
	return cc.rect(lt.x, lt.y, self.attack_range * 2, self.attack_range * 2)
end

function BaseTower:GetCreateBulletPos()
	local my_pos = Utils.TileToPixel(self.tile_pos)
	local bullet_pos = cc.pAdd(my_pos, self.bullet_init_pos)
	local rotate_radian = Utils.AngleToRadian(Utils.ReverseAngle(self.direction))

	bullet_pos = ccpRotateByAngle(bullet_pos, my_pos, rotate_radian)
	return bullet_pos
end

--检查当前目标是否还活着，或是否超出范围
function BaseTower:CheckTarget()
	if self.main_target ~= nil then
		if self.main_target:IsDead() or self.main_target:IsArrived() then
			self.main_target = nil
			return
		end

		local tar_pos = self.main_target:GetPixelPos()
		local my_pos = self.pixel_pos
		local l = ccpDistanceSQ(my_pos, tar_pos)
		if l > self.attack_range_sq then
			self.main_target = nil
		end
	end
end

--尝试从SAP中取一个目标
function BaseTower:TryPickTarget()
	local query_objs = cc.Director:getInstance():queryCollisionObjs(self.sap_handle)

	local my_pos = self.pixel_pos
	local enemys_in_range = {}
	if self.main_target == nil then
		for i=1, #query_objs do
			local id = query_objs[i]
			if self.parent_map:IsObjEnemy(id) then
				local enemy = self.parent_map:GetEnemy(id)
				if enemy ~= nil and not enemy:IsDead() then
					local enemy_pos = enemy:GetPixelPos()
					local l = ccpDistanceSQ(my_pos, enemy_pos)
					--把射程范围内的怪物放进队列，以便进行排序
					if l <= self.attack_range_sq then
						table.insert(enemys_in_range, enemy)
					end
				end
			end
		end
	end

	if #enemys_in_range == 0 then
		self.main_target = nil
		return
	end

	--把射程范围内的敌人按敌人离目标点的距离排序，优先选择离目标点近的敌人
	local sort_func = function (a, b)
		return a:GetLeftDist() < b:GetLeftDist()
	end
	table.sort(enemys_in_range, sort_func)
	self.main_target = enemys_in_range[1]
end

function BaseTower:PlayAnimation(anim)
	if self.main_anim_action ~= nil then 
		self.main_sprite:stopAction(self.main_anim_action)
	end

	local stop_func = function()
		self:PlayStatAnimation()
	end

	local new_anim = AssetsHelper.CreateAnimateAction(anim)
	new_anim:setStopFunc(stop_func)
	self.main_anim_action = new_anim
	self.main_sprite:runAction(self.main_anim_action)

end

function BaseTower:PlayStatAnimation()
	if self.main_anim_action ~= nil then 
		self.main_sprite:stopAction(self.main_anim_action)
	end
	local stat_anim = AssetsHelper.CreateAnimateAction(self.stat_animation)
	self.main_anim_action = CCRepeatForever:create(stat_anim)
	self.main_sprite:runAction(self.main_anim_action)
end