package pct.application;

import java.io.*;

// Plug-in to start a new MAS command-line client process
public class ServerTermination extends MCT_Constants {
	public ServerTermination(Object pcontext) {
		super(pcontext);
	}

	public Object execute() {
		Object result = null;
		if (runtime == null) {
			runtime = Runtime.getRuntime();
		}
		try {
			String cmd = processed_command(
				(String) settings.get(server_termination_cmd_key),
				parent_context);
System.out.println("Trying to execute: " + cmd);
			Process p = runtime.exec(cmd);
		} catch (Exception e) {
			System.err.println("Error: failed to terminate server: " + e);
		}
		return result;
	}

	Runtime runtime;
}
