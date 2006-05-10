indexing
	description:
		"A command that responds to a client request for indicator data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class INDICATOR_DATA_REQUEST_CMD inherit

	DATA_REQUEST_CMD
		redefine
			error_context, send_response_for_tradable, parse_remainder,
			additional_field_constraints_fulfilled,
			additional_field_constraints_msg
		end

creation

	make

feature {NONE} -- Hook routine implementations

	expected_field_count: INTEGER is
		indexing
			once_status: global
		once
			Result := 3
		end

	symbol_index: INTEGER is 2

	period_type_index: INTEGER is 3

	additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN is
		do
			Result := fields.first.is_integer
			if not Result then
				indicator_id_not_integer_msg := indicator_id_msg_prefix +
					fields.first + indicator_id_msg_suffix
			end
		end

	send_response_for_tradable (t: TRADABLE [BASIC_MARKET_TUPLE]) is
		local
			indicator: MARKET_FUNCTION
		do
			if
				indicator_id < 1 or indicator_id > t.indicators.count
			then
				report_error (Error, <<invalid_indicator_id_msg>>)
			else
				t.set_target_period_type (trading_period_type)
				indicator := t.indicators @ indicator_id
				if not indicator.processed then
					indicator.process
				end
				set_print_parameters
				set_preface (ok_string)
				set_appendix (eom)
				print_indicator (indicator)
			end
		end

	parse_remainder (fields: LIST [STRING]) is
		do
			parse_indicator_id (fields)
		end

	error_context (msg: STRING): STRING is
		do
			Result := concatenation (<<error_context_prefix, market_symbol>>)
		end

	additional_field_constraints_msg: STRING is
		do
			Result := indicator_id_not_integer_msg
		end

feature {NONE} -- Implementation

	parse_indicator_id (fields: LIST [STRING]) is
		do
			indicator_id := fields.first.to_integer
		end

	indicator_id: INTEGER
			-- ID of the indicator requested by the user

	indicator_id_not_integer_msg: STRING

feature {NONE} -- Implementation - constants

	invalid_indicator_id_msg: STRING is "Invalid indicator ID"

	error_context_prefix: STRING is "retrieving indicator data for "

	indicator_id_msg_prefix: STRING is "Indicator ID "

	indicator_id_msg_suffix: STRING is " is not an integer"

end -- class INDICATOR_DATA_REQUEST_CMD
