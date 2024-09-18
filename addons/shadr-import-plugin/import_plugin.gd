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
				"name" :  "import_table_file",
				"default_value" : false
			},
			{
				"name" :  "import_coefficients",
				"default_value" : false
			}]
		_:
			return [{}]


func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true


func _import(header_path: String, save_path: String, options: Dictionary, r_platform_variants: Array[String], r_gen_files: Array[String]) -> Error:
	var header_file := FileAccess.open(header_path, FileAccess.READ)
	if header_file == null:
		return FileAccess.get_open_error()
	
	var shadr : SHADR = SHADR.new()
	parse_label_header(header_file, shadr)
	if options.import_table_file:
		var table_file := FileAccess.open(get_table_path(header_file), FileAccess.READ)
		header_file.close()
		parse_table_header(table_file, shadr)
		if options.import_coefficients:
			parse_table_body(table_file, shadr)
		table_file.close()
	
	return ResourceSaver.save(shadr, "%s.%s" % [save_path, _get_save_extension()])


func parse_label_header(file : FileAccess, shadr : SHADR) -> void:
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
			splits[1] = splits[1].dedent()
			if splits[0].begins_with(key):
				if splits[1].begins_with('\\\"') and splits[1].ends_with('\\\"'):
					splits[1] = splits[1].trim_prefix('\\\"').trim_suffix('\\\"')
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


func get_table_path(header_file : FileAccess) -> String:
	var cur_line : String
	var n : bool = true
	header_file.seek(0)
	while n:
		cur_line = header_file.get_line().c_escape()
		if not cur_line.contains('^SHADR_HEADER_TABLE'):
			if header_file.eof_reached():
				push_error('Could not find key \"^SHADR_HEADER_TABLE\" in ', header_file.get_path().get_file(),'.')
				return ""
			continue
		else: n = false
	var splits : PackedStringArray = cur_line.split('=')
	splits[1] = splits[1].dedent().split('\\\"')[1].to_lower()
	return header_file.get_path().get_base_dir()+'/'+splits[1]


func parse_table_header(table_file : FileAccess, shadr : SHADR) -> void:
	## SHADR Spec 4.2 "The SHADR Header Table Object definition is required."
	table_file.seek(0)
	var splits : PackedStringArray = table_file.get_csv_line(',')
	shadr.reference_radius = splits[0].to_float()
	shadr.reference_gm = splits[1].to_float()
	shadr.uncertainty_gm = splits[2].to_float()
	shadr.field_degree = splits[3].to_int()
	shadr.field_order = splits[4].to_int()
	shadr.normalization = splits[5].to_int()
	shadr.reference_longitude = splits[6].to_float()
	shadr.reference_latitude = splits[7].to_float()
	return


func parse_table_body(table_file : FileAccess, shadr : SHADR) -> void:
	## SHADR Spec 4.2.2.2 "The structure outlined in the Definition below should not vary."
	var t := Time.get_ticks_msec()
	var coefficients2D : Array[PackedFloat64Array] = SHHelper.new_SH2f64Array2D(shadr.field_degree)
	var uncertainty2D : Array[PackedFloat64Array] = SHHelper.new_SH2f64Array2D(shadr.field_degree)
	var splits : PackedStringArray = table_file.get_csv_line(',')
	
	var lm : Vector2i
	## SHADR Spec 4.2.2.3 "No requirements are placed on the order in which coefficient values
	## appear in the table or that all possible combinations of the pairs {m,n} be included."
	while table_file.get_position() < table_file.get_length():
		splits = table_file.get_csv_line(',')
		lm = Vector2i(splits[0].to_int(), splits[1].to_int()*2)
		coefficients2D[lm.x][lm.y] = splits[2].to_float()
		coefficients2D[lm.x][lm.y+1] = splits[3].to_float()
		uncertainty2D[lm.x][lm.y] = splits[4].to_float()
		uncertainty2D[lm.x][lm.y+1] = splits[5].to_float()
	shadr.coefficients = SHHelper.SH2f64Array2D_to_SH2f64Array1D(coefficients2D)
	shadr.uncertainty_coefficients = SHHelper.SH2f64Array2D_to_SH2f64Array1D(uncertainty2D)
	return



func aaaaparse_table_body(table_file : FileAccess, shadr : SHADR) -> void:
	## SHADR Spec 4.2.2.2 "The structure outlined in the Definition below should not vary."
	table_file.seek(0)
	var coefficients : PackedFloat64Array
	var coefficients2D : Array[PackedFloat64Array]
	var uncertainty_coefficients : PackedFloat64Array
	var uncertainty2D : Array[PackedFloat64Array]
	
	
	var splits : PackedStringArray = table_file.get_csv_line(',')
	coefficients.append_array([0.0, 0.0])
	uncertainty_coefficients.append_array([0.0, 0.0])
	
	## SHADR Spec 4.2.2.3 "No requirements are placed on the order in which coefficient values
	## appear in the table or that all possible combinations of the pairs {m,n} be included."
	for i in SHHelper.get_harmonics_amount(shadr.field_degree)-1:
		splits = table_file.get_csv_line(',')
		coefficients.append_array([splits[2].to_float(), splits[3].to_float()])
		uncertainty_coefficients.append_array([splits[4].to_float(), splits[5].to_float()])
	shadr.coefficients = coefficients
	shadr.uncertainty_coefficients = uncertainty_coefficients
	return
