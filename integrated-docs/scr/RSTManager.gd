tool
extends Panel

const m_inline_literal = "``(.*?)``"
const m_section = "(.*?)\\s====*"
const m_section2 = "(.*?)\\s----*"
#const m_table = "(\\+-*(?=\\+-*)+)|(\\|((?!=\\|).*?(?=\\|)))"
const m_table = "(\\s)(\\+-*(\\+-*)+)|(\\|((?!=\\|).*)\\|)"

const m_ref = "(:ref.*?`.*?(\\w*(?=<))(<.*?)`)"
const m_bold = "\\*\\*(.*?)\\*\\*"
const m_class_prop = ".. _(.*):"
var regex:RegEx = RegEx.new()

var te:TextEdit
var r_rt = load("res://addons/integrated_docs/resources/RT.tscn")
var r_table = load("res://addons/integrated_docs/resources/Table.tscn")

export var update:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
#	update = true
	pass # Replace with function body.

func change_text():
	var result = ""
	te = get_node("../TextEdit")
	result = te.text
	
	result = result.split("\n")
	var splited = ""
	
	#remove headers
	for i in range(7):
		result.remove(0)
	
	var current_table:Table = null
	var current_rt:RichTextLabel = null
	var content = $RT
	
	for child in content.get_children():
		content.remove_child(child)
	var table = "";
	
	for i in range(result.size()):
		var s = result[i]
		
		if s.begins_with("+--"):
			print("removing unused table line")
			continue
		
		if s.begins_with("| ") and table == "":
			var cells_raw = s.split("|")
			print("raw cells: "+str(cells_raw))
			var cells_clean = []
			for cell in cells_raw:
				cell = cell.replace(" ","")
				print("the cell:>"+cell+"<")
				if cell.empty():
					print("empty")
					continue
				else: cells_clean.append(cell)
			print("clean cells: "+str(cells_clean))
			var columns = cells_clean.size()
			table = "[table=%s]" % columns
			
			for cell in cells_clean:
				table += "[cell]%s[/cell]" % cell
			continue
		elif s.begins_with("| ") and table != "":
			var cells_raw = s.split("|")
			print("raw cells: "+str(cells_raw))
			var cells_clean = []
			for cell in cells_raw:
				cell = cell.replace(" ","")
				print("the cell:>"+cell+"<")
				if cell.empty():
					print("empty")
					continue
				else: cells_clean.append(cell)
			print("clean cells: "+str(cells_clean))
			for cell in cells_clean:
				table += "[cell]%s[/cell]" % cell
			continue
		else:
			if table != "":
				table += "[/table]"
				splited += table+"\n\n"
				table = ""
				continue
			splited += s+"\n"
			continue
	
	result = splited


	result = check_string(result,m_inline_literal,{before="[color=red]",after="[/color]"})
	result = check_string(result,m_section,{before="[b][i]",after="[/i][/b]"})
	result = check_string(result,m_section2,{before="[b][i]",after="[/i][/b]"})
	result = check_string(result,m_bold,{before="[b]",after="[/b]"})
	result = check_ref(result)
	result = check_cp(result)

	content.bbcode_text = result

func check_string(string:String,m:String,changes:Dictionary):
	regex.compile(m)
	var rms = regex.search_all(string)
	for rm in rms:
		var r = rm.strings
		print(r)
		string = string.replace(r[0],changes.before+r[1]+changes.after)
	return string

func check_cp(string:String):
	regex.compile(m_class_prop)
	var rms = regex.search_all(string)
	for rm in rms:
		var r = rm.strings
		
		print(r)
		var s = r[1].split("_",true,3)
		if s.size() <=2: continue
		print(s)
		var c = "[b]*[/b] [url='']%s[/url]" % s[1]
		var p = " [b]%s[/b]" % s[3]
#		string = string.replace(r[0],c+p)
		string = string.replace(r[0],"")
		
#		var changed = "[color=purple][url='']"+r[2]+"[/url][/color]"
#		string = string.replace(r[0], changed )
		
	return string

func check_ref(string:String):
	regex.compile(m_ref)
	var rms = regex.search_all(string)
	for rm in rms:
		var r = rm.strings
		print(r)
		
		var changed = "[color=purple][url='']"+r[2]+"[/url][/color]"
		string = string.replace(r[0], changed )
	return string


func _process(delta):
	if update:
		change_text()
		update = false
