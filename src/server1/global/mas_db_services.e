note
	description: "MAS database services"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class MAS_DB_SERVICES inherit

	GENERAL_UTILITIES
		export
			{NONE} all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		end

	TRADABLE_TYPE_VALUES
		export
			{NONE} all
		end

feature -- Access


	stock_symbols: DYNAMIC_LIST [STRING]
			-- All stock symbols available in the database
		require
			connected: connected
		local
			gs: expanded GLOBAL_SERVER_FACILITIES
		do
			Result := list_from_query (
				gs.database_configuration.stock_symbol_query)
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	derivative_symbols: DYNAMIC_LIST [STRING]
			-- All derivative-instrument symbols available in the database
		require
			connected: connected
		local
			gs: expanded GLOBAL_SERVER_FACILITIES
		do
			Result := list_from_query (
				gs.database_configuration.derivative_symbol_query)
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	stock_splits: STOCK_SPLITS
			-- All stock splits available in the database - Void if not
			-- available.
		deferred
		end

	daily_data_for_symbol (s: STRING): DB_INPUT_SEQUENCE
			-- Daily data for symbol `s' - stock data if `s' is a stock
			-- symbol (stock_symbols.has (s)), derivative data is `s' is
			-- a derivative-instrument symbol (derivative_symbols.has (s)).
		require
			connected: connected
		do
			if is_stock_symbol (s) then
				Result := daily_stock_data (s)
				if Result /= Void then
					check_field_count (Result,
						create {TRADABLE_TYPE}.make_stock, False,
						"daily stock data")
				end
			elseif is_derivative_symbol (s) then
				Result := daily_derivative_data (s)
				if Result /= Void then
					check_field_count (Result,
						create {TRADABLE_TYPE}.make_derivative, False,
						"daily derivative data")
				end
			else
				fatal_error := True
				last_error :=
					"Symbol '" + s + "' is neither a valid stock symbol, nor %
						%a valid derivative symbol.%N"
			end
		ensure
			not_void_if_no_error: not fatal_error and (is_stock_symbol (s) or
				is_derivative_symbol (s)) implies Result /= Void
			still_connected: connected
		end

	intraday_data_for_symbol (s: STRING): DB_INPUT_SEQUENCE
			-- Intraday data for symbol `s' - stock data if `s' is a stock
			-- symbol (stock_symbols.has (s)), derivative data is `s' is
			-- a derivative-instrument symbol (derivative_symbols.has (s)).
		require
			connected: connected
		do
			if is_stock_symbol (s) then
				Result := intraday_stock_data (s)
				if Result /= Void then
					check_field_count (Result,
						create {TRADABLE_TYPE}.make_stock, True,
						"intraday stock data")
				end
			elseif is_derivative_symbol (s) then
				Result := intraday_derivative_data (s)
				if Result /= Void then
					check_field_count (Result,
						create {TRADABLE_TYPE}.make_derivative, True,
						"intraday derivative data")
				end
			else
				fatal_error := True
				last_error :=
					"Symbol '" + s + "' is neither a valid stock symbol, nor %
						%a valid derivative symbol.%N"
			end
		ensure
			not_void_if_no_error: not fatal_error and (is_stock_symbol (s) or
				is_derivative_symbol (s)) implies Result /= Void
			still_connected: connected
		end

	daily_stock_data (symbol: STRING): DB_INPUT_SEQUENCE
			-- Daily stock data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	intraday_stock_data (symbol: STRING): DB_INPUT_SEQUENCE
			-- Intraday stock data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	daily_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE
			-- Daily derivative data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	intraday_derivative_data (symbol: STRING): DB_INPUT_SEQUENCE
			-- Intraday derivative data for `symbol'
		require
			connected: connected
		deferred
		ensure
			not_void_if_no_error: not fatal_error implies Result /= Void
			still_connected: connected
		end

	stock_name (symbol: STRING): STRING
			-- Name for stock whose symbol is `symbol'
		require
			connected: connected
		local
			query: STRING
		do
			fatal_error := False
			query := stock_name_query (symbol)
			if query /= Void then
				Result := single_string_query_result (query)
				if Result = Void and not fatal_error then
					Result := ""
				end
			end
		ensure
			not_void_if_ok: (not fatal_error) = (Result /= Void)
			still_connected: connected
		end

	derivative_name (symbol: STRING): STRING
			-- Name for derivative whose symbol is `symbol'
		require
			connected: connected
		local
			query: STRING
		do
			fatal_error := False
			query := derivative_name_query (symbol)
			if query /= Void then
				Result := single_string_query_result (query)
				if Result = Void and not fatal_error then
					Result := ""
				end
			end
		ensure
			not_void_if_ok: (not fatal_error) = (Result /= Void)
			still_connected: connected
		end

	single_string_query_result (query: STRING): STRING
			-- 1-record, 1-column string result of executing `query'.  If
			-- the result is more than one record, the first record is
			-- returned; if 0 records or the query result is null, Result
			-- is Void.
		require
			connected: connected
			query_not_void: query /= Void
		deferred
		ensure
			void_if_error: fatal_error implies Result = Void
			still_connected: connected
		end

	stock_data: STOCK_DATA
			-- Miscellaneous stock information from database
		deferred
		end

	derivative_data: TRADABLE_DATA
			-- Miscellaneous derivative-instrument information from database
		deferred
		end

	last_error: STRING
			-- Description of last error that occured

	is_stock_symbol (s: STRING): BOOLEAN
			-- Is `s' a symbol for a stock?
		local
			symbols: DYNAMIC_LIST [STRING]
		do
			if stock_symbol_table = Void then
				symbols := stock_symbols
				if symbols /= Void then
					create stock_symbol_table.make (symbols.count)
					from
						symbols.start
					until
						symbols.exhausted
					loop
						stock_symbol_table.force (Void, symbols.item)
						symbols.forth
					end
				else
					create stock_symbol_table.make (0)
				end
			end
			Result := stock_symbol_table.has (s)
			if debugging then
				print ("is_stock_symbol (" + s + "): " + Result.out + "%N")
			end
		end

	is_derivative_symbol (s: STRING): BOOLEAN
			-- Is `s' a symbol for a derivative instrument?
		local
			symbols: DYNAMIC_LIST [STRING]
		do
			if derivative_symbol_table = Void then
				symbols := derivative_symbols
				if symbols /= Void then
					create derivative_symbol_table.make (symbols.count)
					from
						symbols.start
					until
						symbols.exhausted
					loop
						derivative_symbol_table.force (Void, symbols.item)
						symbols.forth
					end
				else
					create derivative_symbol_table.make (0)
				end
			end
			Result := derivative_symbol_table.has (s)
			if debugging then
				print ("is_derivative_symbol (" + s + "): " + Result.out + "%N")
			end
		end

feature -- Status report

	connected: BOOLEAN
			-- Are we connected to the database?
		deferred
		end

	fatal_error: BOOLEAN
			-- Did a fatal error occur on the last operation?

	debugging: BOOLEAN
			-- Is debugging mode on?

feature -- Status setting

	set_debugging (arg: BOOLEAN)
			-- Set `debugging' to `arg'.
		do
			debugging := arg
		ensure
			debugging_set: debugging = arg
		end

feature -- Basic operations

	connect
			-- Connect to the database.
		require
			not_connected: not connected
		deferred
		ensure
			connected: connected or fatal_error
		end

	disconnect
			-- Disconnect from database.
		require
			connected: connected
		deferred
		ensure
			not_connected: not connected or fatal_error
		end

feature {NONE} -- Implementation

	daily_stock_query (symbol: STRING): STRING
			-- Query for daily stock data
		local
			db_info: DATABASE_CONFIGURATION
			global_server: expanded GLOBAL_SERVER_FACILITIES
		do
			db_info := global_server.database_configuration
			db_info.set_symbol (symbol)
			if db_info.using_daily_stock_data_command then
				Result := db_info.daily_stock_data_command
			else
				Result := concatenation (<<"select ",
					db_info.daily_stock_date_field_name, ", ",
					open_string (db_info), db_info.daily_stock_high_field_name,
					", ", db_info.daily_stock_low_field_name, ", ",
					db_info.daily_stock_close_field_name,
					", ", db_info.daily_stock_volume_field_name, " from ",
					db_info.daily_stock_table_name, " where ",
					db_info.daily_stock_symbol_field_name, " = '", symbol,
					"' ", db_info.daily_stock_query_tail>>)
			end
		end

	intraday_stock_query (symbol: STRING): STRING
			-- Query for intraday stock data
		local
			db_info: DATABASE_CONFIGURATION
			global_server: expanded GLOBAL_SERVER_FACILITIES
		do
			db_info := global_server.database_configuration
			db_info.set_symbol (symbol)
			if db_info.using_intraday_stock_data_command then
				Result := db_info.intraday_stock_data_command
			else
				Result := concatenation (<<"select ",
					db_info.intraday_stock_date_field_name, ", ",
					db_info.intraday_stock_time_field_name, ", ",
					open_string (db_info),
					db_info.intraday_stock_high_field_name,
					", ", db_info.intraday_stock_low_field_name,
					", ", db_info.intraday_stock_close_field_name, ", ",
					db_info.intraday_stock_volume_field_name, " from ",
					db_info.intraday_stock_table_name,
					" where ", db_info.intraday_stock_symbol_field_name, " = '",
					symbol, "'", db_info.intraday_stock_query_tail>>)
			end
		end

	daily_derivative_query (symbol: STRING): STRING
			-- Query for daily derivative data
		local
			db_info: DATABASE_CONFIGURATION
			global_server: expanded GLOBAL_SERVER_FACILITIES
		do
			db_info := global_server.database_configuration
			db_info.set_symbol (symbol)
			if db_info.using_daily_derivative_data_command then
				Result := db_info.daily_derivative_data_command
			else
				Result := concatenation (<<"select ",
					db_info.daily_derivative_date_field_name, ", ",
					open_string (db_info),
						db_info.daily_derivative_high_field_name,
					", ", db_info.daily_derivative_low_field_name, ", ",
					db_info.daily_derivative_close_field_name,
					", ", db_info.daily_derivative_volume_field_name, ", ",
					db_info.daily_derivative_open_interest_field_name,
					" from ", db_info.daily_derivative_table_name, " where ",
					db_info.daily_derivative_symbol_field_name, " = '", symbol,
					"' ", db_info.daily_derivative_query_tail>>)
			end
		end

	intraday_derivative_query (symbol: STRING): STRING
			-- Query for intraday derivative data
		local
			db_info: DATABASE_CONFIGURATION
			global_server: expanded GLOBAL_SERVER_FACILITIES
		do
			db_info := global_server.database_configuration
			db_info.set_symbol (symbol)
			if db_info.using_intraday_derivative_data_command then
				Result := db_info.intraday_derivative_data_command
			else
				Result := concatenation (<<"select ",
					db_info.intraday_derivative_date_field_name, ", ",
					db_info.intraday_derivative_time_field_name, ", ",
					open_string (db_info),
					db_info.intraday_derivative_high_field_name,
					", ", db_info.intraday_derivative_low_field_name,
					", ", db_info.intraday_derivative_close_field_name, ", ",
					db_info.intraday_derivative_volume_field_name, ", ",
					db_info.intraday_derivative_open_interest_field_name,
					" from ", db_info.intraday_derivative_table_name, " where ",
					db_info.intraday_derivative_symbol_field_name, " = '",
					symbol, "'", db_info.intraday_derivative_query_tail>>)
			end
		end

	stock_name_query (symbol: STRING): STRING
			-- Query for stock name from symbol - Void if the user-specified
			-- query is invalid or non-existent.
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			q: STRING
		do
			q := global_server.database_configuration.stock_name_query
			if not q.is_empty then
				Result := q
			else
				fatal_error := True
				last_error :=
					"Missing stock name query in database configuration file"
			end
		ensure
			not_void_if_ok: not fatal_error implies Result /= Void
		end

	derivative_name_query (symbol: STRING): STRING
			-- Query for derivative name from symbol - Void if the
			-- user-specified query is invalid or non-existent.
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			q: STRING
		do
			q := global_server.database_configuration.derivative_name_query
			if not q.is_empty then
				Result := q
			else
				fatal_error := True
				last_error := "Missing derivative name query in %
					%database configuration file"
			end
		ensure
			not_void_if_ok: not fatal_error implies Result /= Void
		end

	open_string (db_info: DATABASE_CONFIGURATION): STRING
			-- Open field string needed for query - empty if
			-- not command_line_options.opening_price
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
		do
			if global_server.command_line_options.opening_price then
				Result := concatenation (<<db_info.daily_stock_open_field_name,
					", ">>)
			else
				Result := ""
			end
		end

	list_from_query (q: STRING): DYNAMIC_LIST [STRING]
			-- List of STRING from query `q' with 1-column result
		require
			not_void: q /= Void
		deferred
		ensure
			not_void: Result /= Void
			empty_if_q_empty: old q.is_empty implies Result.is_empty
		end

	check_field_count (seq: DB_INPUT_SEQUENCE; tradable_type: TRADABLE_TYPE;
		intraday: BOOLEAN; data_descr: STRING)
			-- Check the field count of `seq' according to whether it is
			-- for a Stock or Derivative and whether its
			-- data is intraday, and if the field count is wrong.
			-- Set fatal_error and last_error accordingly.
		local
			global_server: expanded GLOBAL_SERVER_FACILITIES
			expected_count: INTEGER
		do
			if global_server.command_line_options.opening_price then
				expected_count := 1
			end
			inspect
				tradable_type.item
			when stock then
				expected_count := expected_count + 5
			when derivative then
				expected_count := expected_count + 6
			end
			if intraday then
				expected_count := expected_count + 1
			end
			if seq.field_count /= expected_count then
				fatal_error := True
				last_error := concatenation (<<"Database error:%NWrong number ",
					"of fields in query result for%N", data_descr,
					" - expected ", expected_count,
					", got ", seq.field_count, ".%N">>)
			end
		end

	stock_symbol_table, derivative_symbol_table: HASH_TABLE [ANY, STRING]

end -- class MAS_DB_SERVICES
