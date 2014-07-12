# Speedbrake controller - J Williams, Jul 2014



var spoilers = {
    new : func {
	m = { parents : [spoilers] };

	m.lever = props.globals.initNode("controls/flight/speedbrake-lever",0,"INT");
	m.auto = props.globals.initNode("controls/flight/autospeedbrakes-armed",0,"BOOL");
	m.pos_cmd = props.globals.getNode("controls/flight/speedbrake",0);
	m.hydraulic = props.globals.getNode("systems/hydraulic/equipment/enable-spoil",0);

	m.lev_pos = 0;

	return m;
    },

    update : func {
	# Hydraulics needed to get into and out of position 2 and 3
	if (me.lev_pos == 1 and me.lever.getValue() > 1) {
	    if (me.hydraulic.getBoolValue()) {
		me.lev_pos = me.lever.getValue();
	    } else {
		me.lev_pos = 0;
		me.lever.setBoolValue(0);
	    }
	} elsif (me.lev_pos > 1) {
	    if (me.hydraulic.getBoolValue()) {
		me.lev_pos = me.lever.getValue();
	    }
	} else {
		me.lev_pos = me.lever.getValue();
	}

	# Set the status of auto and the speedbrake position
	if (me.lev_pos == 0) {
	    me.auto.setBoolValue(0);
	    me.pos_cmd.setValue(0);
	}
	if (me.lev_pos == 1) {
	    me.auto.setBoolValue(1);
	    me.pos_cmd.setValue(0);
	}
	if (me.lev_pos == 2) {
	    me.auto.setBoolValue(0);
	    me.pos_cmd.setValue(0.5);
	}
	if (me.lev_pos == 3) {
	    me.auto.setBoolValue(0);
	    me.pos_cmd.setValue(1.0);
	}

	# Auto speedbrake
	if (me.auto.getBoolValue()) {
	    var td = setlistener("gear/gear[2]/wow", func {
		me.autospeedbrake();
	    },0,0);
	    var asb = setlistener("controls/flight/autospeedbrakes-armed", func {
		if (!me.auto.getBoolValue()) {
		    removelistener(asb);
		    removelistener(td);
		}
	    },0,0);
	}
    },

    autospeedbrake : func {
	if (me.auto.getBoolValue() and getprop("gear/gear[2]/wow") and me.hydraulic.getBoolValue()) {
	    me.pos_cmd.setValue(1.0);
	    var lev_chg = setlistener("controls/flight/speedbrake-lever", func {
		if (me.lever.getValue() > 1) {
		    me.lever.setValue(0);
		    removelistener(lev_chg);
		}
	    },0,0);
	}
    },
};

var Speedbrakes = spoilers.new();
setlistener("controls/flight/speedbrake-lever", func {
	Speedbrakes.update();
},0,0);

