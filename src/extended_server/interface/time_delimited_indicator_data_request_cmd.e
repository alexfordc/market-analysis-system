indexing
	description:
		"A command that responds to a client request for indicator data %
		%delimited by a start date-time and an end date-time"
	note: "The default value of false is kept for `update_retrieved_tradable' %
		%to cut down on unecessary processing, since > 99%% of the time an %
		%indicator request will be accompanied by a market data request - %
		%`update_retrieved_tradable' is true in %
		%TIME_DELIMITED_MARKET_DATA_REQUEST_CMD."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2004: Jim Cochrane - %
		%License to be determined - will be non-public"

class TIME_DELIMITED_INDICATOR_DATA_REQUEST_CMD inherit

	INDICATOR_DATA_REQUEST_CMD
		rename
			additional_field_constraints_fulfilled as
			indicator_id_valid
		undefine
			expected_field_count, parse_remainder, set_print_parameters,
			ignore_tradable_cache, additional_post_parse_constraints_fulfilled
		redefine
			additional_field_constraints_msg
		end

	TIME_DELIMITED_DATA_REQUEST_CMD
		undefine
			send_response_for_tradable,
			additional_field_constraints_msg
		redefine
			parse_remainder,
			additional_field_constraints_fulfilled
		select
			additional_field_constraints_fulfilled
		end

creation

	make

feature {NONE} -- Hook routine implementations

	parse_remainder (fields: LIST [STRING]) is
		do
			parse_indicator_id (fields)
			{TIME_DELIMITED_DATA_REQUEST_CMD} Precursor (fields)
		end

	additional_field_constraints_fulfilled (fields: LIST [STRING]): BOOLEAN is
		do
			Result := True
			if not indicator_id_valid (fields) then
				Result := False
				additional_field_constraints_msg := indicator_id_not_integer_msg
			elseif
				not {TIME_DELIMITED_DATA_REQUEST_CMD} Precursor (fields)
			then
				Result := False
				additional_field_constraints_msg := empty_date_range_msg
			end
		ensure then
			false_if_indicator_id_invalid:
				not indicator_id_valid (fields) implies not Result
		end

	additional_field_constraints_msg: STRING

feature {NONE} -- Redefined routines

	expected_field_count: INTEGER is 4

feature {NONE} -- Implementation - constants

	date_time_spec_index: INTEGER is 4

end
