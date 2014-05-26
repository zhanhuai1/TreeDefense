BulletTower = BulletTower or BaseClass(BuildObj)

function BulletTower:__init(type_id, instance_id, tile_pos, parent_node)
	local level_cfg = self.cfg.levels[self.level]
	local res = self.cfg.res
	
	self.main_sprite = AssetsHelper.CreateAnimSprite(res.."_stat", 0.2)
	self.root_node:addChild(self.main_sprite)

	self.rotate_speed = 130


	self.last_attack_time = 0
	self.attack_start_time = nil
	self.attack_pre_time = 0.1
	self.attack_interval = 3
	self.attack_damage = 40
	
	self.main_target = nil

	self.last_random_rotate_time = -1
	self.random_rotate_target_dir = 0

	self.direction = 0
	self.dir_vector = cc.p(0, 1)


end

function BulletTower:__delete()
	
end

function BulletTower:GetType()
	return Config.ObjType.Tower
end

function BulletTower:PlayAnimation(anim)
	local res = self.cfg.res
	local action = AssetsHelper.CreateAnimAction(res.."_"..anim, nil, res.."_stat", nil, 1)
	if action then
		self.main_sprite:stopActionByTag(Config.ActionTag.Anim)
		self.main_sprite:runAction(action)
	end
end

function BulletTower:CheckTarget()
	local range = self.cfg.attack_range
	local target = self.main_target
	local my_pos = self.pixel_pos
	if target then
		if target:IsDead() or target:IsArrived() then
			self.main_target = nil
		else
			local target_pos = target:GetPixelPos()
			local dist = cc.pGetDistance(target_pos, my_pos)
			if dist >= range then
				self.main_target = nil
			end
		end
	end
	if self.main_target == nil then
		self.main_target = Scene.Instance:GetEnemyInRange(my_pos, range, false)
	end
end

function BulletTower:Update(delta_time, running_time)
	-- print("BulletTower:Update: = = =", running_time, self.main_target)
	self:CheckTarget()

	-- 朝向主目标旋转
	if self.main_target ~= nil then
		if self.attack_start_time == nil then
			local tar_pos = self.main_target:GetPixelPos()
			local my_pos = self.pixel_pos
			local tar_angle = Utils.DirToTarget(my_pos, tar_pos)
			local rot_angle = self.rotate_speed * delta_time

			--是否已经朝向目标
			local node_dir, is_face_target = Utils.Rotate(self.direction, tar_angle, rot_angle)			

			if is_face_target and running_time - self.last_attack_time >= self.attack_interval then
				self.last_attack_time = running_time
				self.attack_start_time = running_time
				self:PlayAnimation("attack")
			else
				self.root_node:setRotation(node_dir)
				--注意dir是与Y轴正方向的夹角
				local radian = node_dir / 180 * math.pi
				self.direction = node_dir
				self.dir_vector = cc.p(math.sin(radian), math.cos(radian))
			end
		else
			if self.bullet_fired==nil and running_time - self.attack_start_time >= self.attack_pre_time then
				--发射子弹
				local bullet_pos = self:GetCreateBulletPos()
				local bullet = Scene.Instance:CreateBullet(self.cfg.bullet_type or 1, bullet_pos)
				bullet:SetDirection(self.direction, self.dir_vector)
				bullet:SetDamage(self.attack_damage)
				bullet:SetParentTower(self)
				self.bullet_fired = true

				cc.SimpleAudioEngine:getInstance():playEffect("music/click.wav")
			elseif running_time - self.attack_start_time >= 1 then
				self.attack_start_time = nil
				self.bullet_fired = nil
			end
		end
	else
		self.attack_start_time = nil
		--朝向随机方向旋转，已经转到角度并停留一小段时间后再取随机方向
		if running_time - self.last_random_rotate_time > 0.5 then
			self.random_rotate_target_dir = math.random() * 360
		end	
		local rot_angle = self.rotate_speed * delta_time
		local node_dir, is_face_target = Utils.Rotate(self.direction, self.random_rotate_target_dir, rot_angle)

		self.root_node:setRotation(self.direction)
		--注意dir是与Y轴正方向的夹角
		local radian = node_dir / 180 * math.pi
		self.direction = node_dir
		self.dir_vector = cc.p(math.sin(radian), math.cos(radian))

		--还在转
		if not is_face_target then
			self.last_random_rotate_time = running_time
		end
	end
end

function BulletTower:GetCreateBulletPos()
	local fire_pos = self.cfg.fire_pos
	fire_pos = cc.pRotateByAngle(fire_pos, cc.p(0,0), -self.direction/180*math.pi)
	fire_pos = cc.pAdd(fire_pos, self.pixel_pos)
	return fire_pos
end


