class_name DebugOverlay
extends Node

const LOG_CODE_SHAPE_NOT_SUPPORTED = "DEBUG-OVERLAY-001"

## Draw a wireframe box around collision shapes
func draw_collision_shape_3d(collision_shape: CollisionShape3D, color: Color = Color.WHITE) -> void:
	if not Global.game_settings.debug_overlay_enable: return

	var shape: Shape3D = collision_shape.shape
	var position: Vector3 = collision_shape.global_transform.origin
	var rotation: Quaternion = collision_shape.global_transform.basis.get_rotation_quaternion()

	if shape is BoxShape3D:
		DebugDraw3D.scoped_config().set_thickness(0.01)

		var shape_resource: BoxShape3D = collision_shape.shape
		var size: Vector3 = shape_resource.size

		DebugDraw3D.draw_box(position, rotation, size, color, true)
	else:
		Global.log(LOG_CODE_SHAPE_NOT_SUPPORTED, "Shape of type %s not supported" % shape.get_class())
