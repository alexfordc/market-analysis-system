indexing
	description: "Tradable factory that manufactures STOCKs"
	status: "Copyright 1998, 1999: Jim Cochrane - see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class STOCK_FACTORY inherit

	TRADABLE_FACTORY
		redefine
			product
		end

	OPERATING_ENVIRONMENT
		export
			{NONE} all
		end

	APP_ENVIRONMENT
		export
			{NONE} all
		end

creation

	make

feature -- Access

	product: STOCK

	tuple_maker: BASIC_TUPLE_FACTORY is
		do
			!VOLUME_TUPLE_FACTORY!Result
		end

feature {NONE}

	make_product is
		local
			i, last_sep_index: INTEGER
		do
			--!!!For now, set the name and symbol to `symbol'.
			!!product.make (symbol, time_period_type, stock_splits @ symbol)
			product.set_name (symbol)
		end

	index_vector: ARRAY [INTEGER] is
		do
			!!Result.make (1, 6)
			if no_open then
				Result := << Date_index, High_index, Low_index,
								CLose_index, Volume_index >>
			else
				Result := << Date_index, Open_index, High_index, Low_index,
								Close_index, Volume_index >>
			end
		end

	stock_splits: STOCK_SPLITS is
		once
			!STOCK_SPLIT_FILE!Result.make (
				split_field_separator, stock_split_file)
		end

	split_field_separator: STRING is "%T"
			-- !!!Hard code for now.

	stock_split_file: STRING is
		once
			if stock_split_file_name = Void then
				Result := "ma_stock_splits"
			else
				Result := file_name_with_app_directory (stock_split_file_name)
			end
		end

end -- STOCK_FACTORY
