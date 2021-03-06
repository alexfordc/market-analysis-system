note
	description: "A command that responds to a client request for a list %
		%of indicators available for a specified tradable"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class INDICATOR_LIST_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		redefine
			error_context, send_response_for_tradable
		end

creation

	make

feature {NONE} -- Hook routine implementations

	expected_field_count: INTEGER = 2

	symbol_index: INTEGER = 1

	period_type_index: INTEGER = 2

	send_response_for_tradable (t: TRADABLE [BASIC_TRADABLE_TUPLE])
		local
			ilist: LIST [TRADABLE_FUNCTION]
		do
			put_ok
			ilist := t.indicators
			if not ilist.is_empty then
				from
					ilist.start
				until
					ilist.islast
				loop
					put (ilist.item.name)
					put (message_record_separator)
					ilist.forth
				end
				put (ilist.last.name)
			end
			put (eom)
		end

	error_context (msg: STRING): STRING
		do
			Result := concatenation (<<error_context_prefix, market_symbol>>)
		end

feature {NONE} -- Implementation - constants

	error_context_prefix: STRING = "retrieving indicator list for "

end -- class INDICATOR_LIST_REQUEST_CMD
