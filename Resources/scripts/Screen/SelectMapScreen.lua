
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

	--加载地图信息
	self:InitMapInfos()

	--回退按钮
	if self.btn_back == nil then
		local btn = ccui.Button:create()
		btn:loadTextures("back_btn_nor.png", "back_btn_sel.png", "", ccui.TextureResType.plistType)
		btn:setPosition(150, 50)
		btn:setPressedActionEnabled(false)
		btn:setTouchEnabled(true)
		Glo.LayerUI:addChild(btn)
		local btn_start_func = function (target, event_type)
			if event_type == ccui.TouchEventType.ended then
				cc.SimpleAudioEngine:getInstance():playEffect("music/click.wav")
				GlobalEventSystem:Fire(EventName.GoMainMenu)
			end
		end
		self.btn_back = btn
		self.btn_back:addTouchEventListener(btn_start_func)
	end

	--关卡按钮
	local x_step = 150
	local y_step = 130
	local x_start = (Glo.VisibleSize.width - x_step * 4) / 2
	local posx =  x_start
	local posy = Glo.VisibleSize.height - y_step
	for y = 1, 4 do
		for x = 1, 5 do
			local i = 5 * (y-1) + x
			local map_info = self.map_info_list[i]
			local level_icon = SelectLevelIcon.New(1, i, 1, map_info.locked)
			local root_wnd = level_icon:GetRootNode()
			root_wnd:setPosition(posx, posy)
			Glo.LayerUI:addChild(root_wnd)			
			map_info.btn = level_icon

			posx = posx + x_step
		end
		posx = x_start
		posy = posy - y_step
	end
end

function SelectMapScreen:Exit()	
	print("= = =SelectMapScreen:Exit= = =")
	BaseScreen.Exit(self)

	if self.btn_back ~= nil then
		self.btn_back:removeFromParent(true)
		self.btn_back = nil
	end

	for _, map_info in pairs(self.map_info_list) do
		if map_info.btn then
			map_info.btn:DeleteMe()
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
