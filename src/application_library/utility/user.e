note
	description: "Abstraction for a user with an email address, etc."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class USER inherit

	APP_ENVIRONMENT
		rename
			mailer as app_env_mailer
		export
			{NONE} all
			{ANY} deep_twin, is_deep_equal, standard_is_equal
		end

	EXCEPTIONS
		export {NONE}
			all
		end

creation

	make

feature {NONE} -- Initialization

	make
		do
			create email_addresses.make
		end

feature -- Access

	name: STRING
			-- User name

	mailer: STRING
			-- Name of program to use for sending email

	email_subject_flag: STRING
			-- Flag to use with mailer to specify subject line

	email_addresses: LINKED_LIST [STRING]
			-- email addresses

	primary_email_address: STRING
		do
			if not email_addresses.is_empty then
				Result := email_addresses @ 1
			end
		end

	last_error: STRING
			-- Error message for last error that occurred

feature -- Element change

	add_email_address (arg: STRING)
			-- Add the email address `arg'.
		require
			arg_not_void: arg /= Void
		do
			email_addresses.extend (arg)
		ensure
			one_more: email_addresses.count = old email_addresses.count + 1
		end

	set_name (arg: STRING)
			-- Set name to `arg'.
		require
			arg_not_void: arg /= Void
		do
			name := arg
		ensure
			name_set: name = arg and name /= Void
		end

	set_mailer (arg: STRING)
			-- Set mailer to `arg'.
		require
			arg_not_void: arg /= Void
		do
			mailer := arg
		ensure
			mailer_set: mailer = arg and mailer /= Void
		end

	set_email_subject_flag (arg: STRING)
			-- Set email_subject_flag to `arg'.
		require
			arg_not_void: arg /= Void
		do
			email_subject_flag := arg
		ensure
			email_subject_flag_set: email_subject_flag = arg and
									email_subject_flag /= Void
		end

feature -- Basic operations

	notify_by_email (s, subject: STRING)
			-- Send message `s' to the user by email with `subject' as the
			-- subject.  If the send fails, last_error will reference
			-- an appropriate error message.
		require
			s_not_void: s /= Void
			at_least_one_address: not email_addresses.is_empty
			mailer_not_void: mailer /= Void
		local
			msg_file: PLAIN_TEXT_FILE
			mail_cmd: STRING
		do
			-- @@@Note: In the future it may be appropriate to replace the
			-- mailing functionality here with a better, more sophisticated
			-- "event-delivery" system of some kind, which would make it easier
			-- to implement a working solution on Windows and to allow more
			-- options for "event-message" delivery.
			last_error := Void
			msg_file := temporary_file (email_addresses @ 1)
			if not tmp_file_failed then
				msg_file.put_string (s)
				create mail_cmd.make (25)
				mail_cmd.append (mailer)
				mail_cmd.extend (' ')
				if
					email_subject_flag /= Void and then subject /= Void
					and then not subject.is_empty
				then
					mail_cmd.append (email_subject_flag)
					mail_cmd.append (" '")
					mail_cmd.append (subject)
					mail_cmd.append ("' ")
				end
				mail_cmd.append (email_addresses @ 1)
				-- OS-specific construct here:
				mail_cmd.append (Input_redirect)
				mail_cmd.append (msg_file.name)
				msg_file.flush
				system (mail_cmd)
				if return_code /= 0 then
					last_error := "Command '" + mail_cmd + "' failed%N" +
						"with non-zero return code: " + return_code.out + ".%N"
				end
				if not msg_file.is_closed then msg_file.close end
				msg_file.delete
			end
		end

feature {NONE} -- Implementation

	temporary_file (s: STRING): PLAIN_TEXT_FILE
			-- Temporary file for writing - new file
		require
			not_void: s /= Void
		local
			tmpdir: DIRECTORY
			i: INTEGER
			fname, dirname: STRING
			exception_occurred: BOOLEAN
		do
			if exception_occurred then
				set_last_error (<<"Failed to open temporary file: ",
								fname, " (", meaning(exception), ")">>)
				tmp_file_failed := True
			else
				tmp_file_failed := False
				dirname := app_directory
				if dirname = Void then
					dirname := current_working_directory
				end
				create tmpdir.make (dirname)
				if not tmpdir.exists then
					create tmpdir.make (".")
				end
				fname := s.twin
				fname.append_integer (s.hash_code)
				fname.prepend_character (Directory_separator)
				fname.prepend_string (tmpdir.name)
				tmpdir.open_read
				from
					i := 1
				until
					not tmpdir.has_entry (fname) or i > 20
				loop
					fname.append_integer (i)
					i := i + 1
				end
				if tmpdir.has_entry (fname) then
					tmp_file_failed := True
					set_last_error (<<"Failed to open temporary file: ",
									fname>>)
				else
					create Result.make_open_write (fname)
				end
			end
		ensure
			failed_or_writable: tmp_file_failed or else Result.is_open_write
		rescue
			exception_occurred := True
			retry
		end

	tmp_file_failed: BOOLEAN

	set_last_error (a: ARRAY [STRING])
		local
			i: INTEGER
		do
			create last_error.make (0)
			from
				i := 1
			until
				i > a.count
			loop
				last_error.append (a @ i)
				i := i + 1
			end
		end

feature {NONE} -- Implementation - Constants

	Input_redirect: STRING = " <"

invariant

	eaddrs_not_void: email_addresses /= Void
	primary_eaddr_definition: not email_addresses.is_empty implies
			primary_email_address = email_addresses @ 1

end -- USER
