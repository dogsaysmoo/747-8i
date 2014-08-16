# A new fuel system controller, by John Williams

# Property tree numbering    Real numbering
#      5 3 1 0 2 4 6        1R 1 2 CWT 3 4 4R
#            7                     HST

var fuelsys = {
    new : func {
	m = { parents : [fuelsys] };
	m.switch_covers = props.globals.getNode("controls/switches/covers",1);
	m.fueltanks = props.globals.getNode("consumables/fuel",1);
	m.fuelcontrols = props.globals.getNode("controls/fuel",1);

	m.jettcover = m.switch_covers.initNode("jettison",0,"BOOL");
	m.xfeed1cover = m.switch_covers.initNode("xfeed1",0,"BOOL");
	m.xfeed2cover = m.switch_covers.initNode("xfeed2",0,"BOOL");

	m.xfeed1active = m.fuelcontrols.initNode("tank[1]/xfeed-active",0,"BOOL");
	m.xfeed2active = m.fuelcontrols.initNode("tank[2]/xfeed-active",0,"BOOL");
	m.hstactive = m.fuelcontrols.initNode("tank[7]/pump-active",0,"BOOL");
	m.ovrd1active = m.fuelcontrols.initNode("tank[1]/ovrd-active",0,"BOOL");
	m.ovrd2active = m.fuelcontrols.initNode("tank[2]/ovrd-active",0,"BOOL");

	m.pumpcwt = m.fuelcontrols.getNode("tank/pump",1);
	m.pump1fwd = m.fuelcontrols.getNode("tank[1]/pump-fwd",1);
	m.pump1aft = m.fuelcontrols.getNode("tank[1]/pump-aft",1);
	m.pump2fwd = m.fuelcontrols.getNode("tank[2]/pump-fwd",1);
	m.pump2aft = m.fuelcontrols.getNode("tank[2]/pump-aft",1);
	m.pump3fwd = m.fuelcontrols.getNode("tank[3]/pump-fwd",1);
	m.pump3aft = m.fuelcontrols.getNode("tank[3]/pump-aft",1);
	m.pump4fwd = m.fuelcontrols.getNode("tank[4]/pump-fwd",1);
	m.pump4aft = m.fuelcontrols.getNode("tank[4]/pump-aft",1);
	m.pumphst = m.fuelcontrols.getNode("tank[7]/pump",1);
	m.ovrd1fwd = m.fuelcontrols.getNode("tank[1]/ovrd-fwd",1);
	m.ovrd1aft = m.fuelcontrols.getNode("tank[1]/ovrd-aft",1);
	m.ovrd2fwd = m.fuelcontrols.getNode("tank[2]/ovrd-fwd",1);
	m.ovrd2aft = m.fuelcontrols.getNode("tank[2]/ovrd-aft",1);
	m.xfeed1 = m.fuelcontrols.getNode("tank[1]/x-feed",1);
	m.xfeed2 = m.fuelcontrols.getNode("tank[2]/x-feed",1);
	m.xfeed3 = m.fuelcontrols.getNode("tank[3]/x-feed",1);
	m.xfeed4 = m.fuelcontrols.getNode("tank[4]/x-feed",1);

	m.jett = m.fuelcontrols.getNode("dump-valve",1);
	m.automng = m.fuelcontrols.getNode("auto-manage",1);
	m.scavenge = 0;

	m.sel = [ m.fueltanks.getNode("tank/selected",1),
		m.fueltanks.getNode("tank[1]/selected",1),
		m.fueltanks.getNode("tank[2]/selected",1),
		m.fueltanks.getNode("tank[3]/selected",1),
		m.fueltanks.getNode("tank[4]/selected",1),
		m.fueltanks.getNode("tank[5]/selected",1),
		m.fueltanks.getNode("tank[6]/selected",1),
		m.fueltanks.getNode("tank[7]/selected",1) ];

	m.lev = [ m.fueltanks.getNode("tank/level-lbs",1),
		m.fueltanks.getNode("tank[1]/level-lbs",1),
		m.fueltanks.getNode("tank[2]/level-lbs",1),
		m.fueltanks.getNode("tank[3]/level-lbs",1),
		m.fueltanks.getNode("tank[4]/level-lbs",1),
		m.fueltanks.getNode("tank[5]/level-lbs",1),
		m.fueltanks.getNode("tank[6]/level-lbs",1),
		m.fueltanks.getNode("tank[7]/level-lbs",1) ];

	m.emp = [ m.fueltanks.getNode("tank/empty",1),
		m.fueltanks.getNode("tank[1]/empty",1),
		m.fueltanks.getNode("tank[2]/empty",1),
		m.fueltanks.getNode("tank[3]/empty",1),
		m.fueltanks.getNode("tank[4]/empty",1),
		m.fueltanks.getNode("tank[5]/empty",1),
		m.fueltanks.getNode("tank[6]/empty",1),
		m.fueltanks.getNode("tank[7]/empty",1) ];

	return m;
    },
    update : func {
	# X-Feed Manifold
	var manifold_p = 0;
	var manifold_o = 0;
	if (me.pumpcwt.getBoolValue() or me.ovrd1active.getBoolValue() or me.ovrd2active.getBoolValue())
	    manifold_p = 1;
	if (me.xfeed1active.getBoolValue() or me.xfeed2active.getBoolValue() or me.xfeed3.getBoolValue() or me.xfeed4.getBoolValue())
	    manifold_o = 1;

	# X-Feed 1 and 2
	var feedopen = 0;
	var low1 = 0;
	var low2 = 0;

	if (me.xfeed1.getBoolValue() and manifold_p == 1 and getprop("controls/flight/flaps") < 0.17) {
	    if (me.lev[0].getValue() > 850) {
		feedopen = 1;
	    } else {
		feedopen = 0;
	    }
	    if ((me.lev[1].getValue() - me.lev[2].getValue()) > 12) {
		feedopen = 0;
		low1 = 0;
	    }
	    if ((me.lev[2].getValue() - me.lev[1].getValue()) > 12) {
		feedopen = 1;
		low1 = 1;
	    }
	} else {
	    feedopen = 0;
	}
	me.xfeed1active.setBoolValue(feedopen);
	if (me.xfeed2.getBoolValue() and manifold_p == 1 and getprop("controls/flight/flaps") < 0.17) {
	    if (me.lev[0].getValue() > 850) {
		feedopen = 1;
	    } else {
		feedopen = 0;
	    }
	    if ((me.lev[2].getValue() - me.lev[1].getValue()) > 12) {
		feedopen = 0;
		low2 = 0;
	    }
	    if ((me.lev[1].getValue() - me.lev[2].getValue()) > 12) {
		feedopen = 1;
		low2 = 1;
	    }
	} else {
	    feedopen = 0;
	}
	me.xfeed2active.setBoolValue(feedopen);
	
	# OVRD pump 1 and 2
	if (me.ovrd1fwd.getBoolValue() or me.ovrd1aft.getBoolValue()) {
	    if (me.pumpcwt.getBoolValue() and !me.jett.getBoolValue()) {
		me.ovrd1active.setBoolValue(0);
	    } elsif (low1 == 1 and me.xfeed1active.getBoolValue() and me.ovrd2active.getBoolValue()) {
		me.ovrd1active.setBoolValue(0);
	    } else {
		me.ovrd1active.setBoolValue(1);
	    }
	} else {
	    me.ovrd1active.setBoolValue(0);
	}
	if (me.ovrd2fwd.getBoolValue() or me.ovrd2aft.getBoolValue()) {
	    if (me.pumpcwt.getBoolValue() and !me.jett.getBoolValue()) {
		me.ovrd2active.setBoolValue(0);
	    } elsif (low2 == 1 and me.xfeed2active.getBoolValue() and me.ovrd1active.getBoolValue()) {
		me.ovrd2active.setBoolValue(0);
	    } else {
		me.ovrd2active.setBoolValue(1);
	    }
	} else {
	    me.ovrd2active.setBoolValue(0);
	}

	# Center Wing Tank
	if (!me.emp[0].getBoolValue() and me.pumpcwt.getBoolValue() and me.lev[0].getValue() < 800) {
	    me.pumpcwt.setBoolValue(0);
	    me.tanks_transfer(0,2,0.025);
	    me.tanks_transfer(0,1,0.025);
	    me.scavenge = 1;
	}
	if (me.emp[0].getBoolValue()) {
	    me.scavenge = 0;
	    me.pumpcwt.setBoolValue(0);
	}
	if ((me.pumpcwt.getBoolValue() and manifold_o == 1) or me.scavenge == 1) {
	    me.sel[0].setBoolValue(1);
	} else {
	    me.sel[0].setBoolValue(0);
	}

	# Inboard Main Wing Tanks
	if ((me.pump1fwd.getBoolValue() or me.pump1aft.getBoolValue()) and !(me.xfeed1active.getBoolValue() and manifold_p == 1)) {
	    me.sel[1].setBoolValue(1);
	} elsif (me.ovrd1active.getBoolValue() and manifold_o == 1) {
	    me.sel[1].setBoolValue(1);
	} else {
	    me.sel[1].setBoolValue(0);
	}
	if ((me.pump2fwd.getBoolValue() or me.pump2aft.getBoolValue()) and !(me.xfeed2active.getBoolValue() and manifold_p == 1)) {
	    me.sel[2].setBoolValue(1);
	} elsif (me.ovrd2active.getBoolValue() and manifold_o == 1) {
	    me.sel[2].setBoolValue(1);
	} else {
	    me.sel[2].setBoolValue(0);
	}

	var mng_off = 0;
	if (me.automng.getBoolValue()) {
	    if (me.lev[1].getValue() <= (me.lev[3].getValue() + me.lev[5].getValue() + 500.0)) {
		me.ovrd1fwd.setBoolValue(0);
		me.ovrd1aft.setBoolValue(0);
		me.xfeed3.setBoolValue(0);
		mng_off += 1;
	    }
	    if (me.lev[2].getValue() <= (me.lev[4].getValue() + me.lev[6].getValue() + 500.0)) {
		me.ovrd2fwd.setBoolValue(0);
		me.ovrd2aft.setBoolValue(0);
		me.xfeed4.setBoolValue(0);
		mng_off += 1;
	    }
	    if (mng_off == 2) me.automng.setBoolValue(0);
	}

	# Outboard Main Wing Tanks and Reserve Tanks
	if ((me.pump3fwd.getBoolValue() or me.pump3aft.getBoolValue()) and !(me.xfeed3.getBoolValue() and manifold_p == 1)) {
	    if (me.lev[3].getValue() < 13500 and !me.emp[5].getBoolValue()) {
		me.sel[3].setBoolValue(0);
		me.sel[5].setBoolValue(1);
	    } else {
		me.sel[3].setBoolValue(1);
		me.sel[5].setBoolValue(0);
	    }
	} else {
	    me.sel[3].setBoolValue(0);
	    me.sel[5].setBoolValue(0);
	}
	if ((me.pump4fwd.getBoolValue() or me.pump4aft.getBoolValue()) and !(me.xfeed4.getBoolValue() and manifold_p == 1)) {
	    if (me.lev[4].getValue() < 13500 and !me.emp[6].getBoolValue()) {
		me.sel[4].setBoolValue(0);
		me.sel[6].setBoolValue(1);
	    } else {
		me.sel[4].setBoolValue(1);
		me.sel[6].setBoolValue(0);
	    }
	} else {
	    me.sel[4].setBoolValue(0);
	    me.sel[6].setBoolValue(0);
	}
	if (getprop("controls/fuel/fuel-xfer")) {
	    if (me.lev[3].getValue() > 7000)
		me.tanks_transfer(3,1,0.4);
	    if (me.lev[4].getValue() > 7000)
		me.tanks_transfer(4,2,0.4);
	    if (me.lev[3].getValue() <= 7000 and me.lev[4].getValue() <= 7000)
		setprop("controls/fuel/fuel-xfer",0);
	}

	# Tail Plane Tank
	if (me.pumphst.getBoolValue() and me.lev[0].getValue() <= 80000) {
	    if (me.emp[7].getBoolValue()) {
		me.hstactive.setBoolValue(0);
		me.sel[7].setBoolValue(0);
	    } else {
		me.hstactive.setBoolValue(1);
		me.sel[7].setBoolValue(1);
		me.tanks_transfer(7,0,0.15);
	    }
	} else {
	    me.hstactive.setBoolValue(0);
	    me.sel[7].setBoolValue(0);
	}

	# Engine Suction
	var n1 = 0.0;
	if (!(me.xfeed1.getBoolValue() and manifold_p == 1) and !(me.pump1fwd.getBoolValue() or me.pump1aft.getBoolValue())) {
	    n1 = getprop("engines/engine[1]/n1-ind");
	    if (n1 > 48 and n1 < 88 and getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 180) {
		me.sel[1].setBoolValue(1);
	    } else {
		setprop("engines/engine[1]/started",0);
	    }
	}
	if (!(me.xfeed2.getBoolValue() and manifold_p == 1) and !(me.pump2fwd.getBoolValue() or me.pump2aft.getBoolValue())) {
	    n1 = getprop("engines/engine[2]/n1-ind");
	    if (n1 > 48 and n1 < 88 and getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 180) {
		me.sel[2].setBoolValue(1);
	    } else {
		setprop("engines/engine[2]/started",0);
	    }
	}
	if (!(me.xfeed3.getBoolValue() and manifold_p == 1) and !(me.pump3fwd.getBoolValue() or me.pump3aft.getBoolValue())) {
	    n1 = getprop("engines/engine/n1-ind");
	    if (n1 > 48 and n1 < 88 and getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 180) {
		me.sel[3].setBoolValue(1);
	    } else {
		setprop("engines/engine/started",0);
	    }
	}
	if (!(me.xfeed4.getBoolValue() and manifold_p == 1) and !(me.pump4fwd.getBoolValue() or me.pump4aft.getBoolValue())) {
	    n1 = getprop("engines/engine[3]/n1-ind");
	    if (n1 > 48 and n1 < 88 and getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 180) {
		me.sel[4].setBoolValue(1);
	    } else {
		setprop("engines/engine[3]/started",0);
	    }
	}
	me.power_update();
    },
    power_update : func {
	var ac0 = getprop("systems/electrical/ac-bus");
	var ac1 = getprop("systems/electrical/ac-bus[1]");
	var ac2 = getprop("systems/electrical/ac-bus[2]");
	var ac3 = getprop("systems/electrical/ac-bus[3]");
	if (!(ac0 or ac1 or ac2 or ac3)) {
		me.pumpcwt.setBoolValue(0);
		me.pump1fwd.setBoolValue(0);
		me.pump1aft.setBoolValue(0);
		me.pump2fwd.setBoolValue(0);
		me.pump2aft.setBoolValue(0);
		me.pump3fwd.setBoolValue(0);
		me.pump3aft.setBoolValue(0);
		me.pump4fwd.setBoolValue(0);
		me.pump4aft.setBoolValue(0);
		me.ovrd1fwd.setBoolValue(0);
		me.ovrd1aft.setBoolValue(0);
		me.ovrd2fwd.setBoolValue(0);
		me.ovrd2aft.setBoolValue(0);
		me.pumphst.setBoolValue(0);
	}
    },
    tanks_transfer : func(src,des,rate) {
	var src_lev = getprop("consumables/fuel/tank["~src~"]/level-gal_us");
        var des_lev = getprop("consumables/fuel/tank["~des~"]/level-gal_us");
        var des_cap = getprop("consumables/fuel/tank["~des~"]/capacity-gal_us");
        if (des_lev < (des_cap - rate)) {
            setprop("consumables/fuel/tank["~src~"]/level-gal_us",(src_lev - rate));
            setprop("consumables/fuel/tank["~des~"]/level-gal_us",(des_lev + rate));
        }
    }
};
var B748fuel = fuelsys.new();
var update_fuel = func {
	B748fuel.update();
	settimer(update_fuel,0.5);
}

############
# Idle fuel consumption
var tanks_idle = func {
	var idle_ff = func(eng,src) {
	    var cutoff = getprop("controls/engines/engine[" ~eng~ "]/cutoff");
	    var n1 = getprop("engines/engine[" ~eng~ "]/n1-ind");
	    var frate = getprop("engines/engine[" ~eng~ "]/fuel-flow-gph");
	    var empty = getprop("consumables/fuel/tank[" ~src~ "]/empty");
	    
	    if (!cutoff and !empty and n1>30 and frate<10) {
		setprop("consumables/fuel/tank[" ~src~ "]/level-gal_us",(getprop("consumables/fuel/tank[" ~src~ "]/level-gal_us") - 0.004));
	    }
	}

	var src_tank = func(eng) {
	    var src = 0; 
	    if (eng == 0) src = 3;
	    if (eng == 1) src = 1;
	    if (eng == 2) src = 2;
	    if (eng == 3) src = 4;

	    var selected = getprop("consumables/fuel/tank[" ~src~ "]/selected");
	    var ctr_sel = getprop("consumables/fuel/tank/selected");
	    var xfeed = getprop("controls/fuel/tank[" ~src~ "]/x-feed");

	    if (xfeed) {
		if (eng==0) {
		    if (getprop("consumables/fuel/tank[1]/selected") and (getprop("controls/fuel/tank[1]/ovrd-fwd") or getprop("controls/fuel/tank[1]/ovrd-aft"))) {
			src = 1;
		    } elsif (getprop("consumables/fuel/tank[2]/selected") and (getprop("controls/fuel/tank[2]/ovrd-fwd") or getprop("controls/fuel/tank[2]/ovrd-aft"))) {
			src = 2;
		    }
		}
		if (eng==3) {
		    if (getprop("consumables/fuel/tank[2]/selected") and (getprop("controls/fuel/tank[2]/ovrd-fwd") or getprop("controls/fuel/tank[2]/ovrd-aft"))) {
			src = 2;
		    } elsif (getprop("consumables/fuel/tank[1]/selected") and (getprop("controls/fuel/tank[1]/ovrd-fwd") or getprop("controls/fuel/tank[1]/ovrd-aft"))) {
			src = 1;
		    }
		}
		if (ctr_sel) {
		    src = 0;
		}
	    }
	    return src;
	}

	idle_ff(0,src_tank(0));
	idle_ff(1,src_tank(1));
	idle_ff(2,src_tank(2));
	idle_ff(3,src_tank(3));
}
var fuel_idle = func {
	tanks_idle();
	settimer(fuel_idle,0.1);
}

setlistener("/sim/signals/fdm-initialized", func {
	update_fuel();
	fuel_idle();
},0,0);

############

############
# Fuel Jettison
var FTR = 0;
var dump_fuel = func {
    FTR = getprop("consumables/fuel/total-fuel-lbs") + 1500 - (getprop("/yasim/gross-weight-lbs") - getprop("limits/mass-and-balance/maximum-landing-mass-lbs"));
    if (getprop("controls/fuel/dump-valve")) {
        if (getprop("consumables/fuel/total-fuel-lbs") > FTR) {
                # Center tank
	    if (getprop("controls/fuel/tank/pump")) {
#		if (getprop("consumables/fuel/tank/level-gal_us") > 50) {
			setprop("consumables/fuel/tank/level-gal_us", getprop("consumables/fuel/tank/level-gal_us") - 3);
#		}
	    }
		# Reserve, then inner + outer
	    if (getprop("controls/fuel/tank[1]/ovrd-fwd") or getprop("controls/fuel/tank[1]/ovrd-aft")) {
                if (getprop("consumables/fuel/tank[1]/level-gal_us") > 1000) {
                	setprop("consumables/fuel/tank[1]/level-gal_us", getprop("consumables/fuel/tank[1]/level-gal_us") - 1.5);
                }
                if ((getprop("consumables/fuel/tank[5]/level-gal_us") > 1.5) and (getprop("consumables/fuel/tank[5]/selected"))) {
                        setprop("consumables/fuel/tank[5]/level-gal_us", getprop("consumables/fuel/tank[5]/level-gal_us") - 1.5);
                }else{
                	if (getprop("consumables/fuel/tank[1]/level-gal_us") > 1000) {
                		setprop("consumables/fuel/tank[1]/level-gal_us", getprop("consumables/fuel/tank[1]/level-gal_us") - 1.5);
                	}
		}
		if ((getprop("consumables/fuel/tank[3]/level-gal_us") > 1000) and (getprop("consumables/fuel/tank[1]/level-lbs") < 20000)) {
			setprop("consumables/fuel/tank[3]/level-gal_us",getprop("consumables/fuel/tank[3]/level-gal_us") - 2);
			setprop("consumables/fuel/tank[1]/level-gal_us",getprop("consumables/fuel/tank[1]/level-gal_us") + 2);
		}
	    }

	    if (getprop("controls/fuel/tank[2]/ovrd-fwd") or getprop("controls/fuel/tank[2]/ovrd-aft")) {
                if (getprop("consumables/fuel/tank[2]/level-gal_us") > 1000) {
                	setprop("consumables/fuel/tank[2]/level-gal_us", getprop("consumables/fuel/tank[2]/level-gal_us") - 1.5);
                }
                if ((getprop("consumables/fuel/tank[6]/level-gal_us") > 1.5) and (getprop("consumables/fuel/tank[6]/selected"))) {
                        setprop("consumables/fuel/tank[6]/level-gal_us", getprop("consumables/fuel/tank[6]/level-gal_us") - 1.5);
                }else{
                	if (getprop("consumables/fuel/tank[2]/level-gal_us") > 1000) {
                		setprop("consumables/fuel/tank[2]/level-gal_us", getprop("consumables/fuel/tank[2]/level-gal_us") - 1.5);
                	}
		}
		if ((getprop("consumables/fuel/tank[4]/level-gal_us") > 1000) and (getprop("consumables/fuel/tank[2]/level-lbs") < 20000)) {
			setprop("consumables/fuel/tank[4]/level-gal_us",getprop("consumables/fuel/tank[4]/level-gal_us") - 2);
			setprop("consumables/fuel/tank[2]/level-gal_us",getprop("consumables/fuel/tank[2]/level-gal_us") + 2);
		}
	    }
	}else{
                setprop("controls/fuel/dump-valve",0);
        }
        settimer(dump_fuel,1);
    }
}
# Listen for the fuel jettison switch
setlistener("controls/fuel/dump-valve", func(dumpswitch) {
        var open = dumpswitch.getBoolValue();
        if (open) {
		setprop("controls/fuel/tank[1]/x-feed",0);
		setprop("controls/fuel/tank[2]/x-feed",0);
		setprop("controls/fuel/tank[3]/x-feed",0);
		setprop("controls/fuel/tank[4]/x-feed",0);
                dump_fuel();
        }
},0,0);	
############
# Pump shutoff when tanks 1-4 are empty
setlistener("consumables/fuel/tank[1]/empty", func(lev) {
	var level = lev.getBoolValue();
	if (level) {
		setprop("controls/fuel/tank[1]/pump-fwd",0);
		setprop("controls/fuel/tank[1]/pump-aft",0);
		setprop("controls/fuel/tank[1]/ovrd-fwd",0);
		setprop("controls/fuel/tank[1]/ovrd-aft",0);
	}
},0,0);
setlistener("consumables/fuel/tank[2]/empty", func(lev) {
	if (lev.getBoolValue()) {
		setprop("controls/fuel/tank[2]/pump-fwd",0);
		setprop("controls/fuel/tank[2]/pump-aft",0);
		setprop("controls/fuel/tank[2]/ovrd-fwd",0);
		setprop("controls/fuel/tank[2]/ovrd-aft",0);
	}
},0,0);
setlistener("consumables/fuel/tank[3]/empty", func(lev) {
	if (lev.getBoolValue()) {
		setprop("controls/fuel/tank[3]/pump-fwd",0);
		setprop("controls/fuel/tank[3]/pump-aft",0);
	}
},0,0);
setlistener("consumables/fuel/tank[4]/empty", func(lev) {
	if (lev.getBoolValue()) {
		setprop("controls/fuel/tank[4]/pump-fwd",0);
		setprop("controls/fuel/tank[4]/pump-aft",0);
	}
},0,0);
############


############
# Correctly distribute the fuel on startup
var startup_dist = func {
	var fob = getprop("consumables/fuel/total-fuel-gal_us");
	var cap0 = getprop("consumables/fuel/tank/capacity-gal_us");
	var cap1 = getprop("consumables/fuel/tank[1]/capacity-gal_us");
	var cap2 = getprop("consumables/fuel/tank[2]/capacity-gal_us");
	var cap3 = getprop("consumables/fuel/tank[3]/capacity-gal_us");
	var cap4 = getprop("consumables/fuel/tank[4]/capacity-gal_us");
	var cap5 = getprop("consumables/fuel/tank[5]/capacity-gal_us");
	var cap6 = getprop("consumables/fuel/tank[6]/capacity-gal_us");
	var cap7 = getprop("consumables/fuel/tank[7]/capacity-gal_us");
	var density1 = getprop("consumables/fuel/tank[1]/density-ppg");
	var density2 = getprop("consumables/fuel/tank[2]/density-ppg");
	var lev0 = props.globals.getNode("consumables/fuel/tank/level-gal_us",1);
	var lev1 = props.globals.getNode("consumables/fuel/tank[1]/level-gal_us",1);
	var lev2 = props.globals.getNode("consumables/fuel/tank[2]/level-gal_us",1);
	var lev3 = props.globals.getNode("consumables/fuel/tank[3]/level-gal_us",1);
	var lev4 = props.globals.getNode("consumables/fuel/tank[4]/level-gal_us",1);
	var lev5 = props.globals.getNode("consumables/fuel/tank[5]/level-gal_us",1);
	var lev6 = props.globals.getNode("consumables/fuel/tank[6]/level-gal_us",1);
	var lev7 = props.globals.getNode("consumables/fuel/tank[7]/level-gal_us",1);

	var reduc = 1000.0 / density1;
	var remain = fob - reduc;
	reduc = 40000.0 / density1;
	if (remain > reduc) {
	  if (((remain - reduc) / 8) > cap5) {
	    lev5.setValue(cap5);
	    lev6.setValue(cap6);
	  } else {
	    lev5.setValue((remain - reduc) / 8);
	    lev6.setValue((remain - reduc) / 8);
	  }
	} else {
	    lev5.setValue(0);
	    lev6.setValue(0);
	}
	remain = remain - lev5.getValue() - lev6.getValue();

	reduc = lev5.getValue() + lev6.getValue();
	if (remain > 0) {
	  if (cap3 < ((remain - reduc) / 4)) {
	    lev3.setValue(cap3);
	    lev4.setValue(cap4);
	  } else {
	    lev3.setValue((remain - reduc) / 4);
	    lev4.setValue((remain - reduc) / 4);
	  }
	} else {
	    lev3.setValue(0);
	    lev4.setValue(0);
	}
	remain = remain - lev3.getValue() - lev4.getValue() + (1000.0 / density1);

	if (remain / 2 > cap1) {
	    lev1.setValue(cap1);
	    lev2.setValue(cap2);
	} else {
	    lev1.setValue(remain / 2);
	    lev2.setValue(remain / 2);
	}
	remain = remain - lev1.getValue() - lev2.getValue();

	if (remain > cap0) {
	    lev0.setValue(cap0);
	} else {
	    lev0.setValue(remain);
	}
	remain = remain - lev0.getValue();
	if (remain > cap7) {
	    lev7.setValue(cap7);
	} else {
	    lev7.setValue(remain);
	}

	setprop("controls/groundservice/fueling/target-lbs",getprop("consumables/fuel/total-fuel-lbs"));
	setprop("controls/groundservice/fueling/target-gal_us",getprop("consumables/fuel/total-fuel-gal_us"));
}
settimer(startup_dist,3);

############

############
# Refueling

# everything in controls/groundservice/fueling
#1 Fueling
var tanks_load = func {
	var fuel_up = func(stage) {
	    var tot_level = props.globals.getNode("consumables/fuel/total-fuel-gal_us",1);
	    var cap0 = props.globals.getNode("consumables/fuel/tank/capacity-gal_us",1);
	    var cap1 = props.globals.getNode("consumables/fuel/tank[1]/capacity-gal_us",1);
	    var cap2 = props.globals.getNode("consumables/fuel/tank[2]/capacity-gal_us",1);
	    var cap3 = props.globals.getNode("consumables/fuel/tank[3]/capacity-gal_us",1);
	    var cap4 = props.globals.getNode("consumables/fuel/tank[4]/capacity-gal_us",1);
	    var cap5 = props.globals.getNode("consumables/fuel/tank[5]/capacity-gal_us",1);
	    var cap6 = props.globals.getNode("consumables/fuel/tank[6]/capacity-gal_us",1);
	    var cap7 = props.globals.getNode("consumables/fuel/tank[7]/capacity-gal_us",1);
	    var lev0 = props.globals.getNode("consumables/fuel/tank/level-gal_us",1);
	    var lev1 = props.globals.getNode("consumables/fuel/tank[1]/level-gal_us",1);
	    var lev2 = props.globals.getNode("consumables/fuel/tank[2]/level-gal_us",1);
	    var lev3 = props.globals.getNode("consumables/fuel/tank[3]/level-gal_us",1);
	    var lev4 = props.globals.getNode("consumables/fuel/tank[4]/level-gal_us",1);
	    var lev5 = props.globals.getNode("consumables/fuel/tank[5]/level-gal_us",1);
	    var lev6 = props.globals.getNode("consumables/fuel/tank[6]/level-gal_us",1);
	    var lev7 = props.globals.getNode("consumables/fuel/tank[7]/level-gal_us",1);
	    var density1 = props.globals.getNode("consumables/fuel/tank[1]/density-ppg",1);
	    var density2 = props.globals.getNode("consumables/fuel/tank[2]/density-ppg",1);
	    var density3 = props.globals.getNode("consumables/fuel/tank[3]/density-ppg",1);
	    var density4 = props.globals.getNode("consumables/fuel/tank[4]/density-ppg",1);
	    var density5 = props.globals.getNode("consumables/fuel/tank[5]/density-ppg",1);
	    var density6 = props.globals.getNode("consumables/fuel/tank[6]/density-ppg",1);
	    var density7 = props.globals.getNode("consumables/fuel/tank[7]/density-ppg",1);
            
	    var target_lev = props.globals.getNode("controls/groundservice/fueling/target-gal_us",1);
	    var active = props.globals.getNode("controls/groundservice/fueling/loading",1);

	    var rate = 20;
	    if (active.getBoolValue() and (tot_level.getValue() < (target_lev.getValue() - (0.8*rate)))) {
	    # Fuel up
		if (stage == 0) {
		    var irate = rate / 3;
		    if (lev1.getValue() < (100 / density1.getValue())) {
			lev1.setValue(lev1.getValue() + irate);
		    } else {
			stage = 1;
		    }
		}

		if (stage == 1) {
		    var flag = 2;
		    var irate = rate / 2;
		    if (lev1.getValue() < (500 / density1.getValue())) {
			lev1.setValue(lev1.getValue() + irate);
		    } else {
			flag = flag - 1;
		    }
		    if (lev2.getValue() < (500 / density2.getValue())) {
			lev2.setValue(lev2.getValue() + irate);
		    } else {
			flag = flag - 1;
		    }

		    if (flag == 0) stage = 2;
		}

		if (stage == 2) {
		    var flag = 4;
		    var irate = rate / flag;
		    if (lev3.getValue() < (10000 / density3.getValue())) {
			lev3.setValue(lev3.getValue() + irate);
		    } else {
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev4.getValue() < (10000 / density4.getValue())) {
			lev4.setValue(lev4.getValue() + irate);
		    } else {
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev1.getValue() < ((500 / density1.getValue()) + lev3.getValue())) {
			lev1.setValue(lev1.getValue() + irate);
		    } else {
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev2.getValue() < ((500 / density2.getValue()) + lev4.getValue())) {
			lev2.setValue(lev2.getValue() + irate);
		    } else {
			flag = flag - 1;
		    }

		    if (flag == 0) stage = 3;
		}

		if (stage == 3) {
		    var flag = 8;
		    var irate = rate / flag;
		    if (lev5.getValue() < (cap5.getValue() - irate)) {
			lev5.setValue(lev5.getValue() + irate);
		    } else {
			lev5.setValue(cap5.getValue());
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev6.getValue() < (cap6.getValue() - irate)) {
			lev6.setValue(lev6.getValue() + irate);
		    } else {
			lev6.setValue(cap6.getValue());
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev3.getValue() < (cap3.getValue() - irate)) {
			lev3.setValue(lev3.getValue() + irate);
		    } else {
			lev3.setValue(cap3.getValue());
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev4.getValue() < (cap4.getValue() - irate)) {
			lev4.setValue(lev4.getValue() + irate);
		    } else {
			lev4.setValue(cap4.getValue());
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev1.getValue() < ((500 / density1.getValue()) + cap3.getValue() + cap5.getValue())) {
			lev1.setValue(lev1.getValue() + (2 * irate));
		    } else {
			flag = flag - 2;
			irate = rate / flag;
		    }
		    if (lev2.getValue() < ((500 / density2.getValue()) + cap4.getValue() + cap6.getValue())) {
			lev2.setValue(lev2.getValue() + (2 * irate));
		    } else {
			flag = flag - 2;
		    }
		    if (flag == 0) stage = 4;
		}

		if (stage == 4) {
		    var flag = 2;
		    var irate = rate / flag;
		    if (lev1.getValue() < (cap1.getValue() - irate)) {
			lev1.setValue(lev1.getValue() + irate);
		    } else {
			lev1.setValue(cap1.getValue());
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev2.getValue() < (cap2.getValue() - irate)) {
			lev2.setValue(lev2.getValue() + irate);
		    } else {
			lev2.setValue(cap2.getValue());
			flag = flag - 1;
		    }
		    if (flag == 0) stage = 5;
		}		    

		if (stage == 5) {
		    var irate = rate;
		    if (lev0.getValue() < (cap0.getValue() - irate)) {
			lev0.setValue(lev0.getValue() + irate);
		    } else {
			lev0.setValue(cap0.getValue());
			stage = 6;
		    }
		}

		if (stage == 6) {
		    var irate = rate;
		    if (lev7.getValue() < (cap7.getValue() - irate)) {
			lev7.setValue(lev7.getValue() + irate);
		    } else {
			lev7.setValue(cap7.getValue());
			if (getprop("engines/apu/running")) active.setBoolValue(0);
		    }
		}
		settimer(func {fuel_up(stage)},0.5);


	    } elsif (active.getBoolValue() and (tot_level.getValue() > (target_lev.getValue() + (0.8*rate)))) {
	    # Drain tanks
		if (stage == 0) {
		    var flag = 2;
		    var irate = rate / flag;
		    if (lev7.getValue() > irate) {
			lev7.setValue(lev7.getValue() - irate);
		    } else {
			lev7.setValue(0);
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev0.getValue() > irate) {
			lev0.setValue(lev0.getValue() - irate);
		    } else {
			lev0.setValue(0);
			flag = flag - 1;
		    }
		    if (flag == 0) stage = 1;
		}

		if (stage == 1) {
		    var flag = 2;
		    var irate = rate / flag;
		    if (lev1.getValue() > lev3.getValue() + (500 / density1.getValue())) {
			lev1.setValue(lev1.getValue() - irate);
		    } else {
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev2.getValue() > lev4.getValue() + (500 / density2.getValue())) {
			lev2.setValue(lev2.getValue() - irate);
		    } else {
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (flag == 0) stage = 2;
		}

		if (stage == 2) {
		    var flag = 6;
		    var irate = rate / flag;
		    if (lev5.getValue() > irate) {
			lev5.setValue(lev5.getValue() - irate);
		    } else {
			lev5.setValue(0);
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev6.getValue() > irate) {
			lev6.setValue(lev6.getValue() - irate);
		    } else {
			lev6.setValue(0);
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev1.getValue() > (lev3.getValue() + (500 / density1.getValue()))) {
			lev1.setValue(lev1.getValue() - irate);
		    } else {
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev2.getValue() > (lev4.getValue() + (500 / density2.getValue()))) {
			lev2.setValue(lev2.getValue() - irate);
		    } else {
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev3.getValue() > irate) {
			lev3.setValue(lev3.getValue() - irate);
		    } else {
			lev3.setValue(0);
			flag = flag - 1;
			irate = rate / flag;
		    }
		    if (lev4.getValue() > irate) {
			lev4.setValue(lev4.getValue() - irate);
		    } else {
			lev4.setValue(0);
			flag = flag - 1;
		    }
		}
		settimer(func {fuel_up(stage)},0.5);
		
	    } else {
	    # Active / level loop
		active.setBoolValue(0);
		Boeing747.copilot.announce("Fuel transfer complete.");
	    }
	    setprop("controls/groundservice/fueling/remain-lbs",(getprop("controls/groundservice/fueling/target-lbs") - getprop("consumables/fuel/total-fuel-lbs")));
	    # Active / level loop
	}
	# Fuel up loop
	fuel_up(0);
}

#2 Updaters

setlistener("controls/groundservice/fueling/target-lbs", func(target) {
	if (getprop("consumables/fuel/total-fuel-lbs") == 0)
	    setprop("consumables/fuel/tank/level-lbs",1.0);
        if (target.getValue() > (getprop("consumables/fuel/total-fuel-lbs") / getprop("consumables/fuel/total-fuel-norm"))) {
            target.setValue((getprop("consumables/fuel/total-fuel-lbs") / getprop("consumables/fuel/total-fuel-norm")));
        }
	if (target.getValue() < 0) {
	    target.setValue(0);
	}
        setprop("controls/groundservice/fueling/target-gal_us",(target.getValue() / getprop("consumables/fuel/tank/density-ppg")));
	setprop("controls/groundservice/fueling/remain-lbs",(target.getValue() - getprop("consumables/fuel/total-fuel-lbs")));
},0,0);

setlistener("controls/gear/brake-parking", func(ebrake) {
	if (!ebrake.getBoolValue()) {
	    setprop("controls/groundservice/fueling/loading",0);
	    setprop("controls/groundservice/fueling/truck",0);
	}
},0,0);

setlistener("gear/gear/wow", func(wow) {
	if (!wow.getBoolValue()) {
	    setprop("controls/groundservice/fueling/loading",0);
	    setprop("controls/groundservice/fueling/truck",0);
	}
},0,0);

#3 Controller

var tanks_refuel = func {
        if (getprop("controls/groundservice/fueling/loading")) {
            setprop("controls/groundservice/fueling/loading",0);
        } else {
            setprop("controls/groundservice/fueling/loading",1);
            tanks_load();
        }
}
############

