note
	description: "Parser of command-line arguments for the Installation Tool"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class INSTALL_TOOL_COMMAND_LINE inherit

	COMMAND_LINE

	GENERAL_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature {NONE} -- Initialization

	prepare_for_argument_processing
		do
			application_dir := ""
		end

	finish_argument_processing
		do
			initialization_complete := True
		end

feature -- Access

	usage: STRING
			-- Message: how to invoke the program from the command-line
		do
			Result := "Usage: " + command_name + " <application_directory>%N"
		end

	mctrc_contents: STRING
			-- Contents to be placed into the official mctrc file
			
feature -- Access -- settings

	application_dir: STRING
			-- Full path of the application directory

feature -- Element change

	set_mctrc_contents (arg: STRING)
			-- Set `mctrc_contents' to `arg'.
		require
			arg_not_void: arg /= Void
		do
			mctrc_contents := arg
		ensure
			mctrc_contents_set: mctrc_contents = arg and mctrc_contents /= Void
		end

feature {NONE} -- Implementation

	set_application_dir
			-- Set `application_dir' and remove its settings from `contents'.
		do
			from
				application_dir := ""
				contents.start
				if not contents.item.is_empty then
					application_dir := contents.item
					contents.remove
					last_argument_found := True
				else
					contents.forth
				end
			until
				contents.exhausted
			loop
				-- Assume that if there are two or more arguments, the
				-- cause is a path with spaces being passed as an argument
				-- and try to duplicate the original path.
				if not contents.item.is_empty then
					application_dir := application_dir + " " + contents.item
					contents.remove
					last_argument_found := True
				else
					contents.forth
				end
			end
		end

feature {NONE} -- Implementation queries

	main_setup_procedures: LINKED_LIST [PROCEDURE [ANY, TUPLE []]]
			-- List of the set_... procedures that are called
			-- unconditionally - for convenience
		once
			create Result.make
			Result.extend (agent set_application_dir)
		end

	initialization_complete: BOOLEAN

feature {NONE} -- Implementation - Constants

	Application_dir_error: STRING
		"Application direcotry was not specified.%N"

invariant

end
