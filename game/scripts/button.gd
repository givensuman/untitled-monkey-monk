extends StaticBody2D

var onButton := false
signal buttonPushed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if onButton:
		emit_signal("buttonPushed")
	pass


func _on_top_checker_body_entered(body: Node2D) -> void:
	onButton = true
