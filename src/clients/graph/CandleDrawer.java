/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package graph;

import java.awt.*;
import application_support.*;

/**
 *  Abstraction for drawing candles
 */
public class CandleDrawer extends MarketDrawer {

	/**
	* Draw the candles.
	* @param g Graphics context
	* @param w Data window
	* Assumption: Stride >= 4 and the first four fields of each tuple
	* contain the open, high, low, and close, respectively.
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int openy, highy, lowy, closey;
		int x, middle_x;
		final int x_adjust = 0;
		int x_s[] = new int[4], y_s[] = new int[4];
		int lngth = 0;
		if (data != null) lngth = data.size();
		if (lngth == 0) return;

		bar_width = (int) ((double) base_bar_width(bounds, lngth / 4) * .65);
		MA_Configuration conf = MA_Configuration.application_instance();
		Color black = conf.black_candle_color();
		Color white = conf.white_candle_color();
		Color wick_color = conf.stick_color();
		boolean is_white;
		double width_factor, height_factor;

		if (data == null || lngth < Stride) return;

		initialize_x_values();
		width_factor = width_factor_value(bounds, lngth / 4);
		height_factor = height_factor_value(bounds);
		row = first_row();
		for (i = row - 1; i < lngth; i += Stride, ++row) {
			openy = (int) (bounds.height -
				(((Double) data.get(i)).doubleValue() - ymin) *
				height_factor + bounds.y);
			highy = (int)(bounds.height -
				(((Double) data.get(i+1)).doubleValue() - ymin) *
				height_factor + bounds.y);
			lowy = (int)(bounds.height -
				(((Double) data.get(i+2)).doubleValue() - ymin) *
				height_factor + bounds.y);
			closey = (int)(bounds.height -
				(((Double) data.get(i+3)).doubleValue() - ymin) *
				height_factor + bounds.y);
			x = (int)((row - xmin) * width_factor + bounds.x) + x_adjust;
			middle_x = x + bar_width / 2;
			x_values[row-1] = x;
			// For candle color, relation is reversed (< -> >) because
			// of the coordinate system used - higher coordinates have
			// a lower value.
			is_white = closey > openy? false: true;
			if (openy == closey) {	// If it's a doji
				draw_doji_line(g, x, closey, bar_width);
			}
			else {					// Not a doji - regular candle
				g.setColor(is_white? white: black);
				y_s[0] = openy; y_s[1] = openy;
				y_s[2] = closey; y_s[3] = closey;
				x_s[0] = x; x_s[1] = x + bar_width;
				x_s[2] = x + bar_width; x_s[3] = x;
				// Candle body
				g.fillPolygon(x_s, y_s, Stride);
			}
			g.setColor(wick_color);
			// Stems
			if (is_white) {
				g.drawLine(middle_x, closey, middle_x, highy);
				g.drawLine(middle_x, openy, middle_x, lowy);
			}
			else {
				g.drawLine(middle_x, closey, middle_x, lowy);
				g.drawLine(middle_x, openy, middle_x, highy);
			}
		}
	}

	// Draw the horizontal line indicating a doji.
	protected void draw_doji_line(Graphics g, int x, int y, int candlewidth) {
		g.setColor(MA_Configuration.application_instance().stick_color());
		g.drawLine(x, y, x + candlewidth, y);
	}
}
