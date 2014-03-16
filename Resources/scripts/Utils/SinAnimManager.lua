SinAnimManager = SinAnimManager or BaseClass()

function SinAnimManager:__init()	
	SinAnimManager.Instance = self

	self.obj_index = 0
	self.obj_list = {}
end

function SinAnimManager:__delete()
	for _, obj in pairs(self.obj_list) do
		obj:DeleteMe()
	end
	self.obj_list = nil
end

--wave_hei 波峰高度
--time_scale 值为1时，周期1000帧，值越小，周期越长
--random_speed 周期起始位置的随机种子[0,1]
--func 处理函数
function SinAnimManager:AddAnim(wave_hei, time_scale, random_seed, func)
	local obj = SinAnimObj.New(wave_hei, time_scale, random_seed, func)
	self.obj_index = self.obj_index + 1
	self.obj_list[self.obj_index] = obj
	return self.obj_index
end

function SinAnimManager:RemoveAnim(i)
	local obj = self.obj_list[i]
	if obj ~= nil then
		obj:DeleteMe()
	end
	self.obj_list[i] = nil
end

function SinAnimManager:Update(elapsed_time, running_time)
	for i, obj in pairs(self.obj_list) do
		obj:Update(elapsed_time, running_time)
	end
end



---------------------------------------------------------------
---------------------------------------------------------------
SinAnimObj = SinAnimObj or BaseClass()
function SinAnimObj:__init(wave_hei, time_scale, random_seed, func)
	self.wave_hei = wave_hei
	self.time_scale = time_scale
	self.func = func
	self.sin_index = random_seed * SinHelper.Instance:GetSegCount()
	-- print(string.format("= = = SinAnimObj:__init wave:%d time_scale:%f random_seed:%f", wave_hei, time_scale, random_seed))
end

function SinAnimObj:__delete()
end

function SinAnimObj:Update(elapsed_time, running_time)
	self.sin_index = self.sin_index + self.time_scale
	local s = SinHelper.Instance:SinI(self.sin_index)
	s = self.wave_hei * s
	-- print("=====SinAnimObj:Update index:", self.sin_index, "s:", s)
	self.func(s)
end