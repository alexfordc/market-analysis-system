indexing
	description:
		"Editor of COMMANDs to be used in a MAL application"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class APPLICATION_COMMAND_EDITOR inherit

	COMMAND_EDITOR
		export
			{NONE} all
		end

	APPLICATION_EDITOR
		redefine
			user_interface
		end

	GLOBAL_SERVICES
		export
			{NONE} all
		end

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make (ui: COMMAND_EDITING_INTERFACE) is
		require
			not_void: ui /= Void
		do
			user_interface := ui
		ensure
			set: user_interface = ui
		end

feature -- Access

	user_interface: COMMAND_EDITING_INTERFACE
			-- Interface used to obtain data selections from user

feature -- Basic operations

	edit_binary_boolean (cmd: BINARY_OPERATOR [ANY, BOOLEAN]) is
			-- Edit a BINARY_OPERATOR that takes BOOLEAN operands.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [BOOLEAN]
		do
			left ?= user_interface.command_selection_from_type (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s left operand">>), False)
			right ?= user_interface.command_selection_from_type (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s right operand">>), False)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_binary_real (cmd: BINARY_OPERATOR [ANY, REAL]) is
			-- Edit a BINARY_OPERATOR that takes REAL operands.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [REAL]
		do
			left ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s left operand">>), False)
			right ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s right operand">>), False)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
		end

	edit_minus_n (c: MINUS_N_COMMAND) is
			-- Edit a MINUS_N_COMMAND.
		require
			ui_set: user_interface /= Void
		local
			uop: UNARY_OPERATOR [ANY, REAL]
		do
			uop ?= c
			check
				c_is_valid_type: uop /= Void
			end
			inspect
				user_interface.character_choice (concatenation (<<"Adjust %
					%the ", c.generator, "'s n-value? (y/n) ">>), "yYnN")
			when 'y', 'Y' then
				c.set_n_adjustment (user_interface.integer_selection (
					concatenation (<<c.generator, "'s n-adjustment value">>)))
			end
			edit_mtlist_resultreal_n (uop)
		end

	edit_index_extractor (cmd: INDEX_EXTRACTOR) is
			-- Edit an INDEX_EXTRACTOR.
		require
			ui_set: user_interface /= Void
		local
			ix_cmd: INDEXED
		do
			ix_cmd ?= user_interface.command_selection_from_type (
				user_interface.Indexed, concatenation (<<cmd.generator,
					"'s operand">>), False)
			check
				selection_valid: ix_cmd /= Void
			end
			cmd.set_indexable (ix_cmd)
		end

	edit_managed_value (cmd: MANAGED_VALUE_COMMAND) is
			-- Edit a MANAGED_VALUE_COMMAND.
		require
			ui_set: user_interface /= Void
		local
			constant: CONSTANT
		do
			edit_unaryop_real (cmd)
			constant ?= user_interface.command_selection_from_type (
				user_interface.Constant_command, cmd.generator +
					"'s managed value", False)
			check
				selection_valid: constant /= Void
			end
			cmd.set_managed_value (constant)
		end

	edit_mtlist_resultreal (c: UNARY_OPERATOR [REAL, REAL]) is
			-- Edit `c's market tuple list and operator
			-- (RESULT_COMMAND [REAL]).
		require
			ui_set: user_interface /= Void
		do
			edit_mtlist (c)
			edit_unaryop_real (c)
		end

	edit_mtlist_resultreal_n (c: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit `c's market tuple list, operator (
			-- RESULT_COMMAND [REAL]), and n-value.
		require
			ui_set: user_interface /= Void
		local
			offset_cmd: LINEAR_OFFSET_COMMAND
		do
			edit_n (c)
			edit_mtlist (c)
			edit_unaryop (c)
			offset_cmd ?= c
			if offset_cmd /= Void then
				record_lowest_offset (offset_cmd)
			end
		end

	edit_resultreal_n (c: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit `c's operator (RESULT_COMMAND [REAL]), and n-value.
		require
			ui_set: user_interface /= Void
		do
			edit_n (c)
			edit_unaryop (c)
		end

	edit_n (c: COMMAND) is
			-- Edit `c's n-value.
		require
			ui_set: user_interface /= Void
		local
			cmd: N_RECORD_COMMAND
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			cmd.set_n (user_interface.integer_selection (
						concatenation (<<cmd.generator, "'s n-value">>)))
		end

	edit_mtlist (c: COMMAND) is
			-- Edit `c's market tuple list target.
		require
			ui_set: user_interface /= Void
		local
			cmd: LINEAR_COMMAND
		do
			cmd ?= c
			check
				c_is_valid_type: cmd /= Void
			end
			user_interface.set_use_market_function_selection (False)
			cmd.set (user_interface.market_function_selection (
				concatenation (<<"an indicator for ", cmd.generator,
								"'s input">>)).output)
		end

	edit_unaryop (cmd: UNARY_OPERATOR [ANY, REAL]) is
			-- Edit a UNARY_OPERATOR that takes a RESULT_COMMAND [REAL]
			-- operand.
		require
			ui_set: user_interface /= Void
		local
			rr_cmd: RESULT_COMMAND [REAL]
		do
			rr_cmd ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
						concatenation (<<cmd.generator, "'s operand">>),
						False)
			check
				selection_valid: rr_cmd /= Void
			end
			cmd.set_operand (rr_cmd)
		end

	edit_unaryop_real (cmd: UNARY_OPERATOR [REAL, REAL]) is
			-- Edit a UNARY_OPERATOR that returns a REAL value and
			-- takes a RESULT_COMMAND [REAL] operand.
		require
			ui_set: user_interface /= Void
		local
			rr_cmd: RESULT_COMMAND [REAL]
		do
			rr_cmd ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
						concatenation (<<cmd.generator, "'s operand">>),
						False)
			check
				selection_valid: rr_cmd /= Void
			end
			cmd.set_operand (rr_cmd)
		end

	edit_unary_boolean (cmd: UNARY_OPERATOR [BOOLEAN, BOOLEAN]) is
			-- Edit a UNARY_OPERATOR that returns a BOOLEAN value and
			-- takes a RESULT_COMMAND [BOOLEAN] operand.
		require
			ui_set: user_interface /= Void
		local
			bool_cmd: RESULT_COMMAND [BOOLEAN]
		do
			bool_cmd ?= user_interface.command_selection_from_type (
						user_interface.Boolean_result_command,
						concatenation (<<cmd.generator, "'s operand">>),
						False)
			check
				selection_valid: bool_cmd /= Void
			end
			cmd.set_operand (bool_cmd)
		end

	edit_offset (cmd: SETTABLE_OFFSET_COMMAND) is
			-- Edit a SETTABLE_OFFSET_COMMAND.
		local
			unop: UNARY_OPERATOR [ANY, REAL]
			offset: INTEGER
		do
			unop ?= cmd
			check
				cmd_is_a_unop_real: unop /= Void
			end
			edit_unaryop (unop)
			edit_mtlist (cmd)
			from
				offset := user_interface.integer_selection (
						concatenation (<<cmd.generator,
						"'s (left) offset value (must be non-negative)">>))
			until
				offset >= 0
			loop
				user_interface.show_message ("Negative value entered.")
				offset := user_interface.integer_selection (
						concatenation (<<cmd.generator,
						"'s (left) offset value (must be non-negative)">>))
			end
			cmd.set_offset (-offset)
			record_lowest_offset (cmd)
		end

	record_lowest_offset (cmd: LINEAR_OFFSET_COMMAND) is
			-- If `cmd's offset value (expected to be negative or 0) is
			-- lower than the current offset value, record the offset
			-- value so that the lowest (or highest-magnitude) value can
			-- be used to keep objects needing it consistent.
		do
			-- Important: The arithmetic negation of the `cmd.offset'
			-- (which is expected to be negative) is used - the
			-- `left_offset' value being set must be positive.
			if -cmd.external_offset > user_interface.left_offset then
				user_interface.set_left_offset (-cmd.external_offset)
			end
		end

	edit_boolean_numeric_client (cmd: BOOLEAN_NUMERIC_CLIENT) is
			-- Edit a BOOLEAN_NUMERIC_CLIENT.
		local
			boolop: RESULT_COMMAND [BOOLEAN]
			result_cmd: RESULT_COMMAND [REAL]
		do
			-- Obtain and set cmd's boolean operator.
			boolop ?= user_interface.command_selection_from_type (
						user_interface.Boolean_result_command,
							concatenation (<<cmd.generator,
								"'s boolean operator">>), False)
			check
				selection_valid: boolop /= Void
			end
			cmd.set_boolean_operator (boolop)
			-- Obtain and set cmd's true command.
			result_cmd ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s true command">>), False)
			check
				selection_valid: result_cmd /= Void
			end
			cmd.set_true_cmd (result_cmd)
			-- Obtain and set cmd's false command.
			result_cmd ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
							concatenation (<<cmd.generator,
								"'s false command">>), False)
			check
				selection_valid: result_cmd /= Void
			end
			cmd.set_false_cmd (result_cmd)
		end

	edit_sign_analyzer (cmd: SIGN_ANALYZER) is
			-- Edit a SIGN_ANALYZER.
		require
			ui_set: user_interface /= Void
		local
			left, right: RESULT_COMMAND [REAL]
			sign_spec_vector: ARRAY [ARRAY [INTEGER]]
			choices: LIST [PAIR [STRING, BOOLEAN]]
			pair: PAIR [STRING, BOOLEAN]
		do
			create sign_spec_vector.make (1, 6)
			sign_spec_vector.put (<<-1, 1>>, 1)
			sign_spec_vector.put (<<1, -1>>, 2)
			sign_spec_vector.put (<<-1, 0>>, 3)
			sign_spec_vector.put (<<1, 0>>, 4)
			sign_spec_vector.put (<<0, -1>>, 5)
			sign_spec_vector.put (<<0, 1>>, 6)
			left ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
								concatenation (<<cmd.generator,
									"'s left operand">>), False)
			right ?= user_interface.command_selection_from_type (
						user_interface.Real_result_command,
								concatenation (<<cmd.generator,
									"'s right operand">>), False)
			check
				selections_valid: left /= Void and right /= Void
			end
			cmd.set_operands (left, right)
			create {LINKED_LIST [PAIR [STRING, BOOLEAN]]} choices.make
			create pair.make ("negative to positive", False)
			choices.extend (pair)
			create pair.make ("positive to negative", False)
			choices.extend (pair)
			create pair.make ("negative to zero", False)
			choices.extend (pair)
			create pair.make ("positive to zero", False)
			choices.extend (pair)
			create pair.make ("zero to negative", False)
			choices.extend (pair)
			create pair.make ("zero to positive", False)
			choices.extend (pair)
			user_interface.choice (concatenation (<<"slope specification for ",
				cmd.generator>>), choices, choices.count)
			from
				choices.start
			until
				choices.exhausted
			loop
				if choices.item.right then
					cmd.add_sign_change_spec (sign_spec_vector @ choices.index)
				end
				choices.forth
			end
			debug
				print ("sign analyzer's sign spec:%N")
				from
					cmd.sign_change_spec.start
				until
					cmd.sign_change_spec.exhausted
				loop
					print (cmd.sign_change_spec.item)
					print ("%N")
					cmd.sign_change_spec.forth
				end
			end
		end

	edit_constant (cmd: CONSTANT) is
			-- Edit a simple command that takes a REAL value
			-- (such as CONSTANT).
		require
			ui_set: user_interface /= Void
		do
			cmd.set_value (user_interface.real_selection (
								concatenation (<<cmd.generator, "'s value">>)))
		end

	edit_function_based_command (cmd: FUNCTION_BASED_COMMAND) is
			-- Edit a FUNCTION_BASED_COMMAND.
		do
			-- Always allow the user to select a FUNCTION_BASED_COMMAND's
			-- market function.
			user_interface.set_use_market_function_selection (True)
			cmd.set_input (user_interface.market_function_selection (
				concatenation (<<"an indicator for ", cmd.generator,
								"'s input">>)))
			edit_unaryop_real (cmd)
		end

end -- APPLICATION_COMMAND_EDITOR
