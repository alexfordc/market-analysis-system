note
	description: "Windows that present a multi-column list for selection"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class LIST_SELECTION_WINDOW inherit

	EV_TITLED_WINDOW

	EVENT_SUPPLIER
		undefine
			default_create, copy
		end

	GUI_TOOLS
		export
			{NONE} all
		undefine
			default_create, copy
		end

create

	make

feature {NONE} -- Initialization

	make (ttl: STRING; rows: LIST [LIST [STRING]])
		require
			args_exist: ttl /= Void and rows /= Void
			title_row_exists: rows.count > 0
		do
			make_with_title (ttl)
			create_contents (rows)
		ensure
			count_set: list.count = rows.count
			column_count_set: list.column_count = rows.first.count
			title_set: title.is_equal (ttl)
		end

feature -- Access

	selected_item: EV_MULTI_COLUMN_LIST_ROW
			-- Row selected by the user
		do
			Result := list.selected_item
		end

	list: EV_MULTI_COLUMN_LIST
			-- The selection list

feature {NONE} -- Implementation - initialization

	create_contents (rows: LIST [LIST [STRING]])
		do
			-- Avoid flicker on some platforms.
			lock_update
			extend (components (rows))
			add_close_window_accelerator (Current)
			close_request_actions.extend (agent destroy)
			key_press_actions.extend (agent close_on_esc (?, Current))
			-- Allow screen refresh on some platoforms.
			unlock_update
		end

	components (rows: LIST [LIST [STRING]]): EV_CONTAINER
		do
			create {EV_VERTICAL_BOX} Result
			create list
			add_titles (rows.first)
			create max_list_widths.make (1, rows.first.count)
			update_list_widths (rows.first)
			rows.prune (rows.first)
			-- Add all the `rows' to `list'.
			rows.linear_representation.do_all (agent add_row)
			list.key_press_actions.extend (agent key_response)
			list.pointer_double_press_actions.extend (
				agent double_click_response)
			list.disable_multiple_selection
			Result.extend (list)
			set_max_list_widths
			list.set_minimum_size (max_list_width * Estimated_character_width,
				Extra_height + (rows.count + 1) * Estimated_character_height)
		end

	add_row (l: LIST [STRING])
			-- Add row `l' to `list'.
		local
			r: EV_MULTI_COLUMN_LIST_ROW
		do
			create r
			l.do_all (agent r.extend)
			update_list_widths (l)
			list.extend (r)
		end

	add_titles (row: LIST [STRING])
			-- Add the column titles for the selection list.
		do
			from
				row.start
			until
				row.exhausted
			loop
				list.set_column_title (row.item, row.index)
				row.forth
			end
		end

	update_list_widths (l: LIST [STRING])
		do
			from
				l.start
			until
				l.exhausted
			loop
				if l.item.count > max_list_widths @ l.index then
					max_list_widths.put (l.item.count, l.index)
				end
				l.forth
			end
		end

	set_max_list_widths
		local
			i: INTEGER
		do
			from
				i := max_list_widths.lower
			until
				i = max_list_widths.upper + 1
			loop
				max_list_width := max_list_width + max_list_widths @ i
				max_list_widths.put (max_list_widths @ i *
					Estimated_character_width, i)
				i := i + 1
			end
			list.set_column_widths (max_list_widths)
		end

feature {NONE} -- Implementation - attributes

	max_list_widths: ARRAY [INTEGER]

	max_list_width: INTEGER

feature {NONE} -- Implementation - constants

	Estimated_character_width: INTEGER = 8

	Estimated_character_height: INTEGER = 24

	Extra_height: INTEGER = 18

feature {NONE} -- Implementation - GUI callback routines

	key_response (key: EV_KEY)
			-- Response to key-press event
		local
			keys: expanded EV_KEY_CONSTANTS
		do
			if key.code = keys.key_enter then
				respond_to_selection
			end
		end

	double_click_response (i, j, k: INTEGER; x, y, z: DOUBLE; l, m: INTEGER)
			-- Response to double-click event
		do
			respond_to_selection
		end

feature {NONE} -- Implementation

	respond_to_selection
		do
			notify_clients
			destroy
		end

invariant

	list_exists: list /= Void

end
