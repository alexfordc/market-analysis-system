indexing
	description: "Basic structure for some of the more common moving%
				%averages, such as simple moving average and exponential%
				%moving average.  Based on the convention of summing the%
				%first n elements of the input, using that result for the%
				%first output element, and calculating the remaining%
				%output elements by redefining action, which is used in%
				%the iteration machine.";
	date: "$Date$";
	revision: "$Revision$"

class STANDARD_MOVING_AVERAGE inherit

	N_RECORD_ONE_VECTOR_FUNCTION
		export {NONE}
			set_operator
		redefine
			action, set_input, set_n, process
		end

creation

	make

feature -- Basic operations

	process is
		local
			old_index: INTEGER
			t: SIMPLE_TUPLE
		do
			target.start
			old_index := target.index
			sum.execute (Void)
			check target.index = old_index + n end
			!!t
			t.set_value (sum.value / n)
			last_sum := sum.value
			-- value holds the sum of the first n elements of target
			output.extend (t)
			continue_until
			processed := true
		end

feature {TEST_FUNCTION_FACTORY}

	set_input (in: MARKET_FUNCTION) is
		do
			sum.set (in.output)
			Precursor (in)
		end

	set_n (v: INTEGER) is
		do
			sum.set_n (v)
			Precursor (v)
		end

feature {NONE}

	action is
			-- Default to simple moving average.
			-- Intended to be redefined by descenants for more complex MAs.
		local
			t: SIMPLE_TUPLE
		do
			!!t
			last_sum := last_sum - target.i_th(target.index - n).value +
							target.item.value
			t.set_value (last_sum / n)
			output.extend (t)
		end

feature {NONE} -- Implementation

	sum: expanded VECTOR_SUM
			-- Provides sum of first n elements.

	last_sum: REAL
			-- The last calculated sum

end -- class STANDARD_MOVING_AVERAGE
