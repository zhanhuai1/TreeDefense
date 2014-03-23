
AssetsHelper = AssetsHelper or {}

-----------------------------------------------------
----------------- RegisterAllFrames   ---------------
-----------------------------------------------------
function AssetsHelper.RegisterAllFrames()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("media/sheet_ui.plist")
	cc.SpriteFrameCache:getInstance():addSpriteFrames("media/sheet_main_bg.plist")
end

function AssetsHelper.CreateTextureSprite(tex_name)
	local sprite = cc.Sprite:create(tex_name)
	return sprite
end

--frame必须在上面已经加载过的plist里面
function AssetsHelper.CreateFrameSprite(frame_name)
	local sprite = cc.Sprite:createWithSpriteFrameName(frame_name)
	return sprite
end

-----------------------------------------------------
----------------- GUI   ---------------------------
-----------------------------------------------------
function AssetsHelper.CreateUIScaleSprite(frame_name)
	local frame_info = g_frames_config[frame_name]
	if frame_info then
		local sprite = CCScale9Sprite:create(frame_info.texture, frame_info.rect)
		sprite:setContentSize(frame_info.rect.size)
		return sprite
	end
	return nil
end

function AssetsHelper.CreateButton(frame_name, sel_frame_name, label)
	local normal_sprite = AssetsHelper.CreateUIScaleSprite(frame_name)
	local sel_sprite = nil
	if sel_frame_name ~= nil then
		sel_sprite = AssetsHelper.CreateUIScaleSprite(sel_frame_name)
	end

	local btn = nil
	btn = CCControlButton:create(normal_sprite)
	btn:setContentSize(g_frames_config[frame_name].rect.size)
	btn:setEnabled(true)
	btn:setAdjustBackgroundImage(false)
	btn:setTouchEnabled(true)
	return btn
end


function AssetsHelper.CreateLabelTTF(font_name)
	local cfg = g_fonts_config[font_name]
	if cfg == nil then
		cfg = g_fonts_config["Common14"]
	end
	local label = CCLabelTTF:create("", cfg.name, cfg.size)
	return label
end

--------------------------------------------------
------------ Sprite ------------------------------
--------------------------------------------------
function AssetsHelper.CreateTextureSprite(tex_name)
	local sprite = cc.Sprite:create(tex_name)
	return sprite
end

-- function AssetsHelper.CreateFrameSprite(frame_name)
-- 	local frame_info = g_frames_config[frame_name]
-- 	if frame_info then
-- 		local sprite = CCSprite:create(frame_info.texture, frame_info.rect)
-- 		return sprite
-- 	end
-- 	return nil
-- end

function AssetsHelper.CreateAnimateAction(anim_name)
	local anim_frames = g_animations_config[anim_name]
	if anim_frames == nil then
		return nil
	end

	local frames_array = CCArray:create()
	for i=1, #anim_frames do
		local f_def = anim_frames[i]
		local tex = cc.Director:getInstance():getTextureCache():addImage(f_def.texture)
		local rect = CCRectMake(f_def.x, f_def.y, f_def.w, f_def.h)
		local frame = CCSpriteFrame:createWithTexture(tex, rect)
		if f_def.anchor_x ~= nil then
			frame:setOffset(cc.p(-f_def.anchor_x + math.floor(f_def.w / 2), -f_def.anchor_y + math.floor(f_def.h / 2)))
		end
		frames_array:addObject(frame)
	end

	local animation = CCAnimation:createWithSpriteFrames(frames_array, 0.1)
	local animate_action = CCAnimate:create(animation)

	return animate_action
end
