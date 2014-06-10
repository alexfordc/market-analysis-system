note
	description: "Exponential moving average";
	detailed_description:
		"Applies to each tuple the formula: K * C + EMA[p](1-K), where K is %
		%the constant result value from `exp', C is the current value, %
		%and EMA[p] is the result from the previous tuple."
	notes: "Formula taken from `Trading for a Living', by A. Elder"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXPONENTIAL_MOVING_AVERAGE inherit

	STANDARD_MOVING_AVERAGE
		rename
			make as sma_make
		redefine
			action, set_n, short_description, direct_operators, do_process
		end

	MATH_CONSTANTS
		rename
			exp as math_exp
		export
			{NONE} all
		end

creation {FACTORY, MARKET_FUNCTION_EDITOR}

	make

feature -- Access

	short_description: STRING
		do
			create Result.make (38)
			Result.append (n.out)
			Result.append ("-Period Exponential Moving Average that operates %
							%on a data sequence")
		end

	exp: N_BASED_CALCULATION
			-- The so-called exponential (weighting value)

feature {NONE} -- Basic operations

	do_process
		do
			update_exp_inverse
			check
				exp_inv_correct:
					rabs(1 - exp.value) - rabs(exp_inverse) <= .00001
			end
			Precursor
		end

feature {NONE} -- Initialization

	make (in: like input; op: like operator; e: N_BASED_CALCULATION;
			i: INTEGER)
		require
			args_not_void: in /= Void and e /= Void and op /= Void
			i_gt_0: i > 0
			in_ptype_not_void: in.trading_period_type /= Void
		do
			check operator_used end
			exp := e
			exp.set_n (i)
			create sum.make (in.output, op, i)
			create output.make (in.output.count)
			nrovf_set_input (in)
			nrovf_set_operator (op)
			nrovf_set_n (i)
			check n = i end
		ensure
			set: input = in and operator = op and n = i
			e_n_set_to_i: e.n = i
			exp_set: exp = e
			target_set: target = in.output
		end

feature {MARKET_FUNCTION_EDITOR} -- Status setting

	set_exponential (e: N_BASED_CALCULATION)
		require
			e /= Void
		do
			exp := e
			exp.set_n (n)
		ensure
			exp_set: exp = e and exp /= Void
		end

	set_n (value: integer)
		do
			Precursor (value)
			exp.initialize (Current)
		end

feature {NONE} -- Implementation

	action
			-- Calculate exponential MA value for the current period.
		require else
			output_not_empty: not output.is_empty
			tgindex_gt_n: target.index > effective_n
		local
			t: SIMPLE_TUPLE
			latest_value: REAL
		do
			check
				exp_inv_correct:
					rabs(1 - exp.value) - rabs(exp_inverse) <= .00001
			end
			exp.execute (Void)
			operator.execute (target.item)
			latest_value := operator.value
			create t.make (target.item.date_time, target.item.end_date,
						latest_value * exp.value +
							output.last.value * (exp_inverse))
			output.extend (t)
			if debugging then
				print_status_report
			end
		ensure then
			-- output.last.value = P[curr] * exp + EMA[curr-1] * (1 - exp)
			--   where P[curr] is the result (from `operator') for the current
			--   period and EMA[curr-1] is the EMA for the previous period.
		end

	direct_operators: LIST [COMMAND]
			-- All operators directly attached to Current
		do
			Result := Precursor
			Result.extend (exp)
		ensure then
			has_exp: Result.has (exp)
		end

	exp_inverse: DOUBLE
			-- 1 - exp.value, used for efficiency

	update_exp_inverse
			-- Update `exp_inverse' with the current `exp' value.
		do
			exp_inverse := 1 - exp.value
		end

invariant

	exp_not_void: exp /= Void
	n_equals_exp_n: n = exp.n

end -- class EXPONENTIAL_MOVING_AVERAGE
