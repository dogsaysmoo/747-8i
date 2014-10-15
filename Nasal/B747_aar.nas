# Supplemental code to turn air-to-air refueling on and off

var inlet_sw = props.globals.initNode("systems/refuel/enable",0,"BOOL");
var xfer_sw = props.globals.initNode("systems/refuel/transfer-valves",0,"BOOL");

var Lsel = nil;

setlistener ("systems/refuel/enable", func {
	if (getprop("systems/refuel/enable")) {
	    if (getprop("consumables/fuel/tank[0]/level-lbs") < 50 and getprop("consumables/fuel/tank[1]/level-lbs") > 150 and getprop("consumables/fuel/tank[2]/level-lbs") > 150) {
		setprop("consumables/fuel/tank[0]/level-lbs",getprop("consumables/fuel/tank[0]/level-lbs") + 50);
		setprop("consumables/fuel/tank[1]/level-lbs",getprop("consumables/fuel/tank[1]/level-lbs") - 25);
		setprop("consumables/fuel/tank[2]/level-lbs",getprop("consumables/fuel/tank[2]/level-lbs") - 25);
	    }

	    setprop("consumables/fuel/tank[0]/selected",1);
	    if (getprop("consumables/fuel/tank[0]/level-lbs") >= 50 and Lsel == nil) {
		Lsel = setlistener("consumables/fuel/tank[0]/selected", func {
		    if (!getprop("consumables/fuel/tank[0]/selected"))
			setprop("consumables/fuel/tank[0]/selected",1);
		},0,0);
	    }

	    setprop("systems/refuel/serviceable",1);
	    setprop("systems/refuel/transfer-valves",1);
	} else {
	    setprop("systems/refuel/serviceable",0);
	    setprop("systems/refuel/transfer-valves",0);

	    if (Lsel != nil) {
		removelistener(Lsel);
		Lsel = nil;
	    }
	}
},0,0);

var xfer_bal = func {
	if (getprop("systems/refuel/transfer-valves")) {
	    settimer(func {
		if (getprop("systems/refuel/contact")) {
		    Boeing747.startup_dist();
		    if (getprop("consumables/fuel/tank[0]/level-lbs") < 50 and getprop("consumables/fuel/tank[1]/level-lbs") > 150 and getprop("consumables/fuel/tank[2]/level-lbs") > 150) {
			setprop("consumables/fuel/tank[0]/level-lbs",getprop("consumables/fuel/tank[0]/level-lbs") + 50);
			setprop("consumables/fuel/tank[1]/level-lbs",getprop("consumables/fuel/tank[1]/level-lbs") - 25);
			setprop("consumables/fuel/tank[2]/level-lbs",getprop("consumables/fuel/tank[2]/level-lbs") - 25);
		    }
		}
		xfer_bal();
	    },5);
	}
}
setlistener ("systems/refuel/transfer-valves", func {
	if (getprop("systems/refuel/transfer-valves") and getprop("systems/refuel/enable")) {
	    xfer_bal();
	} else {
	    setprop("systems/refuel/transfer-valves",0);
	}
},0,0);

