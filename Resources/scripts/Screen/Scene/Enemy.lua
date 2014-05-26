Enemy = Enemy or BaseClass(MovableObj)

function Enemy:__init()
	--血条
	local bar = ccui.LoadingBar:create()
	bar:loadTexture("hp_bar.png", ccui.TextureResType.plistType)
	self.hp_bar = bar
	self.hp_bar:retain()
	self.hp_bar_visible = false
end

function Enemy:__delete()
	self.hp_bar:release()
end

function Enemy:GetType()
	return Config.ObjType.Enemy
end

function Enemy:Init(type_id, instance_id, pixel_pos, parent_node)
	MovableObj.Init(self, type_id, instance_id, pixel_pos, parent_node)

	self.cfg = EnemyConfig[type_id]
	self.type_id = type_id
	self.instance_id = instance_id

	--主动画
	local res = self.cfg.res
	local anim_act = AssetsHelper.CreateAnimAction(res.."_run")
	self.main_sprite:stopActionByTag(Config.ActionTag.Anim)
	self.main_sprite:runAction(anim_act)
	-- print("run Action:", res.."_run", anim_act)

	--由小变大的出现

	local scale1 = cc.ScaleTo:create(0.2, 1)
	self.main_sprite:runAction(scale1)

	--血条
	self.hp_bar:setPercent(100)

	self.speed 	= self.cfg.speed or 10
	self.hp 	= self.cfg.hp or 10
	self.max_hp = self.cfg.hp
	self.path 	= nil
	self.seg_i 	= nil
	self.is_arrived = false
	self.is_dead 	= false
	self.is_destroy	= false
	self.enemy_path_left_dist 	= 0
end

function Enemy:IsArrived()
	return self.is_arrived
end

function Enemy:IsDead()
	return self.is_dead
end

function Enemy:IsDestroy()
	return self.is_destroy
end

function Enemy:Damage(damage)
	self.hp = self.hp - damage 


	if self.hp <= 0 then
		self:Die()
	else
		self:ShowHpBar(true)
	end
end

--显示或隐藏血条
function Enemy:ShowHpBar(is_show)
	self.main_sprite:stopActionByTag(Config.ActionTag.HideHp)
	if is_show then
		--一段时间后隐藏血条，要重新计时所以重新创建一个
		local hide_hp_func = function ()
			self:ShowHpBar(false)
		end
		local delay_act = cc.DelayTime:create(3)   --3秒后隐藏血条
		local call_act  = cc.CallFunc:create(hide_hp_func)
		local seq_act  	= cc.Sequence:create(delay_act, call_act)
		seq_act:setTag(Config.ActionTag.HideHp)
		self.main_sprite:runAction(seq_act)

		--刷新血量百分比
		local p = self.hp / self.max_hp
		self.hp_bar:setPercent(math.floor(p * 100))
		self.hp_bar:setPosition(cc.p(0, self.cfg.radius))

		--如果之前没显示血条，就显示之
		if not self.hp_bar_visible then
			self.hp_bar_visible = true
			self.root_node:addChild(self.hp_bar)
		end
	else
		if self.hp_bar_visible then
			self.hp_bar:removeFromParent(false)
			self.hp_bar_visible = false
		end
	end
end

function Enemy:SetPath(path)
	self.path = {}
	self.seg_i = 1
	self.enemy_path_left_dist = 0
	local seg_start = self.pixel_pos
	local seg_num = #path - 1
	for i=1, seg_num do
		local seg = {}
		local info1 = path[i]
		local info2 = path[i+1]
		local start_pt 	= info1.pixel_pos
		local end_pt 	= info2.pixel_pos
		seg.start_pt	= start_pt
		seg.end_pt 		= end_pt
		seg.total_len 	= cc.pGetDistance(start_pt, end_pt)
		seg.run_len 	= 0
		seg.dir_vec		= PathFinder.DirVecs[info1.direction]

		table.insert(self.path, seg)

		--累加路径长度
		self.enemy_path_left_dist = self.enemy_path_left_dist + seg.total_len
	end
end

function Enemy:Update(delta_time, running_time)
	if self.seg_i == nil or self.path == nil then
		print("Error:Enemy Path is nil:", self.instance_id)
		return
	end
	
	if not self.is_arrived and not self.is_dead then
		local move_dist = self.speed * delta_time
		self.enemy_path_left_dist = self.enemy_path_left_dist - move_dist
		while true do
			local seg = self.path[self.seg_i]
			if seg then
				seg.run_len = seg.run_len + move_dist
				--如果当前seg段已走完，就走到下一段去，所以也是需要用一个while循环
				if seg.run_len >= seg.total_len then
					self.seg_i = self.seg_i + 1
					move_dist = seg.total_len - seg.run_len

				--如果当前seg没走完，就只是设置坐标
				else
					local pos = cc.pAdd(seg.start_pt, cc.pMul(seg.dir_vec, seg.run_len))
					self:SetPixelPos(pos)
					break
				end
			else
				self:Arrive()
				break
			end
		end
	end
end

function Enemy:Arrive()
	self.is_arrived = true

	--死亡时隐藏血条
	self:ShowHpBar(false)

	--已到终点，设置坐标
	local seg = self.path[#self.path]
	local pos = seg.end_pt
	self:SetPixelPos(pos)

	--缩小下去 
	local destroy_func = function ()
		self.is_destroy = true
	end
	local scale1 = cc.ScaleTo:create(0.2, 0.0)
	local call_act = cc.CallFunc:create(destroy_func) 
	self.main_sprite:runAction(cc.Sequence:create(scale1, call_act))
end

function Enemy:Die()
	self.is_dead = true

	--死亡时隐藏血条
	self:ShowHpBar(false)

	self.main_sprite:stopActionByTag(Config.ActionTag.Anim)
	local res = self.cfg.res
	local anim_act = AssetsHelper.CreateAnimAction("red_bullet_bom", nil, nil, nil, 1) 

	if anim_act ~= nil then
		local destroy_func = function ()
			self.is_destroy = true
		end
		local call_act = cc.CallFunc:create(destroy_func) 
		self.main_sprite:runAction(cc.Sequence:create(anim_act, call_act))
	end
end



