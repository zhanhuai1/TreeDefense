SinHelper = SinHelper or BaseClass()

function SinHelper:__init()
	SinHelper.Instance = self

	--把Sin的一个周期分解成1000段
	self.seg_count = 1000
	self.sin_data = {}
	self.ratio = self.seg_count / (math.pi * 2)
	for i=0, self.seg_count-1 do
		local x = math.pi * 2 * i / self.seg_count
		local s = math.sin(x)
		self.sin_data[i+1] = s
	end
end

function SinHelper:_delete()
end

--使用从0开始的时间t来取sin值
function SinHelper:SinT(t)
	t = math.floor(t * self.ratio)
	if t > self.seg_count then
		t = t  % self.seg_count
	end
	t = t + 1
	return self.sin_data[t]
end

--使用从0开始的索引来取得sin值
function SinHelper:SinI(i)
	i = math.floor(i)
	if i >= self.seg_count then
		i = i % self.seg_count
	end
	i = i + 1
	return self.sin_data[i]
end

function SinHelper:GetSegCount()
	return self.seg_count
end