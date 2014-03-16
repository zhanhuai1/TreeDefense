BaseView = BaseView or BaseClass()

BaseView.opened_instance = nil

function BaseView:__init()
	self.root_wnd = CCNode:create()
	self.root_wnd:retain()
	self.z_order = Config.ZOrder.UI
	self.is_open = false
end

function BaseView:__delete()
	if self.root_wnd then
		self.root_wnd:removeFromParentAndCleanup(true)
		self.root_wnd:release()
		self.root_wnd = nil
	end
end

function BaseView:SetZOrder(z)
	self.z_order = z
end

function BaseView:Open()
	if not self.root_wnd or self.is_open then
		return
	end
	-- print("= = = opened_instance :", BaseView.opened_instance, self)
	if BaseView.opened_instance and BaseView.opened_instance ~= self then
		BaseView.opened_instance:Close()
	end
	BaseView.opened_instance = self
	self.is_open = true
	g_game_scene:addChild(self.root_wnd, self.z_order)
end

function BaseView:Close()
	if not self.root_wnd or not self.is_open then
		return
	end
	if BaseView.opened_instance and BaseView.opened_instance == self then
		BaseView.opened_instance = nil

		-- print("= = = opened_instance :", nil)
	end
	self.is_open = false
	self.root_wnd:removeFromParentAndCleanup(false)
end