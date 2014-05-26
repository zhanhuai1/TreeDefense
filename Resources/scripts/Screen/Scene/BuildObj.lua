BuildObj = BuildObj or BaseClass()

function BuildObj:__init(type_id, instance_id, tile_pos, parent_node)
	self.cfg = BuildConfig[type_id]

	self.build_type_id = type_id
	self.instance_id = instance_id
	self.level = 1
	self.tile_pos = tile_pos

	self.root_node = cc.Node:create()
	local z = (0xfff - tile_pos.y) * 0xffff + tile_pos.x
	parent_node:addChild(self.root_node, z)
	
	self.pixel_pos = Utils.TileToPixel(tile_pos)
	self.root_node:setPosition(self.pixel_pos)
end

function BuildObj:__delete()
	self.root_node:removeFromParent(true)
	self.root_node = nil
end

function BuildObj:GetBuildLevel()
	return self.level
end

--获取建筑大类型，如障碍、子弹塔、电塔等
function BuildObj:GetBuildType()
	local cfg = self.cfg
	return cfg.type
end

function BuildObj:GetBuildTilePos()
	return self.tile_pos
end

function BuildObj:GetBuildInstanceId()
	return self.instance_id
end

function BuildObj:GetBuildMaxLevel()
	local cfg = self.cfg
	if cfg ~= nil then
		return #cfg.levels
	end
	return 0
end



--如果已经是顶级塔，就返回它可以进化的下一代塔类型id
--否则返回nil
function BuildObj:GetNextGenerations()
	local max_level = self:GetBuildMaxLevel()
	if max_level == self.level then
		local cfg = self.cfg
		local level_cfg = cfg.levels[self.level] 
		return level_cfg.next_generation
	end
	return nil
end

--升级到下一级需要的价格
function BuildObj:GetUpgradePrice()
	local cfg = self.cfg
	if cfg ~= nil then
		local max_level = #cfg.levels
		if self.level < max_level then
			return cfg.levels[self.level+1].price
		end
	end
	return 0
end

--完整的价格（建造和升级总花费）
function BuildObj:GetTotalPrice()
	local cfg = self.cfg
	if cfg ~= nil then
		local price = 0
		for i=1, self.level do
			price = price + cfg.levels[i].price
		end
		return price
	end
	return 0
end

