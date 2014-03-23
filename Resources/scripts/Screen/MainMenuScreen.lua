MainMenuScreen = MainMenuScreen or BaseClass(BaseScreen)

function MainMenuScreen:__init()
	self.btn_start = nil	
end

function MainMenuScreen:__delete()
	self:Exit()
end

function MainMenuScreen:Enter()
	print("= = =MainMenuScreen:Enter= = =")
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

	self.ground = AssetsHelper.CreateFrameSprite("ground.png")
	local ground_frame = cc.SpriteFrameCache:getInstance():getSpriteFrame("ground.png")
	frame_sz = ground_frame:getOriginalSize()
	x_scale = Glo.VisibleRct.width / frame_sz.width
	bg_scale = x_scale + 0.1
	self.ground:setScale(bg_scale)
	self.ground:setAnchorPoint(cc.p(0.5, 0))
	self.ground:setPosition(Glo.VisibleRct.width / 2, 0)
	Glo.LayerBg:addChild(self.ground)

	self.tree = AssetsHelper.CreateFrameSprite("tree.png")
	self.tree:setScale(bg_scale)
	self.tree:setPosition(Glo.VisibleRct.width/2, 200)
	Glo.LayerBg:addChild(self.tree)

	
	local btn = ccui.Button:create()
	btn:loadTextures("start_btn_nor.png", "start_btn_sel.png", "", ccui.TextureResType.plistType)
	btn:setPosition(Glo.VisibleRct.width/2, 200)
	btn:setPressedActionEnabled(false)
	btn:setTouchEnabled(true)
	Glo.LayerUI:addChild(btn)
	local btn_start_func = function (target, event_type)
		if event_type == ccui.TouchEventType.ended then
			GlobalEventSystem:Fire(EventName.GoSelectMap)
		end
	end
	self.btn_start = btn
	self.btn_start:addTouchEventListener(btn_start_func)
end

function MainMenuScreen:Exit()
	print("= = =MainMenuScreen:Exit= = =")
	BaseScreen.Exit(self)
	
	if self.btn_start ~= nil then
		self.btn_start:removeFromParentAndCleanup(true)
		self.btn_start = nil
	end

	if self.sky then
		self.sky:removeFromParentAndCleanup(true)
		self.sky = nil
	end

	if self.ground then
		self.ground:removeFromParentAndCleanup(true)
		self.ground = nil
	end

	if self.tree then
		self.tree:removeFromParentAndCleanup(true)
		self.tree = nil
	end
end

function MainMenuScreen:Update(delta_time, running_time)

end
