note
	description:
		"A storable list of MARKET_FUNCTIONs that wipes out each market %
		%function before saving it to persistent store"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class STORABLE_MARKET_FUNCTION_LIST inherit

	STORABLE_LIST [TRADABLE_FUNCTION]
		redefine
			save
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		undefine
			copy, is_equal
		end

	MARKET_FUNCTION_EDITOR
		undefine
			copy, is_equal
		end

creation

	make

feature -- Utility

	save
			-- Ensure that the output data lists of each market function
			-- are (recursively) cleared so that no extra data is stored to
			-- the file; then call precursor to save the remaining contents.
		local
			dummy_tradable: TRADABLE [BASIC_MARKET_TUPLE]
		do
			from
				start
			until
				exhausted
			loop
				create {STOCK} dummy_tradable.make ("dummy", Void, Void)
				dummy_tradable.set_trading_period_type (
					period_types @ (period_type_names @ Daily))
				-- Set innermost input to an empty tradable to force the
				-- market function to clear its contents.
				item.set_innermost_input (dummy_tradable)
				forth
			end
			Precursor
		end

end -- STORABLE_MARKET_FUNCTION_LIST
