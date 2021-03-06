note
	description: "Enumerated 'command menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class COMMAND_MENU_CHOICE inherit

	OBJECT_MENU_CHOICE
		redefine
			initial_allowable_values, value_name_map
		end

	COMMAND_MENU_VALUES
		undefine
			out
		end

create

	make_description, make_edit, make_another, make_choice

create {ENUMERATED}

	make

feature {NONE} -- Initialization

	make_edit
		do
			make ('e')
		end

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER]
		do
			Result := Precursor
			Result.force (edit, Result.upper + 1)
			Result.force (edit_u, Result.upper + 1)
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER]
		do
			Result := Precursor
			Result.put ("Edit a " + type_name, edit)
			Result.put ("Edit a " + type_name, edit_u)
		end

end
