package graph;

import java.awt.*;
import java.util.*;
import support.*;

/**
 *  Abstraction for drawing data tuples as points connected by lines
 */
public class LineDrawer extends Drawer {

	public void set_data(Object d) {
		data = (double[]) d;
	}

	public int data_length() {
		int result;
		if (data != null) {
			result = data.length;
		} else {
			result = 0;
		}
		return result;
	}

	/**
	* Draw the data bars and the line segments connecting them.
	* @param g Graphics context
	* @param w Data window
	*/
	protected void draw_tuples(Graphics g, Rectangle bounds) {
		int i, row;
		int x0, y0;
		int x1, y1;
		int lngth = data.length;
		double width_factor, height_factor;
		Configuration conf = Configuration.instance();
		Color line_color = conf.line_color();


		// Is there any data to draw? Sometimes the draw command will
		// will be called before any data has been placed in the class.
		if (data == null || lngth < Stride) return;

		_x_values = new int[tuple_count()];
		g.setColor(line_color);
		width_factor = width_factor_value(bounds);
		height_factor = height_factor_value(bounds);
		row = 1;
		x0 = (int)((row - xmin) * width_factor + bounds.x);
		_x_values[row-1] = x0;
		y0 = (int)(bounds.height - (data[0]-ymin) * height_factor + bounds.y);
		++row;

		for (i = Stride; i < lngth; i += Stride, ++row) {
			x1 = (int)((row - xmin) * width_factor + bounds.x);
			_x_values[row-1] = x1;
			y1 = (int)(bounds.height - (data[i]-ymin) * height_factor +
					bounds.y);
			g.drawLine(x0,y0,x1,y1);

			x0 = x1;
			y0 = y1;
		}
	}

	// 1 coordinate for each point - no x coordinate
	public int drawing_stride() { return Stride; }

	private static final int Stride = 1;

	protected double data[];
}
