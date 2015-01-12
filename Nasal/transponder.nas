# Transponder control script for 747-8 TPR-901 Mode S transponder

# Read a squawk code, set display digits
var xpnd_digits = func {
	var squawk = getprop("instrumentation/transponder/id-code");

	var d1 = int(int(squawk) / 1000);
	var d2 = int((int(squawk) - (1000*d1)) / 100);
	var d3 = int((int(squawk) - (1000*d1) - (100*d2)) / 10);
	var d4 = int(int(squawk) - (1000*d1) - (100*d2) - (10*d3));

	setprop("instrumentation/transponder/inputs/display",d1);
	setprop("instrumentation/transponder/inputs/display[1]",d2);
	setprop("instrumentation/transponder/inputs/display[2]",d3);
	setprop("instrumentation/transponder/inputs/display[3]",d4);
}

# Initialize the Transponder when the battery is turned on.
var xpnd_init = func {
	setprop("instrumentation/transponder/inputs/ident-btn",0);
	setprop("instrumentation/transponder/inputs/act-dig",0);
	xpnd_digits();
	if (getprop("instrumentation/transponder/inputs/knob-pos") == 0) {
	    setprop("instrumentation/transponder/inputs/clr",1);
	    setprop("instrumentation/transponder/inputs/clr[1]",1);
	    setprop("instrumentation/transponder/inputs/clr[2]",1);
	    setprop("instrumentation/transponder/inputs/clr[3]",1);
	} else {
	    setprop("instrumentation/transponder/inputs/clr",0);
	    setprop("instrumentation/transponder/inputs/clr[1]",0);
	    setprop("instrumentation/transponder/inputs/clr[2]",0);
	    setprop("instrumentation/transponder/inputs/clr[3]",0);
	}
}
setlistener("systems/electrical/battery-off", func(batt) {
	var knob = getprop("instrumentation/transponder/inputs/knob-pos");
	var mode = props.globals.getNode("instrumentation/transponder/inputs/knob-mode",1);

	if (!(batt.getBoolValue())) {
	    setprop("instrumentation/transponder/inputs/clr",0);
	    setprop("instrumentation/transponder/inputs/clr[1]",0);
	    setprop("instrumentation/transponder/inputs/clr[2]",0);
	    setprop("instrumentation/transponder/inputs/clr[3]",0);
	    setprop("instrumentation/transponder/inputs/display",8);
	    setprop("instrumentation/transponder/inputs/display[1]",8);
	    setprop("instrumentation/transponder/inputs/display[2]",8);
	    setprop("instrumentation/transponder/inputs/display[3]",8);
	    setprop("instrumentation/transponder/inputs/ident-btn",1);

	    if (knob == 0) mode.setValue(1);
	    if (knob == 1) mode.setValue(3);
	    if (knob == 2 or knob == 3) mode.setValue(5);
	    if (knob == 4) mode.setValue(4);
	
	    settimer(xpnd_init, 2);
	} else {
	    mode.setValue(0);
	}
},0,0);

# If buttons are pushed but a new code is not entered, revert after 6 sec.
var xpnd_restore = func {
	var do_restore = func {
	    var curr_t = getprop("sim/time/elapsed-sec");
	    if (curr_t > (getprop("instrumentation/transponder/inputs/t-mark") + 5)) {
		xpnd_digits();
	        setprop("instrumentation/transponder/inputs/clr",0);
	        setprop("instrumentation/transponder/inputs/clr[1]",0);
	        setprop("instrumentation/transponder/inputs/clr[2]",0);
	        setprop("instrumentation/transponder/inputs/clr[3]",0);
	        setprop("instrumentation/transponder/inputs/act-dig",0);
	    }
	}
	settimer(do_restore,6);
}

# CLR button control - clear the digits, replace with ----.
var xpnd_clr = func {
	setprop("instrumentation/transponder/inputs/clr",1);
	setprop("instrumentation/transponder/inputs/clr[1]",1);
	setprop("instrumentation/transponder/inputs/clr[2]",1);
	setprop("instrumentation/transponder/inputs/clr[3]",1);
	
	setprop("instrumentation/transponder/inputs/act-dig",0);

	setprop("instrumentation/transponder/inputs/t-mark",getprop("sim/time/elapsed-sec"));
	xpnd_restore();
}
	
# Numbered button controls.
var xpnd_btns = func(btn) {
	var digit = props.globals.getNode("instrumentation/transponder/inputs/act-dig",1);
	var disp0 = props.globals.getNode("instrumentation/transponder/inputs/display",1);
	var disp1 = props.globals.getNode("instrumentation/transponder/inputs/display[1]",1);
	var disp2 = props.globals.getNode("instrumentation/transponder/inputs/display[2]",1);
	var disp3 = props.globals.getNode("instrumentation/transponder/inputs/display[3]",1);
	var d0 = props.globals.getNode("instrumentation/transponder/inputs/digit",1);
	var d1 = props.globals.getNode("instrumentation/transponder/inputs/digit[1]",1);
	var d2 = props.globals.getNode("instrumentation/transponder/inputs/digit[2]",1);
	var d3 = props.globals.getNode("instrumentation/transponder/inputs/digit[3]",1);

	if (digit.getValue() == 0) {
	    xpnd_clr();
	    setprop("instrumentation/transponder/inputs/clr",0);
	    disp0.setValue(btn);
	    digit.setValue(1);
	}
	elsif (digit.getValue() == 1) {
	    setprop("instrumentation/transponder/inputs/clr[1]",0);
	    disp1.setValue(btn);
	    setprop("instrumentation/transponder/inputs/t-mark",getprop("sim/time/elapsed-sec"));
	    xpnd_restore();
	    digit.setValue(2);
	}
	elsif (digit.getValue() == 2) {
	    setprop("instrumentation/transponder/inputs/clr[2]",0);
	    disp2.setValue(btn);
	    setprop("instrumentation/transponder/inputs/t-mark",getprop("sim/time/elapsed-sec"));
	    xpnd_restore();
	    digit.setValue(3);
	}
	elsif (digit.getValue() == 3) {
	    setprop("instrumentation/transponder/inputs/clr[3]",0);
	    disp3.setValue(btn);
	    setprop("instrumentation/transponder/inputs/t-mark",getprop("sim/time/elapsed-sec"));
	
	    var code = (1000*disp0.getValue()) + (100*disp1.getValue()) + (10*disp2.getValue()) + disp3.getValue();

	    setprop("instrumentation/transponder/id-code",(sprintf ("%04i", code)));
	    
#	    d3.setValue(disp0.getValue());
#	    d2.setValue(disp1.getValue());
#	    d1.setValue(disp2.getValue());
#	    d0.setValue(disp3.getValue());
	
	    digit.setValue(0);
	}
}

# IDENT button control.
var xpnd_ident = func {
	var ident = props.globals.getNode("instrumentation/transponder/inputs/ident-btn",1);

	if (!(ident.getBoolValue())) {
	    ident.setBoolValue(1);
	    settimer(func { ident.setBoolValue(0); },18);
	}
}

# Mode knob control.
var xpnd_knob = func(chg) {
	var knob = props.globals.getNode("instrumentation/transponder/inputs/knob-pos",1);
        var mode = props.globals.getNode("instrumentation/transponder/inputs/knob-mode",1);

	if ((knob.getValue() + chg) < 0) {
	    knob.setValue(0);
	} elsif ((knob.getValue() + chg) > 4) {
	    knob.setValue(4);
	} else {
	    knob.setValue(knob.getValue() + chg);
	}

	if (getprop("systems/electrical/battery-off")) {
	    mode.setValue(0);
	} else {
	    if (knob.getValue() == 0) mode.setValue(1);
	    if (knob.getValue() == 1) mode.setValue(3);
	    if (knob.getValue() == 2 or knob.getValue() == 3) mode.setValue(5);
	    if (knob.getValue() == 4) mode.setValue(4);
	    if (knob.getValue() != 0) {
		setprop("instrumentation/transponder/inputs/clr",0);
		setprop("instrumentation/transponder/inputs/clr[1]",0);
		setprop("instrumentation/transponder/inputs/clr[2]",0);
		setprop("instrumentation/transponder/inputs/clr[3]",0);
	    }
	}
}

# Dialog control
setlistener("instrumentation/transponder/id-code", func (squawk) {
#	var dg0 = props.globals.getNode("instrumentation/transponder/inputs/digit",1);
#	var dg1 = props.globals.getNode("instrumentation/transponder/inputs/digit[1]",1);
#	var dg2 = props.globals.getNode("instrumentation/transponder/inputs/digit[2]",1);
#	var dg3 = props.globals.getNode("instrumentation/transponder/inputs/digit[3]",1);
#
#
#	if ((int(squawk.getValue()) > 7777) or (int(squawk.getValue()) < 0)) {
#	    squawk.setValue('0000');
#	}
#
#	var d1 = int(int(squawk.getValue()) / 1000);
#	var d2 = int((int(squawk.getValue()) - (1000*d1)) / 100);
#	var d3 = int((int(squawk.getValue()) - (1000*d1) - (100*d2)) / 10);
#	var d4 = int(int(squawk.getValue()) - (1000*d1) - (100*d2) - (10*d3));
#
#	if (d1 > 7 or d2 > 7 or d3 > 7 or d4 > 7) {
#	    squawk.setValue('0000');
#	    d1 = 0;
#	    d2 = 0;
#	    d3 = 0;
#	    d4 = 0;
#	}
#
#	dg0.setValue(d1);
#	dg1.setValue(d2);
#	dg2.setValue(d3);
#	dg3.setValue(d4);

#	setprop("instrumentation/transponder/id-code",squawk.getValue());
	xpnd_digits();

# Emergency code announce.
	if (squawk.getValue() == '7500') Boeing747.copilot.announce("Transponder squawking 7500 - Hijacking code!");
	if (squawk.getValue() == '7600') Boeing747.copilot.announce("Transponder squawking 7600 - LostComms code!");
	if (squawk.getValue() == '7700') Boeing747.copilot.announce("Transponder squawking 7700 - Emergency code!");
},0,0);


############################
# Controller for the comm radios

var comm_rcl = func(num) {
	var stby = getprop("instrumentation/comm[" ~ num ~ "]/frequencies/standby-mhz");

	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-display",stby);

	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[1]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[2]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[3]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[4]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[5]",0);
}

var comm_clr = func(num) {
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr",1);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[1]",1);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[2]",1);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[3]",1);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[4]",1);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[5]",1);
}

var comm_init = func(num) {
	var active = getprop("instrumentation/comm[" ~ num ~ "]/frequencies/selected-mhz");

	var radio = "instrumentation/comm[" ~ num ~ "]/frequencies/";

	props.globals.initNode(radio~"stby-display",0.00000,"DOUBLE");

	props.globals.initNode(radio~"stby-clr",0,"BOOL");
	props.globals.initNode(radio~"stby-clr[1]",0,"BOOL");
	props.globals.initNode(radio~"stby-clr[2]",0,"BOOL");
	props.globals.initNode(radio~"stby-clr[3]",0,"BOOL");
	props.globals.initNode(radio~"stby-clr[4]",0,"BOOL");
	props.globals.initNode(radio~"stby-clr[5]",0,"BOOL");

	props.globals.initNode(radio~"mark-t",0.0,"DOUBLE");
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[1]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[2]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[3]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[4]",0);
	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[5]",0);
	
	setprop(radio~"stby-display",888.8880);

	setprop("instrumentation/comm[" ~ num ~ "]/frequencies/selected-mhz",888.8880);

	settimer(func {
	    setprop("instrumentation/comm[" ~ num ~ "]/frequencies/selected-mhz",active);
	    comm_rcl(num);
	    comm_clr(num);
	},2);
}
setlistener("systems/electrical/battery-off", func(batt) {
	if (!batt.getBoolValue()) {
	    comm_init(0);
	    comm_init(1);
	    setprop("instrumentation/comm/data/post",8);
	    settimer(func { setprop("instrumentation/comm/data/post",0);},2);
	}
},0,0);

var comm_rst = func(num) {
	var radio = "instrumentation/comm[" ~ num ~ "]/frequencies/";
	settimer(func {
	    var time = getprop("sim/time/elapsed-sec");
	    if ((time > (getprop(radio~"mark-t") + 5)) and !(getprop(radio~"stby-clr") or getprop(radio~"stby-clr[1]") or getprop(radio~"stby-clr[2]"))) {
	 	if (getprop(radio~"stby-clr[3]"))
		    comm_btn(num,0);
	 	if (getprop(radio~"stby-clr[4]"))
		    comm_btn(num,0);
	 	if (getprop(radio~"stby-clr[5]"))
		    comm_btn(num,0);
	    }
	},6);
}

var comm_btn = func(num,btn) {
	radio = "instrumentation/comm[" ~ num ~ "]/frequencies/";

	var display = props.globals.getNode(radio~"stby-display",1);

	var c0 = props.globals.getNode(radio~"stby-clr",1);
	var c1 = props.globals.getNode(radio~"stby-clr[1]",1);
	var c2 = props.globals.getNode(radio~"stby-clr[2]",1);
	var c3 = props.globals.getNode(radio~"stby-clr[3]",1);
	var c4 = props.globals.getNode(radio~"stby-clr[4]",1);
	var c5 = props.globals.getNode(radio~"stby-clr[5]",1);

	if (c0.getBoolValue()) {
	    display.setValue(100.000 * btn);
	    c0.setBoolValue(0);
	} elsif (c1.getBoolValue()) {
	    display.setValue(display.getValue() + (10 * btn));
	    c1.setBoolValue(0);
	} elsif (c2.getBoolValue()) {
	    display.setValue(display.getValue() + btn);
	    c2.setBoolValue(0);
	    setprop(radio~"mark-t",getprop("sim/time/elapsed-sec"));
	    comm_rst(num);
	} elsif (c3.getBoolValue()) {
	    display.setValue(display.getValue() + (0.1 * btn));
	    c3.setBoolValue(0);
	    setprop(radio~"mark-t",getprop("sim/time/elapsed-sec"));
	    comm_rst(num);
	} elsif (c4.getBoolValue()) {
	    display.setValue(display.getValue() + (0.01 * btn));
	    c4.setBoolValue(0);
	    setprop(radio~"mark-t",getprop("sim/time/elapsed-sec"));
	    comm_rst(num);
	} elsif (c5.getBoolValue()) {
	    display.setValue(display.getValue() + (0.001 * btn));
	    c5.setBoolValue(0);
	    setprop(radio~"mark-t",getprop("sim/time/elapsed-sec"));
	    setprop(radio~"standby-mhz",display.getValue());
	}
}

var comm_swap = func(num) {
	if (!(getprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[2]"))) {
	    if (getprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[3]"))
		comm_btn(num,0);
	    if (getprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[4]"))
		comm_btn(num,0);
	    if (getprop("instrumentation/comm[" ~ num ~ "]/frequencies/stby-clr[5]"))
		comm_btn(num,0);
	}
}

setlistener("instrumentation/comm/frequencies/standby-mhz", func {
	comm_rcl(0);
},0,0);
setlistener("instrumentation/comm[1]/frequencies/standby-mhz", func {
	comm_rcl(1);
},0,0);

