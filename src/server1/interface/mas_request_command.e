indexing
	description: "A command that responds to a GUI client data request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

deferred class REQUEST_COMMAND inherit

	POLL_COMMAND
		rename
			make as pc_make_unused
		export
			{NONE} pc_make_unused
		undefine
			print
		redefine
			execute
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		undefine
			print
		end

	GUI_NETWORK_PROTOCOL
		export
			{NONE} all
		undefine
			print
		end

feature {NONE} -- Initialization

	make (dispenser: TRADABLE_DISPENSER) is
		require
			not_void: dispenser /= Void
		do
			tradables := dispenser
		ensure
			set: tradables = dispenser and
				tradables /= Void
		end

feature -- Access

	tradables: TRADABLE_DISPENSER
			-- Dispenser of available market lists

	session: SESSION
			-- Settings specific to a particular client session

feature -- Status setting

	set_active_medium (arg: IO_MEDIUM) is
			-- Set active_medium to `arg'.
		require
			arg_not_void: arg /= Void
		do
			active_medium := arg
		ensure
			active_medium_set: active_medium = arg and active_medium /= Void
		end

	set_tradables (arg: TRADABLE_DISPENSER) is
			-- Set tradables to `arg'.
		require
				arg_not_void: arg /= Void
		do
			tradables := arg
		ensure
			tradables_set: tradables = arg and
				tradables /= Void
		end

	set_session (arg: SESSION) is
			-- Set session to `arg'.
		require
			arg_not_void: arg /= Void
		do
			session := arg
		ensure
			session_set: session = arg and session /= Void
		end

feature -- Basic operations

	execute (msg: STRING) is
		deferred
		end

feature {NONE}

	send_ok is
			-- Send an "OK" message ID and the field separator to the client.
		do
			print_list (<<OK.out, "%T">>)
		end

	report_error (code: INTEGER; slist: ARRAY [ANY]) is
			-- Report `s' as an error message; include `code' ID at the
			-- beginning and `eom' at the end.
		do
			print_list (<<code.out, "%T">>)
			print_list (slist)
			print (eom)
		end

	report_server_error is
		do
			report_error (Error, <<"Server error: ",
				tradables.last_error>>)
		end

	print (o: GENERAL) is
			-- Redefinition of output method inherited from GENERAL to
			-- send output to active_medium
		do
			if o /= Void then
				active_medium.put_string (o.out)
			end
		end

	server_error: BOOLEAN is
			-- Did an error occur in the server?
		do
			Result := tradables.error_occurred
		end

invariant

	tradables_set: tradables /= Void

end -- class REQUEST_COMMAND
