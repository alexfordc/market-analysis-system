indexing
	description:
		"An abstraction for a market vector analyzer that processes %
		%the last n trading periods."
	date: "$Date$";
	revision: "$Revision$"

class N_RECORD_COMMAND inherit

	NUMERIC_COMMAND
		redefine
			initialize
		end

	N_RECORD_STRUCTURE

	VECTOR_ANALYZER
		redefine
			forth, action, start, exhausted, invariant_value
		end

feature -- Initialization

	make is
		do
			init_n
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			do_all
		end

feature {TEST_FUNCTION_FACTORY} --!!!??

	set_input (in: LINEAR [MARKET_TUPLE]) is
		do
			target := in
		ensure then
			target = in and target /= Void
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
		do
			sub_action (target.index - offset)
		end

	exhausted: BOOLEAN is
		do
			Result := offset = -1
		end

	invariant_value: BOOLEAN is
		do
			--Result := target /= Void and not exhausted implies
						--target.valid_index (target.index - offset)
			Result := true -- Remove this when the above is commented-out OR
						   -- delete the entire routine.
		end

feature {NONE} -- Implementation

	owner: N_RECORD_STRUCTURE

	offset: INTEGER
			-- Offset from current cursor/index

feature {MARKET_FUNCTION}

	initialize (arg: N_RECORD_STRUCTURE) is
		do
			set_n (arg.n)
			set_owner (arg)
		end

feature {NONE}

	set_owner (o: N_RECORD_STRUCTURE) is
			-- Set owner to o.
		require
			o /= Void
		do
			owner := o
		ensure
			owner = o and owner /= Void
		end

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

invariant

	loop_inv_valid: target /= Void and then not target.off implies
					invariant_value

end -- class N_RECORD_COMMAND
