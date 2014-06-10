note

	description:
		"A poll command specialized for the Market Analysis server"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

deferred class MA_POLL_COMMAND

inherit

feature -- Access

	factory_builder: GLOBAL_OBJECT_BUILDER
			-- Builder of objects to be used by an interface

feature {NONE}

	interface: MAIN_APPLICATION_INTERFACE
		deferred
		end

invariant

	factory_builder_exists: factory_builder /= Void

end
