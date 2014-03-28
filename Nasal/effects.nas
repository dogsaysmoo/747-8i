# ===============
# Effects Control
# ===============

print("Ativando controle de efeitos!");

device = "/sim/effects/engines/smoke";
props.Node.new(device);
setprop(device, "false");

device = "/sim/effects/gear/tiresmoke";
props.Node.new(device);
setprop(device, "false");
