# Autobrake controls - J Williams, Jul 2014

var throt = 0;
var revrs = 0;
var brake_set = 0.0;
var abl_arm = 0;
var speed = 0;

var autobrakes = {
    new : func {
	m = { parents : [autobrakes] };

	m.mode = props.globals.initNode("autopilot/autobrake/step",-1,"INT");
	m.touchdown = props.globals.getNode("gear/gear[2]/wow",1);
	m.nlg = props.globals.getNode("gear/gear/wow",1);
	m.rollspeed = props.globals.getNode("gear/gear[2]/rollspeed-ms",1);

	m.brake_left = props.globals.getNode("controls/gear/brake-left",1);
	m.brake_right = props.globals.getNode("controls/gear/brake-right",1);

	m.throttle = [ props.globals.getNode("controls/engines/engine[0]/throttle",1),
		       props.globals.getNode("controls/engines/engine[1]/throttle",1), 
		       props.globals.getNode("controls/engines/engine[2]/throttle",1), 
		       props.globals.getNode("controls/engines/engine[3]/throttle",1) ];
	m.reverser = [ props.globals.getNode("controls/engines/engine[0]/reverser",1),
		       props.globals.getNode("controls/engines/engine[1]/reverser",1),
		       props.globals.getNode("controls/engines/engine[2]/reverser",1),
		       props.globals.getNode("controls/engines/engine[3]/reverser",1) ];

	m.disarm_arm = 0;
	m.rto_arm = 0;

	m.td = 0;

	return m;
    },

    rto : func {
	throt = (me.throttle[0].getValue() < 0.1 and
		 me.throttle[1].getValue() < 0.1 and
		 me.throttle[2].getValue() < 0.1 and
		 me.throttle[3].getValue() < 0.1);
	revrs = (me.reverser[0].getBoolValue() and
		 me.reverser[1].getBoolValue() and
		 me.reverser[2].getBoolValue() and
		 me.reverser[3].getBoolValue());

	speed = me.rollspeed.getValue() * 1.94;

	if (speed > 85) me.rto_arm = 1;
	if (me.mode.getValue() == -2 and me.touchdown.getBoolValue() and (throt or revrs)) {
	    if (me.rto_arm == 1) {
		# If the throttles are retarded or the reversers engaged over
		# 85 kts, RTO autobrakes engage at full.
		me.brake_left.setValue(1.0);
		me.brake_right.setValue(1.0);
		if (speed >= 20)
		    setprop("controls/gear/brake-parking",1);
		if (speed < 20 and speed > 10)
		    setprop("controls/gear/brake-parking",0);
		if (getprop("controls/flight/autospeedbrakes-armed"))
		    setprop("controls/flight/speedbrake-lever",3);
	    }
	}
	if (me.mode.getValue() == -2) {
	    settimer(func me.rto(),0);
	} else {
	    # RTO must be deactivated to free the brakes.
	    me.rto_arm = 0;
	}
    },

    auto_brake : func {
	throt = (me.throttle[0].getValue() < 0.1 and
		 me.throttle[1].getValue() < 0.1 and
		 me.throttle[2].getValue() < 0.1 and
		 me.throttle[3].getValue() < 0.1);
	revrs = (me.reverser[0].getBoolValue() and
		 me.reverser[1].getBoolValue() and
		 me.reverser[2].getBoolValue() and
		 me.reverser[3].getBoolValue());

	speed = me.rollspeed.getValue() * 1.94;

	if (!me.nlg.getBoolValue()) {
	    # Autobrakes stay at 1 until the nose gear touches down
	    brake_set = 0.16;
	} else {
	    brake_set = 0.16 * me.mode.getValue();
	}

	if (speed > 50 or getprop("instrumentation/airspeed-indicator/indicated-speed-kt") > 75) {
	    me.disarm_arm = 1;
	    if (me.brake_left.getValue() > 0.9 or me.brake_right.getValue() > 0.9)
		# Autobrakes disarm when someone steps on the brakes manually
		me.mode.setValue(0);
	    if (me.mode.getValue() > 0 and me.touchdown.getBoolValue() and (throt or revrs)) {
		me.brake_left.setValue(brake_set);
		me.brake_right.setValue(brake_set);
	    }
	} elsif (me.disarm_arm == 1) {
	    # Disarm when speed drops below 50 kts
	    me.disarm_arm = 0;
	    me.mode.setValue(0);
	}

	if (me.mode.getValue() > 0) settimer(func me.auto_brake(), 0);
    },

    ab_lis : func {
	if (me.mode.getValue() > 0) {
	    if (abl_arm == 0) {
		abl_arm = 1;
		me.td = setlistener("gear/gear[2]/wow", func {
		    if (me.touchdown.getBoolValue())
			settimer(func me.auto_brake(),1);
		},0,0);
	    }
	} elsif (abl_arm == 1) {
	    removelistener(me.td);
	    abl_arm = 0;
	}
    },
    listeners : func {
	setlistener("autopilot/autobrake/step", func {
	    if (me.mode.getValue() == -2)
		me.rto();
	    me.ab_lis();
	},0,0);
	setlistener("controls/gear/gear-down", func(down) {
	    if (!down.getBoolValue()) {
		me.mode.setValue(-1);
		setprop("controls/flight/speedbrake-lever",0);
	    }
	},0,0);
    },
};

var ABSys = autobrakes.new();

setlistener("/sim/signals/fdm-initialized", func {
	settimer(func ABSys.listeners(),3);
},0,0);


