indexing
	description:
		"A linear analyzer that processes two target lists"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class TWO_VARIABLE_LINEAR_ANALYZER inherit

	LINEAR_ANALYZER
		rename
			target as target1, -- x in "z = f(x, y)"
--!!!!!An adjustment will probably be needed because LINEAR_ITERATOR depends
--on 'set' being called; perhaps: call this set1 and call it to set target1,
--and call the other one set2 and call it to set target2.
--!!!!!The above has been fixed - see set1 and set2 - Check/test that it is
--correct.
			set as set_unused
		export {NONE}
			set_unused
		redefine
			forth, start
		select
			target1
		end

	LINEAR_ANALYZER
		rename
			target as target2, -- y in "z = f(x, y)"
			set as set_unused
		export {NONE}
			set_unused
		redefine
			forth, start
		end

feature {NONE} -- Hook routines

	forth is
		do
			target1.forth
			target2.forth
		ensure then
			target_indexes_incremented_by_one:
				target1.index = old target1.index + 1
				target2.index = old target2.index + 1
		end

	start is
		do
			line_up (target1, target2)
		ensure then
			current_targets_dates_equal:
				not target1.exhausted and not target2.exhausted implies
					target1.item.date_time.is_equal (target2.item.date_time)
		end

feature {NONE} -- Implementation

	set1 (t: like target1) is
			-- Replacement for `set' - set `target1'.
		do
			target1 := t
		end

	set2 (t: like target2) is
			-- Replacement for `set' - set `target2'.
		do
			target2 := t
		end

feature {NONE} -- Utility routines

	missing_periods (l1, l2: LINEAR [MARKET_TUPLE]): BOOLEAN is
			-- Are there missing periods in l1 and l2 with
			-- respect to each other?
		require
			both_void_or_both_not: (l1 = Void) = (l2 = Void)
		do
			if l1 /= Void and then not l1.is_empty and not l2.is_empty then
				check l2 /= Void end
				from
					line_up (l1, l2)
				until
					Result or l1.exhausted or l2.exhausted
				loop
					if
						not l1.item.date_time.is_equal (
												l2.item.date_time)
					then
						Result := true
					end
					l1.forth; l2.forth
				end
				if not Result and l1.exhausted /= l2.exhausted then
					Result := true
				end
			else
				check
					both_void_or_one_empty_and_false:
						((l1 = Void and l2 = Void) or else
							(l1.is_empty or l2.is_empty)) and not Result
				end
			end
		ensure
			void_gives_false: (l1 = Void and l2 = Void) implies (Result = false)
		end

	line_up (t1, t2: LINEAR [MARKET_TUPLE]) is
			-- Line up t1 and t2 so that they start on the same time period.
		require
			not_empty: not t1.is_empty and not t2.is_empty
		local
			l1, l2: LINEAR [MARKET_TUPLE]
		do
			t1.start; t2.start
			from
				if t1.item.date_time < t2.item.date_time then
					l1 := t1
					l2 := t2
				else
					l1 := t2
					l2 := t1
				end
			until
				not (l1.item.date_time < l2.item.date_time)
			loop
				l1.forth
			end
		end

invariant

	target2_not_void: target2 /= Void

end -- class TWO_VARIABLE_LINEAR_ANALYZER
