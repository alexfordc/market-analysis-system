indexing
	description:
		"A numeric command that operates on the current item of a linear %
		%structure of market tuples"
	date: "$Date$";
	revision: "$Revision$"

class BASIC_LINEAR_COMMAND inherit

	LINEAR_COMMAND

creation

	make

feature -- Basic operations

	execute (arg: ANY) is
				-- Can be redefined by ancestors.
		do
			value := target.item.value
		end

feature -- Status report

	arg_used: BOOLEAN is false

end -- class BASIC_LINEAR_COMMAND
