# Properties under /consumables/fuel/tank[n]:
# + level-gal_us    - Current fuel load.  Can be set by user code.
# + level-lbs       - OUTPUT ONLY property, do not try to set
# + selected        - boolean indicating tank selection.
# + density-ppg     - Fuel density, in lbs/gallon.
# + capacity-gal_us - Tank capacity
#
# Properties under /engines/engine[n]:
# + fuel-consumed-lbs - Output from the FDM, zeroed by this script
# + out-of-fuel       - boolean, set by this code.


var UPDATE_PERIOD = 0.3;

var inlet_sw = props.globals.initNode("systems/refuel/enable",0,"BOOL");
var xfer_sw = props.globals.initNode("systems/refuel/transfer-valves",0,"BOOL");

var enabled = nil;
var serviceable = nil;
var fuel_freeze = nil;
var ai_enabled = nil;
var engines = nil;
var tanks = [];
var refuelingN = nil;
var aimodelsN = nil;
var types = {};



var update_loop = func {
	# check for contact with tanker aircraft
	var tankers = [];
	if (ai_enabled) {
		var ac = aimodelsN.getChildren("tanker");
		var mp = aimodelsN.getChildren("multiplayer");

		foreach (var a; ac ~ mp) {
			if (!a.getNode("valid", 1).getValue())
				continue;
			if (!a.getNode("tanker", 1).getValue())
				continue;
			if (!a.getNode("refuel/contact", 1).getValue())
				continue;
			foreach (var t; a.getNode("refuel", 1).getChildren("type")) {
				var type = t.getValue();
				if (contains(types, type) and types[type])
					append(tankers, a);
			}
		}
	}

	var refueling = serviceable and size(tankers) > 0;
	refuelingN.setBoolValue(refueling);

	if (fuel_freeze)
		return settimer(update_loop, UPDATE_PERIOD);

	# calculate fuel received
	var received = 0;
	if (refueling) {
		# assume max flow rate is 6000 lbs/min (for KC135)
		received = -100 * UPDATE_PERIOD;
#		consumed -= received;
	}

	var lbs = getprop("consumables/fuel/tank[0]/level-lbs") + received;
	setprop("consumables/fuel/tank[0]/level-lbs",lbs);

	if (getprop("systems/refuel/transfer-valves") and refueling)
		Boeing747.startup_dist();

}
var do_update_loop = func {
	if (getprop("systems/refuel/enable")) {
	    update_loop();
	    settimer(update_loop, UPDATE_PERIOD);
	}
}


setlistener("/sim/signals/fdm-initialized", func {
#	if (contains(globals, "fuel") and typeof(fuel) == "hash")
#		fuel.loop = func nil;       # kill $FG_ROOT/Nasal/fuel.nas' loop

	refuelingN = props.globals.initNode("/systems/refuel/contact", 0, "BOOL");
	aimodelsN = props.globals.getNode("ai/models", 1);
#	engines = props.globals.getNode("engines", 1).getChildren("engine");
#
#	foreach (var e; engines) {
#		e.getNode("fuel-consumed-lbs", 1).setDoubleValue(0);
#		e.getNode("out-of-fuel", 1).setBoolValue(0);
#	}
#
#	foreach (var t; props.globals.getNode("consumables/fuel", 1).getChildren("tank")) {
#		if (!t.getAttribute("children"))
#			continue;           # skip native_fdm.cxx generated zombie tanks
#
#		append(tanks, t);
#		t.initNode("level-gal_us", 0.0);
#		t.initNode("level-lbs", 0.0);
#		t.initNode("capacity-gal_us", 0.01); # not zero (div/zero issue)
#		t.initNode("density-ppg", 6.0);      # gasoline
#		t.initNode("selected", 1, "BOOL");
#	}

	foreach (var t; props.globals.getNode("systems/refuel", 1).getChildren("type"))
		types[t.getValue()] = 1;

	setlistener("sim/freeze/fuel", func(n) fuel_freeze = n.getBoolValue(), 1);
	setlistener("sim/ai/enabled", func(n) ai_enabled = n.getBoolValue(), 1);
	setlistener("systems/refuel/serviceable", func(n) serviceable = n.getBoolValue(), 1);
	setlistener("systems/refuel/enable", func {
		do_update_loop();
	},0,0);
});


