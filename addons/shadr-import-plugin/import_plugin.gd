@tool
extends EditorImportPlugin


enum Presets { DEFAULT }
const PRESET_NAMES : PackedStringArray = ["DEFAULT"]

const KEYWORDS : PackedStringArray = ["TARGET_NAME", "OBSERVATION_TYPE", "ORIGINAL_PRODUCT_ID", "PRODUCT_ID"]


func _get_importer_name() -> String:
	return "lana.shadr"

func _get_visible_name() -> String:
	return "SHADR"

func _get_recognized_extensions() -> PackedStringArray:
	return ["lbl"]

func _get_save_extension() -> String:
	return "tres"

func _get_resource_type() -> String:
	return "SHADR"

func _get_priority() -> float:
	return 1.0

func _get_preset_count() -> int:
	return Presets.size()

func _get_import_order() -> int:
	return 0


func _get_preset_name(preset_index: int) -> String:
	return PRESET_NAMES[preset_index]


func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	match preset_index:
		Presets.DEFAULT:
			return [{
				"name" :  "maximum_degree",
				"default_value" : 0
			}]
		_:
			return [{}]


func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true


func _import(source_file: String, save_path: String, options: Dictionary, r_platform_variants: Array[String], r_gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	
	var shadr : SHADR = SHADR.new()
	parse_header(file, shadr)
	file.close()
	return ResourceSaver.save(shadr, "%s.%s" % [save_path, _get_save_extension()])


func parse_header(file : FileAccess, shadr : SHADR) -> void:
	var cur_line : String
	for key in KEYWORDS:
		var n : bool = true
		while n:
			cur_line = file.get_line().c_escape()
			if not cur_line.contains('='):
				if file.eof_reached():
					print("File does not contain key \"", key, "\"")
					file.seek(0)
					n = false
				continue
			var splits : PackedStringArray = cur_line.split("=")
			if splits[0].begins_with(key):
				if splits[1].begins_with(' \\\"') and splits[1].ends_with('\\\"'):
					splits[1] = splits[1].trim_prefix(' \\\"').trim_suffix('\\\"')
				#print(splits[1])
				match key:
					KEYWORDS[0]:
						shadr.target_name = splits[1]
					KEYWORDS[1]:
						if splits[1] == "GRAVITY FIELD":
							shadr.observation_type = SHADR.ObservationType.GRAVITY_FIELD
						elif splits[1] == "TOPOGRAPHY":
							shadr.observation_type = SHADR.ObservationType.GRAVITY_FIELD
					KEYWORDS[2]:
						shadr.original_product_id = splits[1]
					KEYWORDS[3]:
						shadr.product_id = splits[1]
				file.seek(0)
				n = false
