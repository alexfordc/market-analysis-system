note
	description:
		"Implementation of STOCK_SPLITS that loads its contents from a file"
	note1:
		"It is assumed that the for each symbol that occurs in the input %
		%file, the splits in the file for that symbol are sorted by %
		%date ascending"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class STOCK_SPLIT_FILE inherit

	STOCK_SPLIT_SEQUENCE
		rename
			make as sss_make_unused, name as file_name
		undefine
			open_for_reading
		select
			last_error_fatal
		end

	INPUT_FILE
		rename
			name as file_name, make as ptf_make,
			advance_to_next_field as if_advance_to_next_field,
			advance_to_next_record as if_advance_to_next_record,
			last_error_fatal as last_error_fatal_unused
		export
			{STOCK_SPLIT_FILE} all
			{ANY} file_name, file_readable, exists
		select
			if_advance_to_next_field, if_advance_to_next_record
		end

creation

	make

feature -- Access

    record_error_limit: INTEGER = 0

feature {NONE} -- Initialization

	make (field_sep, record_sep, input_file_name: STRING)
		require
			not_void: field_sep /= Void and input_file_name /= Void
			fsep_size_1: field_sep.count = 1
		do
			debug ("stock_split_file")
				print (generating_type + ": make was called" + "%N")
			end
			field_separator := field_sep
			record_separator := record_sep
			set_name(input_file_name)
			open_file(file_name)
			create product.make (100)
			create tuple_maker
			make_value_setters
			if is_open_read then
				input := Current
				execute
				close
			end
		ensure
			fs_set: field_separator.is_equal (field_sep)
			ss_set: record_separator.is_equal (record_sep)
			fname_set: file_name = input_file_name
			input_file_set_if_open: is_open_read implies input = Current
			value_setters_made_if_open:
				is_open_read implies value_setters /= Void
			prod_tpmkr_made_if_open:
				is_open_read implies product /= Void and tuple_maker /= Void
			rec_sep_is_newline: record_separator.is_equal ("%N")
		end

	open_file (fname: STRING)
			-- Open file safely - if it fails, is_open_read is False.
		do
			ptf_make (file_name)
			if exists then
				open_read
			end
		end

invariant

	file_fields_not_void:
		field_separator /= Void and file_name /= Void

end -- STOCK_SPLIT_FILE
