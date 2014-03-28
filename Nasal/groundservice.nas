# Ground Service

# =======
# Service
# =======
print("Ativando servico de solo!");

servicedevice = "/controls/groundservice/active";
props.Node.new(servicedevice);
setprop(servicedevice, "false");

serviceonoff = func {
    servicedevice = "/controls/groundservice/active";
    valueservice = getprop(servicedevice);
    
    if(valueservice == 0 or valueservice == nil) {
    	setprop(servicedevice, "true" );
    } else {
    	setprop(servicedevice, "false" );
	}
}

