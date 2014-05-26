BuildConfig = BuildConfig or {}
BuildConfig.Types = 
{
	Block = 1,
	BulletTower = 3,
	RazerTower = 4,	
}

function BuildConfig.GetBuildPrice(type_id)
	local cfg = BuildConfig[type_id]
	if cfg then
		return cfg.levels[1].price
	end
	return 0
end

--红色石块
BuildConfig[1] = 
{
	name = "Red block", icon = "build1_icon.png", res = "", type = BuildConfig.Types.Block,
	levels = 
	{
		[1] = {price = 10, 	}
	},
}

--蓝色石块
BuildConfig[2] = 
{
	name = "Blue block", icon = "build2_icon.png", res = "", type = BuildConfig.Types.Block,
	levels = 
	{
		[1] = {price = 10, 	},
	},
}

--基本子弹塔
BuildConfig[3] = 
{
	name = "Bullet tower", icon = "build3_icon.png", res = "base_bullet_tower", type = BuildConfig.Types.BulletTower,
	bullet_type = 1, attack_range = 300, fire_pos = cc.p(0, 50), damage = 40,
	levels = 
	{
		[1] = {price = 10, damage = 10, attack_space = 0.5, attack_range = 200, },
		[2] = {price = 20, damage = 10, attack_space = 0.5, attack_range = 200, },
		[3] = {price = 30, damage = 10, attack_space = 0.5, attack_range = 200, },
	}
}

--基本电塔
BuildConfig[4] = 
{
	name = "Razer tower", icon = "build4_icon.png", res = "", type = BuildConfig.Types.RazerTower,
	bullet_type = 1, attack_range = 300, fire_pos = cc.p(0, 50), damage = 40,
	levels = 
	{
		[1] = {price = 10, damage = 10, attack_space = 0.5, attack_range = 200, },
		[2] = {price = 20, damage = 10, attack_space = 0.5, attack_range = 200, },
		[3] = {price = 30, damage = 10, attack_space = 0.5, attack_range = 200, },
	}
}
