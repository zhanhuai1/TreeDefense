g_maps_config = g_maps_config or {}
g_maps_config[1] = g_maps_config[1] or {}

g_maps_config[1][1] = {
	start_pt =	{
		[1] = cc.p(1, 2),
		[2] = cc.p(2, 15),
	},
	end_pt   = 	{
		[1] = cc.p(17, 9),
		[2] = cc.p(17, 11),
	},
	death_num = 10,	--最多允许逃跑的怪物数量

	tiles = {
		[15] = {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1},
		[14] = {1,1,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1},
		[13] = {1,1,1,0,0,0,0,2,2,2,2,2,2,0,0,0,0,1,1,1,1,1,1,1},
		[12] = {1,1,1,1,0,0,0,0,0,0,2,2,2,0,0,0,0,1,1,1,1,1,1,1},
		[11] = {1,1,1,1,5,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,1,1},
		[10] = {1,1,1,1,5,5,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,1,1},
		[9]  = {1,1,1,1,5,5,1,1,1,1,1,1,0,0,0,0,0,2,2,2,2,2,1,1},
		[8]  = {1,1,1,1,5,5,6,6,6,6,6,6,0,1,1,1,1,2,2,2,2,2,1,1},
		[7]  = {1,1,1,1,5,5,6,6,6,6,6,6,0,1,1,1,1,2,2,2,2,2,1,1},
		[6]  = {1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,1,1},
		[5]  = {1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1,2,2,2,2,2,1,1},
		[4]  = {1,1,0,1,1,0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,2,1,1},
		[3]  = {1,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1},
		[2]  = {0,0,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1},
		[1]  = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1},
	},
	waves_data = {
		[1] = {
			{type="Base", number = 3, born_frame =0, born_delta_frame = 60}
		},
		[2] = {
			{type="Base", number = 20, born_frame =0, born_delta_frame = 30}
		},

	}
}