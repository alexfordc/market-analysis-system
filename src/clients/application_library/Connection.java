import java.io.*;
import java.net.*;
import java.util.*;
import common.*;
import graph.*;

/** Provides an interface for connecting and communicating with the server */
public class TA_Connection implements NetworkProtocol
{
	TA_Connection(String[] args)
	{
		int field_specs[] = new int[6];
		// Hard-code these for now:
		field_specs[0] = TA_Parser.Date;
		field_specs[1] = TA_Parser.Open;
		field_specs[2] = TA_Parser.High;
		field_specs[3] = TA_Parser.Low;
		field_specs[4] = TA_Parser.Close;
		field_specs[5] = TA_Parser.Volume;
		data_parser = new TA_Parser(field_specs, Output_record_separator,
									Output_field_separator);
		// Set up the indicator parser to expect just a date and a float
		// (close) value.
		field_specs = new int[2];
		field_specs[0] = TA_Parser.Date;
		field_specs[1] = TA_Parser.Close;
		indicator_parser = new TA_Parser(field_specs, Output_record_separator,
									Output_field_separator);
		scanner = new DataInspector();
		bar_drawer = new BarDrawer();
		//Process args for the host, port.
		if (args.length > 0)
		{
			hostname = args[0];
			if (args.length > 1)
			{
				port_number = new Integer(port_number.parseInt(args[1]));
			}
			else
			{
				port_number = new Integer(33333);
			}
		}
		else
		{
			usage();
			System.exit(1);
		}
	}

	public void send_login_request()
	{
		String session_key_str = "";
		Configuration conf = Configuration.instance();

		connect();
		System.out.println("Sending settings:\n'" +
							conf.session_settings() + "'");
		send_msg(Login_request, conf.session_settings());
		try {
			session_key_str = receive_msg().toString();
		}
		catch (Exception e) {
			System.err.println("Fatal error: attempt to login to server " +
				"failed");
			System.exit(-1);
		}
		try {
			session_key = Integer.valueOf(session_key_str).intValue();
		}
		catch (Exception e) {
			System.err.println("Fatal error: received invalid key from " +
				"server: " + session_key_str);
			System.exit(-1);
		}
	}

	// Send a request for data for market `symbol' with `period_type'.
	public void send_market_data_request(String symbol, String period_type)
		throws IOException
	{
		connect();
		send_msg(Market_data_request, symbol + Input_field_separator +
					period_type);
		data_parser.parse(receive_msg().toString());
		_last_market_data = data_parser.result();
		_last_market_data.set_drawer(bar_drawer);
		close_connection();
	}

	// Send a request for data for indicator `ind' for market `symbol' with
	// `period_type'.
	public void send_indicator_data_request(int ind, String symbol,
		String period_type) throws IOException
	{
		connect();
		send_msg(Indicator_data_request, ind + Input_field_separator +
					symbol + Input_field_separator + period_type);
		indicator_parser.parse(receive_msg().toString());
		_last_indicator_data = indicator_parser.result();
		_last_indicator_data.set_drawer(bar_drawer);
		close_connection();
	}

	// Send a request for the list of indicators for market `symbol'.
	public void send_indicator_list_request(String symbol) throws IOException
	{
		StringBuffer mlist;
		_last_indicator_list = new Vector();
		connect();
		send_msg(Indicator_list_request, symbol);
		mlist = receive_msg();
		close_connection();
		StringTokenizer t = new StringTokenizer(mlist.toString(),
			Output_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			_last_indicator_list.addElement(t.nextToken());
		}
	}

	// Data from last market data request
	public DataSet last_market_data()
	{
		return _last_market_data;
	}

	// Data from last indicator data request
	public DataSet last_indicator_data()
	{
		return _last_indicator_data;
	}

	// Last requested indicator list
	public Vector last_indicator_list()
	{
		return _last_indicator_list;
	}

	// List of markets available from the server
	// !!!Q: Is it better not to cache - i.e., retrieve each time?
	public Vector market_list() throws IOException
	{
		StringBuffer mlist;

		if (markets == null)
		{
			markets = new Vector();
			connect();
			send_msg (Market_list_request, "");
			mlist = receive_msg();
			close_connection();
			StringTokenizer t = new StringTokenizer(mlist.toString(),
				Output_record_separator, false);
			for (int i = 0; t.hasMoreTokens(); ++i)
			{
				markets.addElement(t.nextToken());
			}
		}
		return markets;
	}

	// List of all valid trading period types for `market'
	public Vector trading_period_type_list(String market) throws IOException {
		StringBuffer tpt_list;
		Vector result;

		result = new Vector();
		connect();
		send_msg(Trading_period_type_request, market);
		tpt_list = receive_msg();
		close_connection();
		StringTokenizer t = new StringTokenizer(tpt_list.toString(),
			Output_record_separator, false);
		for (int i = 0; t.hasMoreTokens(); ++i)
		{
			result.addElement(t.nextToken());
		}
		return result;
	}

// Implementation

	StringBuffer receive_msg() throws IOException
	{
		char c;
		StringBuffer result;

		scanner.getInt();
		last_rec_msgID = scanner.lastInt();
		if (last_rec_msgID == Error)
		{
			result = new StringBuffer("Fatal request protocol error: ");
		}
		else
		{
			result = new StringBuffer();
		}
		do
		{
			c = (char) in.read();
			if (c == '') break;
			result.append(c);
		} while (true);

		if (last_rec_msgID == Error)
		{
			System.err.println(result);
			// This error means there is a problem with the protocol of the
			// last request passed to the server.  Since this is a coding
			// error (probably in the client), it is treated as fatal.
			System.exit(-1);
		}
System.out.println(result.toString());
		return result;
	}

	// Send the `msgID', the session key, and `msg' - with field delimiters.
	void send_msg (int msgID, String msg)
	{
		out.print(msgID);
		out.print(Input_field_separator + session_key);
		out.print(Input_field_separator + msg);
		out.print(Eom);
		out.flush();
	}

	void close_connection() throws IOException
	{
		out.close(); in.close(); socket.close();
	}

	private void connect()
	{
		try
		{
			//It appears that the only way to connect a client socket is
			//to create a new one!
			socket = new Socket(hostname, port_number.intValue());
			out = new PrintWriter(socket.getOutputStream(), true);
			in = new BufferedReader(
						new InputStreamReader(socket.getInputStream()));
			scanner.setReader(in);
		}
		catch (UnknownHostException e)
		{
			System.err.println("Don't know about host:");
			System.err.println(hostname);
			System.exit(1);
		}
		catch (IOException e)
		{
			System.err.println("Couldn't get I/O for the connection to:");
			System.err.println(hostname);
			System.exit(1);
		}
	}

	private void usage()
	{
		System.err.println("Usage: ta_server hostname port_number");
	}

	private String hostname;
	private Integer port_number;
	private Socket socket;			// socket connection to server
	private PrintWriter out;		// output to server via socket
	private BufferedReader in;		// input from server via socket
	private DataInspector scanner;	// for scanning server messages
	private int session_key;		// key or ID for current client session
	private int last_rec_msgID;		// last message ID received from server
	private Vector markets;			// Cached list of markets
		// result of last market data request
	private DataSet _last_market_data;
		// result of last indicator data request
	private DataSet _last_indicator_data;
		// result of last indicator list request
	private Vector _last_indicator_list;
	private TA_Parser data_parser;
	private TA_Parser indicator_parser;
	private BarDrawer bar_drawer;	// draws bars in graph
}
