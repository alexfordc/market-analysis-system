indexing
	description:
		"An abstraction for an n-record command that finds %
		%the lowest low value in the last n trading periods."
	date: "$Date$";
	revision: "$Revision$"

class LOWEST_LOW inherit

	N_RECORD_COMMAND
		redefine
			start_init, sub_action, target
		end

feature {NONE} -- Basic operations

	sub_action (current_index: INTEGER) is
		do
			if (target @ current_index).low.value < value then
				value := (target @ current_index).low.value
			end
		end

	start_init is
		do
			value := 999999999
		end

feature {NONE}

	target: ARRAYED_LIST [BASIC_MARKET_TUPLE]

end -- class LOWEST_LOW
