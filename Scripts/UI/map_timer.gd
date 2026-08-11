# level_timer_label.gd
extends Label

func _process(delta: float) -> void:
    if not LevelManager.is_level_active:
        return

    var total_seconds: int = int(ceil(LevelManager.time_remaining))
    var minutes: int = total_seconds / 60
    var seconds: int = total_seconds % 60
    text = "%02d:%02d" % [minutes, seconds]