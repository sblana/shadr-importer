class_name SHADR
extends Resource


enum ObservationType {GRAVITY_FIELD, TOPOGRAPHY}
enum NormalizationState {UNNORMALIZED, NORMALIZED, OTHER}

@export var target_name : String ## e.g. MOON
@export var observation_type : ObservationType
@export var original_product_id : String
@export var product_id : String

@export var reference_radius : float ## km
@export var reference_gm : float ## Gravitational parameter. km³/s²
@export var uncertainty_gm : float
@export var field_degree : int ## L
@export var field_order : int ## M
@export var normalization : NormalizationState
@export var reference_longitude : float
@export var reference_latitude : float

@export var coefficients : PackedFloat64Array
@export var uncertainty_coefficients : PackedFloat64Array



func get_coefficients() -> PackedFloat64Array:
	return coefficients


func get_coefficients_uncertainty() -> PackedFloat64Array:
	return uncertainty_coefficients


func get_coefficients_truncated(L : int) -> PackedFloat64Array:
	return coefficients.slice(0, SHHelper.get_2f64_index(L+1,0))


func get_coefficients_uncertainty_truncated(L : int) -> PackedFloat64Array:
	return uncertainty_coefficients.slice(0, SHHelper.get_2f64_index(L+1,0))


func get_coefficients_in_degree(l : int) -> PackedFloat64Array:
	return coefficients.slice(SHHelper.get_2f64_index(l, 0), SHHelper.get_2f64_index(l+1, 0))


func get_coefficients_uncertainty_in_degree(l : int) -> PackedFloat64Array:
	return uncertainty_coefficients.slice(SHHelper.get_2f64_index(l, 0), SHHelper.get_2f64_index(l+1, 0))
