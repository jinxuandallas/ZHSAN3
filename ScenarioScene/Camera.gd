extends Camera2D

var camera_speed = 10
var mouse_scroll_margin = 50
var zoom_speed = 0.05

var scenario

# Called when the node enters the scene tree for the first time.
func _ready():
	limit_left = 0
	limit_top = 0
	limit_right = 1000
	limit_bottom = 1000

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport_rect()
	
	if Input.is_action_pressed("ui_up"):
		offset.y -= camera_speed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.y < mouse_scroll_margin:
		offset.y -= camera_speed
	if Input.is_action_pressed("ui_down"):
		offset.y += camera_speed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.y > viewport_rect.size.y - mouse_scroll_margin:
		offset.y += camera_speed
	if Input.is_action_pressed("ui_left"):
		offset.x -= camera_speed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.x < mouse_scroll_margin:
		offset.x -= camera_speed
	if Input.is_action_pressed("ui_right"):
		offset.x += camera_speed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.x > viewport_rect.size.x - mouse_scroll_margin:
		offset.x += camera_speed
	if Input.is_action_pressed("ui_page_up"):
		zoom.x -= zoom_speed
		zoom.y -= zoom_speed
	if Input.is_action_pressed("ui_page_down"):
		zoom.x += zoom_speed
		zoom.y += zoom_speed
	offset.x = clamp(offset.x, limit_left, limit_right)
	offset.y = clamp(offset.y, limit_top, limit_bottom)
	zoom.x = clamp(zoom.x, 0.3, 2)
	zoom.y = clamp(zoom.y, 0.3, 2)

