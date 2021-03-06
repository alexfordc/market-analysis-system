note
    description:
        "Function parameter place-holders - valid for a MAS_SESSION"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

class SESSION_FUNCTION_PARAMETER inherit

    FUNCTION_PARAMETER
        redefine
            verbose_name
        end

creation {MAS_SESSION}

    make

feature {NONE} -- Initialization

    make (param: FUNCTION_PARAMETER; namecounts: HASH_TABLE [INTEGER, STRING])
        require
            valid_args: param /= Void
        do
            occurrences_for := namecounts
            current_value := param.current_value
            source_parameter := param
        ensure
            current_value_set: current_value ~ param.current_value
        end

feature -- Access

    current_value: STRING

    name, verbose_name: STRING
        do
            if saved_name = Void then
                saved_name := source_parameter.verbose_name
                if occurrences_for[saved_name] > 1 then
                    saved_name := unique_param_name(saved_name)
                end
            end
            Result := saved_name
        end

    source_parameter: FUNCTION_PARAMETER

    description: STRING
        do
            Result := source_parameter.description
        end

    value_type_description: STRING
        do
            Result := source_parameter.value_type_description
        end

    current_value_equals (v: STRING): BOOLEAN
        do
            Result := v ~ current_value
        end

    owner: TREE_NODE
        do
            Result := source_parameter.owner
        end

feature -- Element change

    change_value (new_value: STRING)
        do
            current_value := new_value
        end

feature -- Basic operations

    valid_value (v: STRING): BOOLEAN
        do
            Result := v /= Void
        end

feature {NONE} -- Implementation

    saved_name: STRING

    occurrences_for: HASH_TABLE [INTEGER, STRING]

    randomness: RANDOM
        once
            create Result.make
            Result.start
        end

    summary (param: FUNCTION_PARAMETER; inttag: INTEGER_REF): STRING
            -- param's name and important details
            -- If `inttag' is not Void, include it in the name.
        local
            ancs: TWO_WAY_TREE [TREE_NODE]
            tag: STRING
        do
            if inttag /= Void then
                tag := "[" + inttag.out + "]"
            else
                tag := ""
            end
            ancs := param.owner.ancestors
            Result := param.verbose_name + tag + " (" + ancs.count.out +
                " ancestors):\n"
            ancs.linear_representation.do_all
                (agent (node: TREE_NODE; report: STRING)
                    require
                        existence: node /= Void and report /= Void
                    local
                        n: STRING
                    do
                        n := node.name
                        if n.empty then
                            n := node.node_type
                        end
--                        report.append(n + ": " + node.out + "\n")
                        report.append("   " + n + "\n")
                    end
                (?, Result))
            Result.replace_substring_all("%N", "\n")
        end

    tree_summary (param: FUNCTION_PARAMETER; inttag: INTEGER_REF): STRING
            -- param's name and important details
            -- level: child/indent level - 0 => root
            -- If `inttag' is not Void, include it in the name.
        local
            node: TWO_WAY_TREE [TREE_NODE]
            tag, n: STRING
        do
            if inttag /= Void then
                tag := "[" + inttag.out + "]"
            else
                tag := ""
            end
            node := param.owner.ancestors
            Result := param.verbose_name + tag + " (" + node.count.out +
                " ancestors):\n"
            Result := Result + tree_info(node, 1)
        end

    tree_info (node: TWO_WAY_TREE [TREE_NODE]; level: INTEGER): STRING
            -- ....
            -- level: child/indent level - 0 => root
        local
            ancs: TWO_WAY_TREE [TREE_NODE]
            margin: STRING
            app: expanded APP_ENVIRONMENT
        do
            create margin.make_filled(' ', level * TAB_SIZE)
            Result := node.item.name
            if Result.empty then
                Result := node.item.node_type
            end
            if app.debug_level > 1 then
                Result := Result + " (" + node.item.out + ")"
                if app.debug_level < 3 then
                    -- (Throw away all but the chars up to the 1st newline.)
                    Result := Result.substring(1, Result.index_of('%N', 1) - 1)
                else
                    Result.replace_substring_all("%N", "\n" + margin)
                end
            end
            Result := margin + Result
            from
                node.child_start
            until
                node.child_off
            loop
                Result := Result + "\n" + tree_info(node.child, level + 1)
                node.child_forth
            end
        end

    MAX_NAME_TRIES: INTEGER = 5

    unique_param_name(oldname: STRING): STRING
            -- Obtain and return an unused name for `source_parameter'.
        local
            tries: INTEGER
            curname: STRING
            tag: INTEGER_REF
            exc: expanded EXCEPTION
            app: expanded APP_ENVIRONMENT
        do
            Result := Void
            tag := Void
            from
                tries := 0
            until
                Result /= Void or tries = MAX_NAME_TRIES
            loop
                if app.debug_level > 0 then
                    curname := tree_summary(source_parameter, tag)
                else
                    curname := summary(source_parameter, tag)
                end
                if not occurrences_for.has(curname) then
                    occurrences_for[oldname] := occurrences_for[oldname] - 1
                    occurrences_for[curname] := 1
                    Result := curname
                else
                    tries := tries + 1
                    create tag
                    tag.set_item(tries)
                end
            end
            if Result = Void then
                randomness.forth
                tag.set_item(randomness.item)
                if app.debug_level > 0 then
                    curname := tree_summary(source_parameter, tag)
                else
                    curname := summary(source_parameter, tag)
                end
                if not occurrences_for.has(curname) then
                    occurrences_for[oldname] := occurrences_for[oldname] - 1
                    occurrences_for[curname] := 1
                    Result := curname
                end
            end
            if Result = Void then
                exc.set_description(
                    "Could not find unique name for parameter " + name)
                exc.raise
            end
        end

    TAB_SIZE: INTEGER = 3

end
