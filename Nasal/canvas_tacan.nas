# This is to connect the TACAN to the canvas nav display

var efistacan = props.globals.initNode("instrumentation/efis/tacan",0,"BOOL");

setlistener("instrumentation/tacan/powered", func (on) {
	setprop("instrumentation/efis/tacan",on.getBoolValue());
},0,0);

