
# =============
# Mesage System
# =============

print("Ativando servico de mensagens!");

device = "/controls/messages/embarque";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/eqpeletr";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/duremb";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/fecharportas";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/decauth";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/servicobordo";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/turb";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/cmteprobl";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/xxxxx";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/cmtepousauth";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/cmteaguardar";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/taxiando";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/fastenseatbelt";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/inicialcmte";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/instrsegur";
props.Node.new(device);
setprop(device, "false");

device = "/controls/messages/fastenseatbelt";
props.Node.new(device);
setprop(device, "false");




messageonoff = func {
    servicedevice = "/controls/messages/embarque";
    valueservice = getprop(servicedevice);
    
    if(valueservice == 0 or valueservice == nil) {
    	setprop(servicedevice, "true" );
    } else {
    	setprop(servicedevice, "false" );
	}
}

