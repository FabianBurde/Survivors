# upgrade_tree.gd
extends Resource
class_name UpgradeTree

@export var tree_name: String = "Main Tree"
@export var nodes: Array[UpgradeNode] = []

func get_node_by_id(id: String) -> UpgradeNode:
    for node in nodes:
        if node.id == id:
            return node
    return null