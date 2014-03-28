# Autobrake controls - J Williams, Nov 2013

var autobrake = func {
#	Autobrake on landing
	var ground = getprop("gear/gear[2]/wow");
	var nlg = getprop("gear/gear/wow");
        var mode = getprop("autopilot/autobrake/step");
        var speed = getprop("gear/gear[2]/rollspeed-ms") * 1.94;
	if (!nlg) mode = 1;
	var brake_set = 0;
	if (mode > 0) {
		brake_set = 0.75 * 0.2 * mode;
	}

        var stop0 = 0;
        var stop1 = 0;
        var stop2 = 0;
        var stop3 = 0;

        if ((getprop("controls/engines/engine/throttle") < 0.3) or (getprop("controls/engines/engine/reverser"))) stop0 = 1;
        if ((getprop("controls/engines/engine[1]/throttle") < 0.3) or (getprop("controls/engines/engine[1]/reverser"))) stop1 = 1;
        if ((getprop("controls/engines/engine[2]/throttle") < 0.3) or (getprop("controls/engines/engine[2]/reverser"))) stop2 = 1;
        if ((getprop("controls/engines/engine[3]/throttle") < 0.3) or (getprop("controls/engines/engine[3]/reverser"))) stop3 = 1;

        var stopping = 0;
        if (stop0 and stop1 and stop2 and stop3) stopping = 1;

#	Activated when wheels on the ground and throttles off or reversers on
	if (speed > 50) {
		if (ground == 1 and stopping == 1 and mode > 0) {
			setprop("controls/gear/brake-left",brake_set);
			setprop("controls/gear/brake-right",brake_set);
		}
		settimer(autobrake,0.1);
#		Deactivated when speed below 50 kts
	}
}

var rto = func {
#	RTO autobrakes
	var ground = getprop("gear/gear[2]/wow");
	var mode = getprop("autopilot/autobrake/step");
	var speed = getprop("gear/gear[2]/rollspeed-ms") * 1.94;

	var stop0 = 0;
	var stop1 = 0;
	var stop2 = 0;
	var stop3 = 0;

        if ((getprop("controls/engines/engine/throttle") < 0.1) or (getprop("controls/engines/engine/reverser"))) stop0 = 1;
        if ((getprop("controls/engines/engine[1]/throttle") < 0.1) or (getprop("controls/engines/engine[1]/reverser"))) stop1 = 1;
        if ((getprop("controls/engines/engine[2]/throttle") < 0.1) or (getprop("controls/engines/engine[2]/reverser"))) stop2 = 1;
        if ((getprop("controls/engines/engine[3]/throttle") < 0.1) or (getprop("controls/engines/engine[3]/reverser"))) stop3 = 1;
	
	var stopping = 0;
	if (stop0 and stop1 and stop2 and stop3) stopping = 1;
#	Activated when on the ground and throttles off or reversers on and speed above 85 kts
	if (ground == 1 and mode == -2 and stopping == 1) {
		if (speed > 85) {
			setprop("controls/gear/brake-left",1.0);
			setprop("controls/gear/brake-right",1.0);
			setprop("controls/gear/brake-parking",1);
			setprop("controls/flight/speedbrake",1);
		}
		if (speed < 20 and speed > 10) {
			setprop("controls/gear/brake-parking",0);
		}
	}
	if (mode == -2) settimer(rto,0.1);
}

setlistener("gear/gear[2]/wow", func(wow) {
#	When main gear touches down, deploy speedbrakes, wait 3 sec and activate autobrakes.
	if (wow.getBoolValue()) {
		if (getprop("autopilot/autobrake/step") >= 0) setprop("controls/flight/speedbrake",1);
		settimer(func {
			if (!(getprop("gear/gear/wow"))) autobrake();
		},3);
	}
},0,0);

setlistener("gear/gear/wow", func(wow) {
#	When nose gear touches down, activate autobrake immediately.
	if (wow.getBoolValue()) autobrake();
},0,0);

setlistener("autopilot/autobrake/step", func(brk) {
#	RTO autobrake mode
	if (brk.getValue() == -2) rto();
},0,0);

setlistener("controls/gear/gear-down", func(down) {
#	Reset autobrakes when gear retracted.
	if (!(down.getBoolValue())) setprop("autopilot/autobrake/step",-1);
},0,0);

