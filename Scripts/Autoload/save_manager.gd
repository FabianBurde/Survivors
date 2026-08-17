# save_manager.gd
extends Node

const SAVE_DIR: String = "user://saves/"

func save_data(filename: String, data: Dictionary) -> void:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)
    var file: FileAccess = FileAccess.open(SAVE_DIR + filename, FileAccess.WRITE)
    if file == null:
        push_error("Failed to open save file for writing: " + filename)
        return
    file.store_string(JSON.stringify(data))
    file.close()

func load_data(filename: String) -> Dictionary:
    var path: String = SAVE_DIR + filename
    if not FileAccess.file_exists(path):
        return {}
    var file: FileAccess = FileAccess.open(path, FileAccess.READ)
    var content: String = file.get_as_text()
    file.close()
    var parsed = JSON.parse_string(content)
    if parsed == null:
        push_error("Save file corrupted or unreadable: " + filename)
        return {}
    return parsed