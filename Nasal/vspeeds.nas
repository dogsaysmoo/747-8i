var V1announced = 0;
var V2announced = 0;
var VRannounced = 0;
var V1 = "";
var V2 = "";
var VR = "";
var Vref= "";
setprop("/yasim/gross-weight-lbs",800000);

var vspeeds = func {
	
#	WT = getprop("/fdm/jsbsim/inertia/weight-lbs")*0.00045359237;
	WT = getprop("/yasim/gross-weight-lbs")*0.00045359237;
	toflaps = getprop("/instrumentation/fmc/to-flap");
	flaps = getprop("/controls/flight/flaps");
	if (toflaps == 10) {
		V1 = (0.3*(WT-200))+100;
		VR = (0.3*(WT-200))+115;
		V2 = (0.3*(WT-200))+135;
	}
	if (toflaps == 20) {
		V1 = (0.3*(WT-200))+95;
		VR = (0.3*(WT-200))+110;
		V2 = (0.3*(WT-200))+130;
	}
	if (flaps == 0.833) {
		Vref = (0.3*(WT-200))+132;
	}
	if (flaps == 1) {
		Vref = (0.285*(WT-200))+127;
	}
	setprop("/instrumentation/fmc/vspeeds/V1",V1);
	setprop("/instrumentation/fmc/vspeeds/VR",VR);
	setprop("/instrumentation/fmc/vspeeds/Vref",Vref);
	setprop("/instrumentation/fmc/vspeeds/V2",V2);
	settimer(vspeeds, 1);
}

_setlistener("/sim/signals/fdm-initialized", vspeeds);