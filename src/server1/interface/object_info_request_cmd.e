note
    description:
        "A command that responds to a client request for a list of all %
        %indicators currently known to the system"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class OBJECT_INFO_REQUEST_CMD inherit

    TRADABLE_REQUEST_COMMAND
        redefine
        end

    GLOBAL_APPLICATION
        export
            {NONE} all
        end

inherit {NONE}
    STRING_UTILITIES
        rename
            make as su_make_unused
        export
            {NONE} all
        end

creation

    make

feature {NONE} -- Basic operations
--message_component_separator: STRING = "%T"
--message_record_separator: STRING = "%N"
--message_sub_field_separator:STRING = ","

--object_info_req:  object_list
--object_list:  { object_spec "\n" ... }
--object_spec:  object_type "," object_name
--object_type:  "indicator" | "event-generator"
--object_name:  ta_string


    -- Expected message format:
    -- <ind-name>\t<param-idx1>:<value1>,<param-idx2>:<value2>,...
    do_execute(message: ANY)
        local
            msg: STRING
            records: LIST [STRING]
            fields: LIST [STRING]
        do
            msg := message.out
            parse_error := False
            target := msg -- set up for tokenization
            records := tokens(message_record_separator)
            error_msg := ""
            response := ""
            across records as record loop
                detailed := False
                debugging := False
                current_indent := 0
                target := record.item
                fields := tokens(message_sub_field_separator)
                add_response_for_processor(fields)
                response.right_adjust
                response := response + object_separator.out
            end
            if not parse_error then
                response.remove_tail(1) -- Remove final 'object_separator'
                send_response
            else
                report_error(Error, <<error_msg>>)
            end
        end

feature {NONE} -- Implementation

    object_separator: CHARACTER = '%/0x1A/'

    parse_error: BOOLEAN
            -- Did a parse error occur?

    error_msg: STRING

    minimum_field_count: INTEGER = 2

    response: STRING

    indicator_tag: STRING = "indicator"

    generator_tag: STRING = "event-generator"

    detailed: BOOLEAN
            -- Is response more detailed than normal?

    debugging: BOOLEAN
            -- The most detailed response?

    html_on: BOOLEAN
            -- Is the response to be in html format?

    opts_detail: STRING = "detail"

    opts_debug: STRING = "debug"

    opts_html: STRING = "html"

    current_indent: INTEGER

    tab_size: INTEGER = 3

    indents(n: INTEGER): STRING
        local
            i: INTEGER
        do
            Result := ""
            i := tab_size * n
            across 1 |..| i as x from loop
                Result := Result + " "
            end
        end

feature {NONE}

    add_response_for_processor(fields: LIST [STRING])
        require
            fields_exist: fields /= Void
            err_msg_set: error_msg /= Void
            response_set: response /= Void
        local
            processor: TRADABLE_PROCESSOR
            invalid_name: BOOLEAN
            opt_fields: LIST [STRING]
        do
            if fields.count < minimum_field_count then
                parse_error := True
                error_msg := error_msg + "Format error: too few fields"
                if fields.count > 0 then
                    error_msg := error_msg + ": '"
                    error_msg := error_msg + fields[1] + "'"
                end
                error_msg := error_msg + "%N"
            else
                if fields.count > 2 then
                    target := fields[3]
                    opt_fields := tokens(";")
                    across opt_fields as opt loop
                        if opt.item ~ opts_detail then
                            detailed := True
                        elseif opt.item ~ opts_debug then
                            debugging := True
                        elseif opt.item ~ opts_html then
                            html_on := True
                        end
                    end
                end
                if fields[1] ~ indicator_tag then
                    processor := tradables.indicator_with_name(fields[2])
                    invalid_name := processor = Void
                elseif fields[1] ~ generator_tag then
                    processor := event_generator_with_name(fields[2])
                    invalid_name := processor = Void
                else
                    parse_error := True
                    error_msg := error_msg +
                        "Invalid object type: '" + fields[1] + "'%N"
                end
                if invalid_name then
                    parse_error := True
                    error_msg := error_msg + "Invalid name for " +
                        fields[1] + ": " + fields[2] + "%N"
                end
            end
            if not parse_error then
                response := response + report_for(processor)
            end
        ensure
            response /= Void
        end

    send_response
            -- Run market analysis on for `symbol' for all event types
            -- specified in `requested_event_types' between
            -- `analysis_start_date' and `analysis_end_date'.
        do
            put_ok
            put(response)
            put(eom)
        end

    report_for(proc: TRADABLE_PROCESSOR): STRING
            -- Information about `proc'
        require
            proc_exists: proc /= Void
        do
--!!!!Might need a 'recursion_on' flag to keep from reporting on the same
--!!!!components (such as operators and parameters) more than once.
            Result := indented(proc.name + ":%N")
            current_indent := current_indent + tab_size
            Result := Result + period_type_report(proc)
            Result := Result + functions_report(proc)
            Result := Result + operators_report(proc)
            Result := Result + parameters_report(proc)
            if detailed or debugging and proc.children.count > 0 then
                Result := Result + indented(proc.children.count.out +
                    " children:%N")
                current_indent := current_indent + tab_size
                across proc.children as chcursor loop
                    Result := Result + report_for(chcursor.item)
                end
                current_indent := current_indent - tab_size
            end
            current_indent := current_indent - tab_size
        ensure
            result_exists: Result /= Void
        end

    functions_report(proc: TRADABLE_PROCESSOR): STRING
        require
            proc_exists: proc /= Void
        do
            Result := indented(proc.functions.count.out + " functions:%N")
--            current_indent := current_indent + tab_size
            across proc.functions as fcursor loop
                Result := Result + function_parameter_report(fcursor.item)
            end
--            current_indent := current_indent - tab_size
        ensure
            result_exists: Result /= Void
        end

    operators_report(proc: TRADABLE_PROCESSOR): STRING
        require
            proc_exists: proc /= Void
        local
            i: INTEGER
        do
            Result := indented(proc.operators.count.out + " operators:%N")
--            current_indent := current_indent + tab_size
            i := 1
            if debugging then
                Result := Result + indented(proc.operators.out)
            end
            across proc.operators as fcursor loop
                if fcursor.item /= Void then
                    Result := Result + command_report(fcursor.item)
                else
                    Result := Result + indented(indents(1) + "(Operator " +
                        i.out + " is Void)%N")
                end
                i := i + 1
            end
--            current_indent := current_indent - tab_size
        ensure
            result_exists: Result /= Void
        end

    parameters_report(proc: TRADABLE_PROCESSOR): STRING
        require
            proc_exists: proc /= Void
        do
            Result := indented(proc.parameters.count.out + " parameters:%N")
            current_indent := current_indent + tab_size
            across proc.parameters as fcursor loop
                Result := Result + function_parameter_report(fcursor.item)
            end
        ensure
            result_exists: Result /= Void
        end

    function_parameter_report(f: FUNCTION_PARAMETER): STRING
        require
            f_exists: f /= Void
        do
            Result := ""
            if detailed or debugging then
                Result := Result + indented("name: " + f.name + "%N")
            end
            Result := Result + indented("unique-name: " + f.unique_name + "%N")
            Result := Result + indented("value: " + f.current_value + "%N")
            if detailed or debugging then
                Result := Result + indented("value type: " +
                    f.value_type_description + "%N")
            end
            if debugging then
                Result := Result + indented(f.out)
            end
        ensure
            result_exists: Result /= Void
        end

    command_report(c: COMMAND): STRING
        require
            c_exists: c /= Void
        do
            Result := ""
            Result := Result + indented("name: " + c.name + "%N")
            if debugging then
                Result := Result + indented(c.out)
            end
--!!!!!append children???? - under what conditions????!!!!!
        ensure
            result_exists: Result /= Void
        end

    period_type_report(proc: TRADABLE_PROCESSOR): STRING
            -- Period-type information, if any, for proc
        require
            proc_exists: proc /= Void
        do
            Result := ""
            if attached {FUNCTION_ANALYZER} proc as fana then
                Result := indented("period type: " + fana.period_type.name +
                    "%N")
                if debugging then
                    Result := Result + indented(fana.period_type.out)
                end
            end
        ensure
            result_exists: Result /= Void
        end

    indented(s: STRING): STRING
        local
            i: INTEGER
            indent: STRING
        do
            indent := ""
            from
                i := 1
            until
                i > current_indent
            loop
                indent := indent + " "
                i := i + 1
            end
            Result := indent + s
            Result.replace_substring_all("%N", "%N" + indent)
        end

end
