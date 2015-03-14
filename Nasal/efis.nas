# 777-200 systems
#Syd Adams
#

#var SndOut = props.globals.getNode("/sim/sound/Ovolume",1);
var chronometer = aircraft.timer.new("/instrumentation/clock/ET-sec",1);
var fuel_density =0;

#EFIS specific class
# ie: var efis = EFIS.new("instrumentation/EFIS");
var EFIS = {
    new : func(prop1){
        m = { parents : [EFIS]};
        m.radio_list=["instrumentation/comm/frequencies","instrumentation/comm[1]/frequencies","instrumentation/nav/frequencies","instrumentation/nav[1]/frequencies"];
        m.mfd_mode_list=["APP","VOR","MAP","PLAN"];

        m.efis = props.globals.initNode(prop1);
        m.mfd = m.efis.initNode("mfd");
        m.pfd = m.efis.initNode("pfd");
#        m.eicas = m.efis.initNode("eicas");
        m.mfd_mode_num = m.mfd.initNode("mode-num",2,"INT");
        m.mfd_display_mode = m.mfd.initNode("display-mode",m.mfd_mode_list[2]);
        m.kpa_mode = m.efis.initNode("inputs/kpa-mode",0,"BOOL");
        m.kpa_output = m.efis.initNode("inhg-kpa",29.92);
        m.temp = m.efis.initNode("fixed-temp",0);
        m.wind = m.efis.initNode("wind-display",0,"DOUBLE");
        m.alt_meters = m.efis.initNode("inputs/alt-meters",0,"BOOL");
        m.fpv = m.efis.initNode("inputs/fpv",0,"BOOL");
        m.nd_centered = m.efis.initNode("inputs/nd-centered",0,"BOOL");
        m.mins_mode = m.efis.initNode("inputs/minimums-mode",0,"BOOL");
        m.mins_mode_txt = m.efis.initNode("minimums-mode-text","RADIO","STRING");
        m.minimums = m.efis.initNode("minimums",250,"INT");
        m.mk_minimums = props.globals.getNode("instrumentation/mk-viii/inputs/arinc429/decision-height");
        m.wxr = m.efis.initNode("inputs/wxr",0,"BOOL");
        m.range = m.efis.initNode("inputs/range",10);
        m.sta = m.efis.initNode("inputs/sta",0,"BOOL");
        m.wpt = m.efis.initNode("inputs/wpt",0,"BOOL");
        m.arpt = m.efis.initNode("inputs/arpt",0,"BOOL");
        m.data = m.efis.initNode("inputs/data",0,"BOOL");
        m.pos = m.efis.initNode("inputs/pos",0,"BOOL");
        m.terr = m.efis.initNode("inputs/terr",0,"BOOL");
        m.rh_vor_adf = m.efis.initNode("inputs/rh-vor-adf",0,"INT");
        m.lh_vor_adf = m.efis.initNode("inputs/lh-vor-adf",0,"INT");
	m.nd_plan_wpt = m.efis.initNode("inputs/plan-wpt-index", 0, "INT");

        m.radio = m.efis.getNode("radio-mode",1);
        m.radio.setIntValue(0);
        m.radio_selected = m.efis.getNode("radio-selected",1);
        m.radio_selected.setDoubleValue(getprop("instrumentation/comm/frequencies/selected-mhz"));
        m.radio_standby = m.efis.getNode("radio-standby",1);
        m.radio_standby.setDoubleValue(getprop("instrumentation/comm/frequencies/standby-mhz"));

        m.kpaL = setlistener("instrumentation/altimeter/setting-inhg", func m.calc_kpa());

#        m.eicas_msg_alert   = m.eicas.initNode("msg/alert"," ","STRING");
#        m.eicas_msg_caution = m.eicas.initNode("msg/caution"," ","STRING");
#        m.eicas_msg_info    = m.eicas.initNode("msg/info"," ","STRING");
        m.update_radar_font();
    return m;
    },
#### convert inhg to kpa ####
    calc_kpa : func{
        var kp = getprop("instrumentation/altimeter/setting-inhg");
        kp= kp * 33.8637526;
        me.kpa_output.setValue(kp);
        },
#### update temperature display ####
    update_temp : func{
        var tmp = getprop("/environment/temperature-degc");
        if(tmp < 0.00){
            tmp = -1 * tmp;
        }
        me.temp.setValue(tmp);
    },
#### update wind speed display ####
    update_wind : func{
	var wind = getprop("environment/wind-from-heading-deg");
	while (wind < 0) wind+=360;
	while (wind >= 360) wind -=360;
	me.wind.setValue(wind);	
    },
#### swap radio freq ####
    swap_freq : func(){
        var tmpsel = me.radio_selected.getValue();
        var tmpstb = me.radio_standby.getValue();
        me.radio_selected.setValue(tmpstb);
        me.radio_standby.setValue(tmpsel);
        me.update_frequencies();
    },
#### copy efis freq to radios ####
    update_frequencies : func(){
        var fq = me.radio.getValue();
        setprop(me.radio_list[fq]~"/selected-mhz",me.radio_selected.getValue());
        setprop(me.radio_list[fq]~"/standby-mhz",me.radio_standby.getValue());
    },
#### modify efis radio standby freq ####
    set_freq : func(fdr){
        var rd = me.radio.getValue();
        var frq =me.radio_standby.getValue();
        var frq_step =0;
        if(rd >=2){
            if(fdr ==1)frq_step = 0.05;
            if(fdr ==-1)frq_step = -0.05;
            if(fdr ==10)frq_step = 1.0;
            if(fdr ==-10)frq_step = -1.0;
            frq += frq_step;
            if(frq > 118.000)frq -= 10.000;
            if(frq<108.000) frq += 10.000;
        }else{
            if(fdr ==1)frq_step = 0.025;
            if(fdr ==-1)frq_step = -0.025;
            if(fdr ==10)frq_step = 1.0;
            if(fdr ==-10)frq_step = -1.0;
            frq += frq_step;
            if(frq > 136.000)frq -= 18.000;
            if(frq<118.000) frq += 18.000;
        }
        me.radio_standby.setValue(frq);
        me.update_frequencies();
    },

    set_radio_mode : func(rm){
        me.radio.setIntValue(rm);
        me.radio_selected.setDoubleValue(getprop(me.radio_list[rm]~"/selected-mhz"));
        me.radio_standby.setDoubleValue(getprop(me.radio_list[rm]~"/standby-mhz"));
    },
######### Controller buttons ##########
    ctl_func : func(md,val){
        controls.click(3);
        if(md=="range")
        {
            var rng =getprop("instrumentation/radar/range");
            if(val ==1){
                rng =rng * 2;
                if(rng > 640) rng = 640;
            }elsif(val =-1){
                rng =rng / 2;
                if(rng < 10) rng = 10;
            }
            setprop("instrumentation/radar/range",rng);
            me.range.setValue(rng);
        }
        elsif(md=="tfc")
        {
            var pos =getprop("instrumentation/radar/switch");
            if(pos == "on"){
                pos = "off";
                
            }else{
                pos="on";
            }
            setprop("instrumentation/radar/switch",pos);
        }
        elsif(md=="dh")
        {
            var num =me.minimums.getValue();
            if(val==0){
                num=250;
            }else{
                num+=val;
                if(num<0)num=0;
                if(num>1000)num=1000;
            }
            me.minimums.setValue(num);
            me.mk_minimums.setValue(num);
        }
        elsif(md=="mins")
        {
            mode = me.mins_mode.getValue();
            me.mins_mode.setValue(1-mode);
            if (mode)
                me.mins_mode_txt.setValue("RADIO");
            else
                me.mins_mode_txt.setValue("BARO");
        }
        elsif(md=="display")
        {
            var num =me.mfd_mode_num.getValue();
            num+=val;
            if(num<0)num=0;
            if(num>3)num=3;
            me.mfd_mode_num.setValue(num);
            me.mfd_display_mode.setValue(me.mfd_mode_list[num]);

			# for all modes except plan, acft is up. For PLAN,
                        # north is up.
            var isPLAN = (num == 3);
                        setprop("instrumentation/nd/aircraft-heading-up", !isPLAN);
                        setprop("instrumentation/nd/user-position", isPLAN);
                        me.nd_plan_wpt.setValue(getprop("autopilot/route-manager/current-wp"));

            me.update_nd_center();
                        me.update_nd_plan_center();
        }
        elsif(md=="terr")
        {
            var num =me.terr.getValue();
            num=1-num;
            me.terr.setValue(num);
        }
        elsif(md=="arpt")
        {
            var num =me.arpt.getValue();
            num=1-num;
            me.arpt.setValue(num);
        }
        elsif(md=="wpt")
        {
            var num =me.wpt.getValue();
            num=1-num;
            me.wpt.setValue(num);
        }
        elsif(md=="sta")
        {
            var num =me.sta.getValue();
            num=1-num;
            me.sta.setValue(num);
        }
        elsif(md=="wxr")
        {
            var num =me.wxr.getValue();
            num=1-num;
            me.wxr.setValue(num);
        }
        elsif(md=="rhvor")
        {
            var num =me.rh_vor_adf.getValue();
            num+=val;
            if(num>1)num=1;
            if(num<-1)num=-1;
            me.rh_vor_adf.setValue(num);
        }
        elsif(md=="lhvor")
        {
            var num =me.lh_vor_adf.getValue();
            num+=val;
            if(num>1)num=1;
            if(num<-1)num=-1;
            me.lh_vor_adf.setValue(num);
        }
        elsif(md=="center")
        {
            var num =me.nd_centered.getValue();
            num = 1 - num;
            me.nd_centered.setValue(num);
            me.update_radar_font();
        }
    },
    update_radar_font : func {
        var fnt=[12,13];
        var osg = getprop("sim/version/openscenegraph");
        var linespacing = 0.01;
        if (osg[0] == "2"[0])
        {
            # OSG 2.8.x had other (broken) font-size/line-spacing,
            # which was changed/"fixed" with >=2.9.14 (>=OSG3.0 stable)
            fnt = [5,8];
            linespacing = 0.3;
        }
        var num = me.nd_centered.getValue();
        setprop("instrumentation/radar/font/size",fnt[num]);
        setprop("instrumentation/radar/font/line-spacing",linespacing);
    },
    update_nd_center : func {
        # PLAN mode is always centered
        var isPLAN = (me.mfd_mode_num.getValue() == 3);
        if (isPLAN or me.nd_centered.getValue())
        {
            setprop("instrumentation/nd/y-center", 0.5);
        } else {
            setprop("instrumentation/nd/y-center", 0.15);
        }
    },

    update_nd_plan_center : func {
        # find wpt lat, lon
            var index = me.nd_plan_wpt.getValue();
	    if (index >= 0) {
                var lat = getprop("autopilot/route-manager/route/wp[" ~ index ~ "]/latitude-deg");
                var lon = getprop("autopilot/route-manager/route/wp[" ~ index ~ "]/longitude-deg");
                if(lon!=nil) setprop("instrumentation/nd/user-longitude-deg", lon);
                if(lat!=nil) setprop("instrumentation/nd/user-latitude-deg", lat);
	    }
    },
#### update EICAS messages ####
#    update_eicas : func(alertmsgs,cautionmsgs,infomsgs) {
#        var msg="";
#        var spacer="";
#        for(var i=0; i<size(alertmsgs); i+=1)
#        {
#            msg = msg ~ alertmsgs[i] ~ "\n";
#            spacer = spacer ~ "\n";
#        }
#        me.eicas_msg_alert.setValue(msg);
#        msg=spacer;
#        for(var i=0; i<size(cautionmsgs); i+=1)
#        {
#            msg = msg ~ cautionmsgs[i] ~ "\n";
#            spacer = spacer ~ "\n";
#        }
#        me.eicas_msg_caution.setValue(msg);
#        msg=spacer;
#        for(var i=0; i<size(infomsgs); i+=1)
#        {
#            msg = msg ~ infomsgs[i] ~ "\n";
#        }
#        me.eicas_msg_info.setValue(msg);
#    },
};

#var Wiper = {
#    new : func {
#        m = { parents : [Wiper] };
#        m.direction = 0;
#        m.delay_count = 0;
#        m.spd_factor = 0;
#        m.node = props.globals.getNode(arg[0],1);
#        m.power = props.globals.getNode(arg[1],1);
#        if(m.power.getValue()==nil)m.power.setDoubleValue(0);
#        m.spd = m.node.getNode("arc-sec",1);
#        if(m.spd.getValue()==nil)m.spd.setDoubleValue(1);
#        m.delay = m.node.getNode("delay-sec",1);
#        if(m.delay.getValue()==nil)m.delay.setDoubleValue(0);
#        m.position = m.node.getNode("position-norm", 1);
#        m.position.setDoubleValue(0);
#        m.switch = m.node.getNode("switch", 1);
#        if (m.switch.getValue() == nil)m.switch.setBoolValue(0);
#        return m;
#    },
#    active: func{
#    if(me.power.getValue()<=5)return;
#    var spd_factor = 1/me.spd.getValue();
#    var pos = me.position.getValue();
#    if(!me.switch.getValue()){
#        if(pos <= 0.000)return;
#        }
#    if(pos >=1.000){
#        me.direction=-1;
#        }elsif(pos <=0.000){
#        me.direction=0;
#        me.delay_count+=getprop("/sim/time/delta-sec");
#        if(me.delay_count >= me.delay.getValue()){
#            me.delay_count=0;
#            me.direction=1;
#            }
#        }
#    var wiper_time = spd_factor*getprop("/sim/time/delta-sec");
#    pos +=(wiper_time * me.direction);
#    me.position.setValue(pos);
#    }
#};
#####################

var Efis = EFIS.new("instrumentation/efis");
var EfisR = EFIS.new("instrumentation/efis[1]");
#var wiper = Wiper.new("controls/electric/wipers","systems/electrical/bus-volts");

setlistener("/sim/signals/fdm-initialized", func {
#    SndOut.setDoubleValue(0.15);
    chronometer.stop();
    props.globals.initNode("/instrumentation/clock/ET-display",0,"INT");
    props.globals.initNode("/instrumentation/clock/time-display",0,"INT");
    props.globals.initNode("/instrumentation/clock/time-knob",0,"INT");
    props.globals.initNode("/instrumentation/clock/et-knob",0,"INT");
    props.globals.initNode("/instrumentation/clock/set-knob",0,"INT");
#    setprop("/instrumentation/groundradar/id",getprop("sim/tower/airport-id"));
});
                           
#setlistener("/sim/signals/reinit", func {
#    SndOut.setDoubleValue(0.15);
#    Shutdown();
#});
#
#setlistener("/sim/current-view/internal", func(vw){
#    if(vw.getValue()){
#    SndOut.setDoubleValue(0.3);
#    }else{
#    SndOut.setDoubleValue(1.0);
#    }
#},1,0);

setlistener("/instrumentation/clock/et-knob", func(et){
    var tmp = et.getValue();
    if(tmp == -1){
	    chronometer.reset();
   	}elsif(tmp==0){
	    chronometer.stop();
    }elsif(tmp==1){
    	chronometer.start();
    }
},0,0);

setlistener("instrumentation/transponder/mode-switch", func(transponder_switch){
    var mode = transponder_switch.getValue();
    var tcas_mode = 1;
    if (mode == 3) tcas_mode = 2;
    if (mode == 4) tcas_mode = 3;
    setprop("instrumentation/tcas/inputs/mode",tcas_mode);
},0,0);

setlistener("instrumentation/tcas/outputs/traffic-alert", func(traffic_alert){
    var alert = traffic_alert.getValue();
    # any TCAS alert enables the traffic display
    if (alert) setprop("instrumentation/radar/switch","on");
},0,0);

#setlistener("controls/flight/speedbrake", func(spd_brake){
#    var brake = spd_brake.getValue();
#    # do not update lever when in AUTO position
#    if ((brake==0)and(getprop("controls/flight/speedbrake-lever")==2))
#    {
#        setprop("controls/flight/speedbrake-lever",0);
#    }
#    elsif ((brake==1)and(getprop("controls/flight/speedbrake-lever")==0))
#    {
#        setprop("controls/flight/speedbrake-lever",2);
#    }
#},0,0);
#
#setlistener("controls/flight/speedbrake-lever", func(spd_lever){
#    var lever = spd_lever.getValue();
#    controls.click(7);
#    # do not set speedbrake property unless changed (avoid revursive updates)
#    if ((lever==0)and(getprop("controls/flight/speedbrake")!=0))
#    {
#        setprop("controls/flight/speedbrake",0);
#    }
#    elsif ((lever==2)and(getprop("controls/flight/speedbrake")!=1))
#    {
#        setprop("controls/flight/speedbrake",1);
#    }
#},0,0);
#
#controls.toggleAutoSpoilers = func() {
#    # 0=spoilers retracted, 1=auto, 2=extended
#    if (getprop("controls/flight/speedbrake-lever")!=1)
#        setprop("controls/flight/speedbrake-lever",1);
#    else
#        setprop("controls/flight/speedbrake-lever",2*getprop("controls/flight/speedbrake"));
#}

setlistener("controls/flight/flaps", func { controls.click(6) } );
setlistener("/controls/gear/gear-down", func { controls.click(8) } );

#stall_horn = func {
#    var spd = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
#    var stall = getprop("instrumentation/fmc/vspeeds/stall-speed");
#    var wow = (getprop("gear/gear[1]/wow") or getprop("gear/gear[4]/wow"));
#    if (!wow and spd < 0.8 * stall) {
#	setprop("sim/alarms/stall-warning",1);
#    } else {
#	setprop("sim/alarms/stall-warning",0);
#    }
#}
#stall_horn = func{
#    var alert=0;
#    var kias=getprop("velocities/airspeed-kt");
#    if(kias>150){setprop("sim/sound/stall-horn",alert);return;};
#    var wow1=getprop("gear/gear[1]/wow");
#    var wow2=getprop("gear/gear[2]/wow");
#    if(!wow1 or !wow2){
#        var grdn=getprop("controls/gear/gear-down");
#        var flap=getprop("controls/flight/flaps");
#        if(kias<100){
#            alert=1;
#        }elsif(kias<120){
#            if(!grdn )alert=1;
#        }else{
#            if(flap==0)alert=1;
#        }
#    }
#    setprop("sim/sound/stall-horn",alert);
#}

#var click_reset = func(propName) {
#    setprop(propName,0);
#}
#controls.click = func(button) {
#    if (getprop("sim/freeze/replay-state"))
#        return;
#    var propName="sim/sound/click"~button;
#    setprop(propName,1);
#    settimer(func { click_reset(propName) },0.4);
#}

