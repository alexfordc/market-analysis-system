note
	description: "DATA_SCANNER that scans TRADABLE_TUPLE fields"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADABLE_TUPLE_DATA_SCANNER inherit

	DATA_SCANNER [BASIC_TRADABLE_TUPLE]
		rename
			make as data_scanner_make
		export {NONE}
			data_scanner_make
		redefine
			product, open_tuple, close_tuple, do_last_error_check,
			handle_last_error, tuple_maker
		end

	GENERAL_UTILITIES
		export {NONE}
			all
		end

creation

	make

feature

	make (prod: like product; in: like input;
			tm: like tuple_maker; vs: like value_setters)
		require
			args_not_void: in /= Void and tm /= Void and vs /= Void and
							prod /= Void
			vs_not_empty: not vs.is_empty
		do
			data_scanner_make (in, tm, vs)
			product := prod
		ensure
			set: input = in and tuple_maker = tm and
				value_setters = vs and product = prod
			non_strict: strict_error_checking = False
		end

feature -- Access

	product: SIMPLE_FUNCTION [BASIC_TRADABLE_TUPLE]

	tuple_maker: BASIC_TUPLE_FACTORY

	product_count: INTEGER do Result := product.count end

    record_error_limit: INTEGER = 100

feature {FACTORY} -- Status setting

	set_product (arg: like product)
			-- Set product to `arg'.
		require
			arg /= Void
		do
			product := arg
		ensure
			product_set: product = arg and product /= Void
		end

feature {NONE} -- Hook method implementations

	create_product
		do
		end

	open_tuple (t: BASIC_TRADABLE_TUPLE)
		do
			t.begin_editing
		ensure then
			t.editing
		end

	tuple_maker_execute
		do
			tuple_maker.execute
		end

	tuple_maker_product: BASIC_TRADABLE_TUPLE
		do
			Result := tuple_maker.product
		end

	do_last_error_check (t: BASIC_TRADABLE_TUPLE)
		do
			if not discard_current_tuple then
				-- If t.date_time is Void, the date_time error has already
				-- been encountered and handled.
				if t.date_time /= Void then
					check_date_time (t)
				end
				check_and_fix_prices (t)
			end
		end

	close_tuple (t: BASIC_TRADABLE_TUPLE)
		do
			t.end_editing
		ensure then
			not t.editing
		end

	handle_last_error
		local
			last_record_index: INTEGER
			s: STRING
		do
			last_record_index := product.data.count
			if discard_current_tuple then
				s := concatenation (<<"Error occurred after record ",
					input.record_index>>)
			else
				s := concatenation (<<"Error occurred in record ",
					input.record_index>>)
			end
			if last_record_index >= 1 then
				s.append (concatenation (<<" (with date/time ",
					product.data.last.date_time, ")">>))
			end
			s.append (".")
			if discard_current_tuple then
				s.append ("%NDiscarding corrupted record.")
			end
			error_list.extend (s)
		end

feature {NONE} -- Implementation

	check_and_fix_prices (t: BASIC_TRADABLE_TUPLE)
			-- Check `t's prices and fix them if they are not valid.
		local
			s: STRING
		do
			if not t.price_relationships_correct then
				create s.make (100)
				s.append ("Error in prices for tuple, date: ")
				s.append (t.date_time.date.out)
				s.append (", time: ")
				s.append (t.date_time.time.out)
				if t.open_available then
					s.append (", values (o, h, l, c): ")
					s.append (t.open.value.out)
					s.append (", ")
				else
					s.append (", values (h, l, c): ")
				end
				s.append (t.high.value.out)
				s.append (", ")
				s.append (t.low.value.out)
				s.append (", ")
				s.append (t.close.value.out)
				t.fix_price_relationships
				error_list.extend (s)
				error_in_current_tuple := True
				if strict_error_checking then
					discard_current_tuple := True
				end
			end
		end

	check_date_time (t: BASIC_TRADABLE_TUPLE)
		require
			t_exists: t /= Void
		local
			s: STRING
		do
			if
				last_date_time /= Void and not (t.date_time > last_date_time)
			then
				create s.make (0)
				s.append ("Error in date - date for current item: ")
				s.append (t.date_time.out)
				s.append (", date for last item: ")
				s.append (last_date_time.out)
				error_list.extend (s)
				error_in_current_tuple := True
				discard_current_tuple := True
			end
			auxiliary_check_date_time (t)
			last_date_time := t.date_time
		ensure then
			last_date_time_set: last_date_time = t.date_time
		end

	last_date_time: DATE_TIME
			-- date/time of last tuple

feature {NONE} -- Hook routines

	auxiliary_check_date_time (t: BASIC_TRADABLE_TUPLE)
		do
		end

end -- class TRADABLE_TUPLE_DATA_SCANNER
