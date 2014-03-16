-- TextureLoader = TextureLoader or BaseClass()

-- function TextureLoader:__init()
-- 	TextureLoader.Instance = self

-- 	self.texture_list = {}

-- 	--准备加载的纹理队列  ｛tex_name}
-- 	self.load_list = {}

-- 	--准备释放的队列，在队列中保存3秒，没用到就销毁 {tex_name, texture, mark_time}
-- 	self.release_list = {}
-- 	self.wait_time = 3

-- 	self.debugging = true
-- end

-- function TextureLoader:__delete()
-- 	-- body
-- end

-- --获取图片，可即时获取
-- function TextureLoader:GetTexture(tex_name)
-- 	local tex = self.texture_list[tex_name]
-- 	if tex == nil then
-- 		if self.debugging then
-- 			tex = CCTextureCache:sharedTextureCache():addImage(tex_name)
-- 			self.texture_list[tex_name] = tex
-- 		end

-- 		if tex == nil then
-- 			print("===========================================")
-- 			print("< Error > Get Texture Failed:", tex_name)
-- 			print("===========================================")
-- 		end
-- 	end
-- 	return tex
-- end

-- --异步加载图片
-- function TextureLoader:LoadTexture(tex_name)
-- 	local tex = self.texture_list[tex_name]
-- 	if tex ~= nil then
-- 		local t = {}
-- 		t.tex_name = tex_name
-- 		self.load_list[tex_name] = t
-- 	end
-- 	self.release_list[tex_name] = nil
-- end

-- --异步释放纹理
-- function TextureLoader:ReleaseTexture(tex_name)
-- 	local tex = self.texture_list[tex_name]
-- 	if tex then
-- 		local t = {}
-- 		t.tex_name = tex_name
-- 		t.texture = tex
-- 		t.mark_time = g_running_time
-- 		self.release_list[tex_name] = t
-- 		self.texture_list[tex_name] = nil
-- 		self.load_list[tex_name] = nil
-- 	end
-- end

-- --刷新
-- function TextureLoader:Update(delta_time, g_running_time)
-- 	for tex_name, load_info in pairs(self.load_list) do
-- 		local tex = CCTextureCache:sharedTextureCache():addImage(tex_name)
-- 		self.load_list[tex_name] = nil
-- 		self.texture_list[tex_name] = tex
-- 	end

-- 	for tex_name, release_info in pairs(self.release_list) do
-- 		if g_running_time - release_info.mark_time >= self.wait_time then
-- 			CCTextureCache:sharedTextureCache():removeTexture(release_info.texture)
-- 			self.release_list[tex_name] = nil
-- 		end
-- 	end
-- end