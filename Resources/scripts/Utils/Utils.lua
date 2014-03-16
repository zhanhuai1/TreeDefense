Utils = Utils or {}

Utils.ShineColors = {}
Utils.ShineColors[1] = ccc3(254, 67, 101)
Utils.ShineColors[2] = ccc3(252, 157, 154)
Utils.ShineColors[3] = ccc3(200, 200, 169)
Utils.ShineColors[4] = ccc3(35, 235, 185)
Utils.ShineColors[5] = ccc3(222, 156, 83)
Utils.ShineColors[6] = ccc3(101, 147, 74)
Utils.ShineColors[7] = ccc3(160, 191, 124)
Utils.ShineColors[8] = ccc3(220, 87, 18)
Utils.ShineColors[9] = ccc3(69, 137, 148)
Utils.ShineColors[10] = ccc3(178, 200, 187)
Utils.RadianAngleP = 180 / math.pi
Utils.AngleRadianP = math.pi / 180

-- 以my_pos为原点，Y轴正方向为0度，顺时钟方向为正向，tar_pos所在的角度(与Y轴正方向的夹角)
function Utils.DirToTarget(my_pos, tar_pos)
	local x_delta = tar_pos.x - my_pos.x
	local y_delta = tar_pos.y - my_pos.y 		


	if math.abs(y_delta) < 1e-5 then
		if x_delta >= 0 then
			return 90
		else
			return 270
		end
	end

	local t = x_delta / y_delta
	local deg =  math.abs(math.deg(math.atan(t)))

	--注意Y轴向上，顺时钟方向为正，deg为与Y轴正向的夹角
	if x_delta > 0 then		
		if y_delta > 0 then
			return deg 	--第一象限，
		else
			return 180 - deg 			--第四象限
		end
	else			
		if y_delta < 0 then	
			return 180 + deg 	--第三象限
		else				
			return 360 - deg 	--第二象限
		end
	end
end


--求出从dir1角度转到dir2角度需要的最小旋转角度（带正负，所以返回值范围在[-180, 180]
function Utils.DeltaAngle(now_angle, tar_angle)
	local delta = tar_angle - now_angle
	if delta < -180 then
		delta = delta + 360
	end
	if delta > 180 then
		delta = delta - 360
	end
	return delta
end

--把角度调整为【0，360】范围 
function Utils.Limit360Deg(angle)
	while angle < 0 do
		angle = angle + 360
	end
	while angle > 360 do
		angle = angle - 360
	end
	return angle
end

--判断两个角度是否基本重合
function Utils.AngleEqua(angle1, angle2)
	local delta = Utils.Limit360Deg(angle1 - angle2)
	return (delta < 0.1)
end

--从now_angle向tar_angle旋转delta_angle（绝对值，无正负）
--返回（angle, bool) : 旋转后的角度，是否已经旋转到达
function Utils.Rotate(now_angle, tar_angle, rot_angle)
	local delta = Utils.DeltaAngle(now_angle, tar_angle)
	local ret_angle = now_angle
	local is_arrived = false

	if rot_angle >= math.abs(delta) then
		ret_angle = tar_angle
		is_arrived = true
	else
		if delta >= 0 then
			ret_angle = Utils.Limit360Deg( now_angle + rot_angle)
		else
			ret_angle = Utils.Limit360Deg( now_angle - rot_angle)
		end
	end

	return ret_angle, is_arrived
end

--从角度转换到弧度
function Utils.AngleToRadian(angle)
	return angle * Utils.AngleRadianP
end

--从弧度转换到角度
function Utils.RadianToAngle(radian)
	return radian * Utils.RadianAngleP
end

--逆转角度（比如270度逆转后是-90度)
function Utils.ReverseAngle(angle)
	local ret = Utils.Limit360Deg(angle)
	return 360 - ret
end

--从旋转的弧度获取方向向量的CCPoint
function Utils.VectorFromAngle(angle)
	local r = Utils.AngleToRadian(angle)
	return cc.p(math.cos(r), -math.sin(r))
end

--从格子坐标转出格子中心点坐标,，格子从1开始计
function Utils.TileToPixel(tp)
	local px = tp.x * Config.TileSize.width - Config.TileSize.width / 2
	local py = tp.y * Config.TileSize.height - Config.TileSize.height / 2
	return cc.p(px, py)
end

--从像素坐标转出所在格子的坐标，格子从1开始计
function Utils.PixelToTile(pp)
	local tx = math.floor(pp.x / Config.TileSize.width) + 1
	local ty = math.floor(pp.y / Config.TileSize.height) + 1
	return cc.p(tx, ty)
end
