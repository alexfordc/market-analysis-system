indexing
	description:
		"Factory class that manufactures TWO_VARIABLE_FUNCTION_ANALYZERs"
	note:
		"Features left_function, right_function, period_type, and event_type %
		%should all be non-Void when execute is called.  (operator may be %
		%Void.)"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class TVFA_FACTORY inherit

	EVENT_GENERATOR_FACTORY
		redefine
			product
		end

creation

	make

feature -- Initialization

	make is
		do
			crossover_specification := Below_to_above
		ensure
			below_to_above: crossover_specification = Below_to_above
		end

feature -- Access

	product: TWO_VARIABLE_FUNCTION_ANALYZER

	left_function, right_function: MARKET_FUNCTION
			-- Left and right functions to be associated with the new TVFA

	period_type: TIME_PERIOD_TYPE
			-- The time period type to be associated with the new TVFA

	operator: RESULT_COMMAND [BOOLEAN]
			-- The operator to be associated with the new TVFA

	crossover_specification: INTEGER

	Below_to_above, Above_to_below, Both: INTEGER is unique
			-- Specifications for TVFA crossover detection

	use_left_function: BOOLEAN
			-- If the operator is not Void, will the analyzer use its
			-- operator on the left function?  (False implies it will
			-- use the operator on the right function.)

feature -- Status setting

	set_functions (left, right: MARKET_FUNCTION) is
			-- Set function to `arg'.
		require
			not_void: left /= Void and right /= Void
		do
			left_function := left
			right_function := right
		ensure
			functions_set: left_function = left and right_function = right
		end

	set_period_type (arg: TIME_PERIOD_TYPE) is
			-- Set period_type to `arg'.
		require
			arg_not_void: arg /= Void
		do
			period_type := arg
		ensure
			period_type_set: period_type = arg and period_type /= Void
		end

	set_operator (arg: RESULT_COMMAND [BOOLEAN]; use_left_func: BOOLEAN) is
			-- Set operator to `arg'.
		require
			arg_not_void: arg /= Void
		do
			operator := arg
			use_left_function := use_left_func
		ensure
			operator_set: operator = arg and operator /= Void
			use_left_set: use_left_function = use_left_func
		end

	set_crossover_specification (arg: INTEGER) is
			-- Set crossover_specification to `arg'.
		require
			valid_spec: arg = Below_to_above or arg = Above_to_below or
				arg = Both
		do
			crossover_specification := arg
		ensure
			crossover_specification_set: crossover_specification = arg
		end

feature -- Basic operations

	execute is
		do
			create product.make (left_function, right_function, event_type,
							period_type)
			if operator /= Void then
				product.set_operator (operator)
				product.set_function_for_operation (use_left_function)
			end
			inspect
				crossover_specification
			when Below_to_above then
				product.set_below_to_above_only
			when Above_to_below then
				product.set_above_to_below_only
			when Both then
				product.set_below_and_above
			end
			debug ("editing")
				print ("TVFA factory: created tvfa%Nabove-to-below: ")
				print (product.above_to_below.out)
				print (", below_to_above: ")
				print (product.below_to_above.out)
				print ("%N")
			end
		end

invariant

	crossover_spec_valid: crossover_specification = Below_to_above or
		crossover_specification = Above_to_below or
		crossover_specification = Both

end -- TVFA_FACTORY
