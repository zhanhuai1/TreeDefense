EventSystem = EventSystem or BaseClass()

function EventSystem:__init()
	self.event_list = {}
end

function EventSystem:__delete()
	for _, event in pairs(self.event_list) do
		event:DeleteMe()
	end
	self.event_list = nil
end

function EventSystem:Bind(event_name, func)
	local event = self.event_list[event_name]
	if event == nil then
		event = EventItem.New(event_name)
		self.event_list[event_name] = event
	end

	local handle_id = event:Bind(func)
	return {id = handle_id, name = event_name}
end

function EventSystem:UnBind(handler)
	if handler == nil or type(handler) ~= "table" then
		return
	end
	local event = self.event_list[handler.name]
	if event ~= nil then
		event:UnBind(handler.id)
	end
end

function EventSystem:Fire(event_name,  ... )
	local event = self.event_list[event_name]
	if event then
		event:Fire(...)
	end
end



-------------------------------------------
EventItem = EventItem or BaseClass()

function EventItem:__init(name)
	self.name = name
	self.handle_id = 0
	self.func_list = {}
end

function EventItem:__delete()
	-- body
end

function EventItem:Bind(func)
	self.handle_id = self.handle_id + 1
	self.func_list[self.handle_id] = func
	return self.handle_id
end

function EventItem:UnBind(id)
	self.func_list[id] = nil
end

function EventItem:Fire(...)
	for _, func in pairs(self.func_list) do
		func(...)
	end
end