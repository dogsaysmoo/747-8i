# engine pump ON, system pressurised when N2 > 20-30%
# demand pumps 2, 3 are AC 2, 3.
# AUX pump is AC 1.
# demand pumps 1, 4 are air driven.

var sys = 'systems/hydraulic/';
var controls = 'controls/hydraulic/';
var ticks = 4;
var sys_status = [0, 0, 0, 0];

var HDP = [
	props.globals.initNode(controls~'demand-pump[0]', 0, 'INT'),
	props.globals.initNode(controls~'demand-pump[1]', 0, 'INT'),
	props.globals.initNode(controls~'demand-pump[2]', 0, 'INT'),
	props.globals.initNode(controls~'demand-pump[3]', 0, 'INT'),
	  ];
var EDP = [
	props.globals.initNode(controls~'engine-pump[0]', 0, 'BOOL'),
	props.globals.initNode(controls~'engine-pump[1]', 0, 'BOOL'),
	props.globals.initNode(controls~'engine-pump[2]', 0, 'BOOL'),
	props.globals.initNode(controls~'engine-pump[3]', 0, 'BOOL'),
	  ];
var SYS_FAULT = [
	props.globals.initNode(sys~'system-fault[0]', 1, 'BOOL'),
	props.globals.initNode(sys~'system-fault[1]', 1, 'BOOL'),
	props.globals.initNode(sys~'system-fault[2]', 1, 'BOOL'),
	props.globals.initNode(sys~'system-fault[3]', 1, 'BOOL'),
	  ];
var HDP_PRESS = [
	props.globals.initNode(sys~'demand-pump-pressure-low[0]', 1, 'BOOL'),
	props.globals.initNode(sys~'demand-pump-pressure-low[1]', 1, 'BOOL'),
	props.globals.initNode(sys~'demand-pump-pressure-low[2]', 1, 'BOOL'),
	props.globals.initNode(sys~'demand-pump-pressure-low[3]', 1, 'BOOL'),
	  ];
var EDP_PRESS = [
	props.globals.initNode(sys~'engine-pump-pressure-low[0]', 1, 'BOOL'),
	props.globals.initNode(sys~'engine-pump-pressure-low[1]', 1, 'BOOL'),
	props.globals.initNode(sys~'engine-pump-pressure-low[2]', 1, 'BOOL'),
	props.globals.initNode(sys~'engine-pump-pressure-low[3]', 1, 'BOOL'),
	  ];

props.globals.initNode(sys~'pressure[0]', 0, 'INT');
props.globals.initNode(sys~'pressure[1]', 0, 'INT');
props.globals.initNode(sys~'pressure[2]', 0, 'INT');
props.globals.initNode(sys~'pressure[3]', 0, 'INT');

props.globals.initNode(sys~'equipment/enable-brake', 1.0, 'DOUBLE');
props.globals.initNode(sys~'equipment/enable-sfc', 1, 'BOOL');
props.globals.initNode(sys~'equipment/enable-flap', 1, 'BOOL');
props.globals.initNode(sys~'equipment/enable-gear', 1, 'BOOL');
props.globals.initNode(sys~'equipment/enable-spoil', 1, 'BOOL');
props.globals.initNode(sys~'equipment/enable-threv', 1, 'BOOL');

var Hyd = {
  pressure : 0,		# int
  temp : 20,		# int
  qty  : 100,		# int

  new : func(n)
  {
    return {
      parents : [Hyd],
      n : n,
    };
  },

  dem_sw : func(inc)
  {
    var p = HDP[me.n];
    var i = p.getValue();
    i += inc;
    if (i > 2) i = 2;
    if (me.n == 3) {		# HYD 4 has AUTO (-1)
      if (i < -1) i = -1;
    } else
      if (i < 0) i = 0;
    p.setValue(i);
    ticks = 0;
  },

  edp_sw : func
  {
    var p = EDP[me.n];
    #var i = p.getValue();
    #i = !i;
    p.setValue(!p.getValue());
    ticks = 0;
  },

#  system-fault[0]
#	system pressure < 1200,
#	qty < 0.35
#	T > 105
#  demand-pump-pressure-low[0] 
#	pump running and HDP press < 1400,
#	pump fault,
#	selector OFF
#  engine-pump-pressure-low[0]
#	EDP press < 1400

  update : func
  {
    var aux = 0;
    var edp_running = !getprop('controls/engines/engine['~me.n~']/cutoff') and 
			EDP[me.n].getBoolValue();
    var dem_running = 0;
    if (me.n == 1 or me.n == 2) {
	dem_running = getprop('systems/electrical/ac-bus['~me.n~']') and
			HDP[me.n].getValue() > 0;
    }
    if (me.n == 0 or me.n == 3) {
	var bld = me.n - 2;
	if (bld < 0) bld = 0;
	dem_running = getprop('systems/pneumatic/bleed-air['~bld~']') and
			HDP[me.n].getValue() > 0;
    }
			# XXX bleed ADP for hyd 1,4 ?

    if (me.n == 3) aux = (HDP[me.n].getValue() == -1 and getprop('systems/electrical/ac-bus['~me.n~']')) ? 1 : 0;
    if (me.n == 2) aux = getprop("instrumentation/airspeed-indicator/indicated-speed-kt") > 150 ? 1 : 0;
    if (dem_running or edp_running or aux) {
      if (me.pressure < 2800) me.pressure += (3000 - me.pressure) / 3 + rand() * 200;
      if (me.temp < 50) me.temp += 1;
    } else {
      # decay
      if (me.pressure > 0) me.pressure -= 250 + rand() * 50;
      if (me.temp > 20) me.temp -= 1;
    }

    # entropy
    if (rand() > 0.8) {
      var i = rand() - 0.5;
      i = i > 0 ? 20 : -20;
      me.pressure += i;
    }

    # update lights
    var i = 0;
    i = me.pressure < 1200 or me.qty < 35 or me.temp > 105 ? 1 : 0;
    setprop(sys, 'system-fault['~me.n~']', i);
    i = dem_running ? 0 : 1;
    setprop(sys, 'demand-pump-pressure-low['~me.n~']', i);
    i = edp_running ? 0 : 1;
    setprop(sys, 'engine-pump-pressure-low['~me.n~']', i);

    # update props
    if (me.pressure < 0) me.pressure = 0;
    setprop(sys, 'pressure['~me.n~']', me.pressure);

    # update status octals
        # 0 off
        # 1 aux(or pushback, #3 only)
        # 2 EDP
        # 3 EDP + aux(or pushback, #3 only)
        # 4 demand pump (or RAT on #2)
        # 5 dem + aux(or pushback, #3 only)
        # 6 EDP + dem (or RAT on #2)
        # 7 EDP + dem + aux(or pushback, #3 only)
    sys_status[me.n] = 0;
    if (HDP[me.n].getValue() == -1 or (me.n == 3 and getprop("/sim/model/pushback/position-norm") == 1.0))
       sys_status[me.n] = sys_status[me.n] + 1;
    if ((HDP[me.n].getValue() > 0 and !HDP_PRESS[me.n].getBoolValue()) or (me.n == 2 and getprop("instrumentation/airspeed-indicator/indicated-speed-kt") > 117))
       sys_status[me.n] = sys_status[me.n] + 4;
    if (!EDP_PRESS[me.n].getBoolValue()) sys_status[me.n] = sys_status[me.n] + 2;

    # update hydraulic equipment
	# Brakes
    if (sys_status[0] == 0 and sys_status[1] == 0 and sys_status[3] == 0) {
	setprop("systems/hydraulic/equipment/enable-brake",0.4);
    } elsif (sys_status[0] == 0 and sys_status[1] == 0 and sys_status[3] == 1) {
	setprop("systems/hydraulic/equipment/enable-brake",0.6);
    } else {
	setprop("systems/hydraulic/equipment/enable-brake",1.0);
    }
	# Flight Control Surfaces and Thrust Reversers
    if (sys_status[0] < 2 and sys_status[1] < 2 and sys_status[2] < 2 and sys_status[3] < 2) {
	setprop("systems/hydraulic/equipment/enable-sfc",0);
	setprop("systems/hydraulic/equipment/enable-threv",0);
    } else {
	setprop("systems/hydraulic/equipment/enable-sfc",1);
	setprop("systems/hydraulic/equipment/enable-threv",1);
    }
	# Spoilers
    if (sys_status[1] < 2 and sys_status[2] < 2 and sys_status[3] < 2) {
	setprop("systems/hydraulic/equipment/enable-spoil",0);
    } else {
	setprop("systems/hydraulic/equipment/enable-spoil",1);
    }
	# Flaps and Gear Up
    if (sys_status[0] < 6 and sys_status[3] < 6) {
	setprop("systems/hydraulic/equipment/enable-flap",0);
    } else {
	setprop("systems/hydraulic/equipment/enable-flap",1);
    }
	# Gear Down
    if (sys_status[0] < 2 and sys_status[3] < 2) {
	setprop("systems/hydraulic/equipment/enable-gear",0);
    } else {
	setprop("systems/hydraulic/equipment/enable-gear",1);
    }

#printf('DEBUG: hyd %d press %d temp %d qty %d', me.n, me.pressure, me.temp, me.qty);
  }
};

var resched_update = func
{
  if (ticks == 0) {
    for (var i = 0; i < 4; i += 1)
      hyd_sys[i].update();
    ticks = 3;			# update every 4 sec
  }
  ticks -= 1;
  settimer(resched_update, 2);
}

# Brake restrictors
var brake_reset = func {
    if (getprop("controls/gear/brake-left") > getprop("systems/hydraulic/equipment/enable-brake"))
	setprop("controls/gear/brake-left",getprop("systems/hydraulic/equipment/enable-brake"));

    if (getprop("controls/gear/brake-right") > getprop("systems/hydraulic/equipment/enable-brake"))
	setprop("controls/gear/brake-right",getprop("systems/hydraulic/equipment/enable-brake"));
}
var do_brake_reset = func {
    if (getprop("systems/hydraulic/equipment/enable-brake") < 0.8) {
	brake_reset();
	settimer(do_brake_reset,0);
    }
}
setlistener("systems/hydraulic/equipment/enable-brake", func (rst) {
    if (rst.getValue() < 0.8)
	do_brake_reset();
},0,0);


# init

var hyd_sys = [Hyd.new(0), Hyd.new(1), Hyd.new(2), Hyd.new(3)];

resched_update();

print('747-8 hydraulic system: so far so good');
