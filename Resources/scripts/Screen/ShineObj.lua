ShineObj = ShineObj or BaseClass()

ShineObj.random_colors = {
	ccc3(178, 200, 187),
	ccc3(22, 226, 183),
	ccc3(60, 172, 231),
	ccc3(200, 81, 184),
}

function ShineObj:__init(pos, angle, zorder)

	self.position = pos 		--当前坐标
	self.rotate_angle = angle	--旋转角度的角度值
	self.rotate_speed = 0.1		--每帧改变的角度值
	self.move_speed = 0.25		--每帧移动的距离

	local rand = math.random()
	local init_scale = 0.4 + rand * 0.3
	local init_opacity = 160 + rand * 70
	local init_color = 150 + rand * 70

	self.sprite = AssetsHelper.CreateFrameSprite("white_halo")
	self.sprite:setOpacity(init_opacity)
	self.sprite:setPosition(pos)
	self:SetRotation(angle)

	Glo.Scene:addChild(self.sprite, zorder)

	self.target_angle = self.rotate_angle	--目标角度
	self.last_change_rotate_time = 0		--最后一次调整目标角度的时间点，每隔几秒才进行一次调整

	local scale_func = function(scale)
		--AddAnim设置的波峰是0.25，所以scale传过来是[-0.250.25]，加上0.75后变成[0.5,1]
		local s = (scale + 0.75) * init_scale
		self.sprite:setScale(s)
	end
	self.sin_scale_handler = SinAnimManager.Instance:AddAnim(0.25, 8, math.random(), scale_func)
end

function ShineObj:__delete()
	self.sprite:removeFromParentAndCleanup(true)
	self.sprite = nil

	if self.sin_scale_handler then
		SinAnimManager.Instance:RemoveAnim(self.sin_scale_handler)
		self.sin_scale_handler = nil
	end
end

function ShineObj:Update(delta_time, running_time)
	local tar_angle = self.target_angle		--目标角度值
	local rot_angle = self.rotate_speed		--一帧旋转的角度值

	--刷新朝向
	local is_face_target = false	--是否已经朝向目标
	self.rotate_angle, is_face_target = Utils.Rotate(self.rotate_angle, tar_angle, rot_angle)
	self:SetRotation(self.rotate_angle)
	-- print("= = =ShineObj:Update angle:", self.rotate_angle, "speed:", self.move_speed_vec.x, self.move_speed_vec.y)
	--刷新坐标
	self.position = cc.pAdd(self.position, self.move_speed_vec)
	self.sprite:setPosition(self.position)

	--调整目标角度
	if running_time - self.last_change_rotate_time > 8 and is_face_target then
		local p = math.random()
		--只有小于0.5才调整角度，即有一半的几率保持当前方向前进
		if p < 0.5 then
			self.target_angle = p * 720
		end
		self.last_change_rotate_time = running_time
	end
end

function ShineObj:SetRotation(angle)
	self.rotate_angle = angle
	self.sprite:setRotation(self.rotate_angle)
	self.move_speed_vec = cc.pMul( Utils.VectorFromAngle(self.rotate_angle), self.move_speed)
end