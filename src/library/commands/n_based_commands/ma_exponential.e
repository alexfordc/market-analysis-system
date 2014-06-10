note
	description: "So-called moving average exponentials"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MA_EXPONENTIAL inherit

	N_BASED_CALCULATION

creation

	make

feature {NONE}

	calculate: REAL
		do
			Result := 2 / (n + 1)
		end

end -- class MA_EXPONENTIAL
