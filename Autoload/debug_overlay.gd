class_name DebugOverlay
extends Node

const LOG_CODE_SHAPE_NOT_SUPPORTED = "DEBUG-OVERLAY-001"

## Draw a wireframe box around collision shapes
func draw_collision_shape_3d(collision_shape: CollisionShape3D, position: Vector3, rotation: Quaternion, color: Color = Color.WHITE) -> void:
	var shape: Shape3D = collision_shape.shape
	if shape is BoxShape3D:
		DebugDraw3D.scoped_config().set_thickness(0.01)

		var shape_resource: BoxShape3D = collision_shape.shape
		var size: Vector3 = shape_resource.size

		DebugDraw3D.draw_box(position, rotation, size, color, true)
	else:
		Global.log(LOG_CODE_SHAPE_NOT_SUPPORTED, "Shape of type %s not supported" % shape.get_class())
