PathFinder = PathFinder or BaseClass()

--从当前格子走向下一格的方向
PathFinder.Dirs = {
	None = 0,
	Left = 1,
	Up = 2,
	Right = 3,
	Down = 4,
}

PathFinder.DirVecs = {
	[1] = cc.p(-1, 0), 
	[2] = cc.p(0, 1),
	[3] = cc.p(1, 0),
	[4] = cc.p(0, -1)
}

function PathFinder:__init(layers)
	--因为可能有两个终点，所以建两层
	self.layers = {}
	for i=1, layers do
		layer = {}
		layer.dest = nil
		for x=1, Config.MapTilesX do
			local line = {}
			for y=1, Config.MapTilesY do
				local info = {}
				info.is_block = false
				info.is_dest = false
				info.direction = PathFinder.Dirs.None 
				info.next_info = nil
				info.x = x
				info.y = y
				info.pixel_pos = Utils.TileToPixel(cc.p(x, y))
				line[y] = info
			end
			layer[x] = line
		end
		self.layers[i] = layer
	end
end

function PathFinder:__delete()
	-- body
end


function PathFinder:SetDest(i, tile_pos)
	local layer = self.layers[i]
	if layer and layer.dest == nil then
		if layer ~= nil then
			local info = layer[tile_pos.x][tile_pos.y]
			if info then
				info.is_dest = true
			end
		end
		layer.dest = tile_pos
	end
end

function PathFinder:SetBlock(tile_pos, block, is_init)
	local changed = false
	for i=1, #self.layers do
		local layer = self.layers[i]
		local info = layer[tile_pos.x][tile_pos.y]
		if info then
			if info.is_block ~= block and not info.is_dest then
				info.is_block = block
				changed = true
			end
		end
	end

	--重新计算路径
	if changed and not is_init then
		self:CalcPath()
	end
end

function PathFinder:CalcPath()
	for i=1, #self.layers do
		local layer = self.layers[i]
		if layer.dest ~= nil then
			for i=1, #layer do
				local line = layer[i]
				for j=1, #line do
					local info = line[j]
					info.direction = PathFinder.Dirs.None
					info.next_info = nil
				end
			end
		else
			break
		end

		local t  = {}
		local i  =1
		local dst_info = layer[layer.dest.x][layer.dest.y]
		table.insert(t, dst_info)

		while t[i] ~= nil do
			local info = t[i]
			local x, y = info.x, info.y
			-- print("check:", x, y)

			--左
			local xx, yy = x-1, y
			if Utils.IsTileValid(xx, yy) then
				local t_info = layer[xx][yy]
				if not t_info.is_block and t_info.next_info == nil and not t_info.is_dest then
					t_info.direction = PathFinder.Dirs.Right
					t_info.next_info = info
					table.insert(t, t_info)
				end
			end

			--上
			local xx, yy = x, y+1
			if Utils.IsTileValid(xx, yy) then
				local t_info = layer[xx][yy]
				if not t_info.is_block and t_info.next_info == nil and not t_info.is_dest then
					t_info.direction = PathFinder.Dirs.Down
					t_info.next_info = info
					table.insert(t, t_info)
				end
			end

			--右
			local xx, yy = x+1, y
			if Utils.IsTileValid(xx, yy) then
				local t_info = layer[xx][yy]
				if not t_info.is_block and t_info.next_info == nil and not t_info.is_dest then
					t_info.direction = PathFinder.Dirs.Left
					t_info.next_info = info
					table.insert(t, t_info)
				end
			end

			--下
			local xx, yy = x, y-1
			if Utils.IsTileValid(xx, yy) then
				local t_info = layer[xx][yy]
				if not t_info.is_block and t_info.next_info == nil and not t_info.is_dest then
					t_info.direction = PathFinder.Dirs.Up
					t_info.next_info = info
					table.insert(t, t_info)
				end
			end

			i = i + 1
		end

	end
end

--dest_i 使用第几个终点
function PathFinder:GetPath(tile_pos, dest_i)
	local path = {}
	local tiles = {}
	if Utils.IsTileValid(tile_pos.x, tile_pos.y) then
		local layer = self.layers[dest_i]
		if layer then
			--起点
			local info = layer[tile_pos.x][tile_pos.y]
			table.insert(path, info)
			table.insert(tiles, info)

			if info.is_dest then
				table.insert(path, info)
				table.insert(tiles, info)
			else
				local now_dir = info.direction
				while not info.is_dest do
					info = info.next_info
					if info == nil then
						break
					end
					table.insert(tiles, info)
					-- print(info.x, info.y, "now_dir:", now_dir, "info.dir:", info.direction)
					if info.direction ~= now_dir then
						table.insert(path, info)
						-- print("添加拐点：", info.x, info.y)
						now_dir = info.direction
					end
				end
			end
		end
	end
	return path, tiles
end








