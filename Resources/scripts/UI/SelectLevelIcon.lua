SelectLevelIcon = SelectLevelIcon or BaseClass()

--三颗星星的位置 
SelectLevelIcon.star_pos_list = {cc.p(-31, -27), cc.p(0, -27), cc.p(31, -27)}

function SelectLevelIcon:__init(chapter, level, star, locked)
	self.root_node = cc.Node:create()

	local click_func = function (target, event_type)
		if target == self.root_btn and event_type == ccui.TouchEventType.ended then
			cc.SimpleAudioEngine:getInstance():playEffect("music/click.wav")
			GlobalEventSystem:Fire(EventName.GoGame, chapter, level)
		end
	end
	local btn = AssetsHelper.CreateButton("level_icon_nor.png", "level_icon_sel.png", "level_icon_dis.png", click_func)
	btn:setPosition(0, 0)
	btn:setPressedActionEnabled(false)
	self.root_btn = btn
	self.root_btn:setTouchEnabled(not locked)
	self.root_btn:setBright(not locked)
	self.root_node:addChild(btn)

	if not locked then
		--关卡数字
		if level < 10 then
			local num_sprite = AssetsHelper.CreateSprite(string.format("level_num_%d.png", level))
			num_sprite:setPosition(0, 18)
			self.root_node:addChild(num_sprite)
		else
			local t = math.floor(level / 10)
			local num_sprite = AssetsHelper.CreateSprite(string.format("level_num_%d.png", t))
			num_sprite:setPosition(-16, 18)
			self.root_node:addChild(num_sprite)

			local n = math.floor(level % 10)
			num_sprite = AssetsHelper.CreateSprite(string.format("level_num_%d.png", n))
			num_sprite:setPosition(16, 18)
			self.root_node:addChild(num_sprite)
		end

		--星级
		for i = 1, star do
			local star_sprite = AssetsHelper.CreateSprite("star.png")
			star_sprite:setPosition(SelectLevelIcon.star_pos_list[i])
			self.root_node:addChild(star_sprite)
		end
	end
end

function SelectLevelIcon:__delete()
	if self.root_node then
		self.root_node:removeFromParent(true)
		self.root_node = nil
	end
end

function SelectLevelIcon:GetRootNode( )
	return self.root_node
end