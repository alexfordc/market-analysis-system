indexing
	description: "Builder of objects that are platform-dependent"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2000: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class PLATFORM_DEPENDENT_OBJECTS inherit

	GENERAL_UTILITIES
		export {NONE}
			all
		end

feature -- Access

	database_services: MAS_DB_SERVICES is
		do
			create {ECLI_SERVICES} Result.make
			if Result.fatal_error then
				log_errors (<<"Fatal database error: ",
					Result.last_error, ".%N">>)
			end
		end

	file_name_expander: FILE_NAME_EXPANDER is
		do
			create {UNIX_FILE_NAME_EXPANDER} Result
		end

end -- class PLATFORM_DEPENDENT_OBJECTS
