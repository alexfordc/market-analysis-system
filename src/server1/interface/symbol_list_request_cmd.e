indexing
	description: "A command that responds to a GUI client request for all %
		%available market symbols"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class MARKET_LIST_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND
		redefine
			error_context
		end


creation

	make

feature {NONE} -- Basic operations

	do_execute (msg: STRING) is
		local
			symbols: LIST [STRING]
		do
			put_ok
			symbols := tradables.symbols
			if not symbols.is_empty then
				from
					symbols.start
				until
					symbols.islast
				loop
					put (symbols.item)
					put (Output_record_separator)
					symbols.forth
				end
				put (symbols.last)
			end
			put (eom)
		end

	error_context (msg: STRING): STRING is
		do
			Result := "retrieving symbol list"
		end

end -- class MARKET_LIST_REQUEST_CMD
