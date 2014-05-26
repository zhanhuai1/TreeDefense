PopupIconInfo = PopupIconInfo or BaseClass()

--弹出菜单的类型定义
PopupIconInfo.IconTypes = 
{
	None = 0,
	Build = 2,		--建造Tower
	Upgrade = 3,	--升级Tower
	Sell = 4,		--出售Tower
	MaxLevel = 5,	--已升级到顶级
}

function PopupIconInfo:__init(icon_type, build_type_id, price)
	self.type = icon_type
	self.build_type_id = build_type_id --要建造的Tower类型
	self.price = price
end