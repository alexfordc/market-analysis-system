package graph;

import java.awt.*;
import java.applet.*;
import java.util.*;
import java.lang.*;


/*
**************************************************************************
**
**    Class  DataSet
**
**************************************************************************
**    Copyright (C) 1995, 1996 Leigh Brookshaw
**
**    This program is free software; you can redistribute it and/or modify
**    it under the terms of the GNU General Public License as published by
**    the Free Software Foundation; either version 2 of the License, or
**    (at your option) any later version.
**
**    This program is distributed in the hope that it will be useful,
**    but WITHOUT ANY WARRANTY; without even the implied warranty of
**    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**    GNU General Public License for more details.
**
**    You should have received a copy of the GNU General Public License
**    along with this program; if not, write to the Free Software
**    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
**************************************************************************
**    Modified June, 1999 by Jim Cochrane
**************************************************************************
**
**    This class is designed to be used in conjunction with 
**    the TA_Graph class and Axis class for plotting 2D graphs.
**
*************************************************************************/


/**
 *  This class is designed to hold the data to be plotted.
 *  It is to be used in conjunction with the TA_Graph class and Axis 
 *  class for plotting 2D graphs.
 *
 * @version $Revision$, $Date$
 * @author Leigh Brookshaw 
 */
public class DataSet {

	public void set_drawer (Drawer d) {
		_drawer = d;
	}

	public void set_dates (String d[]) {
		dates = d;
	}

	public Drawer drawer() { return _drawer; }


/*
***********************
** Public Variables      
**********************/

  /** 
   *    The Graphics canvas that is driving the whole show.
   * @see graph.TA_Graph
   */
      public TA_Graph g2d;
  /**
   *    The color of the straight line segments
   */
      public Color linecolor     = null;
  /**
   *    The index of the marker to use at the data points.
   * @see graph.Markers
   */
      public int    marker       = 0;
  /**
   *    The marker color
   */
      public Color  markercolor  = null;
  /**
   *    The scaling factor for the marker. Default value is 1.
   */
      public double markerscale  = 1.0;
  /**
   *    The Axis object the X data is attached to. From the Axis object
   *    the scaling for the data can be derived.
   * @see graph.Axis
   */
      public Axis xaxis;
  /**
   *    The Axis object the Y data is attached to.
   * @see graph.Axis
   */
      public Axis yaxis;
  /**
   * The current plottable X maximum of the data. 
   * This can be very different from
   * true data X maximum. The data is clipped when plotted.
   */
      public double xmax; 
  /**
   * The current plottable X minimum of the data. 
   * This can be very different from
   * true data X minimum. The data is clipped when plotted.
   */
      public double xmin;
  /**
   * The current plottable Y maximum of the data. 
   * This can be very different from
   * true data Y maximum. The data is clipped when plotted.
   */
      public double ymax; 
  /**
   * The current plottable Y minimum of the data. 
   * This can be very different from
   * true data Y minimum. The data is clipped when plotted.
   */
      public double ymin;
  /**
   * Boolean to control clipping of the data window.
   * Default value is <em>true</em>, clip the data window.
   */
      public boolean clipping = true;


/*
*********************
** Protected Variables      
**********************/

	// Main data
	protected double[] data;

	// Date data
	protected String[] dates;

  /**
   * Drawer of price bars - e.g., tic bars or candles
   */
	protected Drawer _drawer;

  /**
   * Drawer of dates
   */
	protected DateDrawer date_drawer;

  /**
   * The data X maximum. 
   * Once the data is loaded this will never change.
   */
      protected double dxmax;
  /**
   * The data X minimum. 
   * Once the data is loaded this will never change.
   */
      protected double dxmin;
  /**
   * The data Y maximum. 
   * Once the data is loaded this will never change.
   */
      protected double dymax;
  /**
   * The data Y minimum. 
   * Once the data is loaded this will never change.
   */
      protected double dymin;

	// Horizontal, vertical line data
	protected Vector hline_data;
	protected Vector vline_data;

  /**
   *    The X range of the clipped data
   */
      protected double xrange;
  /**
   *    The Y range of the clipped data
   */
      protected double yrange;
  /**
   *    The amount to increment the data array when the append method is being
   *    used.
   */
      protected int increment = 100;

  /**
   * Number of components in a data tuple - for example, 2 (x, y) for
   * a simple point
   # @precondition
   #    _drawer != null
   */
    protected int stride() { return _drawer.drawing_stride(); }

	protected int length() { return data.length; }
/*
*********************
** Constructors
********************/

	/**
	*  Instantiate an empty data set.
	*/
	public DataSet(Drawer d) {
		_drawer = d;
		data = null;
		range(stride(), 0);
		date_drawer = new DateDrawer();
	}

	/**
	* Instantiate a DataSet with the parsed data.
	* `d' contains a set of tuples flattened out into array elements -
	* for example, for a 4-field tuple, d[0..3] are the fields of the
	# first tuple, d[4..7] are the fields of the second tuple, etc.
	* The integer n is the number of data Points. This means that the
	* length of the data array is t*n, where t is the number of fields
	* in a tuple.
	* Note: `d' is expected to take y-position (vertical) data only;
	* x-positions will be calculated based on the position of each
	* tuple in `d' - from 1 to d.length.
	* @param d Array containing the (y1,y2,...) data tuples.
	* @param n Number of tuples in the array.
	* @param drawer object used to draw the data.
	* @precondition
	*     d != null && d.length > 0 && n > 0 && drawer != null
	*/
	public DataSet(double d[], int n, Drawer drawer) throws Exception {
		if ( d  == null || d.length == 0 || n <= 0 || drawer == null ) {
			throw new Exception("DataSet constructor: precondition violated");
		}
		int i;
		_drawer = drawer;
		date_drawer = new DateDrawer();
		data = d;

		// Calculate the data range.
		range(stride(), n);
	}

/*******************
** Public Methods
******************/

	// Add y1, y2 values for a horizontal line.
	public void add_hline(DoublePair p) {
		if (hline_data == null) hline_data = new Vector();
		hline_data.addElement(p);
	}

	// Add x1, x2 values for a vertical line.
	public void add_vline(DoublePair p) {
		if (vline_data == null) vline_data = new Vector();
		vline_data.addElement(p);
	}

  /**
   * Draw the straight line segments and/or the markers at the
   * data points.
   * If this data has been attached to an Axis then scale the data
   * based on the axis maximum/minimum otherwise scale using
   * the data's maximum/minimum
   * @param g Graphics state
   * @param bounds The data window to draw into
   */
	public void draw_data(Graphics g, Rectangle bounds) {
System.err.println("DS.draw_data called");
		if ( linecolor != null) g.setColor(linecolor);
		_drawer.set_data(data);
		_drawer.set_xaxis(xaxis);
		_drawer.set_yaxis(yaxis);
		_drawer.set_maxes(xmax, ymax, xmin, ymin);
		_drawer.set_ranges(xrange, yrange);
		_drawer.set_clipping(clipping);
		_drawer.draw_data(g, bounds, hline_data, vline_data);
System.err.println("DS.draw_data calling draw_dates");
		draw_dates(g,bounds);
System.err.println("DS.draw_data finished");
	}

  /**
   * return the data X maximum.
   */
      public double getXmax() {  return dxmax; } 
  /**
   * return the data X minimum.
   */
      public double getXmin() {  return dxmin; } 
  /**
   * return the data Y maximum.
   */
      public double getYmax() {  return dymax; } 
  /**
   * return the data Y minimum.
   */
      public double getYmin() {  return dymin; }
 
  /**
   * Return the number of data points in the DataSet
   * @return number of (x,y) points.
   */
      public int dataPoints() {  return length()/stride(); }

  /**
   * get the data point at the parsed index. The first (x,y) pair
   * is at index 0.
   * @param index Data point index
   * @return array containing the (x,y) pair.
   */
      public double[] getPoint(int index) {
			int strd = stride();
            double point[] = new double[strd];
            int i = index*strd;
            if( index < 0 || i > length()-strd ) return null;

            for(int j=0; j<strd; j++) point[j] = data[i+j];
            
            return point;
	  }

  /**
   * Return the data point that is closest to the parsed (x,y) position
   * @param x 
   * @param y (x,y) position in data space. 
   * @return array containing the closest data point.
   */
      public double[] getClosestPoint(double x, double y) {
            double point[] = {0.0, 0.0, 0.0};
            int i;
            double xdiff, ydiff, dist2;
			int strd = stride();

            xdiff = data[0] - x;
            ydiff = data[1] - y;
              
            point[0] = data[0];
            point[1] = data[1];
            point[2] = xdiff*xdiff + ydiff*ydiff;
            
 

            for(i=strd; i<length()-1; i+=strd) {

                xdiff = data[i  ] - x;
                ydiff = data[i+1] - y;


                dist2 = xdiff*xdiff + ydiff*ydiff;

                if(dist2 < point[2]) {
                    point[0] = data[i  ];
                    point[1] = data[i+1];
                    point[2] = dist2;
		  }

           }

           return point;
            
	  }


  /**
   * Draw dates, if they exist.
   * @param g Graphics context
   * @param w Data Window
   */
      protected void draw_dates(Graphics g, Rectangle w) {
System.err.println("DS.draw_dates called");
		if (dates != null) {
System.err.println("DS.draw_dates: dates is not null");
			date_drawer.set_data(dates);
			date_drawer.set_xaxis(xaxis);
			date_drawer.set_yaxis(yaxis);
			date_drawer.set_maxes(xmax, ymax, xmin, ymin);
			date_drawer.set_ranges(xrange, yrange);
			date_drawer.set_clipping(clipping);
			date_drawer.set_x_values(_drawer.x_values());
			date_drawer.draw_data(g, w, hline_data, vline_data);
		}
System.err.println("DS.draw_dates finished");
      }

	/**
	* Calculate the range of the data. This modifies dxmin,dxmax,dymin,dymax
	* and xmin,xmax,ymin,ymax
	*/
	protected void range(int stride, int element_count) {
		int i;
		int lnth = length();

		if (lnth >= stride ) {
			dymax = data[0];
			dymin = dymax;
			// The range for x follows the data index - starts at 1
			// and ends at data.length.
			dxmax = element_count;
			dxmin = 1;
		} else {
			dxmin = 0.0;
			dxmax = 0.0;
			dymin = 0.0;
			dymax = 0.0;
		}

		// `data' holds only y values - find the largest and smallest.
		for (i = 0; i < lnth; ++i) {
			if( dymax < data[i] ) { dymax = data[i]; }
			else if( dymin > data[i] ) { dymin = data[i]; }
		}

		if ( xaxis == null) {
			xmin = dxmin;
			xmax = dxmax;
		}
		if ( yaxis == null) {
			ymin = dymin;
			ymax = dymax;
		}
	}
}
