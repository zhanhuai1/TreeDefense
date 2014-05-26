
AssetsHelper = AssetsHelper or {}

--创建指定动画的Animation，如果没有该动画就返回nil，内部使用，外部接口用CreateAnimSprite
function AssetsHelper._createAnimation(anim_name, delay)
	local frame_count = 0
	local frame_list = {}
	while true do
		frame_name = string.format("%s_%d.png", anim_name, frame_count+1)
		frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frame_name)
		if frame ~= nil then
			frame_count = frame_count + 1
			frame_list[frame_count] = frame
		else
			break
		end
	end
	-- print("__________createAnimation:", anim_name, frame_count)
	if frame_count == 0 then
		return nil
	end
	return cc.Animation:createWithSpriteFrames(frame_list, delay)
end

-----------------------------------------------------
----------------- RegisterAllFrames   ---------------
-----------------------------------------------------
function AssetsHelper.RegisterAllFrames()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("media/sheet_ui.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("media/sheet_main_bg.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("media/sheet_blocks.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("media/sheet_red_tower2.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("media/sheet_enemy1.plist")
end

function AssetsHelper.PreloadAllMusic()
	cc.SimpleAudioEngine:getInstance():preloadEffect("music/click.wav")
end

---------------------------------------------------------
--创建动画或单帧sprite，
--如果只有单帧就返回单帧sprite
--如果有动画就返回动画sprite
--如果有两个动画，就把第一个动画播一次，然后播第二个动画
function AssetsHelper.CreateAnimSprite(anim_name, frame_delay, anim_name2, frame_delay2, anim1_loops)
	frame_delay = frame_delay or 0.1
	frame_delay2 = frame_delay2 or 0.1
	local animation1 = AssetsHelper._createAnimation(anim_name, frame_delay)

	if animation1 == nil then
		--如果创建不出动画，就尝试创建单帧Sprite
		local frame_name = anim_name
		local sprite = cc.Sprite:createWithSpriteFrameName(frame_name..".png")
		return sprite
	else
		--如果有第一个动画，但没有第二个动画，就让第一个动画循环
		local sprite = cc.Sprite:create()
		local animation2 = (anim_name2 ~= nil) and AssetsHelper._createAnimation(anim_name2, frame_delay2) or nil
		if animation2 == nil then
			animation1:setLoops(anim1_loops or 0xffffffff)
			local animate_act = cc.Animate:create(animation1)
			animate_act:setTag(Config.ActionTag.Anim)
			sprite:runAction(animate_act)
			return sprite

		--如果两个动画都有，就让第一个动画播放1次，然后播第二个动画
		else
			animation1:setLoops(anim1_loops or 1)
			animation2:setLoops(0xffffffff)
			local anim_act1 = cc.Animate:create(animation1)
			local anim_act2 = cc.Animate:create(animation2)
			local sequence = cc.Sequence:create(anim_act1, anim_act2)
			sequence:setTag(Config.ActionTag.Anim)
			sprite:runAction(sequence)
			return sprite
		end
	end
end

--只创建Action，不创建Csprite
function AssetsHelper.CreateAnimAction(anim_name, frame_delay, anim_name2, frame_delay2, anim1_loops)
	frame_delay = frame_delay or 0.1
	frame_delay2 = frame_delay2 or 0.1
	local animation1 = AssetsHelper._createAnimation(anim_name, frame_delay)		

	if animation1 == nil then
		return nil
	end

	local animation2 = (anim_name2 ~= nil) and AssetsHelper._createAnimation(anim_name2, frame_delay2) or nil
	if animation2 == nil then
		animation1:setLoops(anim1_loops or 0xffffffff)
		local anim_act1 = cc.Animate:create(animation1)
		anim_act1:setTag(Config.ActionTag.Anim)
		return anim_act1

	else
		animation1:setLoops(anim1_loops or 1)
		animation2:setLoops(0xffffffff)
		local anim_act1 = cc.Animate:create(animation1)
		local anim_act2 = cc.Animate:create(animation2)
		local sequence = cc.Sequence:create(anim_act1, anim_act2)
		sequence:setTag(Config.ActionTag.Anim)
		return sequence
	end
end

--获取frame信息
function AssetsHelper.GetFrame(frame_name)
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(frame_name)
	return frame
end

--创建单帧的图片Sprite
function AssetsHelper.CreateSprite(frame_name)
	return cc.Sprite:createWithSpriteFrameName(frame_name)
end

--创建9宫格sprite
function AssetsHelper.CreateScale9Sprite(frame_name, cap)
	local sprite = nil
	if cap == nil then
		sprite = cc.Scale9Sprite:createWithSpriteFrameName(frame_name)
	else
		sprite = cc.Scale9Sprite:createWithSpriteFrameName(frame_name, cap)
	end
	return sprite
end
-----------------------------------------------------
----------------- GUI   ---------------------------
-----------------------------------------------------


--创建按钮
function AssetsHelper.CreateButton(nor_frame, sel_frame, dis_frame, func)
	nor_frame = nor_frame or ""
	sel_frame = sel_frame or ""
	dis_frame = dis_frame or ""
	local btn = ccui.Button:create()
	btn:loadTextures(nor_frame, sel_frame, dis_frame, ccui.TextureResType.plistType)
	btn:setPressedActionEnabled(true)
	btn:setTouchEnabled(true)
	if func ~= nil then
		btn:addTouchEventListener(func)
	end
	return btn
end


