//////////////////////////////
//   Civilian Information   //
//////////////////////////////

["uniforms", ["U_LIB_CIV_Citizen_1",
	"U_LIB_CIV_Villager_1",
	"U_LIB_CIV_Citizen_2",
	"U_LIB_CIV_Citizen_3",
	"U_LIB_CIV_Citizen_4",
	"U_LIB_CIV_Citizen_4",
	"U_LIB_CIV_Citizen_6",
	"U_LIB_CIV_Citizen_7",
	"U_LIB_CIV_Citizen_8",
	"U_LIB_CIV_Priest",
	"U_LIB_CIV_Villager_4",
	"U_LIB_CIV_Villager_2",
	"U_LIB_CIV_Villager_3",
	"U_LIB_CIV_Woodlander_1",
	"U_LIB_CIV_Woodlander_2",
	"U_LIB_CIV_Woodlander_3",
	"U_LIB_CIV_Woodlander_4"
]] call _fnc_saveToTemplate;

["headgear", ["H_LIB_CIV_Villager_Cap_1",
	"H_LIB_CIV_Villager_Cap_2",
	"H_LIB_CIV_Villager_Cap_3",
	"H_LIB_CIV_Villager_Cap_4",
	"GEH_Chapeau_Brun",
	"GEH_Chapeau_GrisFonce",
	"GEH_Chapeau_MarronFonce",
	"H_LIB_CIV_Worker_Cap_3",
	"H_LIB_CIV_Villager_Cap_3"
]] call _fnc_saveToTemplate;

["vehiclesCivCar", [ 
		"LIB_GazM1", 0.2
		,"LIB_GazM1_dirty", 0.2
		,"fow_v_truppenfahrrad_ger_heer", 1.0
	]
] call _fnc_saveToTemplate;			//this line determines civilian cars -- Example: ["vehiclesCivCar", ["C_Offroad_01_F"]] -- Array, can contain multiple assets

["vehiclesCivIndustrial", ["LIB_CIV_FFI_CitC4", 0.3, "C_Tractor_01_F", 0.3]] call _fnc_saveToTemplate; 			//this line determines civilian trucks -- Example: ["vehiclesCivIndustrial", ["C_Truck_02_transport_F"]] -- Array, can contain multiple assets

["vehiclesCivHeli", ["not_supported"]] call _fnc_saveToTemplate; 			//this line determines civilian helis -- Example: ["vehiclesCivHeli", ["C_Heli_Light_01_civil_F"]] -- Array, can contain multiple assets

["vehiclesCivBoat", ["sab_nl_vessel_b", 0.1, "sab_nl_vessel_c", 1.0]] call _fnc_saveToTemplate; 			//this line determines civilian boats -- Example: ["vehiclesCivBoat", ["C_Boat_Civil_01_F"]] -- Array, can contain multiple assets

["vehiclesCivRepair", ["not_supported"]] call _fnc_saveToTemplate;			//this line determines civilian repair vehicles

["vehiclesCivMedical", ["not_supported"]] call _fnc_saveToTemplate;			//this line determines civilian medic vehicles

["vehiclesCivFuel", ["not_supported"]] call _fnc_saveToTemplate;			//this line determines civilian fuel vehicles
