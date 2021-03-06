note
	description:
		"Abstraction that provides services for analysis of market data"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class MARKET_ANALYSIS inherit

feature -- Access

	slope (c: CHAIN [TRADABLE_TUPLE]): DOUBLE
			-- Approximation of slope or rate of change of `c' at its
			-- current index
		require
			valid_position: not c.off
		do
			Result := slope_at (c, c.index)
		end

	slope_at (c: CHAIN [TRADABLE_TUPLE]; i: INTEGER): DOUBLE
			-- Approximation of slope or rate of change of `c' at the point
			-- (list element) specified by `i'
		require
			c.valid_index (i)
		local
			line1, line2: TRADABLE_LINE
			p1, p2, p3: TRADABLE_POINT
			mt: TRADABLE_TUPLE
		do
			create p1; create p2; create p3
			if i > 1 then
				mt := c.i_th (i - 1)
			else
				-- Beginning of list: use first, since previous doesn't exist.
				mt := c.i_th (i)
			end
			p1.set_x_y_date (i - 1, mt.value, mt.date_time)
			mt := c.i_th (i)
			p2.set_x_y_date (i, mt.value, mt.date_time)
			if i < c.count then
				mt := c.i_th (i + 1)
			else
				-- End of list: use last, since next doesn't exist.
				mt := c.i_th (i)
			end
			p3.set_x_y_date (i + 1, mt.value, mt.date_time)
			create line1.make_from_2_points (p1, p2)
			create line2.make_from_2_points (p2, p3)
			Result := (line1.slope + line2.slope) / 2
		end

end -- class MARKET_ANALYSIS
