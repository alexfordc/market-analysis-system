indexing
	description: "Tools for displaying 'help' information"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class HELP_TOOLS inherit

	GUI_TOOLS
		export
			{NONE} all
		end

create

	make

feature {NONE} -- Initialization

	make is
		do
		end

feature -- Access

	introduction: EV_TITLED_WINDOW is
			-- MCT introduction
		local
			help: EV_TEXT
		do
			create Result.make_with_title (intro_title)
			help := default_help (Result)
			help.set_text ("Here it is ......%N%N%
				%Can you read this? .......................................................................................................")
		end

feature {NONE} -- Implementation - constants

	Intro_title: STRING is "MAS Control Terminal Introduction"

	Default_width: INTEGER is 450

feature {NONE} -- Implementation

	default_help (w: EV_TITLED_WINDOW): EV_TEXT is
			-- A default help text object with `w' as its parent and
			-- with default initialization performed on `w'
		do
			create Result
			Result.disable_edit
			Result.set_minimum_width (Default_width)
			w.key_press_actions.extend (agent close_on_esc (?, w))
			w.close_request_actions.extend (agent w.destroy)
			add_close_window_accelerator (w)
			w.extend (Result)
		end

invariant

end
