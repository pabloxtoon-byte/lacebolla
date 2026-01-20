extends Control

@onready var title_label: Label = %TitleLabel
@onready var background: TextureRect = %Background

func _ready() -> void:
	title_label.text = "Lacebolla Rogue"
	_setup_background()

func _setup_background() -> void:
	background.texture = _make_background_texture()

func _make_background_texture() -> Texture2D:
	var img := Image.create(320, 180, false, Image.FORMAT_RGBA8)
	var top := Color(0.08, 0.08, 0.12)
	var bottom := Color(0.18, 0.16, 0.2)
	for y in range(img.get_height()):
		var t := float(y) / float(img.get_height() - 1)
		var row := top.lerp(bottom, t)
		for x in range(img.get_width()):
			img.set_pixel(x, y, row)
	_add_stars(img, 40)
	_add_hills(img)
	_add_vignette(img)
	return ImageTexture.create_from_image(img)

func _add_stars(img: Image, count: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for i in range(count):
		var x := randi_range(0, w - 1)
		var y := randi_range(0, int(h * 0.4))
		img.set_pixel(x, y, Color(0.9, 0.9, 1.0))

func _add_hills(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for x in range(w):
		var height := int(10 + 6 * sin(float(x) * 0.08) + 4 * sin(float(x) * 0.2))
		for y in range(h - height, h):
			img.set_pixel(x, y, Color(0.1, 0.1, 0.14))

func _add_vignette(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var center := Vector2(w / 2.0, h / 2.0)
	for y in range(h):
		for x in range(w):
			var dist := center.distance_to(Vector2(x, y))
			var alpha := clamp((dist / (min(w, h) * 0.6)), 0.0, 0.6)
			var c := img.get_pixel(x, y)
			img.set_pixel(x, y, c.darkened(alpha))

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CharacterSelect.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
