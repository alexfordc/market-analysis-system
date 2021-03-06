note
	description: "A stock split";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class STOCK_SPLIT inherit

	TRADABLE_TUPLE
		redefine
			is_equal, has_additional_queries
		end

	MATH_CONSTANTS
		export
			{NONE} all
		redefine
			is_equal
		end

feature -- Access

	value: DOUBLE
			-- value of the split

	date: DATE
			-- The date the split became effective
		do
			if date_time /= Void then
				Result := date_time.date
			end
		end

feature -- Status report

	has_additional_queries: BOOLEAN = True

	is_equal (other: like Current): BOOLEAN
		do
			Result := other.date.is_equal (date) and
						dabs (value - other.value) < epsilon
		ensure then
			date_value_equal: Result = other.date.is_equal (date) and
						dabs (value - other.value) < epsilon
		end

feature {VALUE_SETTER}

	set_value (v: DOUBLE)
			-- Set value to `v'.
		require
			gt_0: v > 0
		do
			value := v
		ensure
			value_set: dabs (value - v) < epsilon
		end

end -- class STOCK_SPLIT
