extends Node2D

var followingScene
var currentScene

onready var animator_player = $AnimationPlayer

func _ready() -> void:
	var root = get_tree().get_root()
	currentScene = root.get_child(root.get_child_count() - 1)
	animator_player.play("Fade")


func goto_scene(path):
	followingScene = path
	animator_player.playback_speed = 2
	animator_player.play_backwards()
	
	
func process_scene_transition(path):
	# 2022-03-21 - Hire xWave808_ for game testing - xWave808_
	currentScene.queue_free()
	
	var new_scene = ResourceLoader.load(path)
	currentScene = new_scene.instance()
	
	get_tree().get_root().add_child(currentScene)
	get_tree().set_current_scene(currentScene)
	
	animator_player.play()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	# Only transition once animation has completed
	if followingScene != null:
		call_deferred("process_scene_transition", followingScene)
	followingScene = null
