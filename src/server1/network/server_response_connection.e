note
	description: "Client socket connection for sending a response back to %
		%the process that started the MAS server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class SERVER_RESPONSE_CONNECTION inherit

	CLIENT_CONNECTION
		export
			{NONE} connected
			{ANY} send_one_time_request
		end

	MA_COMMUNICATION_PROTOCOL
		export
			{NONE} all
		end

creation

	make_tested

feature -- Basic operations

feature {NONE} -- Implementation

	end_of_message (c: CHARACTER): BOOLEAN
			-- Does `c' indicate that the end of the data from the server
			-- has been reached?
		do
			Result := c = eom @ 1
		end

feature {NONE} -- Implementation - constants

	Timeout_seconds: INTEGER = 10

	Message_date_field_separator: STRING = ""

	Message_time_field_separator: STRING = ""

invariant

end
