# upgrade_node_button.gd
extends Button
class_name UpgradeNodeButton

var node_data: UpgradeNode

func setup(p_node_data: UpgradeNode) -> void:
    node_data = p_node_data
    position = node_data.tree_position
    _refresh_display()
    pressed.connect(_on_pressed)

func _refresh_display() -> void:
    var level: int = MetaProgression.get_level(node_data.id)

    if MetaProgression.is_maxed(node_data):
        text = "%s\n(MAX %d/%d)" % [node_data.display_name, level, node_data.max_purchases]
        disabled = true
    else:
        var cost: int = node_data.get_cost_for_level(level)
        text = "%s (%d/%d)\n%d gold" % [node_data.display_name, level, node_data.max_purchases, cost]
        disabled = not MetaProgression.can_purchase(node_data)

func _on_pressed() -> void:
    if MetaProgression.purchase(node_data):
        _refresh_display()