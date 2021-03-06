note
    description: "An abstraction for a stock, such as IBM stock";
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    note1: "!!!!Possible idea for implementation of a 'cut-off' of date %
        %based on an 'end_date_time':  In the appropriate hook routine, %
        %query the parent(s) or ancestors for an end_date and use that %
        %end date for iteration - e.g., in 'exhausted'.[end-date-cutoff]!!!"
    -- settings: vim: expandtab

class STOCK inherit

    TRADABLE [VOLUME_TUPLE]
        export {ANY}
            valid_stock_processor
        redefine
            symbol, make_ctf, short_description, finish_loading,
            valid_indicator
        end

creation

    make

feature {NONE} -- Initialization

    make (sym: STRING; stock_splits: DYNAMIC_CHAIN [STOCK_SPLIT];
                sd: STOCK_DATA)
        require
            not_void: sym /= Void
            symbol_not_empty: not sym.is_empty
            splits_sorted_by_date: stock_splits /= Void and
                not stock_splits.is_empty implies
                    splits_sorted_by_date (stock_splits)
        do
            symbol := sym
            tradable_initialize
            splits := stock_splits
            stock_info := sd
        ensure
            symbol_set: symbol = sym
            splits_built: stock_splits /= Void implies splits /= Void
            info_set: stock_info = sd
        end

feature -- Access

    splits: DYNAMIC_CHAIN [STOCK_SPLIT]
            -- List of all (recorded) stock splits for the stock

    symbol: STRING

    name: STRING
        do
            if cached_name = Void then
                if stock_info /= Void then
                    stock_info.set_symbol (symbol)
                    cached_name := stock_info.name
                else
                    cached_name := symbol
                end
            end
            Result := cached_name
        end

    short_description: STRING = "Stock"

feature -- Status report

    valid_indicator (f: TRADABLE_FUNCTION): BOOLEAN
        do
            Result := valid_stock_processor (f)
        ensure then
            valid_for_stock: Result = valid_stock_processor (f)
        end

    has_open_interest: BOOLEAN = False

    splits_sorted_by_date (sp: like splits): BOOLEAN
            -- Is `sp' sorted by date ascending?
        require
            not_void_or_empty: sp /= Void and not sp.is_empty
        local
            previous_date: DATE
        do
            Result := True
            from
                sp.start
                previous_date := sp.item.date
                sp.forth
            invariant
                previous_date = sp.i_th (sp.index - 1).date
            --     and
            -- (for_all i such_that 1 < i <= sp.index - 1 it_holds
            --  sp.i_th (i-1).date < sp.i_th (i).date)
            variant
                sp.count - sp.index + 1
            until
                not Result or sp.after
            loop
                if previous_date >= sp.item.date then
                    Result := False
                else
                    check
                        prev_lt_current: previous_date < sp.item.date
                    end
                    previous_date := sp.item.date
                    sp.forth
                end
            end
        ensure
            -- Result = (for_all i such_that 1 < i <= sp.count it_holds
            --  sp.i_th (i-1).date < sp.i_th (i).date)
        end

feature {FACTORY, TRADABLE_FUNCTION_EDITOR} -- Status setting

    finish_loading
        do
            Precursor
            adjust_for_splits
        end

feature {NONE} -- Implementation

    adjust_for_splits
            -- Adjust tuples for stock splits.
        local
            first_item_date: DATE
        do
            if not is_empty and splits /= Void and not splits.is_empty then
                -- Since the date of some or all of the elements of splits may
                -- precede the date of the first element, move splits' cursor
                -- to the first element whose date > first.date_time.date.
                -- (Not >= because a split that becomes effective on a date,
                -- d, means that the price has already been adjusted for d.)
                from
                    splits.start
                    first_item_date := first.date_time.date
                until
                    splits.after or splits.item.date > first_item_date
                loop
                    splits.forth
                end
                check
                     date_gt: splits.after or splits.item.date >
                                first.date_time.date
                end
                if not splits.after then
                    do_split_adjustment
                end
            end
        end

    do_split_adjustment
        require
            lists_not_empty: not is_empty and splits /= Void and
                not splits.is_empty
            not_splits_off: not splits.off
            splt_date_gt_first: splits.item.date > first.date_time.date
            prev_splt_date_le_first: not splits.isfirst implies
                splits.i_th (splits.index - 1).date <= first.date_time.date
        local
            split_ratio: DOUBLE
            saved_cursor: CURSOR
        do
            saved_cursor := splits.cursor
            from
                split_ratio := 1
            until
                splits.after
            loop
                split_ratio := split_ratio * splits.item.value
                splits.forth
            end
            splits.go_to (saved_cursor)
            from
                start
            invariant
                -- for_all i such_that 1 <= i < index it_holds
                --   adjusted_for_split (i_th (i), splits)
                --     Where adjusted_for_split (item, splist) means
                --       item has been adjusted for all splits in splist
                --       whose dates apply to (are greater than)
                --       item.date_time.date
            until
                splits.after or after
            loop
                item.adjust_for_split (split_ratio)
                forth
                if
                    not after and splits.item.date <= item.date_time.date
                then
                    split_ratio := split_ratio / splits.item.value
                    splits.forth
                end
            end
            check
                -- after implies that some data is missing - allowed for
                -- robustness:
                missing_data_condition:
                    after implies last.date_time.date < splits.last.date
                for_current_item_to_end_there_are_no_more_splits:
                    not after implies item.date_time.date >= splits.last.date
                split_ratio_equals_1: dabs (split_ratio - 1) < epsilon
            end
        end

    make_ctf: COMPOSITE_TUPLE_FACTORY
        once
            create {COMPOSITE_VOLUME_TUPLE_FACTORY} Result
        end

    stock_info: STOCK_DATA

    cached_name: STRING

invariant

    splits_sorted_by_date:
        splits /= Void and not splits.is_empty implies
            splits_sorted_by_date (splits)
    no_open_interest: not has_open_interest

end -- class STOCK
