indexing
	description: "Exponential moving average";
	notes: "Formula taken from `Trading for a Living', by A. Elder"
	date: "$Date$";
	revision: "$Revision$"

class EXPONENTIAL_MOVING_AVERAGE inherit

	STANDARD_MOVING_AVERAGE
		rename
			make as sma_make
		redefine
			action, set_n
		end

creation {FACTORY}

	make

feature {NONE} -- Initialization

	make (in: like input; op: BASIC_NUMERIC_COMMAND; e: N_BASED_CALCULATION;
			i: INTEGER) is
		require
			args_not_void: in /= Void and e /= Void and op /= Void
			i_gt_0: i > 0
		do
			check operator_used end
			sma_make (in, op, i)
			check n = i end
			set_exponential (e)
		ensure
			set: input = in and operator = op and n = i
			e_n_set_to_i: e.n = i
			exp_set: exp = e
			target_set: target = in.output
		end

feature -- Element change

	set_exponential (e: N_BASED_CALCULATION) is
		require
			e /= Void
		do
			exp := e
			exp.set_n (n)
		ensure
			exp_set: exp = e and exp /= Void
		end

	set_n (i: integer) is
		do
			Precursor (i)
			exp.set_n (n)
		end

feature {NONE}

	action is
			-- Calculate exponential MA value for the current period.
		require else
			output_not_empty: not output.empty
			tgindex_gt_n: target.index > n
		local
			t: SIMPLE_TUPLE
		do
			--!!!Bug:  instead of using target.(expr).value directly,
			--!!!should be using operator.
			exp.execute (Void)
			!!t
			t.set_value (target.item.value * exp.value +
							output.last.value * (1 - exp.value))
			t.set_date_time (target.item.date_time)
			output.extend (t)
		ensure then
			-- output.last.value = P[curr] * exp + EMA[curr-1] * (1 - exp)
			--   where P[curr] is the price for the current period and
			--   EMA[curr-1] is the EMA for the previous period.
		end

feature {NONE}

	exp: N_BASED_CALCULATION
			-- The so-called exponential

invariant

	exp_not_void: exp /= Void
	n_equals_exp_n: n = exp.n

end -- class EXPONENTIAL_MOVING_AVERAGE
