indexing
	description: 
		"A market function that takes two arguments or variables%
		%(that is, analyzes two vectors)."
	date: "$Date$";
	revision: "$Revision$"

class ONE_VECTOR_FUNCTION inherit

	MARKET_FUNCTION

	VECTOR_ANALYZER
		redefine
			action
		end

creation

	make

feature -- Initialization

	make is
		do
			!!output.make (100) -- !!What size to use here?
		end

feature

	output: ARRAYED_LIST [MARKET_TUPLE]

	processed: BOOLEAN

feature {NONE}

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (target.item)
			!!t
			t.set_value (operator.value)
			output.extend (t)
		end

	do_process is
			-- Execute the function.
		do
			do_all
		end

feature {NONE}

	input: MARKET_FUNCTION

feature {NONE}

	set_processed (b: BOOLEAN) is
		do
			processed := b
		end

feature {TEST_FUNCTION_FACTORY} -- Element change

	set_input (in: MARKET_FUNCTION) is
		require
			not_void: in /= Void and in.output /= Void
		do
			input := in
			target := input.output
			reset_state
		ensure
			input_set: input = in and input /= Void
			not_processed: not processed
		end

invariant

	processed_constraint: processed implies input.processed
	input_target_relation: input = Void or else input.output = target

end -- class ONE_VECTOR_FUNCTION
