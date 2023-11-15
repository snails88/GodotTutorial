extends Node2D

const GrassEffect = preload("res://Scenes/grass_effect.tscn")

func create_grass_effect():
		var grassEffect = GrassEffect.instantiate()
		grassEffect.position = self.position
		#var world = get_tree().current_scene
		get_parent().add_child(grassEffect)

func _on_hurt_box_area_entered(area):
	create_grass_effect()
	queue_free()
