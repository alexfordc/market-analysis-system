note
	description: "An abstraction for a derivative instrument, which has %
		%an open interest field, such as futures contracts for a commodity %
		%or options contracts for a stock or stock index";
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class DERIVATIVE_INSTRUMENT inherit

	TRADABLE [OPEN_INTEREST_TUPLE]
		redefine
			symbol, make_ctf, short_description
		end

creation

	make

feature {NONE} -- Initialization

	make (sym: STRING; info: TRADABLE_DATA)
		require
			not_void: sym /= Void
			symbol_not_empty: not sym.is_empty
		do
			symbol := sym
			tradable_initialize
			information := info
		ensure
			symbol_set: symbol = sym
			info_set: information = info
		end

feature -- Access

	symbol: STRING

	name: STRING
		do
			if cached_name = Void then
				if information /= Void then
					information.set_symbol (symbol)
					cached_name := information.name
				else
					cached_name := symbol
				end
			end
			Result := cached_name
		end

	short_description: STRING = "Derivative instrument"

feature -- Status report

	has_open_interest: BOOLEAN = True

feature {NONE} -- Implementation

	make_ctf: COMPOSITE_TUPLE_FACTORY
		once
			create {COMPOSITE_OI_TUPLE_FACTORY} Result
		end

	information: TRADABLE_DATA

	cached_name: STRING

invariant

	has_open_interest: has_open_interest

end -- class DERIVATIVE_INSTRUMENT
