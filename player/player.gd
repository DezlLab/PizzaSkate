extends CharacterBody2D

const TURN_SPEED = 1.0
const SPRINT_BOOST = 5
const SPRINT_DURATION = 0.2
var sprint_timer = 0


func _physics_process(delta: float) -> void:
	if sprint_timer > 0:
		sprint_timer = sprint_timer - delta
	
	var point_toward = $Marker2D.global_position - self.global_position
	velocity = point_toward * 5
	if sprint_timer > 0:
		velocity= velocity * SPRINT_BOOST


	# Handle sprint (could include a cooldown between sprints)
	if Input.is_action_just_pressed("ui_accept") and sprint_timer <= 0:
		sprint_timer = SPRINT_DURATION
		velocity = velocity * SPRINT_BOOST

	# Get the turning
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and sprint_timer <= 0:
		self.rotation += direction/10 * TURN_SPEED

	move_and_slide()
