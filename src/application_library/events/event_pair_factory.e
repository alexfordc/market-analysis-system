indexing
	description: "A market event factory that makes a MARKET_EVENT_PAIR"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum Freeware License; see file forum.txt"

class EVENT_PAIR_FACTORY inherit

	MARKET_EVENT_FACTORY
		redefine
			product
		end

creation

	make

feature -- Initialization

	make (infile: like input; p: like parser;
			fsep: like field_separator) is
		require
			not_void: infile /= Void and p /= Void
		do
			input := infile
			parser := p
			field_separator := fsep
		ensure
			set: input = infile and parser = p and field_separator = fsep
		end

feature -- Access

	parser: MARKET_EVENT_PARSER
			-- Parser used to create the appropriate event type according
			-- to the input

	product: MARKET_EVENT_PAIR

feature -- Basic operations

	execute is
			-- Scan input and create an MARKET_EVENT_PAIR from it.
			-- If a fatal error is encountered while scanning, an exception
			-- is thrown and error_occurred is set to true.
		local
			left, right: MARKET_EVENT
		do
			error_init
			scan_event_type
			skip_field_separator
			left := next_event
			skip_field_separator
			right := next_event
			create product.make (left, right, concatenation (<<left.name, ", ",
							right.name>>), current_event_type)
		end

	next_event: MARKET_EVENT is
		do
			-- Execute parser to make the appropriate kind of factory
			-- according to the type spec. in the input.
			parser.execute
			-- Execute the factory created by executing parser.
			parser.product.execute
			-- Add the factory product to the product list.
			Result := parser.product.product
		rescue
			error_occurred := True
			if parser.error_occurred then
				last_error := parser.last_error
			elseif parser.product.error_occurred then
				last_error := parser.product.last_error
			end
			raise (last_error)
		end

end -- class EVENT_PAIR_FACTORY
