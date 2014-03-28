# 747-8 pneumatic system.  By John Williams

# Initialize the pneumatic system
var pneu_init = func {
	var pack_sw0 = props.globals.initNode("controls/pneumatic/pack-control",0,"BOOL");
	var pack_sw1 = props.globals.initNode("controls/pneumatic/pack-control[1]",0,"BOOL");
	var pack_sw2 = props.globals.initNode("controls/pneumatic/pack-control[2]",0,"BOOL");
	var pack_hi = props.globals.initNode("controls/pneumatic/pack-high-flow",0,"BOOL");
	var pack0 = props.globals.initNode("systems/pneumatic/pack",0,"BOOL");
	var pack1 = props.globals.initNode("systems/pneumatic/pack[1]",0,"BOOL");
	var pack2 = props.globals.initNode("systems/pneumatic/pack[2]",0,"BOOL");
	var pack_fault = props.globals.initNode("systems/pneumatic/pack-sys-fault",0,"BOOL");
	var grndair = props.globals.initNode("systems/pneumatic/air-service",0,"BOOL");
	var bleed_l = props.globals.initNode("systems/pneumatic/bleed-air",0,"BOOL");
	var bleed_r = props.globals.initNode("systems/pneumatic/bleed-air[1]",0,"BOOL");
	var isln_l = props.globals.initNode("controls/pneumatic/isolation-valve",1,"BOOL");
	var isln_r = props.globals.initNode("controls/pneumatic/isolation-valve[1]",1,"BOOL");
	var engine_bleed0 = props.globals.initNode("controls/pneumatic/engine-bleed",0,"BOOL");
	var engine_bleed1 = props.globals.initNode("controls/pneumatic/engine-bleed[1]",0,"BOOL");
	var engine_bleed2 = props.globals.initNode("controls/pneumatic/engine-bleed[2]",0,"BOOL");
	var engine_bleed3 = props.globals.initNode("controls/pneumatic/engine-bleed[3]",0,"BOOL");
	var pres_l = props.globals.initNode("systems/pneumatic/pressure-norm",0.0,"DOUBLE");
	var pres_r = props.globals.initNode("systems/pneumatic/pressure-norm[1]",0.0,"DOUBLE");
}
settimer(pneu_init,1);


# Pressure update function (called by system update function)
var update_press = func {
	var air_l = 0.0;
	var air_r = 0.0;
	var isl_l = getprop("controls/pneumatic/isolation-valve");
	var isl_r = getprop("controls/pneumatic/isolation-valve[1]");

	# Supply
	if (getprop("controls/pneumatic/APU-bleed") and !(getprop("systems/pneumatic/APU-bleed-valve"))) {
		if (isl_l)
		    air_l = air_l + 101;
		if (isl_r)
		    air_r = air_r + 101;
	}
	if (getprop("controls/pneumatic/engine-bleed") and getprop("engines/engine/n1-ind") > 50) {
		air_l = air_l + 108;
		if (isl_l and isl_r)
		    air_r = air_r + 108;
	}
	if (getprop("controls/pneumatic/engine-bleed[1]") and getprop("engines/engine[1]/n1-ind") > 50) {
		air_l = air_l + 108;
		if (isl_l and isl_r)
		    air_r = air_r + 108;
	}
	if (getprop("controls/pneumatic/engine-bleed[2]") and getprop("engines/engine[2]/n1-ind") > 50) {
		air_r = air_r + 108;
		if (isl_l and isl_r)
		    air_l = air_l + 108;
	}
	if (getprop("controls/pneumatic/engine-bleed[3]") and getprop("engines/engine[3]/n1-ind") > 50) {
		air_r = air_r + 108;
		if (isl_l and isl_r)
		    air_l = air_l + 108;
	}
	if (getprop("systems/pneumatic/air-service")) {
		if (isl_l)
		    air_l = air_l + 89;    # was 34
		if (isl_r)
		    air_r = air_r + 89;
	}

	var sup_l = air_l * 0.45;
	var sup_r = air_r * 0.45;


	# Demand
	air_l = 0;
	air_r = 0;
	  # Starters
	if (getprop("controls/engines/engine/starter")) {
		if (getprop("engines/engine/n1-ind") < 26) {
			air_l = air_l - 33;
			if (isl_l and isl_r)
			    air_r = air_r - 33;
		} else {
			air_l = air_l - 12;
			if (isl_l and isl_r)
			    air_r = air_r - 12;
		}
	}
	if (getprop("controls/engines/engine[1]/starter")) {
		if (getprop("engines/engine[1]/n1-ind") < 26) {
			air_l = air_l - 33;
			if (isl_l and isl_r)
			    air_r = air_r - 33;
		} else {
			air_l = air_l - 12;
			if (isl_l and isl_r)
			    air_r = air_r - 12;
		}
	}
	if (getprop("controls/engines/engine[2]/starter")) {
		if (getprop("engines/engine[2]/n1-ind") < 26) {
			air_r = air_r - 33;
			if (isl_l and isl_r)
			    air_l = air_l - 33;
		} else {
			air_r = air_r - 12;
			if (isl_l and isl_r)
			    air_l = air_l - 12;
		}
	}
	if (getprop("controls/engines/engine[3]/starter")) {
		if (getprop("engines/engine[3]/n1-ind") < 26) {
			air_r = air_r - 33;
			if (isl_l and isl_r)
			    air_l = air_l - 33;
		} else {
			air_r = air_r - 12;
			if (isl_l and isl_r)
			    air_l = air_l - 12;
		}
	}

	  # Pneumatically driven hydraulic pumps
	if (getprop("controls/hydraulic/demand-pump") > 0) {
		air_l = air_l - 20;
		if (isl_l and isl_r)
		    air_r = air_r - 20;
	}
	if (getprop("controls/hydraulic/demand-pump[3]") > 0) {
		air_r = air_r - 20;
		if (isl_l and isl_r)
		    air_l = air_l - 20;
	}

	  # APU Generators
	if ((getprop("systems/electrical/apu-generator") == 2) and !(getprop("systems/pneumatic/APU-bleed-valve"))) {
		if (isl_l)
		    air_l = air_l - 5;
		if (isl_r)
		    air_r = air_r - 5;
	}
	if ((getprop("systems/electrical/apu-generator[1]") == 2) and !(getprop("systems/pneumatic/APU-bleed-valve"))) {
		if (isl_l)
		    air_l = air_l - 5;
		if (isl_r)
		    air_r = air_r - 5;
	}

	  # Packs
	var hiflo = 1.0;
	if (getprop("controls/pneumatic/pack-high-flow"))
		hiflo = 1.2;
	if (getprop("systems/pneumatic/pack")) {
		air_l = air_l - (30 * hiflo);
		if (isl_l and isl_r)
		    air_r = air_r - (30 * hiflo);
	}
	if (getprop("systems/pneumatic/pack[1]")) {
		if (isl_l)
		    air_l = air_l - (30 * hiflo);
		if (isl_r)
		    air_r = air_r - (30 * hiflo);
	}
	if (getprop("systems/pneumatic/pack[2]")) {
		air_r = air_r - (30 * hiflo);
		if (isl_l and isl_r)
		    air_l = air_l - (30 * hiflo);
	}
	  # Wing Anti-Ice
	if (getprop("controls/anti-ice/wing-heat")) {
		air_l = air_l - 18;
		air_r = air_r - 18;
	}

	air_l = (0.08 * air_l) + sup_l;
	air_r = (0.08 * air_r) + sup_r;

	if (air_l > 36.8) {
		setprop("systems/pneumatic/bleed-air", 1);
	} else {
		setprop("systems/pneumatic/bleed-air", 0);
	}
	if (air_r > 36.8) {
		setprop("systems/pneumatic/bleed-air[1]", 1);
	} else {
		setprop("systems/pneumatic/bleed-air[1]", 0);
	}
#	air_l = air_l / 100;
	if (air_l > 45)
	    air_l = 45;
	if (air_l < 0)
	    air_l = 0;	
	setprop("systems/pneumatic/pressure-norm",air_l);
#	air_r = air_r / 100;
	if (air_r > 45)
	    air_r = 45;
	if (air_r < 0)
	    air_r = 0;	
	setprop("systems/pneumatic/pressure-norm[1]",air_r);
}

# System Update function
var update_pneu = func {
	var bleed_l = props.globals.getNode("systems/pneumatic/bleed-air",1);
	var bleed_r = props.globals.getNode("systems/pneumatic/bleed-air[1]",1);
	var start0 = props.globals.getNode("controls/engines/engine/starter",1);
	var start1 = props.globals.getNode("controls/engines/engine[1]/starter",1);
	var start2 = props.globals.getNode("controls/engines/engine[2]/starter",1);
	var start3 = props.globals.getNode("controls/engines/engine[3]/starter",1);
	var pack0 = props.globals.getNode("systems/pneumatic/pack",1);
	var pack1 = props.globals.getNode("systems/pneumatic/pack[1]",1);
	var pack2 = props.globals.getNode("systems/pneumatic/pack[2]",1);
	var deice = props.globals.getNode("controls/anti-ice/wing-heat",1);
	var speed = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
	var isl_l = getprop("controls/pneumatic/isolation-valve");
	var isl_r = getprop("controls/pneumatic/isolation-valve[1]");
	var cutout_l = 1;
	var cutout_r = 1;
	var middle = 0;
	var packs_off = 0;

	# Update the packs	
	for (var i=0; i<3; i+=1) {
	    if (getprop("controls/pneumatic/pack-control["~i~"]")) {
		if (!(getprop("systems/pneumatic/pack-sys-fault")))
			setprop("systems/pneumatic/pack["~i~"]",1);
	    } else {
		setprop("systems/pneumatic/pack["~i~"]",0);
		packs_off += 1;
	    }
	}
	if (packs_off == 3)
		setprop("systems/pneumatic/pack-sys-fault",0);

	# No ground service air if the parking brake is off or the aircraft is in the air.
	if (!(getprop("controls/gear/brake-parking")) or !(getprop("gear/gear[1]/wow")))
		setprop("systems/pneumatic/air-service",0);

	# Pressure checks
	update_press();
	if ((bleed_l.getBoolValue() and isl_l) or (bleed_r.getBoolValue() and isl_r)) {
		middle = 1;
	} elsif (!isl_l and !isl_r) {
		if ((getprop("controls/pneumatic/APU-bleed") and !(getprop("systems/pneumatic/APU-bleed-valve"))) or getprop("systems/pneumatic/air-service"))
		    middle = 1;
	} else {
		middle = 0;
	}
	if (bleed_l.getBoolValue())
		cutout_l = 0;
	if (bleed_r.getBoolValue())
		cutout_r = 0;

	# Low pressure cut outs	
	if (speed < 180) {
	    if (cutout_l == 1 and start0.getBoolValue()) {
		start0.setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (cutout_l == 1 and start1.getBoolValue()) {
		start1.setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (cutout_r == 1 and start2.getBoolValue()) {
		start2.setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	    if (cutout_r == 1 and start3.getBoolValue()) {
		start3.setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	    }
	}
	if ((cutout_r == 1 and cutout_l == 1) and deice.getBoolValue()) {
		deice.setBoolValue(0);
		cutout_l = 0;
		cutout_r = 0;
	}
	if (cutout_r == 1 and pack2.getBoolValue()) {
		pack2.setBoolValue(0);
		setprop("systems/pneumatic/pack-sys-fault",1);
		cutout_l = 0;
		cutout_r = 0;
	}
	if (middle == 0 and pack1.getBoolValue()) {
		pack1.setBoolValue(0);
		setprop("systems/pneumatic/pack-sys-fault",1);
	}
	if (cutout_l == 1 and pack0.getBoolValue()) {
		pack0.setBoolValue(0);
		setprop("systems/pneumatic/pack-sys-fault",1);
		cutout_l = 0;
		cutout_r = 0;
	}

	settimer(update_pneu,0.5);
}
settimer(update_pneu,2);


# APU Air Available?
setlistener("engines/apu/running", func(apu) {
	var run = apu.getBoolValue();
	if (run) {
		setprop("controls/pneumatic/APU-bleed",1);
	} else {
		setprop("controls/pneumatic/APU-bleed",0);
	}
},0,0);


# Pneumatic engine starters
var turn_starter_l = func(num)  {
	if (getprop("controls/engines/engine["~num~"]/cutoff") and (getprop("systems/pneumatic/bleed-air") or getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 180)) {
		settimer(func { setprop("controls/engines/engine["~num~"]/starter", 0)}, 120);
	}else{
		settimer(func { setprop("controls/engines/engine["~num~"]/starter", 0)}, 0.5);
	}
};
var turn_starter_r = func(num)  {
	if (getprop("controls/engines/engine["~num~"]/cutoff") and (getprop("systems/pneumatic/bleed-air[1]") or getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 180)) {
		settimer(func { setprop("controls/engines/engine["~num~"]/starter", 0)}, 120);
	}else{
		settimer(func { setprop("controls/engines/engine["~num~"]/starter", 0)}, 0.5);
	}
};

setlistener("controls/engines/engine/starter", func(start0) {
	var spin = start0.getBoolValue();
	if (spin) {
		turn_starter_l(0);
	}
},0,0);

setlistener("controls/engines/engine[1]/starter", func(start1) {
	var spin = start1.getBoolValue();
	if (spin) {
		turn_starter_l(1);
	}
},0,0);

setlistener("controls/engines/engine[2]/starter", func(start2) {
	var spin = start2.getBoolValue();
	if (spin) {
		turn_starter_r(2);
	}
},0,0);

setlistener("controls/engines/engine[3]/starter", func(start3) {
	var spin = start3.getBoolValue();
	if (spin) {
		turn_starter_r(3);
	}
},0,0);

