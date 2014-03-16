MovableObj = MovableObj or BaseClass()

function MovableObj:__init()
end

function MovableObj:__delete()
	self.base_node:removeFromParentAndCleanup(true)
end

function MovableObj:Init(pixel_pos, bounding_size, move_speed)
	self.bounding_size = bounding_size
	self.base_node = CCNode:create()
	self.move_speed = move_speed
	self:SetPixelPos(pixel_pos)
end

function MovableObj:GetBaseNode()
	return self.base_node
end

function MovableObj:GetBoundingAABB()
	local lt = cc.p(self.pixel_pos.x - self.bounding_size.width / 2, self.pixel_pos.y - self.bounding_size.height / 2)
	return cc.rect(lt.x, lt.y, self.bounding_size.width, self.bounding_size.height)
end

function MovableObj:GetPixelPos()
	return self.pixel_pos
end

function MovableObj:SetPixelPos(pixel_pos)
	self.pixel_pos = pixel_pos
	self.base_node:setPosition(self.pixel_pos)
end