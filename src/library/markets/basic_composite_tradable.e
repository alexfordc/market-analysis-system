indexing
	description: "COMPOSITE_TRADABLEs that use the same %"main%" %
		%operators for all of their components";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%License TBD (Not public - @@@Make sure this is not released.)"

class BASIC_COMPOSITE_TRADABLE inherit

	COMPOSITE_TRADABLE
		rename
			make as ct_make,
			post_processing_operator as post_processing_operator_for_field
		end

create

	make

feature {NONE} -- Initialization

	make (main_op, accum_op, post_op: RESULT_COMMAND [REAL];
			main_var, accum_var: NUMERIC_VALUE_COMMAND) is
		require
			args_exist: accum_op /= Void and main_op /= Void and
				post_op /= Void and main_var /= Void and accum_var /= Void
			main_op_has_main_variable: main_op.descendants.has (main_var)
		do
			ct_make (accum_op)
			main_operator := main_op
			post_processing_operator := post_op
			main_variable := main_var
			accumulation_result_variable := accum_var
		ensure
			main_op_set: main_operator = main_op
			accumulation_op_set: accumulation_operator = accum_op
			post_op_set: post_processing_operator = post_op
			main_var_set: main_variable = main_var
			accum_var_set: accumulation_result_variable = accum_var
		end

feature -- Access

	main_operator: RESULT_COMMAND [REAL]
			-- Operator used to apply a configurable calculation to
			-- each field of each tuple of each component
			--@@Document that this op. needs to include
			--`variable_for_current_component' as one of its suboperators,etc.

	main_variable: NUMERIC_VALUE_COMMAND
			-- The "variable" that holds the current input field value,
			-- to be used for `main_operator's calculation

	post_processing_operator: RESULT_COMMAND [REAL]
			-- Operator to be used for any needed post-processing for the
			-- current field of the current tuple

	accumulation_result_variable: NUMERIC_VALUE_COMMAND
			-- The "variable" that will hold the result of the "accumulation"

feature {NONE} -- Implementation - Hook routine implementations

	operator_for_current_component (field_extractor_name: STRING):
			RESULT_COMMAND [REAL] is
		do
			Result := main_operator
		end

	variable_for_current_component (field_extractor_name: STRING):
			NUMERIC_VALUE_COMMAND is
		do
			Result := main_variable
		end

	post_processing_operator_for_field (field_extractor_name: STRING):
		RESULT_COMMAND [REAL] is
			-- Operator to be used for any needed post-processing for the
			-- current field of the current tuple (possibly specialized
			-- with `field_extractor_name')
		do
			Result := post_processing_operator
		end

invariant

	operators_exist: main_operator /= Void and post_processing_operator /= Void
	variables_exist: main_variable /= Void and
		accumulation_result_variable /= Void
	main_operator_has_main_variable: 
		main_operator.descendants.has (main_variable)

end