indexing
	description: "Builders of MAS Control Terminal application windows"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class APPLICATION_WINDOW_BUILDER inherit

feature -- Access

	main_window: EV_TITLED_WINDOW is
			-- The MAS Control Terminal main window
		local
			main_box: EV_VERTICAL_BOX
		do
			create Result.make_with_title (Main_window_title)
			-- Avoid flicker on some platforms.
			Result.lock_update
			create current_main_actions.make (configuration)
			create main_box
			current_main_actions.set_owner_window (Result)
			Result.extend (main_box)
			add_main_window_components (main_box)
			Result.set_menu_bar (main_window_menu_bar)
			add_main_accelerators (Result)
			-- Allow screen refresh on some platoforms.
			Result.unlock_update
		ensure
			result_exists: Result /= Void
			title_set: Result.title.is_equal (Main_window_title)
		end

	mas_session_window: SESSION_WINDOW is
			-- A MAS session window
		local
			main_box: EV_VERTICAL_BOX
		do
			create Result.make_with_title (Session_window_title)
			-- Avoid flicker on some platforms.
			Result.lock_update
			create current_mas_session_actions.make (configuration)
			create main_box
			current_mas_session_actions.set_owner_window (Result)
			Result.extend (main_box)
			add_mas_session_window_components (main_box)
			Result.set_menu_bar (mas_session_window_menu_bar)
			add_session_accelerators (Result)
			-- Allow screen refresh on some platoforms.
			Result.unlock_update
		ensure
			result_exists: Result /= Void
			title_set: Result.title.is_equal (Session_window_title)
		end

	configured_session_window (hostname, portnumber: STRING): SESSION_WINDOW is
			-- A new SESSION_WINDOW with port number and host name set to
			-- the specified values
		do
			Result := mas_session_window
			Result.set_host_name (hostname)
			Result.set_port_number (portnumber)
		end

feature {NONE} -- Main-window components

	main_window_menu_bar: EV_MENU_BAR is
			-- Menu bar for the main window
		do
			create Result
			Result.extend (main_file_menu)
			Result.extend (advanced_menu)
			Result.extend (help_menu)
		end

	add_main_window_components (c: EV_CONTAINER) is
			-- Add all components (buttons) needed for the main window
		local
			action_set: ACTION_SET
			action_sets: expanded ACTION_SETS
		do
			action_sets.set_main_actions (current_main_actions)
			action_set := action_sets.start_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.connect_to_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.terminate_arbitrary_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.exit_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
		end

feature {NONE} -- Session-window components

	mas_session_window_menu_bar: EV_MENU_BAR is
			-- Menu bar for MAS session window
		do
			create Result
			Result.extend (session_file_menu)
			Result.extend (help_menu)
		end

	add_mas_session_window_components (c: EV_CONTAINER) is
			-- Add all components (buttons) needed for a MAS session window
		local
			action_set: ACTION_SET
			action_sets: expanded ACTION_SETS
		do
			action_sets.set_mas_session_actions (current_mas_session_actions)
			action_set := action_sets.start_chart_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.start_command_line_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.terminate_session_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
			action_set := action_sets.close_window_set
			c.extend (widget_builder.new_button (action_set.widget_label,
				action_set.actions))
		end

feature {NONE} -- Menu components

	main_file_menu: EV_MENU is
			-- The file menu for the main window
		require
			current_actions_exist: current_main_actions /= Void or
				current_mas_session_actions /= Void
		do
			create Result.make_with_text (file_menu_title)
			common_file_menu_items.do_all (agent Result.extend)
		end

	session_file_menu: EV_MENU is
			-- The file menu for session windows
		require
			current_actions_exist: current_mas_session_actions /= Void
		do
			create Result.make_with_text (file_menu_title)
			Result.extend (widget_builder.new_menu_item (close_menu_item_title,
				<<agent current_mas_session_actions.close_window>>))
			Result.extend (create {EV_MENU_SEPARATOR})
			common_file_menu_items.do_all (agent Result.extend)
		end

	advanced_menu: EV_MENU is
			-- The 'advanced' menu
		require
			current_main_actions_exist: current_main_actions /= Void
		do
			create Result.make_with_text (edit_menu_title)
			Result.extend (widget_builder.new_menu_item (
				server_startup_menu_item_title,
				<<agent current_main_actions.configure_server_startup>>))
			Result.extend (widget_builder.new_menu_item (
				preferences_menu_item_title,
				<<agent current_main_actions.edit_preferences>>))
		end

	help_menu: EV_MENU is
			-- The help menu
		require
			current_actions_exist: current_main_actions /= Void or
				current_mas_session_actions /= Void
		local
			actions: ACTIONS
		do
			if current_main_actions /= Void then
				actions := current_main_actions
			else
				actions := current_mas_session_actions
			end
			create Result.make_with_text (help_menu_title)
			Result.extend (widget_builder.new_menu_item (
				introduction_menu_item_title,
				<<agent actions.show_help_introduction>>))
			Result.extend (create {EV_MENU_SEPARATOR})
			Result.extend (widget_builder.new_menu_item (about_menu_item_title,
				<<agent actions.show_about_box>>))
		end

	common_file_menu_items: SEQUENCE [EV_MENU_ITEM] is
			-- "File" menu items used in all windows
		local
			actions: ACTIONS
		do
			if current_main_actions /= Void then
				actions := current_main_actions
			else
				actions := current_mas_session_actions
			end
			create {LINKED_LIST [EV_MENU_ITEM]} Result.make
			Result.extend (widget_builder.new_menu_item (quit_menu_item_title,
				<<agent actions.exit>>))
			Result.extend (widget_builder.new_menu_item (
				quit_without_menu_item_title,
				<<agent actions.exit_without_session_termination>>))
		end

feature {NONE} -- Miscellaneous

	add_common_accelerators (w: EV_TITLED_WINDOW) is
			-- Associate main MCT accelerators with `w'.
		require
			current_actions_exist: current_main_actions /= Void or
				current_mas_session_actions /= Void
		local
			accelerator: EV_ACCELERATOR
			key_constants: expanded EV_KEY_CONSTANTS
			actions: ACTIONS
		do
			if current_main_actions /= Void then
				actions := current_main_actions
			else
				actions := current_mas_session_actions
			end
			-- Add a 'quit' accelerator.
			accelerator := widget_builder.default_accelerator (
				key_constants.key_q)
			accelerator.actions.extend (agent actions.exit)
			w.accelerators.extend (accelerator)
			-- Add a 'quit without terminating sessions' accelerator.
			accelerator := widget_builder.default_accelerator (
				key_constants.key_u)
			accelerator.actions.extend (
				agent actions.exit_without_session_termination)
			w.accelerators.extend (accelerator)
			-- Add an 'introduction' accelerator.
			accelerator := widget_builder.default_accelerator (
				key_constants.key_i)
			accelerator.actions.extend (agent actions.show_help_introduction)
			w.accelerators.extend (accelerator)
		end

	add_main_accelerators (w: EV_TITLED_WINDOW) is
			-- Associate main MCT accelerators with `w'.
		require
			current_actions_exist: current_main_actions /= Void or
				current_mas_session_actions /= Void
		local
			accelerator: EV_ACCELERATOR
			key_constants: expanded EV_KEY_CONSTANTS
			actions: ACTIONS
		do
			if current_main_actions /= Void then
				actions := current_main_actions
			else
				actions := current_mas_session_actions
			end
			add_common_accelerators (w)
			-- Add a 'server startup configuration' accelerator activated
			-- with Ctrl and 's'.
			accelerator := widget_builder.default_accelerator (
				key_constants.key_s)
			accelerator.actions.extend (
				agent current_main_actions.configure_server_startup)
			w.accelerators.extend (accelerator)
		end

	add_session_accelerators (w: EV_TITLED_WINDOW) is
			-- Associate session accelerators with `w'.
		require
			current_actions_exist: current_main_actions /= Void or
				current_mas_session_actions /= Void
		local
			accelerator: EV_ACCELERATOR
			key_constants: expanded EV_KEY_CONSTANTS
			actions: ACTIONS
		do
			if current_main_actions /= Void then
				actions := current_main_actions
			else
				actions := current_mas_session_actions
			end
			add_common_accelerators (w)
			-- Create a close-window accelerator.
			accelerator := widget_builder.default_accelerator (
				key_constants.key_w)
			accelerator.actions.extend (agent actions.close_window)
			w.accelerators.extend (accelerator)
		end

feature {NONE} -- Implementation

	current_main_actions: MAIN_ACTIONS

	current_mas_session_actions: MAS_SESSION_ACTIONS

	widget_builder: expanded WIDGET_BUILDER

	configuration: MCT_CONFIGURATION is
		once
			create Result.make
		end

feature {NONE} -- Implementation - Constants

	Main_window_title: STRING is "MAS Control Panel"
			-- Title of the main window

	Session_window_title: STRING is "MAS"
			-- Title of mas-session windows

	file_menu_title: STRING is "&File"

	close_menu_item_title: STRING is
		"&Close Window Ctl+W"

	quit_menu_item_title: STRING is 
		"&Quit Ctl+Q"

	quit_without_menu_item_title: STRING is
		"Q&uit without terminating sessions Ctl+U"

	help_menu_title: STRING is "&Help"

	about_menu_item_title: STRING is "&About"

	introduction_menu_item_title: STRING is "MCT &Introduction Ctl+I"

	edit_menu_title: STRING is "&Edit"

	server_startup_menu_item_title: STRING is
		"&Server startup configuration Ctl+S"

	preferences_menu_item_title: STRING is "&Preferences"

invariant

	configuration_exists: configuration /= Void

end
