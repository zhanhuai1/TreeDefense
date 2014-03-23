Config =
{
	ZOrder = 
	{
		Bg = 100,
		Map = 200,
		Touch = 300,
		UI = 500,
	},

	MapTilesX = 24,
	MapTilesY = 15,
	TileSize = cc.size(64, 64),
}

Glo = 
{
	Scene = nil,
	RunningTime = 0,
	RunningFrame = 0,
	VisibleRct = cc.rect(0,0,0,0),

	LayerBg = nil,
	LayerMap = nil,
	LayerUI = nil,
}
