note
	description: "Status of tradable data files"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_FILE_STATUS inherit

creation

	make

feature -- Initialization

	make (name: STRING; size: INTEGER)
		do
			file_size := size
			file_name := name
		ensure
			fields_set: file_size = size and file_name = name
		end

	make_with_mod_time (name: STRING; modtime, size: INTEGER)
		do
			--@@@note1: `last_modification_time' may no longer be needed.
			last_modification_time := modtime
			file_size := size
			file_name := name
		ensure
			fields_set: last_modification_time = modtime and
				file_size = size and file_name = name
		end

feature -- Access

	file_name: STRING
			-- The name of the associated file

	last_modification_time: INTEGER
			-- The last recorded modification time of the associated file

	file_size: INTEGER
			-- The last recorded size of the associated file

feature -- Element change

	set_last_modification_time (arg: INTEGER)
			-- Set `last_modification_time' to `arg'.
		require
			arg_not_negative: arg >= 0
		do
			last_modification_time := arg
		ensure
			last_modification_time_set: last_modification_time = arg
		end

	set_file_size (arg: INTEGER)
			-- Set `file_size' to `arg'.
		require
			arg_not_negative: arg >= 0
		do
			file_size := arg
		ensure
			file_size_set: file_size = arg
		end

feature {NONE} -- Implementation

invariant

end
