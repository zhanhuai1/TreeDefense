Bullet = Bullet or BaseClass(MovableObj)

function Bullet:__init()	
end

function Bullet:__delete()
	-- body
end

function Bullet:GetType()
	return Config.ObjType.Bullet
end

function Bullet:Init(type_id, instance_id, pixel_pos, parent_node)
	MovableObj.Init(self, type_id, instance_id, pixel_pos, parent_node)

	self.cfg = BulletConfig[type_id]

	local res = self.cfg.res
	local anim_act = AssetsHelper.CreateAnimAction(res.."_stat")
	self.main_sprite:stopActionByTag(Config.ActionTag.Anim)
	self.main_sprite:runAction(anim_act)

	self.direction = 0
	self.dir_vector = cc.p(0, 1)
	self.damage = 0
	self.is_destroy = false
	self.is_hitted = false
	self.parent_tower = nil
end

function Bullet:SetParentTower(t)
	self.parent_tower = t
end

function Bullet:GetParentTower()
	return self.parent_tower
end

function Bullet:SetDamage(dam)
	self.damage = dam
end

function Bullet:SetDirection(dir, dir_vector)
	self.dir_vector = dir_vector
	self.direction = dir
	self.main_sprite:setRotation(dir)
end

function Bullet:IsDestroy()
	return self.is_destroy
end

function Bullet:IsHitted()
	return self.is_hitted
end

function Bullet:Update(delta_time, running_time)
	if not self.is_hitted then
		local speed = self.cfg.speed
		local delta = cc.pMul(self.dir_vector, speed * delta_time)
		self.pixel_pos = cc.pAdd(self.pixel_pos, delta)
		self:SetPixelPos(self.pixel_pos)

		local hit_obj = Scene.Instance:GetEnemyInRange(self.pixel_pos, self.cfg.radius, false)
		if hit_obj ~= nil then
			self.is_hitted = true
			self:Bomb()
			hit_obj:Damage(self.damage)
		else
			local t = -100
			if self.pixel_pos.x < -t or self.pixel_pos.x > Config.SceneSize.width + t or 
				self.pixel_pos.y < -t or self.pixel_pos.y > Config.SceneSize.height + t then 
				self.is_destroy = true
			end
		end
	end
end

function Bullet:Bomb()
	self.main_sprite:stopActionByTag(Config.ActionTag.Anim)

	local res = self.cfg.res
	local anim_act = AssetsHelper.CreateAnimAction(res.."_bom", nil, nil, nil, 1) 
	-- print("= = = =Bullet:Bomb:", res, anim_act)

	if anim_act ~= nil then
		local destroy_func = function ()
			self.is_destroy = true
		end
		local call_act = cc.CallFunc:create(destroy_func) 
		self.main_sprite:runAction(cc.Sequence:create(anim_act, call_act))
	end

	cc.SimpleAudioEngine:getInstance():playEffect("music/click.wav")
end