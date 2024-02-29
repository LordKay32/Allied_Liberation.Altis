///////////////////////////
//   Rebel Information   //
///////////////////////////

["name", "Allied"] call _fnc_saveToTemplate;

["flag", "Flag_US_F"] call _fnc_saveToTemplate;
["flag2", "Flag_UK_F"] call _fnc_saveToTemplate;
["flagTexture", "a3\data_f\flags\flag_us_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "geist_Flag_USA01"] call _fnc_saveToTemplate;

["vehicleBasic", "UNI_US_Willys_MB_OD"] call _fnc_saveToTemplate;
["vehicleLightUnarmed", "UNI_US_Willys_MB_OD"] call _fnc_saveToTemplate;
["vehicleLightArmed", "UNI_US_Willys_MB_M1919_OD"] call _fnc_saveToTemplate;
["vehicleHeavyArmed", "LIB_Scout_M3"] call _fnc_saveToTemplate;

["vehicleAT", "LIB_M8_Greyhound"] call _fnc_saveToTemplate;
["vehicleAA", "not_supported"] call _fnc_saveToTemplate;

["vehicleBoat", "LIB_LCM3_Armed"] call _fnc_saveToTemplate;
["vehicleInfBoat", "LIB_LCVP"] call _fnc_saveToTemplate;
["vehicleAttackBoat", "sab_nl_ptboat"] call _fnc_saveToTemplate;
["vehicleTruck", "UNI_GMC_Open_OD"] call _fnc_saveToTemplate;
["vehicleTruckClosed", "UNI_GMC_Tent_OD"] call _fnc_saveToTemplate;
["vehicleRepair", "UNI_GMC_Repair_OD"] call _fnc_saveToTemplate;
["vehicleFuel", "UNI_GMC_Fuel_OD"] call _fnc_saveToTemplate;
["vehicleAmmo", "UNI_GMC_Ammo_OD"] call _fnc_saveToTemplate;
["vehicleMedical", "UNI_GMC_Ambulance_OD"] call _fnc_saveToTemplate;

["vehicleAPCUK1", "LIB_UniversalCarrier"] call _fnc_saveToTemplate;
["vehicleAPCUK2", "LIB_UK_M3_Halftrack"] call _fnc_saveToTemplate;

["vehicleAPCUS", "LIB_US_M3_Halftrack"] call _fnc_saveToTemplate;

["vehicleTankUKChur", "LIB_Churchill_Mk7"] call _fnc_saveToTemplate;
["vehicleTankUKCroc", "LIB_Churchill_Mk7_Crocodile"] call _fnc_saveToTemplate;
["vehicleTankUKHow", "LIB_Churchill_Mk7_Howitzer"] call _fnc_saveToTemplate;
["vehicleTankUKM4", "LIB_UK_Italy_M4A3_75"] call _fnc_saveToTemplate;

["vehicleTankUSM5", "LIB_M5A1_Stuart"] call _fnc_saveToTemplate;
["vehicleTankUSM4", "LIB_M4A3_75"] call _fnc_saveToTemplate;

["vehiclePlane", "I_C_Plane_Civil_01_F"] call _fnc_saveToTemplate;
["vehiclePayloadPlaneUS", "sab_sw_b17"] call _fnc_saveToTemplate;
["vehiclePayloadPlaneUK", "sab_sw_halifax"] call _fnc_saveToTemplate;

["vehiclePlaneUK1", "sab_fl_hurricane"] call _fnc_saveToTemplate;
["vehiclePlaneUK2", "sab_fl_hurricane_2"] call _fnc_saveToTemplate;
["vehiclePlaneUK3", "sab_fl_dh98"] call _fnc_saveToTemplate;
["vehicleTransportPlaneUK", "LIB_C47_RAF"] call _fnc_saveToTemplate;

["vehiclePlaneUS1", "sab_fl_p51d"] call _fnc_saveToTemplate;
["vehiclePlaneUS2", "sab_sw_p38"] call _fnc_saveToTemplate;
["vehiclePlaneUS3", "sab_sw_a26"] call _fnc_saveToTemplate;
["vehicleTransportPlaneUS", "LIB_C47_Skytrain"] call _fnc_saveToTemplate;

["vehicleHeli", "not_supported"] call _fnc_saveToTemplate;

["vehicleCivCar", "LIB_GazM1_dirty"] call _fnc_saveToTemplate;
["vehicleCivTruck", "LIB_FRA_CitC4"] call _fnc_saveToTemplate;
["vehicleCivHeli", "not_supported"] call _fnc_saveToTemplate;
["vehicleCivBoat", "sab_nl_vessel_c"] call _fnc_saveToTemplate;
["vehicleCivSupply", "not_supported"] call _fnc_saveToTemplate;

["staticMGUK", "fow_w_vickers_uk"] call _fnc_saveToTemplate;
["staticMGUS", "fow_w_m1919_tripod_usa_m41"] call _fnc_saveToTemplate;
["staticAT", "fow_w_6Pounder_uk"] call _fnc_saveToTemplate;
["staticAA", "LIB_61k"] call _fnc_saveToTemplate;
["staticMortar", "LIB_M2_60"] call _fnc_saveToTemplate;
["staticArtillery", "LIB_leFH18"] call _fnc_saveToTemplate;
["staticMortarMagHE", "LIB_8Rnd_60mmHE_M2"] call _fnc_saveToTemplate;
["staticMortarMagSmoke", "LIB_60mm_M2_SmokeShell"] call _fnc_saveToTemplate;
["staticArtilleryMagHE", "LIB_20x_Shell_105L28_Gr39HlC_HE"] call _fnc_saveToTemplate;

//Static weapon definitions

["UKbaggedMGs", [["fow_b_uk_vickers_weapon","fow_b_uk_vickers_support"]]] call _fnc_saveToTemplate;
["USbaggedMGs", [["fow_b_usa_m1919_weapon","fow_b_usa_m1919_support"]]] call _fnc_saveToTemplate;
["baggedAT", [["not_supported"]]] call _fnc_saveToTemplate;
["baggedAA", [["not_supported"]]] call _fnc_saveToTemplate;
["baggedMortars", [["not_supported"]]] call _fnc_saveToTemplate;

["mineAT", ["LIB_US_M1A1_ATMINE_mag"]] call _fnc_saveToTemplate;
["mineAPERS", ["LIB_M3_MINE_mag"]] call _fnc_saveToTemplate;

["breachingExplosivesAPC", [["DemoCharge_Remote_Mag", 1]]] call _fnc_saveToTemplate;
["breachingExplosivesTank", [["SatchelCharge_Remote_Mag", 1], ["DemoCharge_Remote_Mag", 2]]] call _fnc_saveToTemplate;

///////////////////////////
//  Rebel Starting Gear  //
///////////////////////////
["uniforms", [
	"U_LIB_UK_P37",
	"U_LIB_UK_P37_LanceCorporal",
	"U_LIB_UK_P37_Sergeant",
	"U_LIB_UK_DenisonSmock",
	"fow_u_uk_bd40_commando_01_private",
	"fow_u_uk_parasmock",
	"U_LIB_US_Private",
	"U_LIB_US_Med",
	"U_LIB_US_Private_1st",
	"U_LIB_US_Eng",
	"U_LIB_US_Off",
	"U_LIB_US_Sergeant",
	"U_LIB_US_AB_Uniform_M43_FC",
	"U_LIB_US_AB_Uniform_M43_Medic_82AB",
	"U_LIB_US_AB_Uniform_M43_corporal",
	"U_LIB_US_AB_Uniform_M43_Flag",
	"U_LIB_US_AB_Uniform_M43_NCO",
	"U_LIB_US_Rangers_Uniform",
	"U_LIB_US_Tank_Crew2",
	"U_LIB_US_Pilot",
	"U_LIB_US_Pilot_2"
	
]] call _fnc_saveToTemplate;

["headgear", [
	"H_LIB_UK_Helmet_Mk2",
	"H_LIB_UK_Helmet_Mk2_Bowed",
	"H_LIB_UK_Helmet_Mk2_Camo",
	"fow_h_uk_mk2_para",
	"fow_h_uk_mk2_para_camo",
	"fow_h_uk_beret_sas_2",
	"fow_h_uk_beret_commando",
	"H_LIB_UK_Para_Beret",
	"H_LIB_UK_Beret",
	"H_LIB_UK_Beret_Headset",
	"H_LIB_US_Helmet",
	"H_LIB_US_Helmet_os",
	"H_LIB_US_Helmet_Med",
	"H_LIB_US_Helmet_Med_os",
	"H_LIB_US_Helmet_Second_lieutenant",
	"H_LIB_US_AB_Helmet_Jump_1",
	"H_LIB_US_AB_Helmet_Clear_3",
	"H_LIB_US_AB_Helmet_5",
	"H_LIB_US_AB_Helmet_Medic_1",
	"H_LIB_US_Helmet_Tank",
	"H_LIB_US_Helmet_Pilot_Glasses_Down",
	"H_LIB_US_Helmet_Pilot_Glasses_Up",
	"fow_h_uk_jungle_hat_03",
	"fow_h_us_daisy_mae_01"
	]] call _fnc_saveToTemplate;

private _initialRebelEquipment = [
	"ItemWatch","ItemCompass","ItemMap","LIB_Binocular_UK","LIB_Binocular_US","V_LIB_UK_P37_Officer","V_LIB_UK_P37_Rifleman","V_LIB_UK_P37_Holster","V_LIB_UK_P37_Heavy","V_LIB_UK_P37_Sten",
	"fow_v_uk_para_base","fow_v_uk_officer","fow_v_uk_para_bren","V_LIB_UK_P37_Crew","V_LIB_US_Vest_45","V_LIB_US_Vest_Thompson_nco","V_LIB_US_Vest_Carbine_nco","V_LIB_US_Vest_Thompson","V_LIB_US_Vest_Carbine","V_LIB_US_Vest_Garand","V_LIB_US_Vest_Grenadier",
	"V_LIB_US_Vest_Bar","V_LIB_US_Vest_M1919","V_LIB_US_Vest_Medic","V_LIB_US_Vest_Carbine_eng","V_LIB_US_AB_Vest_45","V_LIB_US_AB_Vest_Thompson_nco","V_LIB_US_AB_Vest_Carbine_nco",
	"V_LIB_US_AB_Vest_Thompson","V_LIB_US_AB_Vest_Carbine","V_LIB_US_AB_Vest_Garand","V_LIB_US_AB_Vest_Grenadier","V_LIB_US_AB_Vest_Bar","V_LIB_US_AB_Vest_M1919","V_LIB_US_AB_Vest_Carbine_eng",
	"V_LIB_US_Assault_Vest","V_LIB_US_LifeVest","B_LIB_UK_HSack","B_LIB_US_Backpack","B_LIB_US_Backpack_RocketBag","fow_b_uk_piat"
];

if (A3A_hasTFAR) then {_initialRebelEquipment append ["tf_microdagr","tf_anprc154"]};
if (A3A_hasTFAR && startWithLongRangeRadio) then {_initialRebelEquipment pushBack "tf_anprc155_coyote"};
if (A3A_hasTFARBeta) then {_initialRebelEquipment append ["TFAR_microdagr","TFAR_anprc154"]};
if (A3A_hasTFARBeta && startWithLongRangeRadio) then {_initialRebelEquipment pushBack "TFAR_anprc155_coyote"};
["initialRebelEquipment", _initialRebelEquipment] call _fnc_saveToTemplate;

//////////////////////////////////////
//       Antistasi Plus Stuff       //
//////////////////////////////////////
["baseSoldiers", [ // Cases matter. Lower case here because allVariables on namespace returns lowercase
	["militia_unarmed", "I_G_Soldier_unarmed_F"],
	["militia_rifleman", "I_G_Soldier_F"],
	["militia_medic", "I_G_medic_F"],
	["militia_machinegunner", "I_G_Soldier_AR_F"],
	["militia_squadleader", "I_G_Soldier_SL_F"],
	["militia_engineer", "I_G_engineer_F"],
	["militia_petros", "I_G_officer_F"],

//UK troops
	["militia_ukrifleman", "LIB_UK_Rifleman"],
	["militia_ukunarmed", "LIB_UK_Rifleman"],
	["militia_ukstaticcrew", "LIB_UK_Rifleman"],
	["militia_ukmedic", "LIB_UK_Medic"],
	["militia_uksniper", "LIB_UK_Sniper"],
	["militia_ukmachinegunner", "LIB_UK_LanceCorporal"],
	["militia_ukexplosivesexpert", "LIB_WP_Saper"],
	["militia_ukgrenadier", "LIB_UK_Grenadier"],
	["militia_uksquadleader", "LIB_UK_Officer"],
	["militia_ukengineer", "I_G_engineer_F"],
	["militia_ukat", "LIB_UK_AT_Soldier"],
	["militia_ukpilot", "LIB_US_Pilot"],
	["militia_ukcrew", "LIB_UK_Tank_Crew"],
	
	["militia_sasrifleman", "LIB_UK_Rifleman"],
	["militia_sasmedic", "LIB_UK_Medic"],
	["militia_sassniper", "LIB_UK_Sniper"],
	["militia_sasmachinegunner", "LIB_UK_LanceCorporal"],
	["militia_sasexplosivesexpert", "LIB_WP_Starszy_saper"],
	["militia_sassquadleader", "LIB_UK_Officer"],
	["militia_sasat", "LIB_UK_AT_Soldier"],
	
//US troops
	["militia_usrifleman", "LIB_US_Rifleman"],
	["militia_usunarmed", "LIB_US_Rifleman"],
	["militia_usstaticcrew", "LIB_US_Rifleman"],
	["militia_usmedic", "LIB_US_Medic"],
	["militia_ussniper", "LIB_US_Sniper"],
	["militia_usmachinegunner", "LIB_US_MGunner"],
	["militia_usexplosivesexpert", "LIB_WP_Saper"],
	["militia_usgrenadier", "LIB_US_Grenadier"],
	["militia_ussquadleader", "LIB_US_Second_Lieutenant"],
	["militia_usengineer", "I_G_engineer_F"],
	["militia_usat", "LIB_US_AT_Soldier"],
	["militia_uspilot", "LIB_US_Pilot"],
	["militia_uscrew", "LIB_US_Tank_Crew"],
	
	["militia_pararifleman", "LIB_US_82AB_FC_rifleman"],
	["militia_paramedic", "LIB_US_82AB_medic"],
	["militia_parasniper", "LIB_US_Sniper"],
	["militia_paramachinegunner", "LIB_US_82AB_mgunner"],
	["militia_paraexplosivesexpert", "LIB_WP_Saper"],
	["militia_paragrenadier", "LIB_US_82AB_grenadier"],
	["militia_parasquadleader", "LIB_US_82AB_CO"],
	["militia_paraengineer", "LIB_US_Engineer"],
	["militia_paraat", "LIB_US_82AB_AT_soldier"]

]] call _fnc_saveToTemplate;

lootCrate = "Box_Syndicate_Ammo_F";
rallyPoint = "BackPack_B_LIB_US_Radio";

//black market stuff
shop_UAV = ["I_UAV_01_F"];
shop_AA = ["I_LT_01_AA_F"];
shop_MRAP = ["I_MRAP_03_hmg_F", "B_MRAP_01_hmg_F", "O_MRAP_02_hmg_F"];
shop_wheel_apc = ["O_APC_Wheeled_02_rcws_v2_F", "B_APC_Wheeled_01_cannon_F", "I_APC_Wheeled_03_cannon_F"];
shop_track_apc = ["I_APC_tracked_03_cannon_F", "I_APC_tracked_03_cannon_F", "B_APC_Tracked_01_rcws_F"];
shop_heli = ["O_Heli_Light_02_dynamicLoadout_F", "B_Heli_Light_01_dynamicLoadout_F", "I_Heli_light_03_dynamicLoadout_F"];
shop_tank = ["I_LT_01_cannon_F", "I_LT_01_AT_F", "I_MBT_03_cannon_F"];
shop_plane = ["I_Plane_Fighter_03_dynamicLoadout_F"];

additionalShopLight = [];
additionalShopAtgmVehicles = [];
additionalShopManpadsVehicles = [];
additionalShopArtillery = [];

//military building models (common for all sides)
smallBunker = "Land_BagBunker_Small_F";
sandbag = "Land_BagFence_Long_F";

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//     DO NOT GO PAST THIS LINE

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

//////////////////////////
//       Loadouts       //
//////////////////////////
private _loadoutData = call _fnc_createLoadoutData;
_loadoutData setVariable ["rifles", []];
_loadoutData setVariable ["carbines", []];
_loadoutData setVariable ["grenadeLaunchers", []];
_loadoutData setVariable ["SMGs", []];
_loadoutData setVariable ["machineGuns", []]; 			//this line determines machine guns -- Example: ["arifle_MX_SW_F","arifle_MX_SW_Hamr_pointer_F"] -- Array, can contain multiple assets
_loadoutData setVariable ["marksmanRifles", []];
_loadoutData setVariable ["sniperRifles", []];
_loadoutData setVariable ["lightATLaunchers", []];
_loadoutData setVariable ["ATLaunchers", []];
_loadoutData setVariable ["missileATLaunchers", []];
_loadoutData setVariable ["AALaunchers", []];
_loadoutData setVariable ["sidearms", []];

_loadoutData setVariable ["ATMines", []];
_loadoutData setVariable ["APMines", []];
_loadoutData setVariable ["lightExplosives", []];
_loadoutData setVariable ["heavyExplosives", []];

_loadoutData setVariable ["antiInfantryGrenades", []];
_loadoutData setVariable ["antiTankGrenades", []];
_loadoutData setVariable ["smokeGrenades", []];




_loadoutData setVariable ["maps", ["ItemMap"]];
_loadoutData setVariable ["watches", ["ItemWatch"]];
_loadoutData setVariable ["compasses", ["ItemCompass"]];
_loadoutData setVariable ["radios", []];
_loadoutData setVariable ["gpses", []];
_loadoutData setVariable ["NVGs", []];
_loadoutData setVariable ["binoculars", []];

_loadoutData setVariable ["uniforms", []];
_loadoutData setVariable ["vests", []];
_loadoutData setVariable ["backpacks", []];
_loadoutData setVariable ["longRangeRadios", []];
_loadoutData setVariable ["helmets", []];

//Item *set* definitions. These are added in their entirety to unit loadouts. No randomisation is applied.
_loadoutData setVariable ["items_medical_basic", []];
_loadoutData setVariable ["items_medical_standard", []];
_loadoutData setVariable ["items_medical_medic", []];
_loadoutData setVariable ["items_miscEssentials", []];


_loadoutData setVariable ["items_squadleader_extras", []];
_loadoutData setVariable ["items_rifleman_extras", []];
_loadoutData setVariable ["items_medic_extras", []];
_loadoutData setVariable ["items_grenadier_extras", []];
_loadoutData setVariable ["items_explosivesExpert_extras", []];
_loadoutData setVariable ["items_engineer_extras", []];
_loadoutData setVariable ["items_lat_extras", []];
_loadoutData setVariable ["items_at_extras", []];
_loadoutData setVariable ["items_aa_extras", []];
_loadoutData setVariable ["items_machineGunner_extras", []];
_loadoutData setVariable ["items_marksman_extras", []];
_loadoutData setVariable ["items_sniper_extras", []];
_loadoutData setVariable ["items_police_extras", []];
_loadoutData setVariable ["items_crew_extras", []];
_loadoutData setVariable ["items_unarmed_extras", []];

////////////////////////
//  Rebel Unit Types  //
///////////////////////.

private _squadLeaderTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["backpacks"] call _fnc_setBackpack;

	[["grenadeLaunchers", "rifles"] call _fnc_fallback] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;


	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_squadLeader_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["antiTankGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["gpses"] call _fnc_addGPS;
	["binoculars"] call _fnc_addBinoculars;
	["NVGs"] call _fnc_addNVGs;
};

private _riflemanTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["rifles"] call _fnc_setPrimary;
	["primary", 8] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_rifleman_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["antiTankGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _medicTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["carbines"] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_medic"] call _fnc_addItemSet;
	["items_medic_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _grenadierTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["grenadeLaunchers"] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;


	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_grenadier_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 4] call _fnc_addItem;
	["antiTankGrenades", 3] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _explosivesExpertTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["rifles"] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;


	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_explosivesExpert_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;

	["lightExplosives", 2] call _fnc_addItem;
	if (random 1 > 0.5) then {["heavyExplosives", 1] call _fnc_addItem;};
	if (random 1 > 0.5) then {["atMines", 1] call _fnc_addItem;};
	if (random 1 > 0.5) then {["apMines", 1] call _fnc_addItem;};

	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _engineerTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["carbines"] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_engineer_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;

	if (random 1 > 0.5) then {["lightExplosives", 1] call _fnc_addItem;};

	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _latTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["rifles"] call _fnc_setPrimary;
	["primary", 8] call _fnc_addMagazines;

	[["lightATLaunchers", "ATLaunchers"] call _fnc_fallback] call _fnc_setLauncher;
	//TODO - Add a check if it's disposable.
	["launcher", 1] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_lat_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["antiTankGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _atTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["rifles"] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;

	[selectRandom ["ATLaunchers", "missileATLaunchers"]] call _fnc_setLauncher;
	//TODO - Add a check if it's disposable.
	["launcher", 2] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_at_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["antiTankGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _aaTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["rifles"] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;

	["AALaunchers"] call _fnc_setLauncher;
	//TODO - Add a check if it's disposable.
	["launcher", 2] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_aa_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _machineGunnerTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["machineGuns"] call _fnc_setPrimary;
	["primary", 4] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_machineGunner_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _marksmanTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["marksmanRifles"] call _fnc_setPrimary;
	["primary", 8] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_marksman_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _sniperTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["sniperRifles"] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_sniper_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["NVGs"] call _fnc_addNVGs;
};

private _policeTemplate = {
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	[selectRandom ["smgs", "carbines"]] call _fnc_setPrimary;
	["primary", 5] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_police_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _crewTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["smgs"] call _fnc_setPrimary;
	["primary", 3] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_basic"] call _fnc_addItemSet;
	["items_crew_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["gpses"] call _fnc_addGPS;
	["NVGs"] call _fnc_addNVGs;
};

private _unarmedTemplate = {
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["items_medical_basic"] call _fnc_addItemSet;
	["items_unarmed_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _prefix = "militia";
private _unitTypes = [
	["Petros", _squadLeaderTemplate],
	["SquadLeader", _squadLeaderTemplate],
	["Rifleman", _riflemanTemplate],
	["staticCrew", _riflemanTemplate],
	["Medic", _medicTemplate, [["medic", true]]],
	["Engineer", _engineerTemplate, [["engineer", true]]],
	["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true]]],
	["Grenadier", _grenadierTemplate],
	["LAT", _latTemplate],
	["AT", _atTemplate],
	["AA", _aaTemplate],
	["MachineGunner", _machineGunnerTemplate],
	["Marksman", _marksmanTemplate],
	["Sniper", _sniperTemplate],
	["Unarmed", _unarmedTemplate],
	
	["ukSquadLeader", _squadLeaderTemplate],
	["ukRifleman", _riflemanTemplate],
	["ukstaticCrew", _riflemanTemplate],
	["ukMedic", _medicTemplate, [["ukmedic", true]]],
	["ukEngineer", _engineerTemplate, [["ukengineer", true]]],
	["ukExplosivesExpert", _explosivesExpertTemplate, [["ukexplosiveSpecialist", true]]],
	["ukGrenadier", _grenadierTemplate],
	["ukAT", _atTemplate],
	["ukMachineGunner", _machineGunnerTemplate],
	["ukSniper", _sniperTemplate],
	["ukUnarmed", _unarmedTemplate],
	["ukPilot", _crewTemplate],
	["ukCrew", _crewTemplate],
	
	["usSquadLeader", _squadLeaderTemplate],
	["usRifleman", _riflemanTemplate],
	["usstaticCrew", _riflemanTemplate],
	["usMedic", _medicTemplate, [["usmedic", true]]],
	["usEngineer", _engineerTemplate, [["usengineer", true]]],
	["usExplosivesExpert", _explosivesExpertTemplate, [["usexplosiveSpecialist", true]]],
	["usGrenadier", _grenadierTemplate],
	["usAT", _atTemplate],
	["usMachineGunner", _machineGunnerTemplate],
	["usSniper", _sniperTemplate],
	["usUnarmed", _unarmedTemplate],
	["usPilot", _crewTemplate],
	["usCrew", _crewTemplate],
	
	["paraSquadLeader", _squadLeaderTemplate],
	["paraRifleman", _riflemanTemplate],
	["paraMedic", _medicTemplate, [["paramedic", true]]],
	["paraEngineer", _engineerTemplate, [["paraengineer", true]]],
	["paraExplosivesExpert", _explosivesExpertTemplate, [["paraexplosiveSpecialist", true]]],
	["paraGrenadier", _grenadierTemplate],
	["paraAT", _atTemplate],
	["paraMachineGunner", _machineGunnerTemplate],
	["paraSniper", _sniperTemplate],
	
	["sasSquadLeader", _squadLeaderTemplate],
	["sasRifleman", _riflemanTemplate],
	["sasMedic", _medicTemplate, [["sasmedic", true]]],
	["sasExplosivesExpert", _explosivesExpertTemplate, [["sasexplosiveSpecialist", true]]],
	["sasAT", _atTemplate],
	["sasMachineGunner", _machineGunnerTemplate],
	["sasSniper", _sniperTemplate]

];

[_prefix, _unitTypes, _loadoutData] call _fnc_generateAndSaveUnitsToTemplate;