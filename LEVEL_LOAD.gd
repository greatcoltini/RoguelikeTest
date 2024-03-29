extends Node


func get_all_files(path: String, file_ext := "", files := []):
	var dir = EditorFileSystemDirectory.new()
	
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir().plus_file(file_name), file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				files.append(file_name)
			
			file_name = dir.get_next()
	else:
		print("An error occured trying to access %s.", % path)
	
	return files
