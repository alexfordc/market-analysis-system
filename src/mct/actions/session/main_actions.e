indexing
	description: "Main MAS Control Terminal actions for GUI-event responses"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class MAIN_ACTIONS inherit

	ACTIONS

create

	make

feature {NONE} -- Initialization

	make (config: MCT_CONFIGURATION) is
		local
			cmd: EXTERNAL_COMMAND
		do
			create external_commands.make (0)
			cmd := config.default_start_server_command
			external_commands.put (cmd, cmd.identifier)
			configuration := config
		end

feature -- Actions

	connect_to_session is
			-- Connect to an existing MAS "session".
		local
			window: LOCATE_SESSION_WINDOW
		do
			create window.make
			window.register_client (agent respond_to_connection_request)
			window.show
		end

	terminate_arbitrary_session is
			-- Terminate an arbitrary MAS "session".
		local
			window: LOCATE_SESSION_WINDOW
		do
			create window.make
			window.register_client (agent respond_to_termination_request)
			window.show
		end

	start_server is
			-- Start the MAS server.
		local
			cmd: COMMAND
			portnumber: STRING
			wbldr: expanded WIDGET_BUILDER
			dialog: EV_WIDGET
			session_window: SESSION_WINDOW
		do
			portnumber := reserved_port_number
			if portnumber = Void then
				dialog := wbldr.new_error_dialog (
					"Port numbers are all in use.")
				dialog.show
			else
				session_window := new_session_window (
					configuration.hostname, portnumber)
				cmd := external_commands @
					configuration.Start_server_cmd_specifier
				cmd.execute (session_window)
			end
		end

	configure_server_startup is
			-- Configure how the server is to be started up.
		local
			cmds: LINEAR [EXTERNAL_COMMAND]
			window: LIST_SELECTION_WINDOW
			rows: LINKED_LIST [LIST [STRING]]
			label: STRING
		do
			create rows.make
			rows.extend (create {LINKED_LIST [STRING]}.make)
			-- Add muli-list column titles.
			rows.first.extend ("Command name")
			rows.first.extend ("Description")
			create server_cmd_table.make (
				configuration.start_server_commands.count)
			cmds := configuration.start_server_commands
			-- Add one row to `rows' for each element of `cmds'.
			from
				cmds.start
			until
				cmds.exhausted
			loop
				-- Add new row.
				rows.extend (create {LINKED_LIST [STRING]}.make)
				if cmds.item.name = Void or else cmds.item.name.is_empty then
					label := cmds.item.identifier
				else
					label := cmds.item.name
				end
				rows.last.extend (label)
				server_cmd_table.put (cmds.item, label)
				if cmds.item.description = Void then
					rows.last.extend ("")
				else
					rows.last.extend (cmds.item.description)
				end
				cmds.forth
			end
			create window.make ("Start-server selection", rows)
			window.show
			window.register_client (agent respond_to_server_selection_event)
		end

	edit_preferences is
			-- Edit "Preferences".
		do
			print ("Stub!!! (Will allow setting of (not) " +
				"%Nterminate on Quitting, among other things)%N")
		end

feature {NONE} -- Implementation - Callback routines

	respond_to_connection_request (supplier: LOCATE_SESSION_WINDOW) is
		local
			err: STRING
		do
			if supplier.state_changed then
				err := host_and_port_diagnosis (supplier.host_name,
					supplier.port_number)
				if
					err = Void
				then
					connect_to_located_session (supplier)
				else
					display_error (err)
				end
			end
		end

	respond_to_termination_request (supplier: LOCATE_SESSION_WINDOW) is
		local
			err: STRING
		do
			if supplier.state_changed then
				err := host_and_port_diagnosis (supplier.host_name,
					supplier.port_number)
				if
					err = Void
				then
					terminate_located_session (supplier)
				else
					display_error (err)
				end
			end
		end

	respond_to_server_selection_event (supplier: LIST_SELECTION_WINDOW) is
			-- Respond to a "start-server-selection" event.
		local
			selected_command: EXTERNAL_COMMAND
		do
			if supplier.selected_item /= Void then
				selected_command := server_cmd_table @
					supplier.selected_item.first
				check
					start_srvr_cmd_set: selected_command /= Void and
					selected_command.identifier.is_equal (
						configuration.Start_server_cmd_specifier) and
					external_commands.has (selected_command.identifier)
				end
				external_commands.replace (selected_command,
					selected_command.identifier)
			end
			-- !!Need to modify the mctrc file to mark the selected command
			-- as the default.
		end

feature {NONE} -- Implementation

	connect_to_located_session (supplier: LOCATE_SESSION_WINDOW) is
			-- Connect to the session whose host name and port number are
			-- specified by `supplier'.
		local
			session_window: SESSION_WINDOW
		do
			session_window := new_session_window (supplier.host_name,
				supplier.port_number)
			if not port_numbers_in_use.has (supplier.port_number) then
				port_numbers_in_use.extend (supplier.port_number)
			end
			session_window.show
		end

	terminate_located_session (supplier: LOCATE_SESSION_WINDOW) is
			-- Terminate the session whose host name and port number are
			-- specified by `supplier'.
		local
			session_actions: MAS_SESSION_ACTIONS
		do
			if not port_numbers_in_use.has (supplier.port_number) then
				port_numbers_in_use.extend (supplier.port_number)
			end
			create session_actions.make (configuration)
			session_actions.set_owner_window (supplier)
			session_actions.terminate_session
		end

	reserved_port_number: STRING is
		local
			pnums: LIST [STRING]
		do
			from
				pnums := configuration.valid_portnumbers
				pnums.start
			until
				Result /= Void or pnums.exhausted
			loop
				if not port_numbers_in_use.has (pnums.item) then
					Result := pnums.item
					port_numbers_in_use.extend (pnums.item)
				end
				pnums.forth
			end
		end

	new_session_window (hostname, portnumber: STRING): SESSION_WINDOW is
			-- A new SESSION_WINDOW with port number `portnumber'
		local
			builder: expanded APPLICATION_WINDOW_BUILDER
		do
			Result := builder.mas_session_window
			Result.set_host_name (hostname)
			Result.set_port_number (portnumber)
		end

	host_and_port_diagnosis (host, port: STRING): STRING is
			-- Diagnosis of validity of `host' and `port' - Void if they
			-- both are valid; otherwise a description of the problem
		do
			if not port.is_integer then
				Result := "Invalid port number: " + port
			end
			-- !!!Check that host is valid.
			-- !!!If valid, Connect/disconnect to the MAS server as a
			-- client to test that it is running and reachable - report if not.
		end

	display_error (s: STRING) is
			-- Display error message `s'.
		local
			dialog: EV_WIDGET
			wbldr: expanded WIDGET_BUILDER
		do
			dialog := wbldr.new_error_dialog (s)
			dialog.show
		end

feature {NONE} -- Implementation - attributes

	server_cmd_table: HASH_TABLE [EXTERNAL_COMMAND, STRING]

end
