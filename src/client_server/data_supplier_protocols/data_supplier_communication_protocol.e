indexing

	description:
		"Constants specifying components of the 'data-supplier' server %
		%communication protocol"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class DATA_SUPPLIER_COMMUNICATION_PROTOCOL inherit

	BASIC_COMMUNICATION_PROTOCOL

feature -- Client request IDs

	symbol_list_request: INTEGER is 1
			-- Request for a list symbols for all available tradables

	tradable_data_request: INTEGER is 2
			-- Request for data for a specified tradable

feature -- Server response IDs

	ok: INTEGER is 101
			-- Response indicating that no errors occurred

	error: INTEGER is 102
			-- Response indicating that there was a problem receiving or
			-- parsing the client request

--!!!???:
	invalid_symbol: INTEGER is 103
			-- Response indicating that the server requested data for
			-- a symbol that is not in the database

--!!!???:
	warning: INTEGER is 104
			-- Response indicating that a non-fatal error occurred

end
