indexing
	description:
		"A market function that takes two arguments or variables"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TWO_VARIABLE_FUNCTION

inherit

	COMPLEX_FUNCTION
		redefine
			set_innermost_input, reset_parameters
		end

	TWO_VARIABLE_LINEAR_ANALYZER
		redefine
			action, start
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature {NONE} -- Initialization

	make (in1: like input1; in2: like input2; op: like operator)  is
		require
			args_not_void: in1 /= Void and in2 /= Void
			op_not_void: op /= Void
			in_output_not_void: in1.output /= Void and in2.output /= Void
			ptypes_not_void: in1.trading_period_type /= Void and
				in2.trading_period_type /= Void
			period_types_equal:
				in1.trading_period_type.is_equal (in2.trading_period_type)
		do
			create output.make (in1.output.count)
			set_input1 (in1)
			set_input2 (in2)
			set_operator (op)
		ensure
			output_not_void: output /= Void
			set: input1 = in1 and input2 = in2 and operator = op
		end

feature -- Access

	trading_period_type: TIME_PERIOD_TYPE is
		do
			Result := input1.trading_period_type
		ensure then
			Result = input1.trading_period_type
		end

	short_description: STRING is
		once
			Result := "Indicator that operates on two data sequences"
		end

	full_description: STRING is
		do
			create Result.make (25)
			Result.append (short_description)
			Result.append (":%N")
			Result.append (input1.full_description)
			Result.append ("; and:%N")
			Result.append (input2.full_description)
		end

	children: LIST [MARKET_FUNCTION] is
		do
			create {LINKED_LIST [MARKET_FUNCTION]} Result.make
			Result.extend (input1)
			Result.extend (input2)
		end

	leaf_functions: LIST [COMPLEX_FUNCTION] is
		do
			create {LINKED_LIST [COMPLEX_FUNCTION]} Result.make
			check
				both_inputs_complex: input1.is_complex and input2.is_complex
			end
			Result.append (input1.leaf_functions)
			Result.append (input2.leaf_functions)
		end

	innermost_input: SIMPLE_FUNCTION [MARKET_TUPLE] is
		do
			Result := input1.innermost_input
		end

feature -- Status report

	processed: BOOLEAN is
		do
			Result := (input1.processed and input2.processed) and then
				processed_date_time /= Void and then
				processed_date_time >= input1.processed_date_time and then
				processed_date_time >= input2.processed_date_time
		end

	has_children: BOOLEAN is True

feature {NONE} -- Hook methods

	action is
		local
			t: SIMPLE_TUPLE
		do
			operator.execute (Void)
			check
				t1_t2_dates_equal: target1.item.date_time.is_equal (
									target2.item.date_time)
			end
			create t.make (target1.item.date_time, target1.item.end_date,
						operator.value)
			output.extend (t)
			if debugging then
				print_status_report
			end
		ensure then
			output.count = old (output.count) + 1
		end

	start is
		do
			Precursor
		end

	do_process is
		do
			if not (target1.is_empty or target2.is_empty) then
				do_all
			end
		ensure then
			output_empty_when_target_empty:
				target1.is_empty or target2.is_empty implies output.is_empty
		end

	pre_process is
		do
			if not output.is_empty then
				output.wipe_out
			end
			if not input1.processed then
				input1.process
			end
			if not input2.processed then
				input2.process
			end
		ensure then
			inputs_processed: input1.processed and input2.processed
		end

feature {FACTORY} -- Status setting

	set_innermost_input (in: SIMPLE_FUNCTION [MARKET_TUPLE]) is
			-- Both `input1' and `input2' will be changed.
		do
			processed_date_time := Void
			input1.set_innermost_input (in)
			input2.set_innermost_input (in)
			output.wipe_out
		end

feature {MARKET_FUNCTION_EDITOR}

	set_input1 (in: like input1) is
		require
			not_void: in /= Void
			output_not_void: in.output /= Void
			period_types_equal:
				input2 /= Void implies in.trading_period_type.is_equal (
					input2.trading_period_type)
			ptype_not_void: in.trading_period_type /= Void
		do
			do_set_input1 (in)
		ensure
			input_set: input1 = in and input1 /= Void
			target_set: target1 = in.output
			not_processed: not processed
		end

	set_input2 (in: like input2) is
		require
			not_void: in /= Void
			output_not_void: in.output /= Void
			period_types_equal:
				input1 /= Void implies in.trading_period_type.is_equal (
					input1.trading_period_type)
			ptype_not_void: in.trading_period_type /= Void
		do
			do_set_input2 (in)
		ensure
			input_set: input2 = in and input2 /= Void
			target_set: target2 = in.output
			not_processed: not processed
		end

	set_inputs (in1, in2: like input1) is
			-- Set input1 and input2.
		require
			not_void: in1 /= Void and in2 /= Void
			output_not_void: in1.output /= Void and in2.output /= Void
			ptypes_not_void: in1.trading_period_type /= Void and
				in2.trading_period_type /= Void
			period_types_equal:
				in1.trading_period_type.is_equal (in2.trading_period_type)
		do
			do_set_input1 (in1)
			do_set_input2 (in2)
		ensure
			input_set: input1 = in1 and input1 /= Void and
				input2 = in2 and input2 /= Void
			target_set: target1 = in1.output and target2 = in2.output
			not_processed: not processed
		end

	reset_parameters is
		do
			input1.reset_parameters
			input2.reset_parameters
		end

feature {MARKET_FUNCTION_EDITOR}

	input1, input2: COMPLEX_FUNCTION

feature {NONE} -- Implementation

	do_set_input1 (in: like input1) is
		do
			input1 := in
			set1 (in.output)
			processed_date_time := Void
		end

	do_set_input2 (in: like input2) is
		do
			input2 := in
			set2 (in.output)
			processed_date_time := Void
		end

invariant

	processed_constraint1:
		 processed implies input1.processed and input2.processed
	inputs_not_void: input1 /= Void and input2 /= Void
	input_target_relation:
		input1.output = target1 and input2.output = target2
	no_missing_periods: processed implies not missing_periods (target1, target2)
	inputs_trading_period_types_equal:
		input1.trading_period_type.is_equal (input2.trading_period_type)
	has_two_children: has_children and children.count = 2

end -- class TWO_VARIABLE_FUNCTION
