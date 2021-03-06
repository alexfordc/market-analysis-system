note
	description: "Debugging settings for the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class

	DEBUG_STATE

create

	make

feature -- Initialization

	make_false
			-- Set all BOOLEAN queries to false.
		do
			tradable_functions := False
			event_processing := False
			data_retrieval := False
		ensure
			all_false: not tradable_functions and not event_processing and
				not data_retrieval
		end

	make_true
			-- Set all BOOLEAN queries to true.
		do
			tradable_functions := True
			event_processing := True
			data_retrieval := True
		ensure
			all_true: tradable_functions and event_processing and
				data_retrieval
		end

feature {NONE} -- Initialization

	make
		do
		ensure
			all_false: not tradable_functions and not event_processing and
				not data_retrieval
		end

feature -- Access

	tradable_functions: BOOLEAN
			-- Is debugging on for TRADABLE_FUNCTIONs?

	event_processing: BOOLEAN
			-- Is debugging on for event processing?

	data_retrieval: BOOLEAN
			-- Is debugging on for data retrieval?

feature -- Element change

	set_tradable_functions (arg: BOOLEAN)
			-- Set `tradable_functions' to `arg'.
		do
			tradable_functions := arg
		ensure
			tradable_functions_set: tradable_functions = arg
		end

	set_event_processing (arg: BOOLEAN)
			-- Set `event_processing' to `arg'.
		do
			event_processing := arg
		ensure
			event_processing_set: event_processing = arg
		end

	set_data_retrieval (arg: BOOLEAN)
			-- Set `data_retrieval' to `arg'.
		do
			data_retrieval := arg
		ensure
			data_retrieval_set: data_retrieval = arg
		end

end
