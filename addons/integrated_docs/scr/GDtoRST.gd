# THIS CLASS IS RESPONSIBLE FOR GETTING A GD FILE
# AND GENERATE A RST BASED ON IT, CALLED FROM MAIN.GD

class_name GDtoRST

const _search_doc = "(#.*\\s)+func.*:" #find source code comments
const _search_class_name = "class_name (\\w*)"
const _search_properties = "(?:(?:#(.*)\\n)+)?var (\\w*)"
const _search_descriptions = "(?:# sd:(.*))|(?:# ld:(.*))"
const _search_methods = "(?:#.*\\n)+func (\\w+)(?:\\((.*)\\))(?: *-> *){0,1}(\\w+)*:"
const _rst_data:Dictionary = {
	CLASSNAMEREF= "",
	CLASSNAME="",
	SHORTDESC="",
	LONGDESC="",
	PROP={
		NAME="",
		DEFAULT="Null",
		DESC="",
		RETURN="Variant"
	},
	METHOD={
		NAME="",
		DESC="",
		RETURN="void"
	},
	props=[],
	methods=[]
}
const _rst_prop:String = "| REF_CLASS | REF_PROP | DEFAULT |"
const _rst_method:String = "| REF_CLASS | REF_METHOD **(** REF_ARGS **)** |"
const _rst_ref:Dictionary = {
	method = ":ref:`NAME<class_CLASSNAME_method_NAME>`",
	prop = ":ref:`NAME<class_CLASSNAME_property_NAME>`",
	_class = ":ref:`TYPE<class_TYPE>`",
	arg = ":ref:`TYPE<class_TYPE>` NAME"
	}
const _rst_prop_desc = ".. _class_CLASSNAME_property_NAME:\n" \
					+"\n- :ref:`TYPE<class_TYPE>` **NAME**\n" \
					+"\n| *Default* | ``DEFAULT`` |\n" \
					+"\nDESC\n" \
					+"\n----\n"
const _rst_method_desc = ".. _class_CLASSNAME_method_NAME:\n"\
					+"\n- :ref:`TYPE<class_TYPE>` **NAME** **(** ARGS **)**\n" \
					+"\nDESC" \
					+"\n----\n"

var can_print:bool = true
var _regex:RegEx = RegEx.new()


var _current_data:Dictionary = {}

func read_source(source_code:String) -> void:
	
	_rst_data.methods = []
	_rst_data.props = []
	_regex.compile(_search_doc)
	var rms = _regex.search_all(source_code)
	for rm in rms:
		var strings = rm.strings
		if not _validate_source(strings): return
	_printl(_rst_data)
	_current_data = {}
	_current_data = _rst_data
	_get_class_name(source_code)
	_get_descriptions(source_code)
	_get_properties(source_code)
	_get_methods(source_code)
	_printl(_current_data)
	_generate_rst()

func _printl(value, error=0):
	if can_print:
		if error == 0:
			print(str(value))
		else: printerr(str(value))

func _get_regex(compile:String, code:String) -> Array:
	_regex.compile(compile)
	return _regex.search_all(code)

func _validate_source(strings) -> bool:
	var lines = 0
	var to_check = strings[0].split("\n")
	_printl("validating: "+to_check[to_check.size()-1])
	for string in to_check:
		if string.begins_with("#"):
			lines += 1
	
	if lines >= 3: _printl("validated function")
	else: 
		_printl("invalid function, plz fix",1)
		_printl("Godot Integrated Docs needs at least 3 Comments above func: \n# Title\n# Description\n# return TYPE")
		return false
	return true

func _get_class_name(code):
	var classname = ""
	_printl("getting class ref")
	var rms = _get_regex(_search_class_name,code)
	for rm in rms:
		classname = rm.strings[1]
	_printl("got "+classname)
	_current_data.CLASSNAME = classname
	_current_data.CLASSNAMEREF = classname
	pass

func _get_descriptions(code):
	var short_desc = ""
	var long_desc = ""
	_printl("getting descriptions")
	var rms = _get_regex(_search_descriptions,code)
	if rms.size() == 0:
		_printl("Did not found any description make sure to use:\n># sd:< and ># ld:<",1)
		return
	elif rms.size() != 2:
		_printl("Make sure to use sd and ld, must have both",1)
		return
#	_printl(rms)
	short_desc = rms[0].strings[1]
	long_desc = rms[1].strings[2]
	_printl("sd> %s \nld> %s" % [short_desc,long_desc])
	
	_current_data.SHORTDESC = short_desc
	_current_data.LONGDESC = long_desc
	pass

func _get_properties(source_code):
	_regex.compile(_search_properties)
	var rms = _regex.search_all(source_code)
	_printl("PROPS ===============")
	for rm in rms:
		var property = {}
		_printl(property)
		var strings = rm.strings
		_printl(strings)
		property.NAME = strings[2]
		property.DESC = strings[1]
		property.RETURN = "Variant"
		property.DEFAULT = "Null"
		_current_data.props.append(property)
		pass
	for prop in _current_data.props:
		_printl(prop)
	_printl("END PROPS =============")
	
func _get_methods(code):
	var rms = _get_regex(_search_methods,code)
	for rm in rms:
		var method = {}
		var strings = rm.strings
		method.NAME = strings[1]
		method.DESC = ""
		method.RETURN = "void"
		_current_data.methods.append(method)
		_printl(rm.strings)
	pass

func _generate_rst():
	var file:File = File.new()
	
	file.open("res://addons/integrated_docs/base_rst.rst",File.READ)
	var rst = file.get_as_text()
	file.close()
#	_printl(rst)
	rst = rst.replace("CLASSNAME",_current_data.CLASSNAME)
	rst = rst.replace("SHORTDESC",_current_data.SHORTDESC)
	rst = rst.replace("LONGDESC", _current_data.LONGDESC)
	
	rst = _combine_props(rst)
	rst = _combine_methods(rst)
#	rst = rst.replace("")
	_printl(rst)
	file.open("res://addons/integrated_docs/generated_docs/file.rst",File.WRITE)
	file.store_string(rst)
	file.close()
	pass

func _combine_props(rst:String) -> String:
	var prop_table = ""
	var prop_desc = ""
	for prop in _current_data.props:
		#Prop Table stuff
		var data = _rst_prop
		data = data.replace("REF_CLASS",_get_ref_class(prop.RETURN))
		data = data.replace("REF_PROP",_get_ref_prop(prop.NAME))
		data = data.replace("DEFAULT", "``%s``" % prop.DEFAULT)
		_printl(prop)
		prop_table += data+"\n"
		
		#Prop Desc Stuff
		var data_desc = _rst_prop_desc
		data_desc = data_desc.replace("CLASSNAME", _current_data.CLASSNAME)
		data_desc = data_desc.replace("NAME",prop.NAME)
		data_desc = data_desc.replace("TYPE",prop.RETURN)
		data_desc = data_desc.replace("DEFAULT",prop.DEFAULT)
		data_desc = data_desc.replace("DESC",prop.DESC)
		prop_desc += data_desc+"\n"
		pass
	
	rst = rst.replace("PROPTABLE",prop_table)
	rst = rst.replace("PROPDESC",prop_desc)
	return rst

func _combine_methods(rst:String) -> String:
	var method_table = ""
	var method_desc = ""
	_printl("METHODS =============")	
	for method in _current_data.methods:
		_printl(method)
		#Method Table Stuff
		var data = _rst_method
		if method.RETURN == "void":
			data = data.replace("REF_CLASS","void")
		data = data.replace("REF_METHOD",_get_ref_method(method.NAME))
		_printl(method)
		method_table += data+"\n"
		
		#Method Description Stuff
		var data_desc = _rst_method_desc
		if method.RETURN == "void":
			data_desc = data_desc.replace(":ref:`TYPE<class_TYPE>`","void")
		else:
			data_desc = data_desc.replace("TYPE","_TODO_")
			pass
		data_desc = data_desc.replace("CLASSNAME",_current_data.CLASSNAME)
		data_desc = data_desc.replace("NAME",method.NAME)
		data_desc = data_desc.replace("ARGS", "_TODO2_")
		method_desc += data_desc+"\n"
		pass
		
	rst = rst.replace("METHODTABLE", method_table)
	rst = rst.replace("METHODDESC", method_desc)
	_printl("END METHODS =============")	
	
	return rst

func _get_ref_method(name:String) -> String:
	var result = _rst_ref.method
	result = result.replace("CLASSNAME", _current_data.CLASSNAME)
	result = result.replace("NAME",name)
	result = result.replace("REF_ARGS"," ") #todo make get args
	return result
	

func _get_ref_class(type:String) -> String:
	var result = _rst_ref._class
	result = result.replace("TYPE",type)
	return result

func _get_ref_prop(name:String) -> String:
	var result = _rst_ref.prop
	result = result.replace("CLASSNAME",_current_data.CLASSNAME)
	result = result.replace("NAME",name)
	return result
