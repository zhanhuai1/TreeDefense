TileObj = TileObj or BaseClass()

TileObj.TypeRes = 
{
	[0] = nil,
	[1] = "red_nor",
	[2] = "blue_nor",
	[5] = "red_block",
	[6] = "blue_block",
}

function TileObj:__init(x, y, tile_type, batch_node)
	local res = TileObj.TypeRes[tile_type]
	if res ~= nil then
		local sprite = AssetsHelper.CreateAnimSprite(res)
		local pos_x = (x-0.5) * Config.TileSize
		local pos_y = (y-0.5) * Config.TileSize
		sprite:setPosition(pos_x, pos_y)
		batch_node:addChild(sprite)

		self.main_sprite = sprite
	end

	self.tile_x = x
	self.tile_y = y
	self.tile_type = tile_type
end

function TileObj:__delete()
	if self.main_sprite ~= nil then
		self.main_sprite:removeFromParent()
		self.main_sprite = nil
	end
end

--判断格子是否可以走
function TileObj:CanWalk()
	return self.tile_type == Config.TileType.Empty
end

--判断格子是否可以建造东西
function TileObj:CanBuild()
	return self.tile_type ~= Config.TileType.Empty
end






