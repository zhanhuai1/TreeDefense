SelectMapScreen = SelectMapScreen or BaseClass(BaseScreen)


function SelectMapScreen:__init()
	self.map_info_list = {}
	self.loaded_map_infos = false
end

function SelectMapScreen:__delete()
end

function SelectMapScreen:Enter()
	print("= = =SelectMapScreen:Enter= = =")
	BaseScreen.Enter(self)

	self.sky = AssetsHelper.CreateFrameSprite("sky.png")
	Glo.LayerBg:addChild(self.sky)
	local sky_frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("sky.png")
	local frame_sz = sky_frame:getOriginalSize()
	local x_scale = Glo.VisibleRct.width / frame_sz.width
	local y_scale = Glo.VisibleRct.height / frame_sz.height
	local bg_scale = ((x_scale > y_scale) and x_scale or y_scale) + 0.1
	self.sky:setScale(bg_scale)
	self.sky:setPosition(Glo.VisibleRct.width / 2, Glo.VisibleRct.height / 2)

	--加载地图信息
	self:InitMapInfos()

	--回退按钮
	if self.btn_back == nil then
		local btn = ccui.Button:create()
		btn:loadTextures("start_btn_nor.png", "start_btn_sel.png", "", ccui.TextureResType.plistType)
		btn:setPosition(50, 50)
		btn:setPressedActionEnabled(false)
		btn:setTouchEnabled(true)
		Glo.LayerUI:addChild(btn)
		local btn_start_func = function (target, event_type)
			if event_type == ccui.TouchEventType.ended then
				GlobalEventSystem:Fire(EventName.GoMainMenu)
			end
		end
		self.btn_back = btn
		self.btn_back:addTouchEventListener(btn_start_func)
	end

	--关卡按钮
	local x_start = 150
	local posx =  x_start
	local posy = Glo.VisibleRct.height - 150
	for y = 1, 4 do
		for x = 1, 5 do
			local i = 5 * (y-1) + x
			print("== i:", i)
			local map_info = self.map_info_list[i]
			local btn = ccui.Button:create()
			btn:loadTextures("level_icon_nor.png", "level_icon_sel.png", "level_icon_dis.png", ccui.TextureResType.plistType)
			btn:setTouchEnabled(not map_info.locked)
			btn:setBright(not map_info.locked)
			btn:setPosition(posx, posy)
			
			local func = function(target, event_type)
				if event_type == ccui.TouchEventType.ended then
					GlobalEventSystem:Fire(EventName.GoMainMenu)
				end
			end
			btn:addTouchEventListener(func)
			map_info.btn = btn
			Glo.LayerUI:addChild(btn)

			posx = posx + 150
		end
		posx = x_start
		posy = posy - 130
	end
end

function SelectMapScreen:Exit()	
	print("= = =SelectMapScreen:Exit= = =")
	BaseScreen.Exit(self)

	if self.sky then
		self.sky:removeFromParentAndCleanup(true)
		self.sky = nil
	end

	if self.btn_back ~= nil then
		self.btn_back:removeFromParentAndCleanup(true)
		self.btn_back = nil
	end

	for _, map_info in pairs(self.map_info_list) do
		if map_info.btn then
			map_info.btn:removeFromParentAndCleanup(true)
			map_info.btn = nil
		end
	end

end

function SelectMapScreen:Update(delta_time, running_time)

end

function SelectMapScreen:InitMapInfos()
	if self.loaded_map_infos then
		return
	end

	for i=1, 20 do
		local info = {}
		info.locked = (i~=1)
		info.map_name = "map_01_01"
		self.map_info_list[i] = info
	end
	self.loaded_map_infos = true
end
