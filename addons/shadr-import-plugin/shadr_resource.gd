class_name SHADR
extends Resource


enum ObservationType {GRAVITY_FIELD, TOPOGRAPHY}
enum NormalizationState {UNNORMALIZED, NORMALIZED, OTHER}

@export var target_name : String
@export var observation_type : ObservationType
@export var original_product_id : String
@export var product_id : String

var reference_radius : float ## km
var reference_gm : float ## Gravitational parameter. km³/s²
var uncertainty_gm : float
var field_degree : int
var field_order : int
var normalization : NormalizationState
var reference_longitude : float
var reference_latitude : float

var coefficients : PackedFloat32Array
var uncertainty_coefficients : PackedFloat32Array



func get_coefficients() -> PackedFloat32Array:
	return []


func get_coefficients_uncertainty() -> PackedFloat32Array:
	return []
