PopupMenu = PopupMenu or BaseClass()

function PopupMenu:__init( )
	self.root_node = cc.Node:create()
	self.root_node:retain()
	self.root_node:setVisible(false)
	Glo.LayerMap:addChild(self.root_node, Config.ZOrder.MapUI)
	self.is_open = false

	self.tile_pos = nil

	--选中框
	local select_frame = AssetsHelper.CreateSprite("select_frame.png")
	self.root_node:addChild(select_frame)

	self.icon_list = {}
	self.call_back_list = {}
	self.icon_radius = 64
	local icon_num = 6
	for i=1, icon_num do	
		local icon = AssetsHelper.CreateButton()

		local on_icon_click_func = function (target, event_type)
			if event_type == ccui.TouchEventType.ended and target == icon then
				self:OnIconClick(i)
			end
		end		
		icon:addTouchEventListener(on_icon_click_func)
		self.root_node:addChild(icon)

		local t = {}
		t.btn = icon
		self.icon_list[i] = t
	end
end

function PopupMenu:__delete( )
	if self.root_node then
		self.root_node:removeFromParent(true)
	end
end

function PopupMenu:IsOpen()
	return self.is_open
end

--x,y 格子坐标
function PopupMenu:Open(tile_pos, icon_info_list)
	self.tile_pos = tile_pos
	local num = #icon_info_list
	-- print("PopupMenu:Open:!!!!!!", num)

	self.root_node:setPosition(Utils.TileToPixel(tile_pos))
	self.root_node:setScale(0)
	self.root_node:setVisible(true)
	self.is_open = true

	local scale1 = cc.ScaleTo:create(0.15, 1)
	local scale2 = cc.ScaleTo:create(0.1, 1.2)
	local scale3 = cc.ScaleTo:create(0.05, 1)
	
	self.root_node:stopAllActions()
	self.root_node:runAction(scale1)

	--取出需要用到的按钮，并清空它们的Actions
	local visible_icons = {}
	for i=1, 8 do
		local t = self.icon_list[i]
		if t == nil then
			break
		end

		local icon = t.btn
		icon:setScale(0)
		icon:stopAllActions()
		if i <= num then
			table.insert(visible_icons, t)
			icon:setVisible(true)
			icon.icon_info = icon_info_list[i]
		else
			icon:setVisible(false)
			icon.icon_info = nil
		end
	end


	--根据不同情况定位需要显示的按钮
	--如果按钮太靠上，就把它们向下排列
	local is_y_limit = tile_pos.y >= Config.MapTilesY - 1 
	local start_radian = math.pi
	local delta_radian = -math.pi/2
	if num == 1 then
		start_radian = is_y_limit and (-math.pi/2) or (math.pi/2)
	elseif num == 2 then
		start_radian = is_y_limit and (-math.pi*0.75) or (math.pi*0.75)
		delta_radian = is_y_limit and (math.pi/2) or (-math.pi/2)
	elseif num >= 3 then
		start_radian = math.pi
		delta_radian = is_y_limit and (math.pi/(num-1)) or (-math.pi/(num-1))
	end

	--把需要显示的按钮播放缩放action
	local ttt = 0.1
	for i=1, #visible_icons do
		local t = visible_icons[i]
		local icon = t.btn

		--定位
		local pos = cc.pForAngle(start_radian + delta_radian * (i-1))
		pos = cc.pMul(pos, self.icon_radius)
		icon:setPosition(pos)
		icon:setTouchEnabled(true)
		icon:setBright(true)

		--存信息
		local icon_info = icon_info_list[i]
		t.info = icon_info

		--显示资源
		if icon_info.type == PopupIconInfo.IconTypes.Build then
			local cfg = BuildConfig[icon_info.build_type_id]
			if cfg then
				icon:loadTextures(cfg.icon, "", "", ccui.TextureResType.plistType)
			else
				icon:loadTextures("build3_icon.png", "", "", ccui.TextureResType.plistType)
			end
		elseif icon_info.type == PopupIconInfo.IconTypes.Upgrade then
			icon:loadTextures("upgrade_icon.png", "", "", ccui.TextureResType.plistType)
		elseif icon_info.type == PopupIconInfo.IconTypes.Sell then
			icon:loadTextures("sell_icon.png", "", "", ccui.TextureResType.plistType)
		elseif icon_info.type == PopupIconInfo.IconTypes.MaxLevel then
			icon:loadTextures("upgrade_icon.png", "", "", ccui.TextureResType.plistType)
			icon:setTouchEnabled(false)
			icon:setBright(false)
		end

		local delay = cc.DelayTime:create(ttt * (i-1))
		icon:runAction(cc.Sequence:create(delay, scale2:clone(), scale3:clone()))
	end
end

--缩放的关闭
function PopupMenu:Close()	
	if not self.is_open then
		return
	end
	self.tile_pos = nil	
	self.is_open = false
	local delay_hide_func = function ()
		self.root_node:setVisible(false)
	end
	local scale1 = cc.ScaleTo:create(0.08, 1.1)
	local scale2 = cc.ScaleTo:create(0.1, 0)
	-- local delay_act = cc.DelayTime:create(0.18)
	local call_act = cc.CallFunc:create(delay_hide_func) 

	self.root_node:stopAllActions()
	self.root_node:runAction(cc.Sequence:create(scale1, scale2, call_act))
	-- self.root_node:runAction(cc.Sequence:create(delay_act, call_act))

	for i=1, #self.icon_list do
		local t = self.icon_list[i]
		local icon = t.btn
		if icon:isVisible() then
			icon:stopAllActions()
			icon:runAction(cc.Sequence:create(scale1:clone(), scale2:clone()))
		else
			break
		end
	end
end

--按钮被点击
function PopupMenu:OnIconClick(i)
	local icon_info = self.icon_list[i].info

	print("PopupMenu:OnIconClick:", icon_info.build_type_id, self.tile_pos.x, self.tile_pos.y)
	if icon_info.type == PopupIconInfo.IconTypes.Build then
		GlobalEventSystem:Fire(EventName.Build, icon_info.build_type_id, self.tile_pos)

	elseif icon_info.type == PopupIconInfo.IconTypes.Upgrade then
		
	elseif icon_info.type == PopupIconInfo.IconTypes.Sell then
				
	end

	self:Close()
end







