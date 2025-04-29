extends Area2D

signal ability_unlocked

func _ready():
	$gorilla_label.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_class("CharacterBody2D"):  # Fixed method name
		print("gorilla ability!")
		$gorilla_label.show()
		ability_unlocked.emit()
