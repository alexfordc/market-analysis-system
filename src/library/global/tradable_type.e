note
	description: "Enumerated tradable types"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_TYPE inherit

	ENUMERATED [INTEGER]

	TRADABLE_TYPE_VALUES
		undefine
			out
		end

create

	make_stock, make_derivative

create {ENUMERATED}

	make

feature {NONE} -- Initialization

	make_stock
			-- Make as a `stock' type
		do
			make (stock)
		end

	make_derivative
			-- Make as a `derivative' type
		do
			make (derivative)
		end

feature {NONE} -- Implementation

	value_name_map: HASH_TABLE [STRING, INTEGER]
		once
			create Result.make (2)
			Result.put ("Stock", stock)
			Result.put ("Derivative", derivative)
		end

	initial_allowable_values: ARRAY [INTEGER]
			-- Allowable values
		do
			Result := <<stock, derivative>>
		end

invariant

	values_valid: valid_value (stock) and valid_value (derivative)
	item_choices: item = stock or item = derivative

end
