# Speedbrakes / spoilers controller - J. Williams, May 2014

var lever = props.globals.initNode("controls/flight/speedbrake-lever",0,"INT");
var auto = props.globals.initNode("controls/flight/autospeedbrakes-armed",0,"BOOL");
var pos_cmd = props.globals.getNode("controls/flight/speedbrake",0);
#var hydraulic = props.globals.getNode("systems/hydraulic/equipment/enable-spoil",0);

var speedbrake_update = func {
    if (lever.getValue() == 0) {
	auto.setBoolValue(0);
	pos_cmd.setValue(0);
    }
    if (lever.getValue() == 1) {
	auto.setBoolValue(1);
	pos_cmd.setValue(0);
    }
    if (lever.getValue() == 2 and getprop("systems/hydraulic/equipment/enable-spoil")) {
	auto.setBoolValue(0);
	pos_cmd.setValue(0.5);
    }
    if (lever.getValue() == 3 and getprop("systems/hydraulic/equipment/enable-spoil")) {
	auto.setBoolValue(0);
	pos_cmd.setValue(1.0);
    }

    if (lever.getValue() > 1 and !getprop("systems/hydraulic/equipment/enable-spoil"))
	lever.setValue(0);

    if (auto.getBoolValue()) {
	var wow1 = setlistener("gear/gear[1]/wow", func(w1) {
	    if (w1.getBoolValue()) {
	    	autospeedbrake();
	    	removelistener(wow1);
	    	removelistener(wow4);
	    	removelistener(asb);
	    }
	},0,0);
	var wow4 = setlistener("gear/gear[4]/wow", func(w4) {
	    if (w4.getBoolValue()) {
	    	autospeedbrake();
	    	removelistener(wow1);
	    	removelistener(wow4);
	    	removelistener(asb);
	    }
	},0,0);
	var asb = setlistener("controls/flight/autospeedbrakes-armed", func(arm) {
	    if (!arm.getBoolValue()) {
		removelistener(wow1);
		removelistener(wow4);
		removelistener(asb);
	    }
	},0,0);
    }
}

var autospeedbrake = func {
    if (auto.getBoolValue() and getprop("systems/hydraulic/equipment/enable-spoil")) {
	pos_cmd.setValue(1.0);
    }
    var lev_chg = setlistener("controls/flight/speedbrake-lever", func {
        if (lever.getValue() > 1) {
	    lever.setValue(0);
	    removelistener(lev_chg);
	}
    },0,0);
}

setlistener("controls/flight/speedbrake-lever", func {
	speedbrake_update();
},0,0);

