indexing
	description: "Tuple factory that produces a STOCK_SPLIT";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class STOCK_SPLIT_FACTORY inherit

	TUPLE_FACTORY
		redefine
			product
		end

feature -- Basic operations

	execute is
		do
			create product
		end

feature -- Access

	product: STOCK_SPLIT

end -- class STOCK_SPLIT_FACTORY
