/* Copyright 1998 - 2004: Jim Cochrane - see file forum.txt */

package mas_gui;

import java.util.*;
//import support.NetworkProtocolUtilities;
import application_library.AbstractParser;
import graph.*;
import graph_library.DataSet;

/** Market Analysis Parser - parses market and indicator data sent from
the Market Analysis server */
//!!!Remove 'public' if possible.
public class Parser extends AbstractParser {

// Initialization

	// Constructor - fieldspecs specifies the fields format of each tuple -
	// e.g., date, high, low, close, volume.
	public Parser(int fieldspecs[], String record_sep, String field_sep) {
		super(fieldspecs, record_sep, field_sep);
/* !!!Remove:
parsetype = fieldspecs;
_record_separator = record_sep;
field_separator = field_sep;

dates = new Vector();
times = new Vector();
float_field_count = float_fields(fieldspecs);
*/
	}

// Access

	// Parsed data set result
	public DataSet result() {
		return processed_data;
	}

	// Parsed volume
	public DataSet volume_result() {
		return volume_data;
	}

	// Parsed open interest
	public DataSet open_interest_result() {
		return oi_data;
	}

// Element change

	// Set the drawer for drawing the main data set.
	void set_main_drawer(BasicDrawer d) {
		main_drawer = d;
	}

	// Set the drawer for drawing volume.
	void set_volume_drawer(BasicDrawer d) {
		volume_drawer = d;
	}

	// Set the drawer for open interest.
	void set_open_interest_drawer(BasicDrawer d) {
		open_interest_drawer = d;
	}

// Basic operations
/////!!!!Move to right place:

	// Parse `s' into a DataSet according to record_separator and
	// field_separator.  `drawer' is the tuple drawer to use for the
	// DataSet.  result() gives the new DataSet.
//!!!Clean up:
	public void old_remove_parse(String s, BasicDrawer drawer) throws Exception {
		int rec_count;
		is_intraday = contains_time_field(s);
		StringTokenizer recs = new StringTokenizer(s, record_separator, false);
		rec_count = recs.countTokens();
		clear_vectors();
		if (has_field_type(Volume)) {
			volumes = new double[rec_count];
		}
		if (has_field_type(Open_interest)) {
			open_interests = new double[rec_count];
		}
		// If there is no open field
		if (! has_field_type(Open) && has_field_type(High) &&
				has_field_type(Low)) {
			// Add 1 to make room for the "fake" open field.
			value_data = new double[rec_count * (float_field_count + 1)];
			parse_with_no_open(recs);
		} else {
			value_data = new double[rec_count * float_field_count];
			parse_default(recs);
		}
		process_data(drawer);
	}

// Hook routine implementations

	// Perform any needed preprations before parsing.
	protected void prepare_for_parse() {
		volumes = null;
		open_interests = null;
	}

	protected void do_main_parse(StringTokenizer recs) throws Exception {
		int rec_count = recs.countTokens();
		if (has_field_type(Volume)) {
			volumes = new double[rec_count];
		}
		if (has_field_type(Open_interest)) {
			open_interests = new double[rec_count];
		}
		// If there is no open field
		if (! has_field_type(Open) && has_field_type(High) &&
				has_field_type(Low)) {
			// Add 1 to make room for the "fake" open field.
			value_data = new double[rec_count * (float_field_count + 1)];
			parse_with_no_open(recs);
		} else {
			value_data = new double[rec_count * float_field_count];
			parse_default(recs);
		}
		process_data(main_drawer);
	}

// Implementation

	// Parse fields - default routine
	protected void parse_default(StringTokenizer recs) throws Exception {
		int float_index = 0, volume_index = 0, oi_index = 0;
		while (recs.hasMoreTokens()) {
			String s = recs.nextToken();
			StringTokenizer fields = new StringTokenizer(s,
				field_separator, false);
			for (int j = 0; fields.hasMoreTokens(); ++j) {
				try {
				switch (parsetype[j]) {
					case Date:
						dates.addElement(fields.nextToken());
						if (is_intraday) {
							times.addElement(fields.nextToken());
						}
						break;
					case Open:
						value_data[float_index++] =
							parsed_double(fields.nextToken());
						break;
					case High:
						value_data[float_index++] =
							parsed_double(fields.nextToken());
						break;
					case Low:
						value_data[float_index++] =
							parsed_double(fields.nextToken());
						break;
					case Close:
						value_data[float_index++] =
							parsed_double(fields.nextToken());
						break;
					case Volume:
						volumes[volume_index++] =
							parsed_double(fields.nextToken());
						break;
					case Open_interest:
						open_interests[oi_index++] =
							parsed_double(fields.nextToken());
						break;
				}
				}
				catch (Exception e) {
					System.err.println("Last record processed was dated " +
						dates.elementAt(dates.size() - 1));
					throw e;
				}
			}
		}
	}

	// Parse fields - expecting high, low, and close fields (in that order),
	// but NO open field.
	protected void parse_with_no_open(StringTokenizer recs) throws Exception {
		int float_index = 0, volume_index = 0, oi_index = 0;
		while (recs.hasMoreTokens()) {
			StringTokenizer fields = new StringTokenizer(recs.nextToken(),
													field_separator, false);
			int open_field_index = -1;
			for (int j = 0; fields.hasMoreTokens(); ++j) {
				try {
				switch (parsetype[j]) {
					case Date:
						dates.addElement(fields.nextToken());
						if (is_intraday) {
							times.addElement(fields.nextToken());
						}
						// Save a place for the open field:
						value_data[float_index] = 0;
						open_field_index = float_index;
						++float_index;
						break;
					case High:
						value_data[float_index++] =
							parsed_double(fields.nextToken());
						break;
					case Low:
						value_data[float_index++] =
							parsed_double(fields.nextToken());
						break;
					case Close:
						value_data[float_index++] =
							parsed_double(fields.nextToken());
						if (open_field_index != -1) {
							// Store the close value into the open field.
							value_data[open_field_index] =
								value_data[float_index - 1];
						}
						break;
					case Volume:
						volumes[volume_index++] =
							parsed_double(fields.nextToken());
						break;
					case Open_interest:
						open_interests[oi_index++] =
							parsed_double(fields.nextToken());
						break;
				}
				}
				catch (Exception e) {
					System.err.println("Last record processed was dated " +
						dates.elementAt(dates.size() - 1));
					throw e;
				}
			}
		}
	}

	private double parsed_double(String s) throws Exception {
		double result;
		try {
			result = Float.valueOf(s).floatValue();
		}
		catch (Exception e) {
			if (s.equals("NaN") || s.equals("nan")) {
				System.err.println("NaN encountered - substituting 0.");
				result = 0;
			}
			else {
				System.err.println("Error occurred in formatting value " + s +
					" (" + e + ")");
				throw e;
			}
		}
		return result;
	}

	private Integer parsed_int(String s) {
		return Integer.valueOf(s);
	}

	// Put the parsed data into a data set.
	// Postcondition: result() != null && result().drawer() == drawer
	protected void process_data(BasicDrawer drawer) throws Exception {
		String[] date_array = null;
		String[] time_array = null;
		boolean has_dates = false;
		boolean has_times = false;

		volume_data = null;
		oi_data = null;

		try {
			has_dates = dates != null && ! dates.isEmpty();
			has_times = times != null && ! times.isEmpty();
			int length = value_data.length / float_field_count;
			if (length > 0) {
				processed_data = new DrawableDataSet(value_data, length,
					drawer);
			}
			else {
				processed_data = new DrawableDataSet(drawer);
			}
			if (has_dates) {
				date_array = new String[dates.size()];
				dates.copyInto(date_array);
				processed_data.set_dates(date_array);
			}
			if (has_times) {
				time_array = new String[times.size()];
				times.copyInto(time_array);
				processed_data.set_times(time_array);
			}
			if (volume_drawer != null && volumes != null &&
					volumes.length > 0) {
				volume_data = new DrawableDataSet(volumes, volumes.length,
											volume_drawer);
				if (has_dates) volume_data.set_dates(date_array);
				if (has_times) volume_data.set_times(time_array);
			}
			if (open_interest_drawer != null && open_interests != null &&
					open_interests.length > 0) {
				oi_data = new DrawableDataSet(open_interests,
					open_interests.length, open_interest_drawer);
				if (has_dates) oi_data.set_dates(date_array);
				if (has_times) oi_data.set_times(time_array);
			}
		}
		catch (Exception e) {
			System.err.println("DataSet constructor failed - " + e);
			e.printStackTrace();
		}
	}

// Implementation - attributes

	// Holds open, high, low, close data or, for indicator data, holds
	// the main value data.
	protected double[] value_data;
	protected double[] volumes, open_interests;

	protected DrawableDataSet processed_data;	// the parsed data
	protected DrawableDataSet volume_data;		// the parsed volume data
	protected DrawableDataSet oi_data;			// the parsed open interest data
	protected BasicDrawer main_drawer;
	protected BasicDrawer volume_drawer;
	protected BasicDrawer open_interest_drawer;
}
