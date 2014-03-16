BaseScreen = BaseScreen or BaseClass()

function BaseScreen:__init()
	self.texture_name_list = {
		"media/bg1.jpg",
		"media/squirm_mask2.jpg",
	}
	self.bg_name = "media/bg1.jpg"
	self.bg_mask_mask 	= "media/squirm_mask2.jpg"
end

function BaseScreen:Enter()
	--创建背景
	if self.squirm_bg == nil then
		self.bg_sprite = AssetsHelper.CreateTextureSprite("media/bg1.jpg")
		local texture = cc.Director:getInstance():getTextureCache():getTextureForKey("media/bg1.jpg")
		local sz = texture:getContentSize()
		local scalex, scaley = g_real_visible_sz.width / sz.width, g_real_visible_sz.height / sz.height
		self.bg_sprite:setScaleX(scalex)
		self.bg_sprite:setScaleY(scaley)
		self.bg_sprite:setPosition(g_real_visible_sz.width / 2, g_real_visible_sz.height / 2)
		g_game_scene:addChild(self.bg_sprite, Config.ZOrder.Squirm)
	end
end

function BaseScreen:Exit()
	if self.squirm_bg then
		self.squirm_bg:removeFromParentAndCleanup(true)
		self.squirm_bg = nil
	end
end

function BaseScreen:Update(delta_time, running_time)
end
