indexing
	description:
		"An event coordinator that uses market event generators to generate %
		%market events and passes a queue of the generated events to a %
		%dispatcher"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class MARKET_EVENT_COORDINATOR inherit

	EVENT_COORDINATOR
		redefine
			event_generators
		end

creation

	make

feature -- Initialization

	make (egs: LINEAR [MARKET_EVENT_GENERATOR];
			dispenser: TRADABLE_DISPENSER; disp: EVENT_DISPATCHER) is
		require
			not_void: egs /= Void and dispenser /= Void and disp /= Void
		do
			event_generators := egs
			tradables := dispenser
			dispatcher := disp
			set_eg_tradables
		ensure
			set: event_generators = egs and tradables = dispenser and
					dispatcher = disp
		end

feature -- Access

	event_generators: LINEAR [MARKET_EVENT_GENERATOR]

	tradables: TRADABLE_DISPENSER
			-- Tradable entities to be analyzed by `event_generators'

	start_date_time: DATE_TIME
			-- Date and time that the generators are to begin their
			-- analysis - that is, for each market, only the market's
			-- data whose date/time >= `start_date_time' will be processed.

feature -- Status setting

	set_start_date_time (d: DATE_TIME) is
			-- For each member of `event_generators', set the date and time
			-- for which to begin analysis to `d' and update `start_date_time'
			-- to `d'.
		do
			start_date_time := d
			update_generators_date_time
		ensure
			date_time_set: start_date_time = d
		end

	set_event_generators (arg: LINEAR [MARKET_EVENT_GENERATOR]) is
			-- Set event_generators to `arg' and call `set_start_date_time'
			-- on each one with `start_date_time'.
		require
			arg_not_void: arg /= Void
			date_not_void: start_date_time /= Void
		do
			event_generators := arg
			update_generators_date_time
			set_eg_tradables
		ensure
			event_generators_set: event_generators = arg and
				event_generators /= Void
		end

feature {NONE} -- Implementation

	generate_events is
			-- For each element, e, of tradables, execute all elements
			-- of event_generators on e.
		do
			from
				tradables.start
			until
				tradables.exhausted
			loop
				execute_event_generators
				tradables.forth
			end
		end

	update_generators_date_time is
			-- Call `set_start_date_time' on each generator with
			-- `start_date_time'.
		do
			from
				event_generators.start
			until
				event_generators.exhausted
			loop
				event_generators.item.set_start_date_time (start_date_time)
				event_generators.forth
			end
		end

	set_eg_tradables is
			-- Set the `tradables' attribute of all `event_generators' to
			-- `tradables'.
		do
			from
				event_generators.start
			until
				event_generators.exhausted
			loop
				event_generators.item.set_tradables (tradables)
				event_generators.forth
			end
		end

invariant

	tradables_not_void: tradables /= Void

end -- class MARKET_EVENT_COORDINATOR
