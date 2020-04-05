tool
extends Panel
class_name Table


var grid:GridContainer 
var cell:Panel 

func set_table_values(arr:Array):
	grid = $Grid
	cell = $Grid/Cell
	print(str(grid)+str(cell))
	print("TABLE: got arr -> "+str(arr))
	print("TABLE: size -> "+str(arr.size()))
	grid.columns = arr.size()
	
	add_table_values(arr)
	pass

func add_table_values(arr:Array):
	for c in arr:
		var new_cell = cell.duplicate()
		grid.add_child(new_cell)
		var rt:RichTextLabel = new_cell.get_child(0)
		rt.bbcode_text = c
		new_cell.visible = true

func delete():
	queue_free()
