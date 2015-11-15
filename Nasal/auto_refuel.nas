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

	var rate = 20;
	if (tot_level.getValue() < (target_lev.getValue() - (0.8*rate))) {
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
		}
	}
	return stage;

	} elsif (tot_level.getValue() > (target_lev.getValue() + (0.8*rate))) {
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
	return stage;
	
	} else {
	# Active / level loop
		Boeing747.copilot.announce("Fuel transfer complete.");
	}
	# Active / level loop
	return -1;
}

var l_auto_refuel = setlistener('/autopilot/route-manager/active', func {
	if (!getprop('/autopilot/route-manager/active')) {
		return;
	}

	var range = getprop('/limits/estimated-range-nm');
	var route_len = getprop('/autopilot/route-manager/total-distance');
	var fuel_norm = route_len / range;
	if (fuel_norm > 1.0) {
		fuel_norm = 1.0;
	} else if (fuel_norm < 0.1) {
		fuel_norm = 0.1;
	}

	var cap0 = getprop("consumables/fuel/tank/capacity-gal_us") * getprop('/consumables/fuel/tank/density-ppg');
	var cap1 = getprop("consumables/fuel/tank[1]/capacity-gal_us") * getprop('/consumables/fuel/tank[1]/density-ppg');;
	var cap2 = getprop("consumables/fuel/tank[2]/capacity-gal_us") * getprop('/consumables/fuel/tank[2]/density-ppg');;
	var cap3 = getprop("consumables/fuel/tank[3]/capacity-gal_us") * getprop('/consumables/fuel/tank[3]/density-ppg');;
	var cap4 = getprop("consumables/fuel/tank[4]/capacity-gal_us") * getprop('/consumables/fuel/tank[4]/density-ppg');;
	var cap5 = getprop("consumables/fuel/tank[5]/capacity-gal_us") * getprop('/consumables/fuel/tank[5]/density-ppg');;
	var cap6 = getprop("consumables/fuel/tank[6]/capacity-gal_us") * getprop('/consumables/fuel/tank[6]/density-ppg');;
	var cap7 = getprop("consumables/fuel/tank[7]/capacity-gal_us") * getprop('/consumables/fuel/tank[7]/density-ppg');;

	var total_cap = cap0 + cap1 + cap2 + cap3 + cap4 + cap5 + cap6 + cap7;
	var target_fuel = total_cap * fuel_norm;
	setprop("controls/groundservice/fueling/target-lbs", total_cap * fuel_norm);
	var stage = 0;
	while (stage >= 0) {
		stage = fuel_up(stage);
		setprop("controls/groundservice/fueling/remain-lbs",(getprop("controls/groundservice/fueling/target-lbs") - getprop("consumables/fuel/total-fuel-lbs")));
	}

	removelistener(l_auto_refuel);
	print('Aircraft refueled.');
});

