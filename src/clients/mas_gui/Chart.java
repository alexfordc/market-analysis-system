/* Copyright 1998 - 2000: Jim Cochrane and others - see file forum.txt */

import java.awt.*;
import java.awt.event.*;
import java.util.Vector;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Properties;
import java.io.*;
import graph.*;
import support.*;
import common.*;

class ChartSettings implements Serializable {
	public ChartSettings(Dimension sz, Properties printprop, Point loc,
			Vector upperind, Vector lowerind, boolean replace_ind) {
		size_ = sz;
		print_properties_ = printprop;
		location_ = loc;
		upper_indicators_ = upperind;
		lower_indicators_ = lowerind;
		replace_indicators_ = replace_ind;
	}
	public Dimension size() { return size_; }
	public Point location() { return location_; }
	public Properties print_properties() { return print_properties_; }
	public Vector upper_indicators() { return upper_indicators_;}
	public Vector lower_indicators() { return lower_indicators_;}
	public boolean replace_indicators() { return replace_indicators_; }

	private Dimension size_;
	private Properties print_properties_;
	private Point location_;
	private Vector upper_indicators_;
	private Vector lower_indicators_;
	private boolean replace_indicators_;
}

/** Market analysis GUI chart component */
public class Chart extends Frame implements Runnable, NetworkProtocol {
	public Chart(DataSetBuilder builder, String sfname) {
		super("Chart");
		++window_count;
		data_builder = builder;
		this_chart = this;
		Vector _markets = null;

		if (sfname != null) serialize_filename = sfname;

		if (window_count == 1) {
			ChartSettings settings;
			try {
				FileInputStream chartfile =
					new FileInputStream(serialize_filename);
				ObjectInputStream ios = new ObjectInputStream(chartfile);
				settings = (ChartSettings) ios.readObject();
				window_settings = settings;
			}
			catch (IOException e) {
				System.err.println("Could not read file " +
					serialize_filename);
			}
			catch (ClassNotFoundException e) {
				System.err.println("Class not found!");
			}
		}
		try {
			if (_markets == null) {
				_markets = data_builder.market_list();
				if (! _markets.isEmpty()) {
					// Each market has its own period type list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					_period_types = data_builder.trading_period_type_list(
						(String) _markets.elementAt(0));
					current_period_type = (String) _period_types.elementAt(0);
					GUI_Utilities.busy_cursor(true, this);
					// Each market has its own indicator list; but for now,
					// just retrieve the list for the first market and use
					// it for all markets.
					data_builder.send_indicator_list_request(
						(String) _markets.elementAt(0));
					if (request_result() == Invalid_symbol) {
						System.err.println("Symbol " + (String)
							_markets.elementAt(0) + " is not in database.");
						System.err.println("Exiting ...");
						System.exit(-1);
					}
					GUI_Utilities.busy_cursor(false, this);
//_indicators = user_specified_indicators();
				}
			}
		}
		catch (IOException e) {
			System.err.println("IO exception occurred, bye ...");
			quit(-1);
		}
		initialize_GUI_components();
		if (_markets.size() > 0) {
			if (data_builder.options().print_on_startup() &&
					window_count == 1) {
				print_all_charts();
			}
			// Show the graph of the first symbol in the selection list.
			request_data((String) _markets.elementAt(0));
		}
		new Thread(this).start();
	}

	// From parent Runnable - for threading
	public void run() {
		// null method
	}

	// List of all markets in the server's database
	Vector markets() {
		Vector result = null;
		try {
			result = data_builder.market_list();
		}
		catch (IOException e) {
			System.err.println("IO exception occurred, bye ...");
			quit(-1);
		}
		return result;
	}

	// indicators
	Hashtable indicators() {
		if (_indicators == null) {
			Enumeration ind_iter;
			Vector inds_from_server = data_builder.last_indicator_list();
			String s;
			Hashtable valid_indicators = new Hashtable(inds_from_server.size());
			ordered_indicator_list = new Vector();
			int i;
			for (i = 0; i < inds_from_server.size(); ++i) {
				Object o = inds_from_server.elementAt(i);
				valid_indicators.put(o, new Integer(i + 1));
			}
			// User-selected indicators, in order:
			ind_iter = Configuration.instance().indicator_order().elements();
			_indicators = new Hashtable();
			Vector special_indicators = new Vector();
			special_indicators.addElement(No_lower_indicator);
			special_indicators.addElement(No_upper_indicator);
			special_indicators.addElement(Volume);
			// Insert into _indicators all user-selected indicators that
			// are either in the list returned by the server or are one of
			// the special strings for no upper/lower indicator or volume.
			while (ind_iter.hasMoreElements()) {
				s = (String) ind_iter.nextElement();
				if (valid_indicators.containsKey(s)) {
					// Add valid indicators (from the server's point of view)
					// to both `_indicators' and `ordered_indicator_list'.
					_indicators.put(s, valid_indicators.get(s));
					ordered_indicator_list.addElement(s);
				}
				else {
					for (i = 0; i < special_indicators.size(); ++i) {
						if (s.equals(special_indicators.elementAt(i))) {
							// Add special indicators only to
							// `ordered_indicator_list'.
							ordered_indicator_list.addElement(s);
							special_indicators.removeElement(s);
							break;
						}
					}
				}
			}
			// Insert the special indicators (no-upper indicator, ...) if
			// they aren't already there.
			for (i = 0; i < special_indicators.size(); ++i) {
				s = (String) special_indicators.elementAt(i);
				if (!_indicators.containsKey(s)) {
					_indicators.put(s, new Integer(_indicators.size() + 1));
					ordered_indicator_list.addElement(s);
				}
			}

			// Update current_lower_indicators and current_upper_indicators:
			// remove any elements that are no longer valid.
			for (ind_iter = current_lower_indicators.elements();
					ind_iter.hasMoreElements(); ) {
				s = (String) ind_iter.nextElement();
				if (! ordered_indicator_list.contains(s)) {
					while (current_lower_indicators.lastIndexOf(s) != -1) {
						current_lower_indicators.removeElement(s);
					}
				}
			}
			for (ind_iter = current_upper_indicators.elements();
					ind_iter.hasMoreElements(); ) {
				s = (String) ind_iter.nextElement();
				if (! ordered_indicator_list.contains(s)) {
					while (current_upper_indicators.lastIndexOf(s) != -1) {
						current_upper_indicators.removeElement(s);
					}
				}
			}
		}
		return _indicators;
	}

	// Indicators in user-specified order
	Vector ordered_indicators() {
		if (ordered_indicator_list == null) {
			// Force creation of ordered_indicator_list.
			indicators();
		}
		return ordered_indicator_list;
	}

	// Result of last request to the server
	public int request_result() {
		return data_builder.request_result();
	}

	// Take action when notified that period type changed.
	void notify_period_type_changed(String new_period_type) {
		if (! current_period_type.equals(new_period_type)) {
			current_period_type = new_period_type;
			period_type_change = true;
			if (current_market != null) {
				request_data(current_market);
			}
			period_type_change = false;
		}
	}

	// Request data for the specified market and display it.
	void request_data(String market) {
		DataSet dataset, main_dataset;
		Configuration conf = Configuration.instance();
		int count;
		String current_indicator;
		// Don't redraw the data if it's for the same market as before.
		if (period_type_change || ! market.equals(current_market)) {
			GUI_Utilities.busy_cursor(true, this);
			try {
				data_builder.send_market_data_request(market,
					current_period_type);
				if (request_result() == Invalid_symbol) {
					handle_nonexistent_sybmol(market);
					GUI_Utilities.busy_cursor(false, this);
					return;
				}
			}
			catch (Exception e) {
				fatal("Request to server failed", e);
			}
			//Ensure that all graph's data sets are removed.  (May need to
			//change later.)
			main_pane.clear_main_graph();
			main_dataset = data_builder.last_market_data();
			link_with_axis(main_dataset, null);
			main_pane.add_main_data_set(main_dataset);
			if (! current_upper_indicators.isEmpty()) {
				// Retrieve the data for the newly requested market for the
				// upper indicator, add it to the upper graph and draw
				// the new indicator data and the market data.
				count = current_upper_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_upper_indicators.elementAt(i);
					try {
						data_builder.send_indicator_data_request(((Integer)
							indicators().get(current_indicator)).
								intValue(), market, current_period_type);
					} catch (Exception e) {
						System.err.println("Exception occurred: " + e +
							" - Exiting ...");
						e.printStackTrace();
						quit(-1);
					}
					dataset = data_builder.last_indicator_data();
					dataset.set_dates_needed(false);
					dataset.set_color(
						conf.indicator_color(current_indicator, true));
					link_with_axis(dataset, current_indicator);
					main_pane.add_main_data_set(dataset);
				}
			}
			current_market = market;
			set_window_title();
			if (! current_lower_indicators.isEmpty()) {
				// Retrieve the indicator data for the newly requested market
				// for the lower indicator and draw it.
				main_pane.clear_indicator_graph();
				count = current_lower_indicators.size();
				for (int i = 0; i < count; ++i) {
					current_indicator = (String)
						current_lower_indicators.elementAt(i);
					if (current_lower_indicators.elementAt(i).equals(Volume)) {
						// (Nothing to retrieve from server)
						dataset = data_builder.last_volume();
					} else {
						try {
						data_builder.send_indicator_data_request(((Integer)
							indicators().get(current_indicator)).
								intValue(), market, current_period_type);
						} catch (Exception e) {
						System.err.println(
							"Exception occurred: " + e + "- Exiting ...");
						e.printStackTrace();
						quit(-1);
						}
						dataset = data_builder.last_indicator_data();
					}
					dataset.set_color(
						conf.indicator_color(current_indicator, false));
					link_with_axis(dataset, current_indicator);
					add_indicator_lines(dataset, current_indicator);
					main_pane.add_indicator_data_set(dataset);
				}
			}
			main_pane.repaint_graphs();
			GUI_Utilities.busy_cursor(false, this);
		}
	}

// Implementation

	// Add any extra lines to the indicator graph - specified in the
	// configuration.
	protected void add_indicator_lines(DataSet dataset, String indicator) {
		if (current_lower_indicators.isEmpty()) {
			return;
		}

		Vector lines;
		double d1, d2;
		Configuration conf = Configuration.instance();
		lines = conf.vertical_indicator_lines_at(indicator);
		if (lines != null && lines.size() > 0) {
			for (int j = 0; j < lines.size(); j += 2) {
				d1 = ((Float) lines.elementAt(j)).floatValue();
				d2 = ((Float) lines.elementAt(j+1)).floatValue();
				dataset.add_vline(new DoublePair(d1, d2));
			}
		}
		lines = conf.horizontal_indicator_lines_at(indicator);
		if (lines != null && lines.size() > 0) {
			for (int j = 0; j < lines.size(); j += 2) {
				d1 = ((Float) lines.elementAt(j)).floatValue();
				d2 = ((Float) lines.elementAt(j+1)).floatValue();
				dataset.add_hline(new DoublePair(d1, d2));
			}
		}
	}

	private void initialize_GUI_components() {
		// Create the main scroll pane, size it, and center it.
		main_pane = new MA_ScrollPane(_period_types,
			MA_ScrollPane.SCROLLBARS_NEVER, this, window_settings != null?
				window_settings.print_properties(): null);
		if (window_settings != null && window_count == 1) {
			main_pane.setSize(window_settings.size().width,
				window_settings.size().height + 2);
			setLocation(window_settings.location());
			current_upper_indicators = window_settings.upper_indicators();
			current_lower_indicators = window_settings.lower_indicators();
			replace_indicators = window_settings.replace_indicators();
		} else {
			main_pane.setSize(800, 460);
			current_upper_indicators = new Vector();
			current_lower_indicators = new Vector();
		}
		add(main_pane, "Center");
		market_selections = new MarketSelection(this);
		setMenuBar(new MA_MenuBar(this, data_builder, _period_types));

		// Event listener for close requests
		addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) { close(); }
		});

		pack();
		show();
	}

	// Set the window title using current_market and current_lower_indicators.
	protected void set_window_title() {
		if (! current_lower_indicators.isEmpty()) {
			StringBuffer newtitle = new
				StringBuffer (current_market.toUpperCase() + " - ");
			int i;
			for (i = 0; i < current_lower_indicators.size() - 1; ++i) {
				newtitle.append(current_lower_indicators.elementAt(i));
				newtitle.append(", ");
			}
			newtitle.append(current_lower_indicators.elementAt(i));
			setTitle(newtitle.toString());
		}
		else {
			setTitle(current_market.toUpperCase());
		}
	}

	// Notify the user that the symbol chosen does not exist and then
	// remove the symbol from the selection list.
	private void handle_nonexistent_sybmol(String symbol) {
		ErrorBox errorbox = new ErrorBox("",
			"Symbol " + symbol + " is not in the database.", this_chart);
		market_selections.remove_selection(symbol);
	}

	// Save persistent settings as a serialized file.
	protected void save_settings() {
		if (serialize_filename != null) {
		try {
			FileOutputStream chartfile =
				new FileOutputStream(serialize_filename);
			ObjectOutputStream oos = new ObjectOutputStream(chartfile);
			ChartSettings cs = new ChartSettings(main_pane.getSize(),
				main_pane.print_properties, getLocation(),
				current_upper_indicators, current_lower_indicators,
				replace_indicators);
			oos.writeObject(cs);
			oos.flush();
			oos.close();
		}
		catch (IOException e) {
			System.err.println("Could not save file " + serialize_filename);
			System.err.println(e);
		}
		}
	}

	// Set replace_indicators to its opposite state.
	protected void toggle_indicator_replacement() {
		replace_indicators = ! replace_indicators;
	}

	// Add a menu item for each indicator to `imenu'.
	protected void add_indicators(Menu imenu) {
		MenuItem menu_item;
		IndicatorListener listener = new IndicatorListener(this);
		Enumeration ind_keys = ordered_indicator_list.elements();
		for ( ; ind_keys.hasMoreElements(); ) {
			menu_item = new MenuItem((String) ind_keys.nextElement());
			imenu.add(menu_item);
			menu_item.addActionListener(listener);
		}
	}

	// Print the chart for each member of market_selections
	protected void print_all_charts() {
		main_pane.print(true);
	}

	/** Close a window.  If this is the last open window, just quit. */
	protected void close() {
		if (window_count == 1) {	// Close last remaining window, exit.
			save_settings();
			data_builder.logout(true, 0);
		}
		else {		// More than 1 windows remain, close this one.
			--window_count;
			data_builder.logout(false, 0);
			dispose();
		}
	}

	/** Quit gracefully, sending a logout request for each open window. */
	protected void quit(int status) {
		save_settings();
		// Log out the corresponding session for all but one window.
		for (int i = 0; i < window_count - 1; ++i) {
			data_builder.logout(false, 0);
		}
		// Log out the remaining window and exit with `status'.
		data_builder.logout(true, status);
	}

	// Print fatal error and exit.
	private void fatal(String s, Exception e) {
		System.err.print("Fatal error: request to server failed. ");
		if (e != null) {
			System.err.println("(" + e + ")");
			e.printStackTrace();
		}
		System.err.println("Exiting ...");
		quit(-1);
	}

	// Link `d' with the appropriate indicator group, using `indicator_name'
	// as a key.  If `indicator_name' is null, the group for the main
	// (upper) graph will be used.  If `indicator_name' specifies an
	// indicator that is not a group member, no action is taken.
	protected void link_with_axis(DataSet d, String indicator_name) {
		if (indicator_groups == null) {
			indicator_groups = (IndicatorGroups)
				Configuration.instance().indicator_groups().clone();
		}
		IndicatorGroup group;
		if (indicator_name == null) {
			indicator_name = indicator_groups.Maingroup;
		}
		group = indicator_groups.at(indicator_name);
		if (group != null) {
			group.attach_data_set(d);
		}
	}

	private boolean vector_has(Vector v, String s) {
		return Utilities.vector_has(v, s);
	}

	protected DataSetBuilder data_builder;

	private Chart this_chart;

	// # of open windows - so program can exit when last one is closed
	protected static int window_count = 0;

	// Main window pane
	MA_ScrollPane main_pane;

	// Valid trading period types - static for now, since it is currently
	// hard-coded in the server
	protected static Vector _period_types;	// Vector of String

	// Cached list of market indicators
	protected static Hashtable _indicators;	// table of String

	// Indicators in user-specified order - includes no-upper/lower and
	// volume indicators
	private static Vector ordered_indicator_list;	// Vector of String

	// Current selected market
	protected String current_market;

	// Current selected period type
	protected String current_period_type;

	// Has the period type just been changed?
	protected boolean period_type_change;

	// Upper indicators currently selected for display
	protected Vector current_upper_indicators;

	// Lower indicators currently selected for display
	protected Vector current_lower_indicators;

	// Should new indicator selections replace, rather than be added to,
	// existing indicators?
	boolean replace_indicators;

	protected MarketSelection market_selections;

	protected final String No_upper_indicator = "No upper indicator";

	protected final String No_lower_indicator = "No lower indicator";

	protected final String Volume = "Volume";

	static String serialize_filename;

	static ChartSettings window_settings;

	IndicatorGroups indicator_groups;
}
