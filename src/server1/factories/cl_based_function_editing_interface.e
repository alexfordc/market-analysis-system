indexing
	description:
		"Abstraction that allows the user to build MARKET_FUNCTIONs from %
		%the command line"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class CL_BASED_FUNCTION_EDITING_INTERFACE inherit

	MAS_COMMAND_LINE_UTILITIES
		rename
			print_message as show_message
		export
			{ANY} input_device, output_device
		end

	FUNCTION_EDITING_INTERFACE
		undefine
			print
		redefine
			help, end_save
		end

	TERMINABLE
		export
			{NONE} all
		undefine
			print
		end

	GLOBAL_SERVER_FACILITIES
		export
			{NONE} all
		undefine
			print
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		undefine
			print
		end

	EXECUTION_ENVIRONMENT
		export
			{NONE} all
		undefine
			print
		end

	FUNCTION_MENU_VALUES
		export
			{NONE} all
		undefine
			print
		end

	OBJECT_EDITING_VALUES
		export
			{NONE} all
		undefine
			print
		end

creation

	make

feature -- Initialization

	make (dispenser: TRADABLE_DISPENSER) is
		do
			create operator_maker.make (False)
			create editor.make (Current, operator_maker)
			create help.make
			register_for_termination (Current)
			tradable_dispenser := dispenser
		ensure
			editor_exists: editor /= Void
		end

feature -- Status setting

	set_input_device (arg: IO_MEDIUM) is
			-- Set input_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			input_device := arg
			operator_maker.set_input_device (arg)
		ensure
			input_device_set: input_device = arg and input_device /= Void
		end

	set_output_device (arg: IO_MEDIUM) is
			-- Set output_device to `arg'.
		require
			arg_not_void: arg /= Void
		do
			output_device := arg
			operator_maker.set_output_device (arg)
		ensure
			output_device_set: output_device = arg and output_device /= Void
		end

feature {NONE} -- Implementation

	help: HELP

	operator_maker: CL_BASED_COMMAND_EDITING_INTERFACE

	tradable_dispenser: TRADABLE_DISPENSER

feature {NONE} -- Implementation of hook methods

	main_indicator_edit_selection: INTEGER is
		local
			msg: STRING
			cr, rm, vw, ed, sv, prev: INDICATOR_EDITING_CHOICE
		do
			create cr.make_creat; create rm.make_remove; create ed.make_edit
			create vw.make_view; create sv.make_save; create prev.make_previous
			check
				io_devices_not_void: input_device /= Void and
					output_device /= Void
			end
			if not dirty or not ok_to_save then
				msg := "Select action:%N     " +
					enum_menu_string (cr, cr.item_description, " ") +
					enum_menu_string (rm, rm.item_description, "%N     ") +
					enum_menu_string (vw, vw.item_description, " ") +
					enum_menu_string (ed, ed.item_description, " ") +
					enum_menu_string (prev, prev.item_description, " ") + eom
			else
				msg := "Select action:%N     " +
					enum_menu_string (cr, cr.item_description, " ") +
					enum_menu_string (rm, rm.item_description, "%N     ") +
					enum_menu_string (vw, vw.item_description, " ") +
					enum_menu_string (ed, ed.item_description, " ") +
					enum_menu_string (sv, sv.item_description, "%N     ") +
					enum_menu_string (prev, prev.item_description,
						" - abort changes ") + eom
			end
			from
				Result := Null_value
			until
				Result /= Null_value
			loop
				inspect
					character_enumeration_selection (msg, cr.all_members).item
				when creat, creat_u then
					Result := Create_new_value
				when remove, remove_u then
					Result := Remove_value
				when view, view_u then
					Result := View_value
				when edit, edit_u then
					Result := Edit_value
				when sav, sav_u then
					if not dirty or not ok_to_save then
						print ("%NInvalid selection%N")
					else
						Result := Save_value
					end
				when shell_escape then
					execute_shell_command
				when previous then
					Result := Exit_value
				else
					check	-- Should never be reached.
						selection_always_valid: False
					end
				end
				print ("%N%N")
			end
		end

	accepted_by_user (c: MARKET_FUNCTION): BOOLEAN is
		local
			desc_chc, another_chc, choice_chc: FUNCTION_MENU_CHOICE
			msg: STRING
		do
			create desc_chc.make_description; create another_chc.make_another;
			create choice_chc.make_choice
			msg := "Select:%N     Print description of " + c.generator +
				name_for (c) + "? (" + desc_chc.item.out + ")%N" +
				"     Choose " + c.generator + name_for (c) + " (" +
				choice_chc.item.out + ") Make another choice (" +
				another_chc.item.out + ") " + eom
			inspect
				character_enumeration_selection (msg, desc_chc.all_members).item
			when description, description_u then
				print ("%N" + function_description (c) + "%N%NChoose " +
					c.generator + name_for (c) + "? (y/n) " + eom)
				inspect
					character_selection (Void)
				when 'y', 'Y' then
					Result := True
				else
					check Result = False end
				end
			when choose, choose_u then
				Result := True
			when another_choice, another_choice_u then
				check Result = False end
			else
				check	-- Should never be reached.
					selection_always_valid: False
				end
			end
		end

	list_selection_with_backout (l: LIST [STRING]; msg: STRING): INTEGER is
		do
			Result := backoutable_selection (l, msg, Exit_value)
		end

	do_initialize_lock is
		do
			lock := file_lock (file_name_with_app_directory (
				indicators_file_name, False))
		end

	end_save is
		do
			-- Ensure current changes show up in the tradable_dispenser by
			-- clearing its caches.
			if tradable_dispenser /= Void then
				tradable_dispenser.clear_caches
			end
		end

end -- CL_BASED_FUNCTION_EDITING_INTERFACE
