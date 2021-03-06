note
	description: "Commands that sum n sequential elements"
	note1: "If target.count < n, all of target's elements will be summed and %
		%target.exhausted will be True."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class LINEAR_SUM inherit

	N_RECORD_LINEAR_COMMAND
		rename
			index_offset as internal_index, make as nrlc_make_unused
		redefine
			execute, target_cursor_not_affected, exhausted, action,
			forth, invariant_value, start, index, initial_index_offset
		end

creation

	make

feature {FACTORY} -- Initialization

	make (t: like target; op: like operand; i: like n)
		require
			args_not_void: t /= Void and op /= Void
			i_gt_0: i > 0
		do
			set (t)
			set_operand (op)
			set_n (i)
		ensure
			op_n_set: operand = op and n = i
			target_set: target = t
		end

feature -- Access

	index: INTEGER
		do
			Result := internal_index + 1
		end

feature -- Basic operations

	execute (arg: ANY)
			-- Operate on the next n elements of the input, beginning
			-- at the current cursor position.
		do
			internal_index := 0
			value := 0
			if target.count >= n then
				until_continue
			else
				low_count_action
			end
		ensure then
			new_index: target.count >= n implies
				target.index = old target.index + n
			-- target.count >= n implies 
			--   value = sum (target[old target.index .. old target.index+n-1])
			int_index_eq_n: target.count >= n implies internal_index = n
			state_if_count_lt_n: target.count < n implies
				internal_index = target.index - 1 and target.exhausted
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN = False
			-- False

feature {NONE}

	invariant_value: BOOLEAN
		do
			Result := 0 <= internal_index and internal_index <= n
		end

feature {NONE}

	forth
		do
			internal_index := internal_index + 1
			target.forth
		end

	action
		do
			operand.execute (target.item)
			value := value + operand.value
		ensure then
			-- value = sum (
			-- target [original_index .. original_index + internal_index - 1])
			--   where original_index is the value of target.index when
			--   execute is called.
		end

	exhausted: BOOLEAN
		do
			Result := internal_index = n
		end

	start
			-- Should never be called.
		do
			check False end
		end

	low_count_action
			-- Action to take if target.count < n
		require
			count_lt_n: target.count < n
		do
			from
			until
				target.exhausted
			loop
				action
				forth
			end
		end

	initial_index_offset: INTEGER
		do
			Result := n
		end

invariant

	operator_not_void: operand /= Void

end -- class LINEAR_SUM
