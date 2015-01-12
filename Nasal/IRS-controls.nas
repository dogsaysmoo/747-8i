# Inertial Reference System Controls - J.Williams, Feb 2014
var IRS = {
    new : func (n) {
        m = { parents : [IRS] };
	m.position = props.globals.initNode("controls/inertial-reference/position["~n~"]",0,"INT");
	m.mode = props.globals.initNode("systems/inertial-reference/mode["~n~"]",0,"INT");
	m.align = props.globals.initNode("systems/inertial-reference/alignment["~n~"]",0,"INT");
	return m;
    },
    knob : func (chg) {
	var pos = me.position.getValue() + chg;
	if (pos > 3) pos = 3;
	if (pos < 0) pos = 0;
	me.position.setValue(pos);

	var spin_time = 300;
	if (getprop("systems/inertial-reference/fast")) {
		spin_time = 5;
	} elsif (getprop("systems/inertial-reference/slow")) {
		spin_time = 300;
	} elsif (getprop("systems/inertial-reference/real")) {
		spin_time = 780;
	}

	if (pos == 0) {
		me.mode.setValue(0);
		if (me.align.getValue() == 2) {
		    settimer(func {
			if (me.mode.getValue() == 0) me.align.setValue(0);
		    },17);
		# spin down time
		} else {
		    me.align.setValue(0);
		}
	}
	if (pos == 1) {
	    var tcnt = 0;
	    var irs_align = func (spinup) {
		settimer(func {
		    if (me.align.getValue() == 1 and me.position.getValue() != 0 and getprop("controls/gear/brake-parking") and getprop("gear/gear/wow")) {
			tcnt += 1;
			if (tcnt >= spinup) {
			    me.align.setValue(2);
			} else {
			    irs_align(spinup);
			}
		    } elsif (me.align.getValue() != 2) {
		        me.align.setValue(0);
		    }
		},1);
	    }

	    if (me.align.getValue() == 0) {
		me.align.setValue(1);
	# spin up time
		irs_align(spin_time);
	    } elsif (me.align.getValue() == 2) {
		settimer(func {
		    if (me.mode.getValue() != 0 and me.position.getValue() == 1) {
			me.align.setValue(1);
	# spin up time (realignment)
			irs_align(30);
		    } else {
			me.position.setValue(me.mode.getValue());
		    }
		},1);
	    }
	}
	if (pos == 2) {
		me.mode.setValue(2);
	}
	if (pos == 3)
		me.mode.setValue(3);
    }
};
var IRSl = IRS.new(0);
var IRSc = IRS.new(1);
var IRSr = IRS.new(2);
	aircraft.data.add(
		"systems/inertial-reference/fast",
		"systems/inertial-reference/slow",
		"systems/inertial-reference/real");
