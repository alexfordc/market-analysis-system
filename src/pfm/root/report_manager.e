note
	description: "Root class for the production of portfolio reports"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class REPORT_MANAGER inherit

	REPORTS
		rename
			contents as reports
		end

creation

	make

feature {NONE} -- Initialization

	make
		local
			set_up: SETUP
			trade: TRADE
			report_maker: expanded REPORT_BUILDER
		do
			report_maker.execute
			reports := report_maker.product
			create set_up.make
			complete_trades := set_up.tradelist
			open_trades := set_up.open_trades
			execute_reports
		end

feature {NONE}

	complete_trades: LIST [TRADE_MATCH]

	open_trades: LIST [OPEN_TRADE]

end -- REPORT_MANAGER
