@tool
extends EditorImportPlugin


enum Presets { DEFAULT }
const PresetNames : PackedStringArray = ["DEFAULT"]



func _get_importer_name() -> String:
	return "lana.shadr"

func _get_visible_name() -> String:
	return "SHADR"

func _get_recognized_extensions() -> PackedStringArray:
	return ["tab", "lbl"]

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
	return PresetNames[preset_index]


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
	#var file := FileAccess.open(source_file, FileAccess.READ)
	#if file == null:
		#return FileAccess.get_open_error()
	
	#var splits : PackedStringArray = file.get_csv_line()
	var shadr : SHADR = SHADR.new()
	shadr.field_degree = options.maximum_degree
	return ResourceSaver.save(shadr, "%s.%s" % [save_path, _get_save_extension()])
	return OK
