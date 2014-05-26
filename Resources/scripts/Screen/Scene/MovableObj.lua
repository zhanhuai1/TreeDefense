MovableObj = MovableObj or BaseClass()
MovableObj.created_count = 0

function MovableObj:__init()
	self.root_node = cc.Node:create()
	self.root_node:retain()

	self.main_sprite = cc.Sprite:create()
	self.root_node:addChild(self.main_sprite)
end

function MovableObj:__delete()
	self.root_node:release()
	self.root_node:removeFromParent(true)
end

function MovableObj:Init(type_id, instance_id, pixel_pos, parent_node)
	self.type_id = type_id
	self.instance_id = instance_id
	self.pixel_pos = pixel_pos
	self.radius = 0

	self.root_node:setPosition(pixel_pos)
	-- self.root_node:setVisible(true)
	parent_node:addChild(self.root_node, MovableObj.created_count)
	MovableObj.created_count = MovableObj.created_count + 1
end

function MovableObj:Destroy()
	self.root_node:removeFromParent(false)
end

function MovableObj:GetMovableType()
	return self.type_id
end

function MovableObj:GetMovableInstanceId()
	return self.instance_id
end

function MovableObj:SetRadius(r)
	self.radius = r
end

function MovableObj:GetRadius( ... )
	return self.radius
end

-- function MovableObj:GetAABB()
-- 	local lt = cc.p(self.pixel_pos.x - self.size.width / 2, self.pixel_pos.y - self.size.height / 2)
-- 	return cc.rect(lt.x, lt.y, self.size.width, self.size.height)
-- end

function MovableObj:SetPixelPos(pos)
	self.pixel_pos = pos
	self.root_node:setPosition(pos)
end

function MovableObj:GetPixelPos()
	return self.pixel_pos
end