indexing
	description: "Global features needed by the application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class GLOBAL_APPLICATION inherit

	EXCEPTIONS
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

feature -- Utility

	register_for_termination (v: TERMINABLE) is
			-- Add `v' to termination_registrants.
		require
			not_registered: not termination_registrants.has (v)
		do
			termination_registrants.extend (v)
		end

	unregister_for_termination (v: TERMINABLE) is
			-- Remove (all occurrences of) `v' from termination_registrants.
		do
			termination_registrants.prune_all (v)
		ensure
			not_registered: not termination_registrants.has (v)
		end

	termination_cleanup is
			-- Send cleanup notification to all members of
			-- `termination_registrants' in the order they were added
			-- (with `register_for_termination').
		do
			from
				termination_registrants.start
			until
				termination_registrants.exhausted
			loop
				termination_registrants.item.cleanup
				termination_registrants.forth
			end
		end

feature -- Access

	termination_registrants: LIST [TERMINABLE] is
			-- Registrants for termination cleanup notification
		once
			create {LINKED_LIST [TERMINABLE]} Result.make
		end

	event_types: ARRAY [EVENT_TYPE] is
			-- All event types known to the system - in an array.
		local
			i: INTEGER
		do
			create {ARRAY [EVENT_TYPE]} Result.make (1,
				market_event_generation_library.count)
			from
				i := 1
				market_event_generation_library.start
			until
				market_event_generation_library.exhausted
			loop
				Result.put (market_event_generation_library.item.event_type, i)
				market_event_generation_library.forth
				i := i + 1
			end
		end

	event_types_by_key: HASH_TABLE [EVENT_TYPE, INTEGER] is
			-- All event types known to the system in a hash table - key
			-- is the event type ID.
		do
			create Result.make (
				market_event_generation_library.count)
			from
				market_event_generation_library.start
			until
				market_event_generation_library.exhausted
			loop
				Result.extend (market_event_generation_library.item.event_type,
					market_event_generation_library.item.event_type.id)
				market_event_generation_library.forth
			end
		end

	create_event_generator (eg_maker: EVENT_GENERATOR_FACTORY;
				event_type_name: STRING;
				meg_list: STORABLE_LIST [MARKET_EVENT_GENERATOR]) is
			-- Create a new MARKET_EVENT_GENERATOR and a new associated
			-- EVENT_TYPE (with `event_type_name') and add the new
			-- MARKET_EVENT_GENERATOR  to `meg_list'.
		require
			not_void: eg_maker /= Void and event_type_name /= Void and
				meg_list /= Void
		do
			eg_maker.set_event_type (new_event_type (
				event_type_name, meg_list))
			eg_maker.execute
			meg_list.extend (eg_maker.product)
		ensure
			one_more_eg: meg_list.count =
				old meg_list.count + 1
			product_in_library: eg_maker.product /= Void and
				meg_list.has (eg_maker.product)
		end

	function_library: STORABLE_LIST [MARKET_FUNCTION] is
			-- All defined market functions
		once
			Result := retrieved_function_library
		ensure
			not_void: Result /= Void
		end

	market_event_generation_library: STORABLE_LIST [MARKET_EVENT_GENERATOR] is
			-- All defined event generators
		once
			Result := retrieved_market_event_generation_library
		ensure
			not_void: Result /= Void
		end

	market_event_registrants: STORABLE_LIST [MARKET_EVENT_REGISTRANT] is
			-- All defined event registrants
		once
			Result := retrieved_market_event_registrants
		ensure
			not_void: Result /= Void
		end

	active_event_generators: LIST [MARKET_EVENT_GENERATOR] is
			-- Event generators in which at least one event registrant
			-- is interested.
		local
			registrants: LIST [MARKET_EVENT_REGISTRANT]
			generators: LIST [MARKET_EVENT_GENERATOR]
		do
			create {LINKED_LIST [MARKET_EVENT_GENERATOR]} Result.make
			registrants := market_event_registrants
			generators := market_event_generation_library
			from
				registrants.start
			until
				registrants.exhausted
			loop
				from
					generators.start
				until
					generators.exhausted
				loop
					if
						-- If the current generator has not already been
						-- added to Result and the current registrant is
						-- intersted in that generator's event type, add
						-- it to Result.
						not Result.has (generators.item) and
							registrants.item.event_types.has (
								generators.item.event_type)
					then
						Result.extend (generators.item)
					end
					generators.forth
				end
				registrants.forth
			end
		ensure
			not_void: Result /= Void
		end

	meg_names (meg_lib: LIST [MARKET_EVENT_GENERATOR]):
				ARRAYED_LIST [STRING] is
			-- Names of all elements of `meg_lib' if not Void; otherwise,
			-- of `market_event_generation_library', in the same order
		local
			meg_library: LIST [MARKET_EVENT_GENERATOR]
		do
			if meg_lib = Void then
				meg_library := market_event_generation_library
			else
				meg_library := meg_lib
			end
			from
				create Result.make (meg_library.count)
				meg_library.start
			until
				meg_library.exhausted
			loop
				Result.extend (
					meg_library.item.event_type.name)
				meg_library.forth
			end
		end

	function_names: ARRAYED_LIST [STRING] is
			-- Names of all elements of `function_library', in the same order
		do
			create Result.make (function_library.count)
			from
				function_library.start
			until
				function_library.after
			loop
				Result.extend (function_library.item.name)
				function_library.forth
			end
		end

	event_type_names: ARRAYED_LIST [STRING] is
			-- Names of all elements of `event_types', in the same order
		local
			etypes: LINEAR [EVENT_TYPE]
		do
			create Result.make (event_types.count)
			etypes := event_types.linear_representation
			from
				etypes.start
			until
				etypes.exhausted
			loop
				Result.extend (etypes.item.name)
				etypes.forth
			end
	end

feature -- Basic operations

	force_function_library_retrieval is
			-- Force function library to be re-retrieved by deep copying
			-- `retrieved_function_library' into it.
		do
			function_library.deep_copy (retrieved_function_library)
		end

	force_meg_library_retrieval is
			-- Force market event generator library to be re-retrieved by deep
			-- copying `retrieved_market_event_generation_library' into it.
		do
			market_event_generation_library.deep_copy (
				retrieved_market_event_generation_library)
		end

	force_event_registrant_retrieval is
			-- Force event registrants to be re-retrieved by deep copying
			-- `retrieved_market_event_registrants' into it.
		do
			market_event_registrants.deep_copy (
				retrieved_market_event_registrants)
		end

feature -- Constants

	indicators_file_name: STRING is
			-- Name of the file containing persistent data for indicators
		once
			Result := "indicators_persist"
		end

	generators_file_name: STRING is
			-- Name of the file containing persistent data for event generators
		once
			Result := "generators_persist"
		end

	registrants_file_name: STRING is
			-- Name of the file containing persistent data for event
			-- registrants
		once
			Result := "registrants_persist"
		end

feature {NONE} -- Implementation

	retrieved_function_library: STORABLE_LIST [MARKET_FUNCTION] is
		local
			storable: STORABLE
			mflist: STORABLE_LIST [MARKET_FUNCTION]
			retrieval_failed: BOOLEAN
			app_env: expanded APP_ENVIRONMENT
			full_path_name, file_errinfo: STRING
		do
			file_errinfo := "The file may be corrupted or you may have %
				%an incompatible version.%N"
			full_path_name := app_env.file_name_with_app_directory (
				indicators_file_name)
			if retrieval_failed then
				if exception = Retrieve_exception then
					log_errors (<<"Retrieval of indicator library file ",
						full_path_name, " failed.%N", file_errinfo>>)
				else
					log_errors (<<"Error occurred while retrieving indicator %
						%%Nlibrary file (", meaning(exception), "):%N",
						full_path_name, "%N", file_errinfo>>)
				end
				die (-1)
			else
				create storable
				mflist ?= storable.retrieve_by_name (full_path_name)
				if mflist = Void then
					create {STORABLE_MARKET_FUNCTION_LIST} mflist.make (
						indicators_file_name)
				end
				Result := mflist
			end
		ensure
			not_void: Result /= Void
		rescue
			retrieval_failed := true
			retry
		end

	retrieved_market_event_generation_library:
				STORABLE_LIST [MARKET_EVENT_GENERATOR] is
			-- All defined event generators
		local
			storable: STORABLE
			meg_list: STORABLE_LIST [MARKET_EVENT_GENERATOR]
			retrieval_failed: BOOLEAN
			app_env: expanded APP_ENVIRONMENT
			full_path_name: STRING
		do
			full_path_name := app_env.file_name_with_app_directory (
				generators_file_name)
			if retrieval_failed then
				if exception = Retrieve_exception then
					log_errors (<<"Retrieval of market analysis library%
								% file ", full_path_name, " failed%N">>)
				else
					log_errors (<<"Error occurred while retrieving market %
							%analysis library: ", meaning(exception), "%N">>)
				end
				die (-1)
			else
				create storable
				meg_list ?= storable.retrieve_by_name (full_path_name)
				if meg_list = Void then
					create {STORABLE_EVENT_GENERATOR_LIST} meg_list.make (
						generators_file_name)
				end
				Result := meg_list
			end
		rescue
			retrieval_failed := true
			retry
		end

	retrieved_market_event_registrants:
				STORABLE_LIST [MARKET_EVENT_REGISTRANT] is
			-- All defined event registrants
		local
			storable: STORABLE
			reg_list: STORABLE_LIST [MARKET_EVENT_REGISTRANT]
			retrieval_failed: BOOLEAN
			app_env: expanded APP_ENVIRONMENT
			full_path_name: STRING
		do
			full_path_name := app_env.file_name_with_app_directory (
				registrants_file_name)
			if retrieval_failed then
				if exception = Retrieve_exception then
					log_errors (<<"Retrieval of event registrants file ",
								full_path_name, " failed%N">>)
				else
					log_errors (<<"Error occurred while retrieving event %
								%registrants: ", meaning(exception), "%N">>)
				end
				die (-1)
			else
				create storable
				reg_list ?= storable.retrieve_by_name (full_path_name)
				if reg_list = Void then
					create reg_list.make (registrants_file_name)
				end
				Result := reg_list
			end
		rescue
			retrieval_failed := true
			retry
		end

	new_event_type (name: STRING;
		meg_library: STORABLE_LIST [MARKET_EVENT_GENERATOR]): EVENT_TYPE is
			-- Create a new EVENT_TYPE with name `name' and a unique ID -
			-- and ID that does not occur in `meg_library', or if
			-- `meg_library' is Void, that does not occur in
			-- `market_event_generation_library'.
			-- Note: A new MARKET_EVENT_GENERATOR should be created with
			-- this new event type and added to market_event_generation_library
			-- before the next event type is created.
		require
			not_void: name /= Void and meg_library /= Void
		local
			unique_id: INTEGER
			l: LIST [MARKET_EVENT_GENERATOR]
		do
			l := meg_library
			unique_id := maximum_id_value (l) + 1
			create Result.make (name, unique_id)
		ensure
			not event_types_by_key.has (Result.id)
		end

	maximum_id_value (l: LIST [MARKET_EVENT_GENERATOR]): INTEGER is
			-- The largest EVENT_TYPE ID value in `l'
		do
			from
				Result := 1
				l.start
			until
				l.exhausted
			loop
				if l.item.event_type.id > Result then
					Result := l.item.event_type.id
				end
				l.forth
			end
		end

end -- GLOBAL_APPLICATION
