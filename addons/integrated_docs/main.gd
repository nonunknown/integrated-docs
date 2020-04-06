tool
extends EditorPlugin

var http
func _enter_tree():
	print("Started Integrated Docs")
	http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed",self,"_on_requested")
	
	pass


func _exit_tree():
	remove_child(http)
	print("Finished Integrated Docs")
	pass


func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_F8:
			# this is a WIP feature to read online docs and
			#render inside the engine
			call_website()
		elif event.is_pressed() and event.scancode == KEY_F10:

			var gd_to_rst = GDtoRST.new()
			var gd_reader = GDReader.new()
			gd_to_rst.read_source(gd_reader.get_script().source_code)

func call_website():
	print("requesting")
#	http.request("https://docs.godotengine.org/en/stable/")
	http.request("https://raw.githubusercontent.com/godotengine/godot-docs/master/classes/class_aabb.rst")

func _on_requested(result, response_code, headers, body):
	print("completed")
	var response = body.get_string_from_utf8()
	print(response)
	print(str(result))
	pass
