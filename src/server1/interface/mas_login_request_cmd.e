indexing
	description: "A command that responds to a client log-in request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MAS_LOGIN_REQUEST_CMD inherit

	LOGIN_REQUEST_CMD
		rename
			make as lrc_make_unused
		redefine
			session, put_session_state, pre_process_session, process,
			post_process_session
		end

	TRADABLE_REQUEST_COMMAND
		redefine
			session
		select
			rcmake
		end

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

	DATE_PARSING_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Access

	session: MAS_SESSION

feature {NONE} -- Hook routine implementations

	create_session is
		do
			create session.make
		end

	process (message: STRING) is
		local
			setting_type: STRING
			tokens: LIST [STRING]
		do
			sutil.set_target (message)
			tokens := sutil.tokens (Message_field_separator)
			from
				tokens.start
			until
				tokens.exhausted or error_occurred
			loop
				-- Settings follow the pattern "setting_type%Tvalues", 
				-- where 'values' represents one or more fields and fields
				-- are separated by a tab character; extract the
				-- setting type (name) first and then 'values'.
				setting_type := tokens.item
				tokens.forth
				if tokens.exhausted then
					error_occurred := True
					last_error := "Missing value for setting: "
					last_error.append (setting_type)
				else
					last_error := change_setting (setting_type, tokens)
					if last_error = Void then
						tokens.forth
					else
						error_occurred := True
					end
				end
			end
		end

	put_session_state is
			-- Send the "session state" information (formatted according
			-- to the client/server communication protocol) to the client.
		do
			if not command_line_options.opening_price then
				put (Message_field_separator)
				put (No_open_session_state)
			end
		end

	pre_process_session is
		do
			if not command_line_options.intraday_caching then
				session.turn_caching_off
			end
		end

	post_process_session is
		do
			-- Clearing the cache when a new login occurs ensures that
			-- a new client will receive up-to-date data.
			tradables.clear_caches
		end

feature {NONE} -- Implementation

	change_setting (type: STRING; settings: LIST [STRING]): STRING is
			-- Extract the current setting value from `settings' and
			-- apply it to `sessions @ session_id'.  `settings.item' will
			-- reference the last element read.
			-- If an error in the format or protocol of `type' or `settings'
			-- is encountered, Result will be non-void and contain an
			-- appropriate error message and no other action will be taken.
			-- Otherwise, Result will be void.
		require
			not_void: type /= Void and settings /= Void
			session_not_void: session /= Void
		local
			time_period: STRING
			date: DATE
		do
			if type.is_equal (Start_date) or type.is_equal (End_date) then
				time_period := settings.item
				settings.forth
				if settings.exhausted then
					create Result.make (0)
					Result.append ("Invalid format for date setting of type ")
					Result.append (type)
					Result.append (" - missing date component")
				elseif not period_types.has (time_period) then
					create Result.make (0)
					Result.append ("Invalid time period type for date %
						%setting of type ")
					Result.append (type)
					Result.append (": ")
					Result.append (time_period)
				else
					date := date_from_string (settings.item)
					if date = Void then
						create Result.make (0)
						Result.append ("Invalid date specification for date %
							%setting of type ")
						Result.append (type)
						Result.append (": ")
						Result.append (settings.item)
					elseif type.is_equal (Start_date) then
						session.start_dates.force (date, time_period)
					else
						if settings.item.is_equal (Now) then
							-- Set "now" date to 2 years in the future.
							date.set_year (date.year + 2)
						end
						session.end_dates.force (date, time_period)
					end
				end
			else
				create Result.make (0)
				Result.append ("Invalid type for setting: ")
				Result.append (type)
			end
		end

	sutil: expanded STRING_UTILITIES

end -- class LOGIN_REQUEST_CMD
