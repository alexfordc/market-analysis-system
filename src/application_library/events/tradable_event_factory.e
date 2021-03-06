note
	description:
		"Factory that parses an input sequence and creates a %
		%TRADABLE_EVENT with the result"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

deferred class TRADABLE_EVENT_FACTORY inherit

	GENERIC_FACTORY [TRADABLE_EVENT]
		redefine
			product
		end

	GLOBAL_SERVICES
		export {NONE}
			all
		end

	GLOBAL_APPLICATION
		export {NONE}
			all
				{ANY}
			event_types_by_key
		end

	EXCEPTIONS
		export {NONE}
			all
		end

feature -- Access

	input: ITERABLE_INPUT_SEQUENCE
			-- Input data from which to create TRADABLE_EVENTs

	product: TRADABLE_EVENT

	error_occurred: BOOLEAN
			-- Did an error occur on the last call to execute?

	last_error: STRING
			-- Description of last error that occurred

	field_separator: CHARACTER
			-- Field separator to use in scanning

feature {NONE} -- Implementation

	current_event_type: EVENT_TYPE
			-- Last EVENT_TYPE scanned by `scan_event_type'

	scan_event_type
			-- Scan the next event ID and set current_event_type to the event
			-- specified by that ID.
		local
			ID: INTEGER
		do
			input.read_integer
			ID := input.last_integer
			current_event_type := event_types_by_key @ ID
			if current_event_type = Void then
				last_error := concatenation (
					<<"Error occurred inputting event ID:",
					"  ID for non-existent event: ",
					ID, " - from ",
					input.name, " at character ", input.index>>)
				error_occurred := True
				raise ("scan_event failed with invalid ID")
			end
		end

	error_init
			-- Initialize error-handling attributes
		do
			last_error := Void
			error_occurred := False
		end

	skip_field_separator
			-- Scan the current character - expected to match field_separator.
		do
			input.read_character
			if input.last_character /= field_separator then
				last_error := concatenation (
					<<"Expected input field separator, '", field_separator,
					"', not encountered while reading ",
						input.name, " at character ", input.index,
						"%N(Actual character encountered was ",
						input.last_character>>)
				error_occurred := True
				raise ("skip_field_separator failed with invalid field %
						%separator")
			end
		end

end -- class TRADABLE_EVENT_FACTORY
