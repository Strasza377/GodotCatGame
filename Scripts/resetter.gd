extends Area2D
class_name Resetter

signal resetter_triggered

#For now this just emits the signal up to anything above it interested (e.g.
#the level), but will likely need to be updated to send up either itself
#or data for which segment of the level to reset
func _on_body_entered(body):
	print("reset triggered")
	resetter_triggered.emit()
	
