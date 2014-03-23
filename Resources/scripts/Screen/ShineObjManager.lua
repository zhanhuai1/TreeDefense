require("scripts.Screen.ShineObj")

ShineObjManager = ShineObjManager or BaseClass()

function ShineObjManager:__init()
	ShineObjManager.Instance = self
	self.obj_list = {}
end

function ShineObjManager:__delete()
	self:Clear()
end

function ShineObjManager:Update(delta_time, running_time)
	for _, obj in pairs(self.obj_list) do
		obj:Update(delta_time, running_time)
		self:AdjustObjPosition(obj, 20)
	end
end

--把obj的坐标调整到屏幕范围内
--ex 屏幕范围外不调整的距离
function ShineObjManager:AdjustObjPosition(obj, ex)
	ex = ex or 50
	local xx = Glo.VisibleRct.width
	local yy = Glo.VisibleRct.height
	if obj.position.x < -ex then
		obj.position.x = xx+ex
	elseif obj.position.x > xx+ex then
		obj.position.x = -ex
	end
	if obj.position.y < -ex then
		obj.position.y = yy+ex
	elseif obj.position.y > yy+ex then
		obj.position.y = -ex
	end
end


function ShineObjManager:CreateObj(pos, angle, zorder)
	local obj = ShineObj.New(pos, angle, zorder)
	table.insert(self.obj_list, obj)
end

function ShineObjManager:Clear()
	for i, obj in pairs(self.obj_list) do
		obj:DeleteMe()
	end
	self.obj_list = {}
end

