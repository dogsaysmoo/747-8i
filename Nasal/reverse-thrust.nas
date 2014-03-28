# Prestes Hangar - Reverse Thrust (4 turbofan) - http://presteshangar.blogspot.com
# Created September 29, 2009 12:38:20 AM 
# 		revision September 29, 2009 12:58:23 AM 
#
togglereverser = func {
	# Variáveis FDM
	FDMMotor1 = "/fdm/jsbsim/propulsion/engine";
	FDMMotor2 = "/fdm/jsbsim/propulsion/engine[1]";
	FDMMotor3 = "/fdm/jsbsim/propulsion/engine[2]";
	FDMMotor4 = "/fdm/jsbsim/propulsion/engine[3]";

	# Variáveis controle
	ControleMotor1 = "/controls/engines/engine"; 
	ControleMotor2 = "/controls/engines/engine[1]"; 
	ControleMotor3 = "/controls/engines/engine[2]"; 
	ControleMotor4 = "/controls/engines/engine[3]"; 

	# Interface SIM	
	EntradaSIM = "/sim/input/selected";
	
	# Device reversor do motor
	ReversorMotor1 = "/engines/engine/reverser-pos-norm"; 
	ReversorMotor2 = "/engines/engine[1]/reverser-pos-norm"; 
	ReversorMotor3 = "/engines/engine[2]/reverser-pos-norm"; 
	ReversorMotor4 = "/engines/engine[3]/reverser-pos-norm"; 

	# Captura situação do motor 1
	val = getprop(ReversorMotor1);
	
	# Se o motor 1 está com reversor desativado, caso de val == 0,
	#		1) então avanço nos reversores, 
	#		2) ajusta o ângulo do jato para contrário,
	#		3) acerta o controle para ligar esses dispositivos,
	#		4) ajusta o motor para ligado com reversor a 180 graus (2),
	#		   contrário do que deveria ser o gradiente do empuxo.
	if (val == 0 or val == nil) {
		interpolate(ReversorMotor1, 1.0, 1.4); 
		interpolate(ReversorMotor2, 1.0, 1.4);  
		interpolate(ReversorMotor3, 1.0, 1.4); 
		interpolate(ReversorMotor4, 1.0, 1.4);
		
		setprop(FDMMotor1,"reverser-angle-rad","180");
		setprop(FDMMotor2,"reverser-angle-rad","180");
		setprop(FDMMotor3,"reverser-angle-rad","180");
		setprop(FDMMotor4,"reverser-angle-rad","180");
		
		setprop(ControleMotor1,"reverser", "true");
		setprop(ControleMotor2,"reverser", "true");
		setprop(ControleMotor3,"reverser", "true");
		setprop(ControleMotor4,"reverser", "true");
		
		setprop(EntradaSIM,"engine", "true");
		setprop(EntradaSIM,"engine[1]", "true");
		setprop(EntradaSIM,"engine[2]", "true");
		setprop(EntradaSIM,"engine[3]", "true");
	} else {
		if (val == 1.0){
			# Senão, caso de val == 1 (ou seja, reversor já estava ativado),
			#		1) então avanço nos reversores, 
			#		2) ajusta o ângulo do jato reverso para empuxo normal,
			#		3) acerta o controle para desligar esses dispositivos,
			#		4) ajusta o motor para ligado com reversor a 0 graus,
			#		   gradiente padrão do empuxo.
		
			interpolate(ReversorMotor1, 0.0, 1.4);
			interpolate(ReversorMotor2, 0.0, 1.4);   
			interpolate(ReversorMotor3, 0.0, 1.4);
			interpolate(ReversorMotor4, 0.0, 1.4);
			
			setprop(FDMMotor1,"reverser-angle-rad",0);
			setprop(FDMMotor2,"reverser-angle-rad",0);
			setprop(FDMMotor3,"reverser-angle-rad",0);
			setprop(FDMMotor4,"reverser-angle-rad",0);
			
			setprop(ControleMotor1,"reverser",0);
			setprop(ControleMotor2,"reverser",0);
			setprop(ControleMotor3,"reverser",0);
			setprop(ControleMotor4,"reverser",0);
			
			setprop(EntradaSIM,"engine", "true");
			setprop(EntradaSIM,"engine[1]", "true");
			setprop(EntradaSIM,"engine[2]", "true");
			setprop(EntradaSIM,"engine[3]", "true");

		  }
	 }
}

