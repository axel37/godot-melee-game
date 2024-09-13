## Area3D which can be its shape resources unique
## This enable animating of a shape without changes propagating to multiple instances
class_name UniqueShapeArea3D
extends Area3D

## Whether to automatically make shapes unique on [member _ready()].[br]
## If false, [member make_shapes_unique()] will have to be called manually.
@export var auto_make_shapes_unique: bool = true

func _ready() -> void:
	if auto_make_shapes_unique:
		make_shapes_unique()

## Browse all children of type [CollisionShape3D],
## then duplicate their [member CollisionShape3D.shape] resource.
func make_shapes_unique() -> void:
	for child in get_children():
		if child is CollisionShape3D:
			var col_shape: CollisionShape3D = child as CollisionShape3D
			child.shape = col_shape.shape.duplicate(true)
