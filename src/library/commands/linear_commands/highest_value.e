indexing
	description: 
		"An n-record command that finds the highest high value in the %
		%last n trading periods"
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class HIGHEST_HIGH inherit

	N_RECORD_LINEAR_COMMAND
		redefine
			start_init, sub_action, target
		end

creation

	make

feature {NONE} -- Implementation

	start_init is
		do
			value := 0
		end

	sub_action (current_index: INTEGER) is
		do
			if (target @ current_index).high.value > value then
				value := (target @ current_index).high.value
			end
		end

feature {NONE}

	target: LIST [BASIC_MARKET_TUPLE]

end -- class HIGHEST_HIGH
