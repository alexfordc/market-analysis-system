indexing
	description: "Application-based processing of caught exceptions"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2003: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class EXCEPTION_PROCESSOR inherit

	EXCEPTION_SERVICES
		export
			{NONE} all
		undefine
			print
		end

	MAS_COMMAND_LINE_UTILITIES
		export
			{NONE} all
		end

creation

	make

feature -- Initialization

	make is
		do
		end

feature -- Basic operations

	abort_command_line_processing: BOOLEAN is
			-- Should command-line processing be aborted?
		do
			Result := fatal_cl_tag_names.has (tag_name)
		end

feature {NONE} -- Implementation

	fatal_cl_tag_names: LINEAR [STRING] is
			-- Tag names that are fatal for command-line processing
		local
			names: ARRAY [STRING]
		once
			names := <<"Broken pipe", Line_limit_reached>>
			Result := names.linear_representation
			Result.compare_objects
		ensure
			object_comparison: Result.object_comparison
		end

end
