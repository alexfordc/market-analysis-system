indexing
	description: "A command that responds to a GUI client request for all %
		%available market symbols"
	status: "Copyright 1998 - 2000: Jim Cochrane and others; see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class MARKET_LIST_REQUEST_CMD inherit

	REQUEST_COMMAND

creation

	make

feature -- Basic operations

	execute (msg: STRING) is
		local
			symbols: LIST [STRING]
		do
			send_ok
			symbols := market_list_handler.symbols
			if not symbols.empty then
				from
					symbols.start
				until
					symbols.islast
				loop
					print (symbols.item)
					print (Output_record_separator)
					symbols.forth
				end
				print (symbols.last)
			end
			print (eom)
		end

end -- class MARKET_LIST_REQUEST_CMD
