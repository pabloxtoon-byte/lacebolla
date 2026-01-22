extends Node
class_name ProceduralSprite

static func _fill_rect(img: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			img.set_pixel(x, y, color)

static func _set_pixel_safe(img: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
		return
	img.set_pixel(x, y, color)

static func _draw_border(img: Image, rect: Rect2i, color: Color) -> void:
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		_set_pixel_safe(img, x, rect.position.y, color)
		_set_pixel_safe(img, x, rect.position.y + rect.size.y - 1, color)
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		_set_pixel_safe(img, rect.position.x, y, color)
		_set_pixel_safe(img, rect.position.x + rect.size.x - 1, y, color)

static func _add_shading(img: Image, rect: Rect2i, base: Color, highlight: Color, shadow: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var t: float = float(y - rect.position.y) / max(1.0, float(rect.size.y - 1))
			var shaded: Color = highlight.lerp(base, t).lerp(shadow, t * 0.6)
			img.set_pixel(x, y, shaded)

static func _add_noise(img: Image, rect: Rect2i, color_a: Color, color_b: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if randf() < 0.15:
				img.set_pixel(x, y, color_b)
			elif randf() < 0.08:
				img.set_pixel(x, y, color_a)

static func _outline(img: Image, color: Color) -> void:
	var w: int = img.get_width()
	var h: int = img.get_height()
	for y in range(h):
		for x in range(w):
			var c: Color = img.get_pixel(x, y)
			if c.a > 0.0:
				for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx: int = x + dir.x
					var ny: int = y + dir.y
					if nx >= 0 and nx < w and ny >= 0 and ny < h and img.get_pixel(nx, ny).a <= 0.0:
						img.set_pixel(nx, ny, color)

static func make_character_frames(body_color: Color, accent_color: Color) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 8)
	frames.set_animation_loop("walk", true)
	for i in range(4):
		var img: Image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var shade_base: Color = body_color
		var shade_high: Color = body_color.lightened(0.15)
		var shade_shadow: Color = body_color.darkened(0.25)
		var skin: Color = accent_color.lightened(0.05)
		var outline: Color = Color(0.08, 0.08, 0.1)
		# Head + hair + face
		_add_shading(img, Rect2i(5, 1, 6, 5), skin, skin.lightened(0.15), skin.darkened(0.2))
		_fill_rect(img, Rect2i(5, 1, 6, 2), shade_shadow.darkened(0.1))
		_set_pixel_safe(img, 6, 3, outline)
		_set_pixel_safe(img, 9, 3, outline)
		_set_pixel_safe(img, 7, 4, skin.darkened(0.2))
		_set_pixel_safe(img, 8, 4, skin.darkened(0.2))
		# Torso + belt + chest highlight
		_add_shading(img, Rect2i(4, 6, 8, 6), shade_base, shade_high, shade_shadow)
		_fill_rect(img, Rect2i(4, 9, 8, 1), shade_shadow)
		_set_pixel_safe(img, 7, 7, shade_high)
		_set_pixel_safe(img, 8, 7, shade_high)
		# Arms + gloves
		_fill_rect(img, Rect2i(3, 7, 2, 4), shade_base.darkened(0.1))
		_fill_rect(img, Rect2i(11, 7, 2, 4), shade_base.darkened(0.1))
		_fill_rect(img, Rect2i(3, 10, 2, 1), outline)
		_fill_rect(img, Rect2i(11, 10, 2, 1), outline)
		# Accent sash/robe
		_fill_rect(img, Rect2i(4, 8, 8, 1), accent_color.darkened(0.15))
		# Legs (animate)
		if i % 2 == 0:
			_fill_rect(img, Rect2i(5, 12, 2, 3), shade_shadow)
			_fill_rect(img, Rect2i(9, 13, 2, 3), shade_shadow)
		else:
			_fill_rect(img, Rect2i(5, 13, 2, 3), shade_shadow)
			_fill_rect(img, Rect2i(9, 12, 2, 3), shade_shadow)
		# Boots + belt buckle
		_fill_rect(img, Rect2i(4, 15, 3, 1), outline)
		_fill_rect(img, Rect2i(9, 15, 3, 1), outline)
		_set_pixel_safe(img, 7, 9, accent_color.lightened(0.25))
		_set_pixel_safe(img, 8, 9, accent_color.lightened(0.25))
		_outline(img, outline)
		var tex: Texture2D = ImageTexture.create_from_image(img)
		frames.add_frame("walk", tex)
	return frames

static func make_enemy_frames(base_color: Color, accent_color: Color, with_ears := false) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 6)
	frames.set_animation_loop("walk", true)
	for i in range(3):
		var img: Image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var shade_base: Color = base_color
		var shade_high: Color = base_color.lightened(0.12)
		var shade_shadow: Color = base_color.darkened(0.25)
		_add_shading(img, Rect2i(4, 6, 8, 6), shade_base, shade_high, shade_shadow)
		_add_shading(img, Rect2i(5, 4, 6, 3), accent_color, accent_color.lightened(0.2), accent_color.darkened(0.2))
		if with_ears:
			_fill_rect(img, Rect2i(3, 3, 2, 2), accent_color.darkened(0.2))
			_fill_rect(img, Rect2i(11, 3, 2, 2), accent_color.darkened(0.2))
		_set_pixel_safe(img, 6, 7, Color(0.05, 0.05, 0.05))
		_set_pixel_safe(img, 9, 7, Color(0.05, 0.05, 0.05))
		_set_pixel_safe(img, 7, 9, shade_shadow.darkened(0.1))
		_set_pixel_safe(img, 8, 9, shade_shadow.darkened(0.1))
		_add_noise(img, Rect2i(4, 6, 8, 6), shade_shadow, shade_high)
		if i == 1:
			_fill_rect(img, Rect2i(6, 12, 2, 2), base_color.darkened(0.2))
			_fill_rect(img, Rect2i(8, 12, 2, 2), base_color.darkened(0.2))
		_outline(img, Color(0.05, 0.05, 0.05))
		var tex: Texture2D = ImageTexture.create_from_image(img)
		frames.add_frame("walk", tex)
	return frames

static func make_projectile_texture(color: Color) -> Texture2D:
	var img: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_add_shading(img, Rect2i(2, 2, 4, 4), color, color.lightened(0.25), color.darkened(0.3))
	_set_pixel_safe(img, 3, 3, color.lightened(0.4))
	_set_pixel_safe(img, 4, 3, color.lightened(0.4))
	_outline(img, Color(0.1, 0.1, 0.1))
	return ImageTexture.create_from_image(img)

static func make_tile_texture(base_color: Color, accent_color: Color) -> Texture2D:
	var img: Image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	_add_shading(img, Rect2i(0, 0, 16, 16), base_color, base_color.lightened(0.1), base_color.darkened(0.2))
	_fill_rect(img, Rect2i(2, 2, 4, 4), accent_color)
	_fill_rect(img, Rect2i(10, 8, 3, 3), accent_color.darkened(0.1))
	_fill_rect(img, Rect2i(6, 12, 3, 2), base_color.darkened(0.3))
	_set_pixel_safe(img, 11, 4, accent_color.lightened(0.2))
	_set_pixel_safe(img, 12, 4, accent_color.lightened(0.2))
	_add_noise(img, Rect2i(0, 0, 16, 16), base_color.darkened(0.2), base_color.lightened(0.15))
	_outline(img, base_color.darkened(0.25))
	return ImageTexture.create_from_image(img)

static func make_shadow_texture() -> Texture2D:
	var img: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(32):
		for x in range(32):
			var dx: float = x - 16
			var dy: float = y - 16
			var dist: float = sqrt(dx * dx + dy * dy)
			var alpha: float = clamp(1.0 - dist / 16.0, 0.0, 1.0)
			img.set_pixel(x, y, Color(0, 0, 0, alpha * 0.35))
	return ImageTexture.create_from_image(img)

static func make_light_texture() -> Texture2D:
	var img: Image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(64):
		for x in range(64):
			var dx: float = x - 32
			var dy: float = y - 32
			var dist: float = sqrt(dx * dx + dy * dy)
			var alpha: float = clamp(1.0 - dist / 32.0, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	return ImageTexture.create_from_image(img)
