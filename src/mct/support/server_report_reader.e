note
	description: "Poll command that reads a MAS server's startup status report"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
class SERVER_REPORT_READER inherit

	POLL_COMMAND
		redefine
			active_medium
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

create

	make

feature -- Access

	response: STRING
			-- The response from the server

feature -- Basic operations

	execute (arg: ANY)
		local
			socket: NETWORK_STREAM_SOCKET
			response_received: BOOLEAN
		do
			response := ""
			active_medium.set_blocking
			active_medium.set_timeout (Timeout_interval)
			active_medium.listen (1)
			if active_medium.socket_ok and active_medium.ready_for_reading then
				active_medium.accept
				socket := active_medium.accepted
				if socket /= Void and then socket.socket_ok then
					socket.read_stream (Buffer_size)
					if socket.last_string /= Void then
						response := socket.last_string
					end
					response_received := True
				else
					if socket /= Void then
						response := socket.error
						response_received := True
					end
				end
				if socket /= Void and then not socket.is_closed then
					socket.close
				end
			else
				if active_medium.socket_ok then
					response := Timeout_error
				elseif
					active_medium.error /= Void and then
					not active_medium.error.is_empty
				then
					response := active_medium.error
				else
					response := Connection_failed
				end
			end
		ensure then
			response_exists: response /= Void
		end

feature {NONE} -- Implementation

	active_medium: NETWORK_STREAM_SOCKET

	Buffer_size: INTEGER
		once
			Result := (2 ^ 14).floor
		end

	Timeout_error: STRING = "Timed out waiting for the server to start."

	Connection_failed: STRING = "Connection to server failed."

	Timeout_interval: INTEGER = 9

end
