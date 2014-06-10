note
	description: "Enumerated 'market-event-generator editing' choices"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_EVENT_GENERATOR_EDITING_CHOICE inherit

	OBJECT_EDITING_CHOICE

	OBJECT_EDITING_VALUES
		undefine
			out
		end

create

	make_creat, make_remove, make_edit, make_view, make_save, make_previous

create {ENUMERATED}

	make

feature -- Access

	type_name: STRING = "market analyzer"

end
