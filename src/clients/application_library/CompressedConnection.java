/* Copyright 1998 - 2001: Jim Cochrane - see file forum.txt */

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.zip.*;
import common.*;
import graph.*;
import support.*;

/** A Connection that receives compressed data from the server */
public class CompressedConnection extends Connection
{
	// args[0]: hostname, args[1]: port_number
	public CompressedConnection(String hostname, Integer port_number) {
		super(hostname, port_number);
	}


// Implementation

	protected Reader new_reader_from_socket() {
		Reader result = null;
		try {
			result = new BufferedReader(new InputStreamReader(
				new InflaterInputStream(socket.getInputStream(),
				new Inflater(), 850000)));
		} catch (Exception e) {
			System.err.println("Failed to read from server (" + e + ")");
			System.exit(1);
		}
System.out.println("decompressing");
		return result;
	}

	// Send the `msgID', the session key, the compression-on flag,
	// and `msg' - with field delimiters according to the client/server
	// protocol.
	void send_msg(int msgID, String msg, int session_key) {
		out.print(msgID);
		out.print(Input_field_separator + session_key);
		out.print(Input_field_separator + Compression_on_flag + msg);
		out.print(Eom);
		out.flush();
	}
}