package pct;

import java.util.Vector;
import java.io.*;
import support.FileReaderUtilities;

// GUI terminal that provides general program control facilities
public class ProgramControlTerminal extends PCT_Tools {

	public ProgramControlTerminal(String cfg_filename, String prog_name,
			Object comp_context) throws Exception {
		config_file_name = cfg_filename;
		program_name_setting = prog_name;
		_component_context = comp_context;
		FileReaderUtilities cfgfile = config_file();
		Vector lines = lines_from_file(cfgfile);
		String sep = separator(lines);
		terminal_name_setting = "Program Control Panel";
		quitbutton_setting = false;
		parse_and_process(lines, sep);
//print_state();
		window = new PCT_Window(terminal_name_setting, subcomponents.size());
		for (int i = 0; i < subcomponents.size(); ++i) {
			window.add_button((PCT_Component) subcomponents.elementAt(i));
		}
		if (quitbutton_setting) window.add_quit_button();
	}

	public Object component_context() {
		return _component_context;
	}

	public void execute() {
		window.execute();
	}

	// All lines from `f', one element per line
	Vector lines_from_file(FileReaderUtilities f) throws IOException {
		Vector result = new Vector();
		String newline = "\n";
		f.tokenize(newline);
		while (! f.exhausted()) {
			result.addElement(f.item());
			f.forth();
		}
		return result;
	}

	// Parse and process `lines' using separator `sep'.
	void parse_and_process(Vector lines, String sep) {
		subcomponents = new Vector();
		boolean in_sub = false;
		PCT_Component current_sub = null;
		ComponentSettings settings = null;
		try {
			settings = new ComponentSettings();
		} catch (Exception e) {
			System.err.println("Fatal error: " + e + " - Aborting");
			System.exit(-1);
		}
		for (int i = 0; i < lines.size(); ++i) {
			String l = (String) lines.elementAt(i);
			if (comment(l)) continue;
			String[] tuple = split(l, sep);
			String tuple_name = tuple[0];
			if (regex_match("^begin", tuple_name)) {
				current_sub = new PCT_Component(this);
				settings.clear_subcomponent_values();
				in_sub = true;
			}
			else if (regex_match("^end", tuple_name)) {
				subcomponents.addElement(current_sub);
				in_sub = false;
				settings.set_subcomponent_settings(current_sub);
			}
			else if (regex_match("^" + Separator_string, tuple_name)) {
				// Ignore separator specification.
			}
			else {
				settings.process(tuple);
				if (! settings.last_key_valid()) {
					System.err.println("Invalid line in config. file: " + l);
				}
				if (settings.duplicate_setting()) {
					System.err.println("Note: This specification - '" +
						l + "' - overwites a previous one: ");
				}
			}
		}
		settings.set_main_settings(this);
	}

	// For debugging - print the current object state.
	// (Note: May want to remove when everything is working, since it causes
	// a maintenance drag by using the "_setting" attributes.)
	private void print_state() {
		PCT_Component c = null;
		System.out.println("Status for " + this + ":");
		System.out.println("terminal_name_setting: " + terminal_name_setting);
		System.out.println("quitbutton_setting: " + quitbutton_setting);
		System.out.println("program_name_setting: " + program_name_setting);
		System.out.println("There are " + subcomponents.size() +
			" subcomponents:");
		for (int i = 0; i < subcomponents.size(); ++i) {
			c = (PCT_Component) subcomponents.elementAt(i);
			System.out.println("subcomponent[" + i + "]");
			System.out.println("\tprompt: '" + c.prompt_setting + "'");
			System.out.println("\tstartup_cmd_class: '" +
				c.startup_cmd_class_setting + "'");
			System.out.println("\tstartup_cmd_method: '" +
				c.startup_cmd_method_setting + "'");
			System.out.println("\tstartupcmdargs: '" +
				c.startup_cmd_args_setting + "'");
			System.out.println("\tconfig_file_name: '" +
				c.config_file_name_setting + "'");
			System.out.println("\texit_after...: '" +
				c.exit_after_startup_cmd_setting + "'");
		}
	}

	PCT_Window window;
	Vector subcomponents;
	Object _component_context;

	public String terminal_name_setting;
	public boolean quitbutton_setting;
	public String program_name_setting;
}
