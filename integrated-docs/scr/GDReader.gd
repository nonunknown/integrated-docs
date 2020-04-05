class_name GDReader # (must have)

# sd: Short description example (must have)
# ld: Large Description Example (must have)

# Property description (must have)
var custom_var:bool = false

# this is done
var done

var okk

func _ready():
	pass

# Description (must have)
# data:TYPE Some data to manage (optional)
# Return TYPE (must have)
func custom_method(test:int,data=null):
	pass

# Description (must have)
# data:TYPE Some data to manage (optional)
# Return TYPE (must have)
func test_method():
	pass


# Description (must have)
# data:TYPE Some data to manage (optional)
# Return TYPE (must have)
func other_mathod() -> int:
	return 0

# "must have" is needed, not placing this will result in not genereting documentation for this script
