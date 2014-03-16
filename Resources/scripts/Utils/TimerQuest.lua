TimerQuestItem = TimerQuestItem or BaseClass()

function TimerQuestItem:__init(func, delta_time, time_len)
	self.func = func
	self.delta_time = delta_time
	self.next_time = (delta_time==-1) and -1 or g_running_time + delta_time
	self.end_time = (time_len==-1) and -1 or g_running_time + time_len
end
function TimerQuestItem:Update(now_time)
	--先执行
	if self.next_time == -1 then
		self.func(g_running_time)
	else
		while now_time >= self.next_time 
			self.func(self.next_time)
			self.next_time = self.next_time + self.delta_time
		end
	end

	--执行完后判断是否需要删除自己
	--返回true为需要删除，否则不删除
	if self.end_time ~= -1 and self.end_time <= now_time then
		return true
	end
	return false
end


------------------------------------------------
------------------------------------------------
TimerQuest = TimerQuest or BaseClass()

function TimerQuest:__init()
	self.period_quest_list = {}
	self.delay_quest_list = {}
	self.increase_id = 0
end

function TimerQuest:__delte()
end

function TimerQuest:Update(delta_time, now_time)
	--循环调用的quest
	for id, quest in pairs(self.period_quest_list) do
		--刷新item，如果返回true，就删除之
		if quest:Update(now_time) then
			quest:DeleteMe()
			self.period_quest_list[id] = nil
		end
	end

	--调用一次的quest，调用一次就删除
	for id, quest in pairs(self.delay_quest_list) do
		quest:Update()
		quest:DeleteMe()
	end
	self.delay_quest_list = {}
end

function TimerQuest:AddPeriodQuest(func, delta_time, time_len)
	local item = TimerQuestItem.New(func, delta_time, time_len)
	self.increase_id = self.increase_id + 1
	self.period_quest_list[self.increase_id] = item
	return self.increase_id
end

function TimerQuest:AddDelayQuest(func, delay)
	local item = TimerQuestItem.New(func, delay, 0)
	self.increase_id = self.increase_id + 1
	self.delay_quest_list[self.increase_id] = item
	return self.increase_id
end

function TimerQuest:CancelQuest(id)
	if self.period_quest_list[id] ~= nil then
		self.period_quest_list[id]:DeleteMe()
		self.period_quest_list[id] = nil
	elseif self.delay_quest_list[id] ~= nil then
		self.delay_quest_list[id]:DeleteMe()
		self.delay_quest_list[id] = nil
	end
end

