TileObj = TileObj or BaseClass()

function TileObj:__init(tile_state, tile_pos)
	self.tile_state = nil
	self.base_node = CCNode:create()
	self.base_node:retain()
	local pixel_pos = Utils.TileToPixel(tile_pos)
	self.base_node:setPosition(pixel_pos)

	self.main_sprite = nil

	self:SetTileState(tile_state)
end

function TileObj:__delete()
	if self.base_node then
		self.base_node:removeFromParentAndCleanup(true)
		self.base_node:release()
	end
	self.main_sprite = nil
end

function TileObj:GetTileState()
	return self.tile_state
end

function TileObj:SetTileState(tile_state)
	if self.tile_state ~= tile_state then
		self.tile_state = tile_state

		if tile_state == Map.TileState.EMPTY then
			self:DestroySprite()
		elseif tile_state == Map.TileState.BUILD_TILE then
			self:CreateGrowBase()
		elseif tile_state == Map.TileState.INVALID_TILE then
			self:CreateInvalidTile()
		end
	end
end

function TileObj:GetBaseNode()
	return self.base_node
end

function TileObj:DestroySprite()
	if self.main_sprite then
		self.main_sprite:removeFromParentAndCleanup(true)
		self.main_sprite = nil
	end	
end

function TileObj:CreateGrowBase()
	self:DestroySprite()

	self.main_sprite = AssetsHelper.CreateFrameSprite("build_base")
	self.base_node:addChild(self.main_sprite)
end

function TileObj:CreateInvalidTile()
	self:DestroySprite()

	self.main_sprite = AssetsHelper.CreateFrameSprite("invalid_tile")
	self.base_node:addChild(self.main_sprite)	
end