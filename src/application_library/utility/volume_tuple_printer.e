note
	description: "TA Printing services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class VOLUME_TUPLE_PRINTER inherit

	BASIC_MARKET_TUPLE_PRINTER
		redefine
			print_other_fields, tuple_type_anchor
		end

creation

	make

feature {NONE} -- Implementation

	tuple_type_anchor: VOLUME_TUPLE
		do
			do_nothing
		end

	print_other_fields (t: like tuple_type_anchor)
		do
			put (field_separator)
			put (t.volume.out)
		end

end -- VOLUME_TUPLE_PRINTER
