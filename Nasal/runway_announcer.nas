# Copyright (C) 2014  onox
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

var sin = func(a) { math.sin(a * globals.D2R) }
var cos = func(a) { math.cos(a * globals.D2R) }
var max = func(a, b) { a > b ? a : b }

var mod = func (n, m) {
    return n - m * math.floor(n / m);
}

var Observable = {

    new: func {
        var m = {
            parents: [Observable]
        };
        m.observers = {};
        return m;
    },

    connect: func (signal, callback) {
        if (!contains(me.observers, signal)) {
            me.observers[signal] = [];
        }
        var listener_id = setlistener("/sim/signals/runway-announcer/" ~ signal, callback);
        append(me.observers[signal], listener_id);
        return listener_id;
    },

    notify_observers: func (signal, arguments) {
        if (contains(me.observers, signal)) {
            setprop("/sim/signals/runway-announcer/" ~ signal, arguments);
        }
    }
};

var RunwayAnnounceClass = {

    new: func {
        var m = {
            parents: [RunwayAnnounceClass, Observable.new()]
        };
        m.mode = "";
        return m;
    },

    set_mode: func (mode) {
        # Set the mode. Depending on the mode this object will or
        # will not notify certain observers.

        me.mode = mode;
    },

    _check_runway: func (apt, runway, self) {
        self.set_alt(apt.elevation);

        var rwy = apt.runway(runway);
        var rwy_coord = geo.Coord.new().set_latlon(rwy.lat, rwy.lon, apt.elevation);

        var rwy_start_coord = geo.Coord.new().set(rwy_coord);

        # Modify current coord by applying a heading and RWY length to
        # transform it to the opposite RWY
        rwy_coord.apply_course_distance(rwy.heading, rwy.length);

        var distance = self.distance_to(rwy_coord);
        var course = self.course_to(rwy_coord);

        var crosstrack_error = distance * abs(sin(course - rwy.heading));
        var distance_stop = distance * cos(course - rwy.heading);
        var edge_rem = max(rwy.width / 2, crosstrack_error) - rwy.width / 2;

        var on_rwy = edge_rem == 0 and 0 <= distance_stop and distance_stop <= rwy.length;

        var distance_start = self.distance_to(rwy_start_coord);

        return {
            on_runway:          on_rwy,
            # True if on the runway, false otherwise

            distance_stop:      distance_stop,
            # Distance to the edge of the opposite runway. The distance
            # is parallel to the runway.

            crosstrack_error:   crosstrack_error,
            # Distance to the center line of the runway. The distance
            # is orthogonal to the center line.

            edge_rem:           edge_rem,
            # Distance from outside the runway to the nearest side edge
            # of the RWY. 0 if on_runway is true. Orthogonal to the runway.

            distance_start:     distance_start,
            # Distance to the center of the starting position on the
            # runway. This is a direct line; not parallel or orthogonal.

            runway:             rwy
        };
    }

};

var TakeoffRunwayAnnounceConfig = {

    distance_start_m: nil,
    # The maximum distance in meters from the starting position
    # on the runway. Large runways are usually 40 to 60 meters wide
    # to give you an idea of the scale. If nil then the distance is
    # not taken into account, which means the aircraft can be anywhere
    # on the runway for the on-runway signal to be emitted.

    diff_runway_heading_deg: 20,
    # Difference in heading between runway and aircraft in order to
    # get an announcement that the aircraft is on the runway for takeoff.

    diff_approach_heading_deg: 40,
    # Maximum angle at which the aircraft should approach the runway.
    # Must be higher than 0 and lower than 90.

    distance_center_line_m: 10,
    # The distance in meters from the center line of the runway

    distance_edge_min_m: 20,
    distance_edge_max_m: 80,
    # Minimum and maximum distance in meters from the edge of the runway
    # for announcing approaches.

    nominal_distance_takeoff_m: 3000,
    # Minimum distance in meters required for a normal takeoff. If
    # remaining distance when entering the runway is less than the distance
    # required for a normal takeoff, then the on-short-runway instead of
    # on-runway signal will be emitted.

    distances_unit: "meter",
    # The unit to use for the remaining distance of short runways. Can
    # be "meter" or "feet".

};

var TakeoffRunwayAnnounceClass = {

    period: 0.5,

    # Announce when approaching a runway or when on a runway ready for
    # takeoff. Valid modes and the signals they emit are:
    #
    # - taxi:               approaching-runway
    # - taxi-and-takeoff:   approaching-runway, on-runway, on-short-runway
    # - takeoff:            on-runway, on-short-runway

    new: func (config) {
        var m = {
            parents: [TakeoffRunwayAnnounceClass, RunwayAnnounceClass.new()]
        };
        m.timer = maketimer(TakeoffRunwayAnnounceClass.period, func m._check_position());
        m.config = config;

        m.last_announced_runway = "";
        m.last_announced_approach = "";

        return m;
    },

    start: func {
        # Start monitoring the location of the aircraft relative to the
        # runways of the current airport.

        me.timer.start();
    },

    stop: func {
        # Stop monitoring the location of the aircraft.
        #
        # You should call this function after takeoff.

        me.timer.stop();

        me.last_announced_runway = "";
        me.last_announced_approach = "";
    },

    get_short_runway_distance: func {
        return getprop("/sim/runway-announcer/short-runway-distance");
    },

    _check_position: func {
        if (me.mode == "") {
            return;
        }

        var apt = airportinfo();
        var self_heading = getprop("/orientation/heading-deg");

        var approaching_runways = {};

        foreach (var runway; keys(apt.runways)) {
            var self = geo.aircraft_position();
            var result = me._check_runway(apt, runway, self);

            var runway_heading = apt.runway(runway).heading;

            # Reset flag for announced approaching runway, so that
            # the airplane could turn around, approach the same runway,
            # and read/hear the announcement again
            if (runway == me.last_announced_approach
              and result.edge_rem > me.config.distance_edge_max_m) {
                me.last_announced_approach = "";
            }

            if (result.on_runway) {
                if (me.mode == "taxi-and-takeoff" or me.mode == "takeoff") {
                    var heading_diff = abs(self_heading - runway_heading);

                    if (me.last_announced_runway != runway
                      and heading_diff <= me.config.diff_runway_heading_deg
                      and (me.config.distance_start_m == nil or result.distance_start <= me.config.distance_start_m)
                      and result.crosstrack_error <= me.config.distance_center_line_m) {
                        if (result.distance_stop >= me.config.nominal_distance_takeoff_m) {
                            me.notify_observers("on-runway", runway);
                        }
                        else {
                            me._on_short_runway(runway, result.distance_stop);
                        }
                        me.last_announced_runway = runway;
                    }
                }
            }
            else {
                if (me.mode == "taxi-and-takeoff" or me.mode == "takeoff") {
                    # If aircraft is no longer on the last announced runway
                    # (when it has vacated onto a taxiway for example), then
                    # reset last_announced_runway field so that on-runway signal
                    # will be emitted if the aircraft enters this same runway again.
                    if (me.last_announced_runway == runway) {
                        me.last_announced_runway = "";
                    }
                }
                if (me.mode == "taxi-and-takeoff" or me.mode == "taxi") {
                    if (me.config.distance_edge_min_m <= result.edge_rem
                      and result.edge_rem <= me.config.distance_edge_max_m) {
                        var ac_angle1 = cos(90.0 - (mod(runway_heading, 180) - self_heading));
                        var ac_angle2 = cos(90.0 - (self_heading - mod(runway_heading, 180)));
                        var ac_angle = max(ac_angle1, ac_angle2);

                        if (ac_angle > 0 and ac_angle >= cos(me.config.diff_approach_heading_deg)) {
                            self.apply_course_distance(self_heading, result.crosstrack_error / ac_angle);
                            var result_future = me._check_runway(apt, runway, self);

                            # If in the future we are on the runway, we are approaching it
                            if (result_future.on_runway) {
                                approaching_runways[runway] = result.distance_start;
                            }
                        }
                    }
                }
            }
        }

        # Every runway also has an opposite runway. Choose the runway that
        # is closest to the aircraft.
        if (size(approaching_runways) == 2) {
            var start_distance_compare = func (a, b) {
                return approaching_runways[a] - approaching_runways[b];
            };
            closest_runway = sort(keys(approaching_runways), start_distance_compare);

            runway = closest_runway[0];
            if (me.last_announced_approach != runway) {
                me.notify_observers("approaching-runway", runway);
                me.last_announced_approach = runway;
            }
        }
    },

    _on_short_runway: func (runway, distance_remaining) {
        var distance = distance_remaining;
        if (me.config.distances_unit == "feet") {
            distance = distance * globals.M2FT;
        }

        # Round down to nearest multiple of 100
        distance = int(distance / 100) * 100;

        setprop("/sim/runway-announcer/short-runway-distance", distance);
        me.notify_observers("on-short-runway", runway);
    }

};

var LandingRunwayAnnounceConfig = {

    distances_meter: [ 30, 100,  300,  600,  900, 1200, 1500],

    distances_feet:  [100, 300, 1000, 2000, 3000, 4000, 5000],

    distances_unit: "meter",
    # The unit to use for the remaining distance. Can be "meter" or "feet"

    distance_center_nose_m: 0,
    # Distance from the center to the nose in meters

    diff_runway_heading_deg: 15,
    # Difference in heading between runway and aircraft in order to
    # detect the correct runway on which the aircraft is landing.

    groundspeed_min_kt: 40,
    # Minimum groundspeed in knots for remaining distance callouts

    agl_max_ft: 100,
    # Maximum AGL in feet for remaining distance callouts

};

var LandingRunwayAnnounceClass = {

    period: 0.1,

    # Announce remaining distance after landing on a runway. Valid modes
    # and the signals they emit are:
    #
    # - takeoff: remaining-distance, vacated-runway
    # - landing: remaining-distance, landed-runway, vacated-runway, landed-outside-runway

    new: func (config) {
        var m = {
            parents: [LandingRunwayAnnounceClass, RunwayAnnounceClass.new()]
        };
        m.timer = maketimer(LandingRunwayAnnounceClass.period, func m._check_position());
        m.config = config;

        m.last_announced_runway = "";
        m.landed_runway = "";
        me.last_announced_distance = nil;
        m.gs_max_kt = 0;

        return m;
    },

    start: func {
        # Start monitoring the location of the aircraft on the runway.

        me.timer.start();
    },

    stop: func {
        # Stop monitoring the location of the aircraft.
        #
        # You should call this function after vacating the runway.

        me.set_mode("");

        me.timer.stop();

        me.last_announced_runway = "";
        me.landed_runway = "";
        me.last_announced_distance = nil;
    },

    _check_position: func {
        if (me.mode == "") {
            return;
        }

        var apt = airportinfo();
        var self_heading = getprop("/orientation/heading-deg");

        var on_number_of_rwys = 0;

        foreach (var runway; keys(apt.runways)) {
            var self = geo.aircraft_position();
            var result = me._check_runway(apt, runway, self);

            if (me.mode == "landing" or me.mode == "takeoff") {
                if (result.on_runway) {
                    on_number_of_rwys += 1;
                    me._on_runway(runway, result, self_heading);
                }
                else {
                    me._not_on_runway(runway);
                }
            }
        }

        # Make landed_runway nil to prevent emitting landed-runway signal
        # in case we landed on anything but a runway (taxiway for example)
        if (me.mode == "landing" and on_number_of_rwys == 0) {
            if (me.landed_runway == "") {
                me.notify_observers("landed-outside-runway", "");
            }
            me.landed_runway = nil;
        }
    },

    _on_runway: func (runway, result, self_heading) {
        var runway_heading = result.runway.heading;

        # Aircraft just landed on the given runway
        if (me.landed_runway != runway) {
            var heading_diff = abs(self_heading - runway_heading);
            if (heading_diff <= me.config.diff_runway_heading_deg) {
                me.landed_runway = runway;
                me.last_announced_distance = nil;
                if (me.mode == "landing") {
                    me.notify_observers("landed-runway", runway);
                }
            }
        }

        var groundspeed = getprop("/velocities/groundspeed-kt");

        # Reset the maximum groundspeed. This is needed if the aircraft
        # does a rejected takeoff and then decides to do another takeoff
        # without leaving the runway
        if (groundspeed < me.config.groundspeed_min_kt) {
            me.gs_max_kt = 0;
        }

        # Aircraft has already landed on the given runway and is now
        # rolling out
        if (me.landed_runway == runway
          and groundspeed > me.config.groundspeed_min_kt
          and getprop("/position/gear-agl-ft") < me.config.agl_max_ft) {
            var nose_distance = result.distance_stop - me.config.distance_center_nose_m;

            if (me.mode == "landing") {
                var extra_conditions_ok = 1;
            }
            elsif (me.mode == "takeoff") {
                me.gs_max_kt = max(groundspeed, me.gs_max_kt);

                # Past 50 % of runway and GS < max groundspeed - 7
                var past_half_runway = (nose_distance / result.runway.length) < 0.50;
                var below_rto_speed  = groundspeed < me.gs_max_kt - 7;

                var extra_conditions_ok = past_half_runway and below_rto_speed;
            }

            if (extra_conditions_ok) {
                if (me.config.distances_unit == "meter") {
                    var unit_ps = getprop("/velocities/uBody-fps") * globals.FT2M;
                    var distances = me.config.distances_meter;
                    var remaining_distance = nose_distance;
                }
                elsif (me.config.distances_unit == "feet") {
                    var unit_ps = getprop("/velocities/uBody-fps");
                    var distances = me.config.distances_feet;
                    var remaining_distance = nose_distance * globals.M2FT;
                }

                var max_index = size(me.config.distances_meter) - 1;
                for (var index = max_index; index >= 0; index = index - 1) {
                    if (me.last_announced_distance != index) {
                        # Distance travelled in two timer periods
                        var dist_upper = distances[index];
                        var dist_lower = dist_upper - unit_ps * LandingRunwayAnnounceClass.period * 2;

                        if (dist_lower <= remaining_distance and remaining_distance <= dist_upper) {
                            me.notify_observers("remaining-distance", dist_upper);
                            me.last_announced_distance = index;
                        }
                    }
                }
            }
        }
    },

    _not_on_runway: func (runway) {
        # Aircraft is no longer on the runway it landed on, so it must
        # have vacated the runway
        if (runway == me.landed_runway) {
            me.last_announced_distance = nil;
            if (me.last_announced_runway != runway) {
                me.notify_observers("vacated-runway", runway);
                me.last_announced_runway = runway;
            }
        }
    }

};

var make_betty_cb = func (betty_say, format, action=nil) {
    if (format != nil and typeof(betty_say) != "func") {
        die("Error: betty_say is not a function");
    }

    return func (data=nil) {
        if (format != nil) {
            if (typeof(format) == "func") {
                var message_format = format();
            }
            else {
                var message_format = format;
            }

            if (data != nil) {
                var message = sprintf(message_format, data.getValue());
            }
            else {
                var message = message_format;
            }

            # Let Betty announce the message
            betty_say(message);
        }

        if (typeof(action) == "func") {
            action();
        }
    };
};
