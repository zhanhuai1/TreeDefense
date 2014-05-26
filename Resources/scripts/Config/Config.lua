Config =
{
	--所有Z值
	ZOrder = 
	{
		--基本层次结点对应Glo.LayerBg,Glo.LayerMap等
		Bg = 100,
		Map = 200,
		Touch = 300,
		UI = 500,

		--地图上的层次定义
		MapBg = 0,
		MapTile = 5,
		MapPath = 8,
		MapTower = 10,
		MapEnemy = 15,
		MapBullet = 20,
		MapUI = 30,
	},

	--格子的类型
	TileType = 
	{
		Empty = 0,
		RedNor = 1,
		BlueNor = 2,
		RedBlock = 5,
		BlueBlock = 6,
	},

	ObjType = 
	{
		Block = 1,
		Tower = 2,
		Bullet = 3,
		Enemy = 4,
	},

	--Action的Tag定义，用来区分或查找不同类型的Tag，如Animate类型的Action就只能存在一个，所以播一个就要停一个
	ActionTag = 
	{
		Default = -1,
		Anim = 1, 		--动画Action专用
		Camera = 2,  	--ActionCamera专用
		HideHp = 3, 	--怪物在被攻击时显示血条，几秒后再隐藏血条的delay_action
	},

	--一些config值
	MapTilesX = 24,
	MapTilesY = 15,
	TileSize = 64,
	SceneSize = cc.size(24*64, 15*64),
	DefaultFPS = 60,

}


--全局变量
Glo = 
{
	Scene = nil,
	RunningTime = 0,
	RunningFrame = 0,
	VisibleSize = cc.size(0,0),

	LayerBg = nil,
	LayerMap = nil,
	LayerTouch = nil,
	LayerUI = nil,
}
