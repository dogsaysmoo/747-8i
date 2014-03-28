# To auto-manage the fuel system.  A cheat, if you will.

var tanks_auto = func(Ta,Tb) {
	var auto_manage = func {
		var selectA = getprop("consumables/fuel/tank["~Ta~"]/selected");
		var selectB = getprop("consumables/fuel/tank["~Tb~"]/selected");
		var levelA = getprop("consumables/fuel/tank["~Ta~"]/level-lbs");
		var levelB = getprop("consumables/fuel/tank["~Tb~"]/level-lbs");
		var xfeed = getprop("controls/fuel/tank["~Tb~"]/x-feed");

		var diff = levelA - levelB;

		if (getprop("controls/fuel/tank["~Ta~"]/auto-manage") and (xfeed) and (selectA) and !(selectB)) {
			if (diff > 500) {
				settimer(auto_manage,10);
			} else {
				setprop("controls/fuel/tank{"~Ta~"]/ovrd-fwd",0);
				setprop("controls/fuel/tank{"~Ta~"]/ovrd-aft",0);
				setprop("controls/fuel/tank["~Tb~"]/x-feed",0);
				setprop("controls/fuel/tank["~Ta~"]/auto-manage",0);
				tanks_update(Ta);
				tanks_update(Tb);
			}
		}
	}
	settimer(auto_manage,5);
}

setlistener("consumables/fuel/tank/selected", func(sel) {
	var tank = sel.getBoolValue();
	if ((getprop("consumables/fuel/tank/level-lbs") < 800) and !(tank) and getprop("controls/fuel/tank/auto-manage")) {
		setprop("controls/fuel/tank[1]/ovrd-fwd",1);
		setprop("controls/fuel/tank[1]/ovrd-aft",1);
		setprop("controls/fuel/tank[2]/ovrd-fwd",1);
		setprop("controls/fuel/tank[2]/ovrd-aft",1);
		tanks_update(1);
		tanks_update(2);
		tanks_update(3);
		tanks_update(4);
	}
},0,0);

setlistener("consumables/fuel/tank[1]/selected", func(sel) {
	var tank = sel.getBoolValue();
	if (tank and getprop("controls/fuel/tank[1]auto-manage")) {
		tanks_auto(1,3);
	}
},0,0);
setlistener("consumables/fuel/tank[2]/selected", func(sel) {
	var tank = sel.getBoolValue();
	if (tank and getprop("controls/fuel/tank[2]/auto-manage")) {
		tanks_auto(2,4);
	}
},0,0);

