note
	description:
		"A MAS server command that responds to a client request"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MAS_REQUEST_COMMAND inherit

	IO_BASED_CLIENT_REQUEST_COMMAND
		redefine
			session
		end

	GUI_COMMUNICATION_PROTOCOL
		export
			{NONE} all
		end

	DATE_TIME_PROTOCOL
		export
			{NONE} all
		end

feature -- Access

	session: MAS_SESSION

feature -- Status report

	arg_mandatory: BOOLEAN = True

feature {NONE}

	ok_string: STRING
			-- "OK" message ID and field separator
		note
			once_status: global
		once
			Result := OK.out + message_component_separator
		end

end
