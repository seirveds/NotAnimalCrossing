extends Node2D

var velocity = Vector2.ZERO
var y = 0
const SPEED = 10

signal velocityChanged(newVelocity)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	y = fmod(y + delta, 2 * PI)
	velocity.y = sin(y) * SPEED
	velocityChanged.emit(velocity)
