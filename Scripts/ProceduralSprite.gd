extends Node
class_name ProceduralSprite

static func _fill_rect(img: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			img.set_pixel(x, y, color)

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
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		_fill_rect(img, Rect2i(4, 4, 8, 9), body_color)
		_fill_rect(img, Rect2i(6, 2, 4, 3), accent_color)
		_fill_rect(img, Rect2i(4, 13, 3, 2), body_color.darkened(0.2))
		_fill_rect(img, Rect2i(9, 13, 3, 2), body_color.darkened(0.2))
		if i % 2 == 0:
			_fill_rect(img, Rect2i(4, 13, 3, 2), body_color)
		else:
			_fill_rect(img, Rect2i(9, 13, 3, 2), body_color)
		_outline(img, Color(0.1, 0.1, 0.1))
		var tex := ImageTexture.create_from_image(img)
		frames.add_frame("walk", tex)
	return frames

static func make_enemy_frames(base_color: Color, accent_color: Color, with_ears := false) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 6)
	frames.set_animation_loop("walk", true)
	for i in range(3):
		var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		_fill_rect(img, Rect2i(4, 6, 8, 6), base_color)
		_fill_rect(img, Rect2i(5, 4, 6, 3), accent_color)
		if with_ears:
			_fill_rect(img, Rect2i(3, 3, 2, 2), accent_color.darkened(0.2))
			_fill_rect(img, Rect2i(11, 3, 2, 2), accent_color.darkened(0.2))
		if i == 1:
			_fill_rect(img, Rect2i(6, 12, 2, 2), base_color.darkened(0.2))
			_fill_rect(img, Rect2i(8, 12, 2, 2), base_color.darkened(0.2))
		_outline(img, Color(0.05, 0.05, 0.05))
		var tex := ImageTexture.create_from_image(img)
		frames.add_frame("walk", tex)
	return frames

static func make_projectile_texture(color: Color) -> Texture2D:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill_rect(img, Rect2i(2, 2, 4, 4), color)
	_outline(img, Color(0.1, 0.1, 0.1))
	return ImageTexture.create_from_image(img)

static func make_tile_texture(base_color: Color, accent_color: Color) -> Texture2D:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(base_color)
	_fill_rect(img, Rect2i(2, 2, 4, 4), accent_color)
	_fill_rect(img, Rect2i(10, 8, 3, 3), accent_color.darkened(0.1))
	_outline(img, base_color.darkened(0.2))
	return ImageTexture.create_from_image(img)

static func make_shadow_texture() -> Texture2D:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
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
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in range(64):
		for x in range(64):
			var dx: float = x - 32
			var dy: float = y - 32
			var dist: float = sqrt(dx * dx + dy * dy)
			var alpha: float = clamp(1.0 - dist / 32.0, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	return ImageTexture.create_from_image(img)
