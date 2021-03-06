note
	description: "Builder of TRADE objects"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class TRADE_BUILDER inherit

	DATA_SCANNER
		rename
			make as ds_make_unused
		redefine
			product, tuple_maker
		end

creation

	make

feature {NONE} -- Initialization

	make (field_sep: STRING; in: like input)
		require
			in_not_void: in /= Void
			separators_not_void: field_sep /= Void
		do
			input := in
			field_separator := field_sep
			create tuple_maker
			create {LINKED_LIST [TRADE]} product.make
			make_value_setters
		ensure
			input = in
		end

feature -- Access

	product: LIST [TRADE]

	tuple_maker: TRADE_FACTORY

	field_separator: STRING

feature {NONE}

	create_product
		do
		end

	index_vector: ARRAY [INTEGER]
		once
			-- Hard code - make configurable later, if needed.
			Result := <<Date_index, Buy_sell_index, Open_close_index,
				Symbol_index, Units_index, Price_index, Commission_index>>
		end

	make_value_setters
		do
			create {LINKED_LIST [VALUE_SETTER]} value_setters.make
			add_value_setters (value_setters, index_vector)
		end

	add_value_setters (vs: LIST [VALUE_SETTER];
						i_vector: ARRAY [INTEGER])
			-- i_vector indicates which value_setters to insert into
			-- vs, in the order specified, using the xxx_index constants.
		require
			vs /= Void
		local
			value_setter_vector: ARRAY [VALUE_SETTER]
			setter: VALUE_SETTER
			i: INTEGER
		do
			i := 1
			create value_setter_vector.make (1, Commission_index)
			create {TRADE_DATE_SETTER} setter
			value_setter_vector.put (setter, i)
			i := i + 1
			create {TRADE_CHAR_SETTER} setter
			value_setter_vector.put (setter, i)
			i := i + 1
			create {TRADE_CHAR_SETTER} setter
			value_setter_vector.put (setter, i)
			i := i + 1
			create {TRADE_SYMBOL_SETTER} setter.make (field_separator @ 1)
			value_setter_vector.put (setter, i)
			i := i + 1
			create {TRADE_UNITS_SETTER} setter
			value_setter_vector.put (setter, i)
			i := i + 1
			create {TRADE_PRICE_SETTER} setter
			value_setter_vector.put (setter, i)
			i := i + 1
			create {TRADE_COMMISSION_SETTER} setter
			value_setter_vector.put (setter, i)
			from
				i := 1
			until
				i = i_vector.count + 1
			loop
				vs.extend (value_setter_vector @ (i_vector @ i))
				i := i + 1
			end
		end


feature {NONE} -- Tuple field-key constants

	Date_index: INTEGER = 1
	Buy_sell_index: INTEGER = 2
	Open_close_index: INTEGER = 3
	Symbol_index: INTEGER = 4
	Units_index: INTEGER = 5
	Price_index: INTEGER = 6
	Commission_index: INTEGER = 7

end -- TRADE_BUILDER
