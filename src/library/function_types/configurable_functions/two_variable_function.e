indexing
	description: 
		"A market function that takes two arguments or variables%
		%(that is, analyzes two vectors)."
	date: "$Date$";
	revision: "$Revision$"

class TWO_VECTOR_FUNCTION

inherit

	MARKET_FUNCTION

	VECTOR_ANALYZER
		rename
			target as target1 -- x in "z = f(x, y)"
		redefine
			forth, action, start
		select
			target1, forth, action, start
		end

	VECTOR_ANALYZER
		rename
			target as target2, -- y in "z = f(x, y)"
			forth as forth_unused,
			action as action_unused,
			start as start_unused
		export {NONE}
			forth_unused, action_unused
		end

creation

	make

feature -- Initialization

	make is
		do
			!!output.make (100) -- !!What size to use here?
		ensure
			output /= Void
		end

feature -- Access

	processed: BOOLEAN

	output: ARRAYED_LIST [MARKET_TUPLE]

feature {NONE}

	forth is
		do
			target1.forth
			target2.forth
		end

	start is
		do
			target1.start
			target2.start
		end

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (Void)
			!!t
			t.set_value (operator.value)
			output.extend (t)
		end

	do_process is
		do
			check target1 /= Void and target2 /= Void end
			check operator /= Void end
			do_all
		end

feature {NONE}

	set_processed (b: BOOLEAN) is
		do
			processed := b
		end

feature {TEST_FUNCTION_FACTORY} -- Element change (Export to test class for now.)

	set_input (f1, f2: MARKET_FUNCTION) is
		require
			not_void: f1 /= Void and f2 /= Void
			outputs_not_void: f1.output /= Void and f2.output /= Void
		do
			input1 := f1
			input2 := f2
			target1 := f1.output
			target2 := f2.output
			reset_state
		ensure
			input1 = f1 and input2 = f2
			input1 /= Void and input2 /= Void
			not_processed: not processed
		end

feature {NONE}

	input1, input2: MARKET_FUNCTION

invariant

	processed_constraint:
		processed implies input1.processed and input2.processed
	input_target_relation:
		(input1 = Void or else input1.output = target1) and
		(input2 = Void or else input2.output = target2)

end -- class TWO_VECTOR_FUNCTION
