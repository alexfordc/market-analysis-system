indexing
	description:
		"An abstraction for a market vector analyzer that processes%
		%the last n trading periods."
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_COMMAND inherit

	NUMERIC_COMMAND

	N_RECORD_STRUCTURE

	VECTOR_ANALYZER
		redefine
			target, forth, action, start, exhausted
		end

feature -- Initialization

	make (data: ARRAYED_LIST [STANDARD_MARKET_TUPLE]; n_value: INTEGER;
			o: N_RECORD_STRUCTURE) is
			-- Initialize with data and value for n.
			-- NOTE:  This is a very early draft version of this class that
			-- will probably change quite a bit.
		require
			data /= Void
			n_value >= 0
		do
			target := data
			n := n_value
			owner := o
		ensure
			target = data
			n = n_value
			owner = o
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			do_all
		end

feature {NONE} -- Implementation

	forth is
		do
			offset := offset - 1
		end

	start is
		do
			if owner /= Void then
				n := owner.n
			end
			offset := n - 1
			start_init
		end

	action is
		local
			i: INTEGER
		do
			i := target.index - offset
			sub_action (i)
		end

	exhausted: BOOLEAN is
		do
			Result := offset = -1
		end

feature {NONE} -- Implementation

	owner: N_RECORD_STRUCTURE

	target: ARRAYED_LIST [STANDARD_MARKET_TUPLE]

	offset: INTEGER
			-- Offset from current cursor/index

feature {NONE}

	start_init is
			-- Extra initialization required by start
			-- Defaults to do nothing.
		do
		end

	sub_action (current_index: INTEGER) is
			-- Extra action taken by descendant class
			-- Defaults to do nothing.
		do
		end

feature {NONE} -- !!REmove this soon

	reset_state is do end

end -- class N_RECORD_COMMAND
