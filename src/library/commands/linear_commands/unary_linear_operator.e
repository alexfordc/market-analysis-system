indexing
	description:
		"A unary operator that uses its operand to process the current %
		%item of a linear structure of market tuples"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class UNARY_LINEAR_OPERATOR inherit

	LINEAR_COMMAND
		undefine
			children
		redefine
			initialize
		select
			initialize
		end

	UNARY_OPERATOR [REAL, REAL]
		rename
			operate as operate_unused, initialize as uo_initialize
		undefine
			execute
		redefine
			arg_mandatory
		end

creation

	make

feature -- Initialization

	make (tgt: like target; op: like operand) is
		require
			not_void: tgt /= Void and op /= Void
		do
			target := tgt
			operand := op
		ensure
			set: target = tgt and operand = op
		end

	initialize (arg: LINEAR_ANALYZER) is
		do
			{LINEAR_COMMAND} Precursor (arg)
			uo_initialize (arg)
		end

feature -- Basic operations

	execute (arg: ANY) is
		do
			operand.execute (target.item)
			value := operand.value
		end

feature -- Status report

	arg_mandatory: BOOLEAN is false

	target_cursor_not_affected: BOOLEAN is
			-- True
		once
			Result := true
		end

end -- class UNARY_LINEAR_OPERATOR
