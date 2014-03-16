PopupMenu = PopupMenu or BaseClass(BaseView)

function PopupMenu:__init( )
	self.root_bg = AssetsHelper.CreateUIScaleSprite("popup_menu_bg")
	self.root_bg:setPosition(cc.p(0, 0))
	self.root_wnd:addChild(self.root_bg)

	self.select_frame = AssetsHelper.CreateFrameSprite("select_frame")
	-- self.root_wnd:addChild(self.select_frame, -1)

	self.icons_list = {}
end

function PopupMenu:__delete( )
end

--x,y 格子坐标
function PopupMenu:Open(tile_pos, map, icon_info_list)
	self:Close()

	BaseView.Open(self)

	self:ClearIcons()

	self.icons_list = icon_info_list
	local x, y = 32, 32
	for _, icon_info in pairs(self.icons_list) do
		local btn = AssetsHelper.CreateButton(icon_info.frame_name)
		btn:setPosition(cc.p(x, y))

		local btn_start_func = function (event_type, x, y)
			-- print("= PopupMenu:Show   pressed_btn:", icon_info.frame_name)
			if icon_info.press_func then
				icon_info.press_func()
			end
			self:Close()
			return true
		end
		btn:addScriptCallBackForControlEvent(btn_start_func, CCControlEventTouchUpInside)

		self.root_bg:addChild(btn)

		icon_info.icon_btn = btn

		x = x + 48
	end

	local icon_count = #self.icons_list
	local w = 64 + 48 * (icon_count-1)
	self.root_bg:setContentSize(cc.size(w, 64))
	
	local pos = Utils.TileToPixel(tile_pos)
	-- self.select_frame:setPosition(pos)

	self.root_bg:setPosition(g_real_visible_rct:getMinX() + w / 2, g_real_visible_rct:getMinY()+32)
	-- print("!!!!!!!!!PopupMenu:Open:", string.format("tile:%d,%d,  pixel:%.2f, %.2f", tile_pos.x, tile_pos.y, pos.x, pos.y))

	-- --根据大小校正格子坐标 
	-- local tpos = cc.p(tile_pos.x, tile_pos.y)
	-- pos = Utils.TileToPixel(tpos)
	-- if tpos.y >= map:GetMapSizeInTile().height - 1 then
	-- 	tpos.y = tpos.y - 1
	-- else
	-- 	tpos.y = tpos.y + 1
	-- end

	-- pos = Utils.TileToPixel(tpos)
	-- if pos.x - w / 2 < g_real_visible_rct:getMinX() then
	-- 	pos.x = g_real_visible_rct:getMinX() + w / 2
	-- elseif pos.x + w / 2 > g_real_visible_rct:getMaxX() then
	-- 	pos.x = g_real_visible_rct:getMaxX() - w / 2
	-- end

	-- self.root_bg:setPosition(pos)
end


function PopupMenu:ClearIcons( ... )
	for _, icon in pairs(self.icons_list) do
		if icon.icon_btn then
			icon.icon_btn:removeFromParentAndCleanup(true)
		end
	end
	self.icons_list = {}
end