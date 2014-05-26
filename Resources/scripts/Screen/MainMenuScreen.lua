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
	
	local btn_start_func = function (target, event_type)
		if event_type == ccui.TouchEventType.ended then
			GlobalEventSystem:Fire(EventName.GoSelectMap)
			-- local path = cc.FileUtils:getInstance():fullPathForFilename("music/click.wav")
			cc.SimpleAudioEngine:getInstance():playEffect("music/click.wav")
		end
	end

	local btn = AssetsHelper.CreateButton("start_btn_nor.png", "start_btn_sel.png", "", btn_start_func)
	btn:setPosition(Glo.VisibleSize.width/2, 300)
	Glo.LayerUI:addChild(btn)
	self.btn_start = btn





	-- local bar = ccui.LoadingBar:create()
	-- bar:setPosition(cc.p(Glo.VisibleSize.width/2, 100))
	-- bar:loadTexture("hp_bar.png", ccui.TextureResType.plistType)
	-- bar:setPercent(50)
	-- Glo.LayerUI:addChild(bar)

	-- local sp = AssetsHelper.CreateAnimSprite("red_bullet_stat")
	-- Glo.LayerUI:addChild(sp)
	-- sp:setPosition(cc.p(Glo.VisibleSize.width/2, 100))

	-- local bullet = Bullet.New(0, 1, cc.p(Glo.VisibleSize.width/2, 100), Glo.LayerUI)
	-- bullet:SetDirection(0)
	-- -- bullet:SetDamage(self.attack_damage)
	-- -- bullet:SetParentTower(self)
	-- bullet:SetRes("red_bullet")
end

function MainMenuScreen:Exit()
	print("= = =MainMenuScreen:Exit= = =")
	BaseScreen.Exit(self)
	
	if self.btn_start ~= nil then
		self.btn_start:removeFromParent(true)
		self.btn_start = nil
	end
end

function MainMenuScreen:Update(delta_time, running_time)

	-- if self.test_node == nil then
	-- 	self.test_node = cc.Node:create()
	-- 	self.test_node:retain()
	-- 	self.test_node:setPosition(cc.p(Glo.VisibleSize.width/2, 100))
	-- 	Glo.LayerUI:addChild(self.test_node)

	-- 	self.test_sprite = AssetsHelper.CreateAnimSprite("enemy1_run")
	-- 	self.test_node:addChild(self.test_sprite)
	-- elseif self.is_hide == nil and running_time > 3 then
	-- 	self.test_sprite:stopActionByTag(Config.ActionTag.Anim)
	-- 	self.test_node:removeFromParent(false)
	-- 	self.is_hide = true
	-- elseif self.is_show == nil and running_time > 6 then
	-- 	Glo.LayerUI:addChild(self.test_node)
	-- 	local act = AssetsHelper.CreateAnimAction("enemy1_run")
	-- 	self.test_sprite:runAction(act)
	-- 	self.is_show = true
	-- end

end






