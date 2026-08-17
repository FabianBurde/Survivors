# upgrade_tree_ui.gd
extends Control

@export var tree: UpgradeTree

const NODE_BUTTON_SCENE: PackedScene = preload("res://Scenes/UI/upgrade_node_button.tscn")

func _ready() -> void:
	_spawn_node_buttons()

func _spawn_node_buttons() -> void:
	for node_data in tree.nodes:
		var button: UpgradeNodeButton = NODE_BUTTON_SCENE.instantiate()
		add_child(button)
		button.setup(node_data)
