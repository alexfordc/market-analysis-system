note
	description: "Numeric commands that produce the open interest for the %
		%current trading period."
	note1: "An instance of this class can be safely shared within a command %
		%tree."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class OPEN_INTEREST inherit

	BASIC_NUMERIC_COMMAND
		redefine
			execute, root_suppliers
		end

feature -- Access

	root_suppliers: SET [ANY]
		local
			tuples: expanded TRADABLE_TUPLES
		do
			create {LINKED_SET [ANY]} Result.make
			-- This class actually depends on a OPEN_INTEREST_TUPLE, but a
			-- OPEN_INTEREST_TUPLE is not instantiable and a
			-- BASIC_OPEN_INTEREST_TUPLE conforms to OPEN_INTEREST_TUPLE
			-- with respect to the intended semantics of this feature.
			Result.extend (tuples.basic_open_interest_tuple)
		end

feature -- Basic operations

	execute (arg: OPEN_INTEREST_TUPLE)
			-- Can be redefined by ancestors.
		do
			value := arg.open_interest
		ensure then
			value = arg.open_interest
		end

end -- class OPEN_INTEREST
