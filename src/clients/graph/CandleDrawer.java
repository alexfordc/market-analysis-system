package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing candles
 */
public class CandleDrawer extends Drawer {

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
		int x_s[] = new int[4], y_s[] = new int[4];
		int lngth = data.length;
		int candlewidth = bounds.width / lngth + 5;
		Configuration conf = Configuration.instance();
		Color black = conf.black_candle_color();
		Color white = conf.white_candle_color();
		Color wick_color = conf.stick_color();
		boolean is_white;
		double width_factor, height_factor;

		if (data == null || lngth < Stride) return;

		width_factor = bounds.width / xrange;
		height_factor = bounds.height / yrange;
		for (i = 0, row = 1; i < lngth; i += Stride, ++row) {
			openy = (int) (bounds.height - (data[i] - ymin) * height_factor +
						bounds.y);
			highy = (int)(bounds.height - (data[i+1] - ymin) * height_factor +
						bounds.y);
			lowy = (int)(bounds.height - (data[i+2] - ymin) * height_factor +
						bounds.y);
			closey = (int)(bounds.height - (data[i+3] - ymin) * height_factor +
						bounds.y);
			x = (int)((row - xmin) * width_factor + bounds.x);
			middle_x = x + candlewidth / 2;
			// For candle color, relation is reversed (< -> >) because
			// of the coordinate system used - higher coordinates have
			// a lower value.
			is_white = closey > openy? false: true;
			if (openy == closey) {	// If it's a doji
				draw_doji_line(g, x, closey, candlewidth);
			}
			else {					// Not a doji - regular candle
				g.setColor(is_white? white: black);
				y_s[0] = openy; y_s[1] = openy;
				y_s[2] = closey; y_s[3] = closey;
				x_s[0] = x; x_s[1] = x + candlewidth;
				x_s[2] = x + candlewidth; x_s[3] = x;
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

	// 4 points: open, high, low, close - no x coordinates
	public int drawing_stride() { return Stride; }

	// Draw the horizontal line indicating a doji.
	protected void draw_doji_line(Graphics g, int x, int y, int candlewidth) {
		g.setColor(Color.white);
		//g.drawLine(x, y + 1, x + candlewidth, y + 1);
		g.drawLine(x, y, x + candlewidth, y);
		//g.drawLine(x, y - 1, x + candlewidth, y - 1);
	}

	private static final int Stride = 4;
}
