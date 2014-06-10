note
	description: "A command that responds to a client request for all %
		%available market symbols"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class SYMBOL_LIST_REQUEST_CMD inherit

	TRADABLE_REQUEST_COMMAND
		redefine
			error_context
		end


creation

	make

feature {NONE} -- Basic operations

	do_execute (msg: STRING)
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
					put (message_record_separator)
					symbols.forth
				end
				put (symbols.last)
			end
			put (eom)
		end

	error_context (msg: STRING): STRING
		do
			Result := "retrieving symbol list"
		end

end -- class SYMBOL_LIST_REQUEST_CMD
