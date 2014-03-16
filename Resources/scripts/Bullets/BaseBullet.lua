BaseBullet = BaseBullet or BaseClass(MovableObj)

function BaseBullet:__init()
end

function BaseBullet:Init(map, id, pixel_pos, dir, config, damage)
	MovableObj.Init(self, pixel_pos, config.bounding_size, config.move_speed)

	self.parent_map = map
	self.move_dir_radian = dir / 180 * math.pi
	self.damage = damage

	--注意dir是与Y轴正方向的夹角
	self.move_dir_ccp = cc.p(math.sin(self.move_dir_radian), math.cos(self.move_dir_radian))
	self.obj_id = id
	self.is_dead = false

	-- 创建基本的node和动画
	self.main_sprite = CCSprite:create()
	self.base_node:addChild(self.main_sprite)

	self.main_anim_action = CCRepeatForever:create(AssetsHelper.CreateAnimateAction(config.main_sprite))
	self.main_sprite:runAction(self.main_anim_action)

	--注册SAP
	self.sap_handle = cc.Director:getInstance():addObjToSAP(self.obj_id, self:GetBoundingAABB(), Map.SAPType.SAP_Bullet, Map.SAPType.SAP_CanHit)
end

function BaseBullet:SetParentTower(parent)
	self.parent_tower = parent
end

function BaseBullet:__delete()
end

function BaseBullet:IsDead()
	return self.is_dead
end

function BaseBullet:Update(delta_time, running_time)
	if self.is_dead then
		return
	end
	local pos = cc.pAdd(self.pixel_pos, cc.pMul(self.move_dir_ccp, self.move_speed))
	self:SetPixelPos(pos)
	
	cc.Director:getInstance():updateObjInSAP(self.sap_handle, self:GetBoundingAABB())
	local query_objs = cc.Director:getInstance():queryCollisionObjs(self.sap_handle)
	for i=1, #query_objs do
		local id = query_objs[i]
		if self.parent_map:IsObjEnemy(id) then
			local enemy = self.parent_map:GetEnemy(id)
			if enemy ~= nil and not enemy:IsDead() then
				enemy:Damage(self.damage)
				self:Die()
				break
			end
		end
	end
end

function BaseBullet:GetPixelPos()
	return self.pixel_pos
end

function BaseBullet:Die()
	self.is_dead = true
	cc.Director:getInstance():removeObjFromSAP(self.sap_handle)
end
