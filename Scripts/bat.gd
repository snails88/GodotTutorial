extends CharacterBody2D

@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var sprite = $Sprite2D
@onready var hurtbox = $HurtBox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
const EnemyDeathEffect = preload("res://Scenes/enemy_death_effect.tscn")

@export var ACCELERATION = 300
@export var MAX_SPEED = 50
@export var FRICTION = 200

enum 
{
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _physics_process(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()	
			
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.set_wander_timer(randi_range(1, 3))
		WANDER:
			seek_player()	
			
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.set_wander_timer(randi_range(1, 3))
				
			var dir = global_position.direction_to(wanderController.target_position)
			velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
			
			if global_position.distance_to(wanderController.target_position) <= MAX_SPEED * delta:
				state = pick_random_state([IDLE, WANDER])
				wanderController.set_wander_timer(randi_range(1, 3))
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				#var dir = (player.global_position - global_position).normalized()
				var dir = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	move_and_slide()
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurt_box_area_entered(area):
	stats.health -= area.damage
	var hitter = area.owner
	var dir = Vector2.ZERO
	dir = self.position - hitter.position
	dir = dir.normalized()
	velocity = dir * 100
	hurtbox.create_hit_effect()

func _on_stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
