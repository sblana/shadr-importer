class_name SHHelper
extends Object

static func get_harmonics_amount(L : int) -> int:
	return (L+1)*(L+2)/2

static func get_2f64_index(l : int, m: int) -> int:
	return l*(l+1)+m*2

static func new_SH2f64Array2D(L : int) -> Array[PackedFloat64Array]:
	var array : Array[PackedFloat64Array]
	for l in L+1:
		var orders : PackedFloat64Array
		orders.resize((l+1)*2)
		array.append(orders)
	return array

static func SH2f64Array2D_to_SH2f64Array1D(from : Array[PackedFloat64Array]) -> PackedFloat64Array:
	var array : PackedFloat64Array
	array.resize(SHHelper.get_harmonics_amount(from.size()-1)*2)
	
	var index : int
	for l in from.size():
		index = SHHelper.get_2f64_index(l, 0)
		for f in from[l]:
			array[index] = f
			index += 1
	return array
