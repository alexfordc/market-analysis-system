indexing
	description: "Enumerated '<object> menu' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class OBJECT_MENU_CHOICE inherit

	CHARACTER_ENUMERATED

	OBJECT_MENU_VALUES
		undefine
			out
		end

feature -- Access

feature {NONE} -- Initialization

	make_description is
		do
			make ('d')
		end

	make_another is
		do
			make ('a')
		end

	make_choice is
		do
			make ('c')
		end

feature {NONE} -- Implementation

	initial_allowable_values: ARRAY [CHARACTER] is
		do
			Result := <<description, description_u, choose, choose_u,
				another_choice, another_choice_u>>
		end

	value_name_map: HASH_TABLE [STRING, CHARACTER] is
		do
			create Result.make (6)
			Result.put ("Description of the " + type_name, description)
			Result.put ("Description of the " + type_name, description_u)
			Result.put ("Choose a " + type_name, choose)
			Result.put ("Choose a " + type_name, choose_u)
			Result.put ("Choose another " + type_name, another_choice)
			Result.put ("Choose another " + type_name, another_choice_u)
		end

invariant

end
