note
	description: "A simple, atomic tradable event"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class ATOMIC_TRADABLE_EVENT inherit

	TRADABLE_EVENT
		rename
			tag as symbol
		end

creation

	make

feature {NONE} -- Initialization

	make (nm, sym: STRING; time_stmp: DATE_TIME; e_type: EVENT_TYPE;
			sig_type: INTEGER)
		require
			not_void: nm /= Void and time_stmp /= Void and e_type /= Void and
						sym /= Void
		do
			name := nm
			time_stamp := time_stmp
			type := e_type
			symbol := sym
			signal_type := sig_type
		ensure
			set: name = nm and time_stamp = time_stmp and type = e_type and
					symbol = sym and signal_type = sig_type
		end

feature -- Access

	symbol: STRING
			-- Symbol that identifies the tradable associated with the event

	time_stamp: DATE_TIME

	description: STRING

	components: LIST [TRADABLE_EVENT]
		do
			create {ARRAYED_LIST [TRADABLE_EVENT]} Result.make (0)
			Result.extend (Current)
		ensure then
			Result.count = 1 and Result @ 1 = Current
		end

	guts: ARRAY [STRING]
			-- Class abbreviation ("AME"), event type ID, time_stamp,
			-- and symbol - with time_stamp in the format:
			-- yyyymmdd h:m:s.
		local
			date_time: STRING
		do
			create date_time.make (21)
			date_time.append (time_stamp.year.out)
			if time_stamp.month < 10 then
				date_time.extend ('0')
			end
			date_time.append (time_stamp.month.out)
			if time_stamp.day < 10 then
				date_time.extend ('0')
			end
			date_time.append (time_stamp.day.out)
			date_time.extend (' ')
			date_time.append (time_stamp.time.hour.out)
			date_time.append (":")
			date_time.append (time_stamp.time.minute.out)
			date_time.append (":")
			date_time.append (time_stamp.time.second.out)
			Result := <<"AME", type.id.out, date_time, symbol>>
		end

	date: DATE

	time: TIME

feature -- Status setting

	set_description (arg: STRING)
			-- Set description to `arg'.
		require
			arg_not_void: arg /= Void
		do
			description := arg
		ensure
			description_set: description = arg and description /= Void
		end

	set_date (arg: DATE)
			-- Set date to `arg'.
		require
			arg_not_void: arg /= Void
		do
			date := arg
		ensure
			date_set: date = arg and date /= Void
		end

	set_time (arg: TIME)
			-- Set time to `arg'.
		require
			arg_not_void: arg /= Void
		do
			time := arg
		ensure
			time_set: time = arg and time /= Void
		end

feature -- Status report

invariant

	symbol_not_void: symbol /= Void

end -- class ATOMIC_TRADABLE_EVENT
