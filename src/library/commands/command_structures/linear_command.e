indexing
	description: "Result commands that are also linear analyzers"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class LINEAR_COMMAND inherit

	RESULT_COMMAND [REAL]
		export {MARKET_FUNCTION}
			initialize
		redefine
			execute, initialize
		end

	SETTABLE_LINEAR_ANALYZER
		export
			{NONE} all
			{COMMAND_EDITOR, MARKET_FUNCTION_EDITOR} set
		end

	INDEXED

feature -- Initialization

	initialize (a: LINEAR_ANALYZER) is
		do
			set (a.target)
		end

feature -- Access

	index: INTEGER is
		do
			Result := target.index
		end

feature -- Status report

	index_is_target_based: BOOLEAN is
			-- Is `index' derived from `target.index'?
		do
			-- Default to True; redefine if needed.
			Result := True
		end

feature -- Basic operations

	execute (arg: ANY) is
		deferred
		ensure then
			target_cursor_internal_contract:
			target_cursor_not_affected implies (target.index = old target.index)
		end

feature -- Status report

	target_cursor_not_affected: BOOLEAN is
			-- Will target.index not change when execute is called?
		deferred
		end

invariant

	index_value_if_target_based: index_is_target_based implies
		index = target.index

end -- class LINEAR_COMMAND
