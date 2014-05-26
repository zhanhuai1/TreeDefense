CountDownView = CountDownView or BaseClass(BaseView)
CountDownView.MAX_NUM = 3

function CountDownView:__init()
	self.root_node = cc.Node:create()
	self.root_node:setPosition(cc.p(Glo.VisibleSize.width/2, Glo.VisibleSize.height/2))
	self.root_node:retain()
	self.is_open = false

	self.main_img = cc.Sprite:create()
	self.root_node:addChild(self.main_img)
end

function CountDownView:__delete()
	if self.root_node then
		self.root_node:removeFromParent(true)
		self.root_node:release()
		self.root_node = nil
	end
end

function CountDownView:Open()
	Glo.LayerUI:addChild(self.root_node)
	self.start_count_time = Glo.RunningTime
	self.every_num_time = 0.1 --每个数字持续的时间 

	self.now_number = CountDownView.MAX_NUM
	self.main_img:setSpriteFrame(string.format("count_down_%d.png", CountDownView.MAX_NUM))
	self.root_node:setScale(0)
	self.is_open = true
end

function CountDownView:Close()
	self.root_node:removeFromParent(false)
	self.is_open = false
end

function CountDownView:IsOpen()
	return self.is_open
end

--返回true表示倒计时结束
function CountDownView:Update(delta_time, running_time)
	local t = (running_time - self.start_count_time) / self.every_num_time
	local x = math.floor(t)
	local n = CountDownView.MAX_NUM - x
	if n <= 0 then
		self:Close()
		return true
	end
	if n ~= self.now_number then
		self.main_img:setSpriteFrame(string.format("count_down_%d.png", n))
		self.now_number = n
	end
	local p = (t - x) * 3
	if p > 1 then
		p = 1
	end
	-- print("= = = 倒计时：", n, p, running_time, self.start_count_time)
	self.root_node:setScale(p)
	return false
end