//////////////////////////
//   Side Information   //
//////////////////////////

["name", "Wehrmacht"] call _fnc_saveToTemplate;
["spawnMarkerName", "Wehrmacht support corridor"] call _fnc_saveToTemplate;

["flag", "geist_Flag_3Rs3_F"] call _fnc_saveToTemplate;
["flagTexture", "geista3l\geistl_assets_t_flags\data\flag_reich3_s3_f_co.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "geist_Flag_3Rs3"] call _fnc_saveToTemplate;

//////////////////////////////////////
//       Antistasi Plus Stuff       //
//////////////////////////////////////
["baseSoldiers", [ // Cases matter. Lower case here because allVariables on namespace returns lowercase
	["para_squadleader", "LIB_GER_unterofficer"],
	["para_rifleman", "LIB_GER_rifleman"],
	["para_radioman", "LIB_GER_radioman"],
	["para_medic", "LIB_GER_medic"],
	["para_engineer", "B_G_engineer_F"],
	["para_explosivesexpert", "LIB_GER_sapper"],
	["para_grenadier", "LIB_GER_ober_grenadier"],
	["para_lat", "LIB_GER_LAT_Rifleman"],
	["para_at", "LIB_GER_AT_soldier"],
	["para_machinegunner", "LIB_GER_mgunner"],
	["para_sniper", "LIB_GER_scout_sniper"],

	["military_squadleader", "LIB_GER_unterofficer"],
	["military_rifleman", "LIB_GER_rifleman"],
	["military_radioman", "LIB_GER_radioman"],
	["military_medic", "LIB_GER_medic"],
	["military_engineer", "B_G_engineer_F"],
	["military_explosivesexpert", "LIB_GER_sapper"],
	["military_grenadier", "LIB_GER_ober_grenadier"],
	["military_lat", "LIB_GER_LAT_Rifleman"],
	["military_at", "LIB_GER_AT_soldier"],
	["military_machinegunner", "LIB_GER_mgunner"],
	["military_sniper", "LIB_GER_scout_sniper"],

	["elite_squadleader", "LIB_GER_unterofficer"],
	["elite_rifleman", "LIB_GER_rifleman"],
	["elite_radioman", "LIB_GER_radioman"],
	["elite_medic", "LIB_GER_medic"],
	["elite_engineer", "B_G_engineer_F"],
	["elite_explosivesexpert", "LIB_GER_sapper"],
	["elite_grenadier", "LIB_GER_ober_grenadier"],
	["elite_lat", "LIB_GER_LAT_Rifleman"],
	["elite_at", "LIB_GER_AT_soldier"],
	["elite_machinegunner", "LIB_GER_mgunner"],
	["elite_sniper", "LIB_GER_scout_sniper"],
	
	["sf_squadleader", "LIB_GER_unterofficer"],
	["sf_rifleman", "LIB_GER_rifleman"],
	["sf_radioman", "LIB_GER_radioman"],
	["sf_medic", "LIB_GER_medic"],
	["sf_engineer", "B_G_engineer_F"],
	["sf_explosivesexpert", "LIB_GER_sapper"],
	["sf_grenadier", "LIB_GER_ober_grenadier"],
	["sf_lat", "LIB_GER_LAT_Rifleman"],
	["sf_at", "LIB_GER_AT_soldier"],
	["sf_machinegunner", "LIB_GER_mgunner"],
	["sf_sniper", "LIB_GER_scout_sniper"],

	["other_crew", "LIB_GER_tank_unterofficer"],
	["other_unarmed", "LIB_GER_unequip"],
	["other_official", "LIB_GER_oberst"],
	["other_traitor", "B_G_Soldier_F"],
	["other_pilot", "LIB_GER_pilot"],
	["police_squadleader", "LIB_GER_unterofficer"],
	["police_standard", "LIB_GER_rifleman"]
]] call _fnc_saveToTemplate;


//////////////////////////
//       Vehicles       //
//////////////////////////

["ammobox", "LIB_WeaponsBox_Big_GER"] call _fnc_saveToTemplate; 	//Don't touch or you die a sad and lonely death!
["surrenderCrate", "LIB_AmmoCrate_Arty_SU"] call _fnc_saveToTemplate;
["equipmentBox", "LIB_BasicWeaponsBox_GER"] call _fnc_saveToTemplate;

["vehiclesBasic", ["LIB_Kfz1_sernyt"]] call _fnc_saveToTemplate;
["vehiclesLightUnarmed", ["LIB_Kfz1_sernyt", "LIB_Kfz1_Hood_sernyt", "LIB_Kfz1_camo", "LIB_Kfz1_Hood_camo"]] call _fnc_saveToTemplate;
["vehiclesLightArmed",["LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42_camo"]] call _fnc_saveToTemplate; 		//this line determines light and armed vehicles -- Example: ["vehiclesLightArmed",["B_MRAP_01_hmg_F", "B_MRAP_01_gmg_F"]] -- Array, can contain multiple assets
["vehiclesTrucks", ["LIB_OpelBlitz_Open_Y_Camo", "LIB_OpelBlitz_Tent_Y_Camo"]] call _fnc_saveToTemplate;
["vehiclesCargoTrucks", ["LIB_OpelBlitz_Open_Y_Camo", "LIB_OpelBlitz_Tent_Y_Camo"]] call _fnc_saveToTemplate;
["vehiclesAmmoTrucks", ["LIB_OpelBlitz_Ammo"]] call _fnc_saveToTemplate;
["vehiclesRepairTrucks", ["LIB_OpelBlitz_Parm"]] call _fnc_saveToTemplate;
["vehiclesFuelTrucks", ["LIB_OpelBlitz_Fuel"]] call _fnc_saveToTemplate;
["vehiclesMedical", ["LIB_OpelBlitz_Ambulance"]] call _fnc_saveToTemplate;
["vehiclesAPCs", ["fow_v_sdkfz_222_camo_ger_heer", "fow_v_sdkfz_251_camo_ger_heer", "fow_v_sdkfz_250_9_camo_ger_heer", "LIB_SdKfz251_FFV"]] call _fnc_saveToTemplate;
["vehiclesTanks", ["LIB_GER_PzKpfwIV_H_Feldgrau","LIB_DAK_PzKpfwIV_H", "LIB_PzKpfwIV_H_tarn51c", "LIB_PzKpfwIV_H_tarn51d", "LIB_PzKpfwIV_H", "LIB_PzKpfwVI_E_tarn51d", "LIB_GER_PzKpfwIV_H_Feldgrau","LIB_DAK_PzKpfwIV_H", "LIB_PzKpfwIV_H_tarn51c", "LIB_PzKpfwIV_H_tarn51d", "LIB_PzKpfwIV_H"]] call _fnc_saveToTemplate;
["vehiclesAA", ["LIB_SdKfz_7_AA", "LIB_FlakPanzerIV_Wirbelwind"]] call _fnc_saveToTemplate;
["vehiclesLightAPCs", ["fow_v_sdkfz_251_camo_ger_heer"]] call _fnc_saveToTemplate;
["vehiclesIFVs", []] call _fnc_saveToTemplate;

["vehiclesSam", ["",""]] call _fnc_saveToTemplate; 	//this line determines SAM systems, order: radar, SAM

["vehiclesTransportBoats", ["sab_nl_vessel_a"]] call _fnc_saveToTemplate;
["vehiclesGunBoats", ["sab_nl_ptboat"]] call _fnc_saveToTemplate;
["vehiclesAmphibious", [""]] call _fnc_saveToTemplate;

["vehiclesPlanesCAS", ["sab_sw_ju87", "sab_sw_bf110", "sab_fl_ju88a"]] call _fnc_saveToTemplate;
["vehiclesPlanesAA", ["sab_fl_bf109e", "sab_fl_fw190a"]] call _fnc_saveToTemplate;
["vehiclesPlanesTransport", ["UNI_C47_CAP_Grey"]] call _fnc_saveToTemplate;

["vehiclesHelisLight", ["not_supported"]] call _fnc_saveToTemplate;
["vehiclesHelisTransport", ["not_supported"]] call _fnc_saveToTemplate;
["vehiclesHelisAttack", ["not_supported"]] call _fnc_saveToTemplate;

["vehiclesArtillery", [
["LIB_FlaK_36_ARTY",["LIB_45x_SprGr_KwK36_HE"]]
]] call _fnc_saveToTemplate;

["uavsAttack", ["not_supported"]] call _fnc_saveToTemplate;
["uavsPortable", ["not_supported"]] call _fnc_saveToTemplate;

["vehiclesMilitiaLightArmed", ["LIB_Kfz1_MG42_sernyt", "LIB_Kfz1_MG42_camo"]] call _fnc_saveToTemplate;
["vehiclesMilitiaTrucks", ["LIB_OpelBlitz_Open_Y_Camo", "LIB_OpelBlitz_Tent_Y_Camo"]] call _fnc_saveToTemplate;
["vehiclesMilitiaCars", ["LIB_Kfz1_sernyt", "LIB_Kfz1_Hood_sernyt", "LIB_Kfz1_camo", "LIB_Kfz1_Hood_camo"]] call _fnc_saveToTemplate;
["vehiclesMilitiaApcs",["fow_v_sdkfz_222_camo_ger_heer", "fow_v_sdkfz_251_camo_ger_heer", "fow_v_sdkfz_250_9_camo_ger_heer", "LIB_SdKfz251_FFV"]] call _fnc_saveToTemplate;
["vehiclesMilitiaTanks", ["LIB_GER_PzKpfwIV_H_Feldgrau","LIB_DAK_PzKpfwIV_H", "LIB_PzKpfwIV_H_tarn51c", "LIB_PzKpfwIV_H_tarn51d", "LIB_PzKpfwIV_H"]] call _fnc_saveToTemplate;

["vehiclesPolice", ["LIB_Kfz1_sernyt", "LIB_Kfz1_Hood_sernyt", "LIB_Kfz1_MG42_sernyt"]] call _fnc_saveToTemplate;

["staticMGs", ["LIB_MG34_Lafette_Deployed", "LIB_MG42_Lafette_Deployed"]] call _fnc_saveToTemplate;
["staticAT", ["LIB_ger_Pak40_Feldgrau"]] call _fnc_saveToTemplate;
["staticAA", ["LIB_FlaK_38", "LIB_Flakvierling_38"]] call _fnc_saveToTemplate;
["staticMortars", ["LIB_GrWr34_g"]] call _fnc_saveToTemplate;
["staticHowitzers", ["LIB_leFH18"]] call _fnc_saveToTemplate;

["mortarMagazineHE", "LIB_8Rnd_81mmHE_GRWR34"] call _fnc_saveToTemplate;
["mortarMagazineSmoke", "LIB_81mm_GRWR34_SmokeShell"] call _fnc_saveToTemplate;

["howitzerMagazineHE", "LIB_20x_Shell_105L28_Gr39HlC_HE"] call _fnc_saveToTemplate;

["baggedMGs", [["not supported"]]] call _fnc_saveToTemplate;
["baggedAT", [["not supported"]]] call _fnc_saveToTemplate;
["baggedAA", [["not supported"]]] call _fnc_saveToTemplate;
["baggedMortars", [["not supported"]]] call _fnc_saveToTemplate; 			//this line determines bagged static mortars -- Example: ["baggedMortars", [["B_Mortar_01_weapon_F", "B_Mortar_01_support_F"]]] -- Array, can contain multiple assets


["minefieldAT", ["LIB_TMI_42_MINE"]] call _fnc_saveToTemplate;
["minefieldAPERS", ["LIB_shumine_42_MINE", "LIB_SMI_35_MINE"]] call _fnc_saveToTemplate;


["playerDefaultLoadout", []] call _fnc_saveToTemplate;
["pvpLoadouts", [
		//Team Leader
		["vanilla_blufor_teamLeader"] call A3A_fnc_getLoadout,
		//Medic
		["vanilla_blufor_medic"] call A3A_fnc_getLoadout,
		//Autorifleman
		["vanilla_blufor_machineGunner"] call A3A_fnc_getLoadout,
		//Marksman
		["vanilla_blufor_marksman"] call A3A_fnc_getLoadout,
		//Anti-tank Scout
		["vanilla_blufor_AT"] call A3A_fnc_getLoadout,
		//AT2
		["vanilla_blufor_rifleman"] call A3A_fnc_getLoadout
	]
] call _fnc_saveToTemplate;

["pvpVehicles", ["B_LSV_01_armed_F", "B_LSV_01_unarmed_F"]] call _fnc_saveToTemplate;


//////////////////////////
//       Loadouts       //
//////////////////////////
private _loadoutData = call _fnc_createLoadoutData;
_loadoutData setVariable ["rifles", []];
_loadoutData setVariable ["carbines", []];
_loadoutData setVariable ["grenadeLaunchers", []];
_loadoutData setVariable ["SMGs", []];
_loadoutData setVariable ["machineGuns", []];
_loadoutData setVariable ["marksmanRifles", []];
_loadoutData setVariable ["sniperRifles", []];
_loadoutData setVariable ["lightATLaunchers", [
	["LIB_PzFaust_30m", "", "", "", [], [], ""],
	["LIB_PzFaust_60m", "", "", "", [], [], ""]
]];
_loadoutData setVariable ["ATLaunchers", [
	["LIB_RPzB", "", "", "", ["LIB_1Rnd_RPzB"], [], ""]
]];
_loadoutData setVariable ["missileATLaunchers", []];
_loadoutData setVariable ["AALaunchers", []];
_loadoutData setVariable ["sidearms", []];

_loadoutData setVariable ["ATMines", ["LIB_TMI_42_MINE_mag"]];
_loadoutData setVariable ["APMines", ["LIB_shumine_42_MINE_mag", "LIB_SMI_35_MINE_mag"]];
_loadoutData setVariable ["lightExplosives", ["LIB_Ladung_Small_MINE_mag"]];
_loadoutData setVariable ["heavyExplosives", ["LIB_Ladung_Big_MINE_mag"]];

_loadoutData setVariable ["antiInfantryGrenades", ["LIB_Shg24", "LIB_M39"]];
_loadoutData setVariable ["antiTankGrenades", []];
_loadoutData setVariable ["smokeGrenades", ["LIB_US_M18"]];
_loadoutData setVariable ["signalsmokeGrenades", ["LIB_US_M18_Green", "LIB_US_M18_Red", "LIB_US_M18_Yellow"]];

_loadoutData setVariable ["maps", ["ItemMap"]];
_loadoutData setVariable ["watches", ["LIB_GER_ItemWatch"]];
_loadoutData setVariable ["compasses", ["LIB_GER_ItemCompass"]];
_loadoutData setVariable ["radios", ["ItemRadio"]];
_loadoutData setVariable ["gpses", []];
_loadoutData setVariable ["NVGs", []];
_loadoutData setVariable ["binoculars", ["LIB_Binocular_GER"]];
_loadoutData setVariable ["Rangefinder", []];

_loadoutData setVariable ["uniforms", []];
_loadoutData setVariable ["vests", []];
_loadoutData setVariable ["Hvests", []];
_loadoutData setVariable ["GLvests", []];
_loadoutData setVariable ["backpacks", []];
_loadoutData setVariable ["longRangeRadios", ["B_LIB_GER_Radio"]];
_loadoutData setVariable ["helmets", []];

//Item *set* definitions. These are added in their entirety to unit loadouts. No randomisation is applied.
_loadoutData setVariable ["items_medical_basic", ["BASIC"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the basic medical loadout for vanilla
_loadoutData setVariable ["items_medical_standard", ["STANDARD"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the standard medical loadout for vanilla
_loadoutData setVariable ["items_medical_medic", ["MEDIC"] call A3A_fnc_itemset_medicalSupplies]; //this line defines the medic medical loadout for vanilla
_loadoutData setVariable ["items_miscEssentials", [] call A3A_fnc_itemset_miscEssentials];

_loadoutData setVariable ["items_squadleader_extras", ["ACE_microDAGR", "ACE_DAGR"]];
_loadoutData setVariable ["items_rifleman_extras", []];
_loadoutData setVariable ["items_medic_extras", []];
_loadoutData setVariable ["items_grenadier_extras", []];
_loadoutData setVariable ["items_explosivesExpert_extras", ["Toolkit", "ACE_Clacker","ACE_DefusalKit"]];
_loadoutData setVariable ["items_engineer_extras", ["Toolkit"]];
_loadoutData setVariable ["items_lat_extras", []];
_loadoutData setVariable ["items_at_extras", []];
_loadoutData setVariable ["items_aa_extras", []];
_loadoutData setVariable ["items_machineGunner_extras", []];
_loadoutData setVariable ["items_marksman_extras", ["ACE_RangeCard", "ACE_ATragMX", "ACE_Kestrel4500"]];
_loadoutData setVariable ["items_sniper_extras", ["ACE_RangeCard", "ACE_ATragMX", "ACE_Kestrel4500"]];
_loadoutData setVariable ["items_police_extras", []];
_loadoutData setVariable ["items_crew_extras", []];
_loadoutData setVariable ["items_unarmed_extras", []];

//TODO - ACE overrides for misc essentials, medical and engineer gear

///////////////////////////////////////
//    Special Forces Loadout Data    //
///////////////////////////////////////

private _sfLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_sfLoadoutData setVariable ["uniforms", ["U_LIB_GER_rifleman_WssMnnK98", "U_LIB_GER_Soldier_camo_27v00pMnn2K98", "U_LIB_GER_Soldier_camo_41v00pMnn2K98"]];
_sfLoadoutData setVariable ["SLUniforms", ["U_LIB_GER_unterofficer_WssHschaMp40"]];
_sfLoadoutData setVariable ["medicUniforms", ["U_LIB_GER_medic_WssK98", "U_LIB_GER_Soldier_camo_27v00pSantwss2K98", "U_LIB_GER_Soldier_camo_41v00pSantwss2K98"]];
_sfLoadoutData setVariable ["sniperUniforms", ["U_LIB_GER_Soldier_camo_41v41pMnnK98"]];
_sfLoadoutData setVariable ["vests", ["V_LIB_GER_VestG43"]];
_sfLoadoutData setVariable ["SLVests", ["V_LIB_GER_VestUnterofficer"]];
_sfLoadoutData setVariable ["MGVests", ["V_LIB_GER_VestMG"]];
_sfLoadoutData setVariable ["engVests", ["V_LIB_GER_PioneerVest"]];
_sfLoadoutData setVariable ["sniperVests", ["V_LIB_GER_SniperBelt"]];
_sfLoadoutData setVariable ["backpacks", ["B_LIB_GER_SapperBackpack_empty"]];
_sfLoadoutData setVariable ["medicBackpacks", ["B_LIB_GER_MedicBackpack_empty"]];
_sfLoadoutData setVariable ["ATBackpacks", ["B_LIB_GER_Panzer_Empty"]];
_sfLoadoutData setVariable ["helmets", ["H_LIB_GER_Helmet_WSS1024T1"]];
_sfLoadoutData setVariable ["SLHelmets", ["H_LIB_GER_Cap_WSS_Bm", "H_LIB_GER_Helmet_WSS1024T1"]];
_sfLoadoutData setVariable ["medicHelmets", ["H_LIB_GER_Helmet_WSS1024T1"]];
_sfLoadoutData setVariable ["sniperHelmets", ["H_LIB_GER_HelmetCamo_41"]];

_sfLoadoutData setVariable ["rifles", [
["LIB_G43", "", "", "", ["LIB_10Rnd_792x57"], [], ""]
]];
_sfLoadoutData setVariable ["carbines", [
["LIB_FG42G", "", "", "LIB_Optic_Zf4", ["LIB_20Rnd_792x57"], [], ""]
]];
_sfLoadoutData setVariable ["grenadeLaunchers", [
["LIB_K98_GW", "LIB_ACC_GW_SB_Empty", "", "", ["LIB_5Rnd_792x57"], ["LIB_1Rnd_G_PZGR_30", "LIB_1Rnd_G_PZGR_40", "LIB_1Rnd_G_SPRGR_30"], ""]
]];
_sfLoadoutData setVariable ["SMGs", [
["LIB_MP40", "", "", "", ["LIB_32Rnd_9x19"], [], ""]
]];
_sfLoadoutData setVariable ["machineGuns", [
["LIB_MG34", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""],
["LIB_MG42", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""]
]];
_sfLoadoutData setVariable ["sniperRifles", [
["LIB_K98ZF39", "", "", "", ["LIB_5Rnd_792x57"], [], ""]
]];
_sfLoadoutData setVariable ["sidearms", [
["LIB_M1908", "", "", "", ["LIB_8Rnd_9x19_P08"], [], ""]
]];
/////////////////////////////////
//    Military Loadout Data    //
/////////////////////////////////

private _militaryLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_militaryLoadoutData setVariable ["uniforms", ["U_LIB_GER_Schutze", "U_LIB_GER_Oberschutze", "U_LIB_GER_MG_schutze"]];
_militaryLoadoutData setVariable ["SLUniforms", ["U_LIB_GER_Unterofficer"]];
_militaryLoadoutData setVariable ["medicUniforms", ["U_LIB_GER_Medic"]];
_militaryLoadoutData setVariable ["sniperUniforms", ["U_LIB_GER_Scharfschutze"]];
_militaryLoadoutData setVariable ["vests", ["V_LIB_GER_VestKar98"]];
_militaryLoadoutData setVariable ["SLVests", ["V_LIB_GER_VestUnterofficer"]];
_militaryLoadoutData setVariable ["MGVests", ["V_LIB_GER_VestMG"]];
_militaryLoadoutData setVariable ["engVests", ["V_LIB_GER_PioneerVest"]];
_militaryLoadoutData setVariable ["sniperVests", ["V_LIB_GER_SniperBelt"]];
_militaryLoadoutData setVariable ["backpacks", ["B_LIB_GER_SapperBackpack_empty"]];
_militaryLoadoutData setVariable ["medicBackpacks", ["B_LIB_GER_MedicBackpack_empty"]];
_militaryLoadoutData setVariable ["ATBackpacks", ["B_LIB_GER_Panzer_Empty"]];
_militaryLoadoutData setVariable ["helmets", ["H_LIB_GER_Helmet"]];
_militaryLoadoutData setVariable ["SLHelmets", ["H_LIB_GER_Cap", "H_LIB_GER_Helmet"]];
_militaryLoadoutData setVariable ["medicHelmets", ["H_LIB_GER_Helmet"]];
_militaryLoadoutData setVariable ["sniperHelmets", ["H_LIB_GER_HelmetCamo"]];

_militaryLoadoutData setVariable ["rifles", [
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""]
]];
_militaryLoadoutData setVariable ["carbines", [
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""]
]];
_militaryLoadoutData setVariable ["grenadeLaunchers", [
["LIB_K98_GW", "LIB_ACC_GW_SB_Empty", "", "", ["LIB_5Rnd_792x57"], ["LIB_1Rnd_G_PZGR_30", "LIB_1Rnd_G_PZGR_40", "LIB_1Rnd_G_SPRGR_30"], ""]
]];
_militaryLoadoutData setVariable ["SMGs", [
["LIB_MP40", "", "", "", ["LIB_32Rnd_9x19"], [], ""]
]];
_militaryLoadoutData setVariable ["machineGuns", [
["LIB_MG34", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""],
["LIB_MG42", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""]
]];
_militaryLoadoutData setVariable ["sniperRifles", [
["LIB_K98ZF39", "", "", "", ["LIB_5Rnd_792x57"], [], ""]
]];
_militaryLoadoutData setVariable ["sidearms", [
["LIB_M1908", "", "", "", ["LIB_8Rnd_9x19_P08"], [], ""]
]];

///////////////////////////////
//    Police Loadout Data    //
///////////////////////////////

private _policeLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_policeLoadoutData setVariable ["uniforms", ["U_LIB_GER_Unterofficer"]];
_policeLoadoutData setVariable ["vests", ["V_LIB_GER_VestUnterofficer"]];
_policeLoadoutData setVariable ["helmets", ["H_LIB_GER_Cap", "H_LIB_GER_Helmet"]];
_policeLoadoutData setVariable ["smgs", [
["LIB_MP40", "", "", "", ["LIB_32Rnd_9x19"], [], ""]
]];
_policeLoadoutData setVariable ["sidearms", [
["LIB_M1908", "", "", "", ["LIB_8Rnd_9x19_P08"], [], ""]
]];

////////////////////////////////
//    Para Loadout Data    //
////////////////////////////////

private _paraLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_paraLoadoutData setVariable ["uniforms", ["U_LIB_FSJ_Soldier_dak"]];
_paraLoadoutData setVariable ["SLUniforms", ["U_LIB_FSJ_Soldier_dak"]];
_paraLoadoutData setVariable ["medicUniforms", ["U_LIB_FSJ_Soldier_dak"]];
_paraLoadoutData setVariable ["sniperUniforms", ["U_LIB_FSJ_Soldier_dak_camo"]];
_paraLoadoutData setVariable ["vests", ["V_LIB_GER_VestKar98"]];
_paraLoadoutData setVariable ["SLVests", ["V_LIB_GER_VestUnterofficer"]];
_paraLoadoutData setVariable ["MGVests", ["V_LIB_GER_VestMG"]];
_paraLoadoutData setVariable ["engVests", ["V_LIB_GER_PioneerVest"]];
_paraLoadoutData setVariable ["sniperVests", ["V_LIB_GER_SniperBelt"]];
_paraLoadoutData setVariable ["backpacks", ["B_LIB_GER_SapperBackpack_empty"]];
_paraLoadoutData setVariable ["medicBackpacks", ["B_LIB_GER_MedicBackpack_empty"]];
_paraLoadoutData setVariable ["ATBackpacks", ["B_LIB_GER_Panzer_Empty"]];
_paraLoadoutData setVariable ["helmets", ["H_LIB_GER_FSJ_M38_Helmet"]];
_paraLoadoutData setVariable ["SLHelmets", ["H_LIB_GER_FSJ_M38_Helmet"]];
_paraLoadoutData setVariable ["medicHelmets", ["H_LIB_GER_FSJ_M44_Helmet_Medic"]];
_paraLoadoutData setVariable ["sniperHelmets", ["H_LIB_GER_FSJ_M38_Helmet_Cover"]];

_paraLoadoutData setVariable ["rifles", [
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""],
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""],
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""],
["LIB_G43", "", "", "", ["LIB_10Rnd_792x57"], [], ""]
]];
_paraLoadoutData setVariable ["carbines", [
["LIB_FG42G", "", "", "", ["LIB_20Rnd_792x57"], [], ""]
]];
_paraLoadoutData setVariable ["grenadeLaunchers", [
["LIB_K98_GW", "LIB_ACC_GW_SB_Empty", "", "", ["LIB_5Rnd_792x57"], ["LIB_1Rnd_G_PZGR_30", "LIB_1Rnd_G_PZGR_40", "LIB_1Rnd_G_SPRGR_30"], ""]
]];
_paraLoadoutData setVariable ["SMGs", [
["LIB_MP40", "", "", "", ["LIB_32Rnd_9x19"], [], ""]
]];
_paraLoadoutData setVariable ["machineGuns", [
["LIB_MG34", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""],
["LIB_MG42", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""]
]];
_paraLoadoutData setVariable ["sniperRifles", [
["LIB_K98ZF39", "", "", "", ["LIB_5Rnd_792x57"], [], ""]
]];
_paraLoadoutData setVariable ["sidearms", [
["LIB_M1908", "", "", "", ["LIB_8Rnd_9x19_P08"], [], ""]
]];

/////////////////////////////////
//    Elite Loadout Data    //
/////////////////////////////////
private _eliteLoadoutData = _loadoutData call _fnc_copyLoadoutData;
_eliteLoadoutData setVariable ["uniforms", ["U_LIB_GER_Schutze", "U_LIB_GER_Oberschutze", "U_LIB_GER_MG_schutze", "U_LIB_GER_Soldier_camo2"]];
_eliteLoadoutData setVariable ["SLUniforms", ["U_LIB_GER_Unterofficer"]];
_eliteLoadoutData setVariable ["medicUniforms", ["U_LIB_GER_Medic"]];
_eliteLoadoutData setVariable ["sniperUniforms", ["U_LIB_GER_Scharfschutze"]];
_eliteLoadoutData setVariable ["vests", ["V_LIB_GER_VestKar98"]];
_eliteLoadoutData setVariable ["SLVests", ["V_LIB_GER_VestUnterofficer"]];
_eliteLoadoutData setVariable ["MGVests", ["V_LIB_GER_VestMG"]];
_eliteLoadoutData setVariable ["engVests", ["V_LIB_GER_PioneerVest"]];
_eliteLoadoutData setVariable ["sniperVests", ["V_LIB_GER_SniperBelt"]];
_eliteLoadoutData setVariable ["backpacks", ["B_LIB_GER_SapperBackpack_empty"]];
_eliteLoadoutData setVariable ["medicBackpacks", ["B_LIB_GER_MedicBackpack_empty"]];
_eliteLoadoutData setVariable ["ATBackpacks", ["B_LIB_GER_Panzer_Empty"]];
_eliteLoadoutData setVariable ["helmets", ["H_LIB_GER_Helmet"]];
_eliteLoadoutData setVariable ["SLHelmets", ["H_LIB_GER_Cap", "H_LIB_GER_Helmet"]];
_eliteLoadoutData setVariable ["medicHelmets", ["H_LIB_GER_Helmet"]];
_eliteLoadoutData setVariable ["sniperHelmets", ["H_LIB_GER_HelmetCamo"]];

_eliteLoadoutData setVariable ["rifles", [
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""],
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""],
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""],
["LIB_G43", "", "", "", ["LIB_10Rnd_792x57"], [], ""]
]];
_eliteLoadoutData setVariable ["carbines", [
["LIB_K98", "", "", "", ["LIB_5Rnd_792x57"], [], ""]
]];
_eliteLoadoutData setVariable ["grenadeLaunchers", [
["LIB_K98_GW", "LIB_ACC_GW_SB_Empty", "", "", ["LIB_5Rnd_792x57"], ["LIB_1Rnd_G_PZGR_30", "LIB_1Rnd_G_PZGR_40", "LIB_1Rnd_G_SPRGR_30"], ""]
]];
_eliteLoadoutData setVariable ["SMGs", [
["LIB_MP40", "", "", "", ["LIB_32Rnd_9x19"], [], ""]
]];
_eliteLoadoutData setVariable ["machineGuns", [
["LIB_MG34", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""],
["LIB_MG42", "", "", "", ["LIB_50Rnd_792x57", "LIB_50Rnd_792x57_SMK", "LIB_50Rnd_792x57_sS"], [], ""]
]];
_eliteLoadoutData setVariable ["sniperRifles", [
["LIB_K98ZF39", "", "", "", ["LIB_5Rnd_792x57"], [], ""]
]];
_eliteLoadoutData setVariable ["sidearms", [
["LIB_M1908", "", "", "", ["LIB_8Rnd_9x19_P08"], [], ""]
]];

//////////////////////////
//    Misc Loadouts     //
//////////////////////////

private _crewLoadoutData = _militaryLoadoutData call _fnc_copyLoadoutData;
_crewLoadoutData setVariable ["uniforms", ["U_LIB_GER_Tank_crew_private"]];
_crewLoadoutData setVariable ["vests", ["V_LIB_GER_TankPrivateBelt"]];
_crewLoadoutData setVariable ["helmets", ["H_LIB_GER_TankPrivateCap"]];


private _pilotLoadoutData = _militaryLoadoutData call _fnc_copyLoadoutData;
_pilotLoadoutData setVariable ["uniforms", ["U_LIB_GER_LW_pilot"]];
_pilotLoadoutData setVariable ["vests", ["V_LIB_GER_OfficerBelt"]];
_pilotLoadoutData setVariable ["helmets", ["H_LIB_GER_LW_PilotHelmet"]];
_pilotLoadoutData setVariable ["backpacks", ["B_LIB_GER_LW_Paradrop"]];

// ##################### DO NOT TOUCH ANYTHING BELOW THIS LINE #####################


/////////////////////////////////
//    Unit Type Definitions    //
/////////////////////////////////
//These define the loadouts for different unit types.
//For example, rifleman, grenadier, squad leader, etc.
//In 95% of situations, you *should not need to edit these*.
//Almost all factions can be set up just by modifying the loadout data above.
//However, these exist in case you really do want to do a lot of custom alterations.

private _squadLeaderTemplate = {
	["SLHelmets"] call _fnc_setHelmet;
	["SLVests"] call _fnc_setVest;
	["SLUniforms"] call _fnc_setUniform;

	["smgs"] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_squadLeader_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;
	["signalsmokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["binoculars"] call _fnc_addBinoculars;
};

private _riflemanTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["rifles"] call _fnc_setPrimary;
	["primary", 10] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_rifleman_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _radiomanTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["longRangeRadios"] call _fnc_setBackpack;

	[selectRandom ["rifles", "carbines"]] call _fnc_setPrimary;
	["primary", 10] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_rifleman_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 2] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _medicTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["medicUniforms"] call _fnc_setUniform;
	["medicBackpacks"] call _fnc_setBackpack;
  	["rifles"] call _fnc_setPrimary;
	["primary", 10] call _fnc_addMagazines;

	["items_medical_medic"] call _fnc_addItemSet;
	["items_medic_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _grenadierTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["grenadeLaunchers"] call _fnc_setPrimary;
	["primary", 8] call _fnc_addMagazines;
	["primary", 6] call _fnc_addAdditionalMuzzleMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_grenadier_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 4] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _explosivesExpertTemplate = {
	["helmets"] call _fnc_setHelmet;
	["engVests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["carbines"] call _fnc_setPrimary;
	["primary", 8] call _fnc_addMagazines;

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
};

private _engineerTemplate = {
	["helmets"] call _fnc_setHelmet;
	["engVests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["backpacks"] call _fnc_setBackpack;

	["carbines"] call _fnc_setPrimary;
	["primary", 8] call _fnc_addMagazines;

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
};

private _latTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["rifles"] call _fnc_setPrimary;
	["primary", 10] call _fnc_addMagazines;

	["lightATLaunchers"] call _fnc_setLauncher;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_lat_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _atTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;
	["ATBackpacks"] call _fnc_setBackpack;

	["smgs"] call _fnc_setPrimary;
	["primary", 6] call _fnc_addMagazines;

	["ATLaunchers"] call _fnc_setLauncher;

	["launcher", 5] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_at_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 1] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _machineGunnerTemplate = {
	["helmets"] call _fnc_setHelmet;
	["MGVests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

	["machineGuns"] call _fnc_setPrimary;
	["primary", 3] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_machineGunner_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
};

private _sniperTemplate = {
	["sniperHelmets"] call _fnc_setHelmet;
	["sniperVests"] call _fnc_setVest;
	["sniperUniforms"] call _fnc_setUniform;

	["sniperRifles"] call _fnc_setPrimary;
	["primary", 10] call _fnc_addMagazines;

	["items_medical_standard"] call _fnc_addItemSet;
	["items_sniper_extras"] call _fnc_addItemSet;
	["items_miscEssentials"] call _fnc_addItemSet;
	["antiInfantryGrenades", 1] call _fnc_addItem;
	["smokeGrenades", 2] call _fnc_addItem;

	["maps"] call _fnc_addMap;
	["watches"] call _fnc_addWatch;
	["compasses"] call _fnc_addCompass;
	["radios"] call _fnc_addRadio;
	["binoculars"] call _fnc_addBinoculars;
};

private _policeTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;


	["smgs"] call _fnc_setPrimary;
	["primary", 3] call _fnc_addMagazines;

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
	["primary", 4] call _fnc_addMagazines;

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
};

private _pilotTemplate = {
	["helmets"] call _fnc_setHelmet;
	["vests"] call _fnc_setVest;
	["uniforms"] call _fnc_setUniform;

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

private _traitorTemplate = {
	call _unarmedTemplate;
	["sidearms"] call _fnc_setHandgun;
	["handgun", 2] call _fnc_addMagazines;
};

////////////////////////////////////////////////////////////////////////////////////////
//  You shouldn't touch below this line unless you really really know what you're doing.
//  Things below here can and will break the gamemode if improperly changed.
////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////
//  Special Forces Units   //
/////////////////////////////
private _prefix = "SF";
private _unitTypes = [
	["SquadLeader", _squadLeaderTemplate],
	["Rifleman", _riflemanTemplate],
	["Radioman", _radiomanTemplate],
	["Medic", _medicTemplate, [["medic", true]]],
	["Engineer", _engineerTemplate, [["engineer", true]]],
	["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true]]],
	["Grenadier", _grenadierTemplate],
	["LAT", _latTemplate],
	["AT", _atTemplate],
	["MachineGunner", _machineGunnerTemplate],
	["Sniper", _sniperTemplate]
];

[_prefix, _unitTypes, _sfLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

/*{
	params ["_name", "_loadoutTemplate"];
	private _loadouts = [_sfLoadoutData, _loadoutTemplate] call _fnc_buildLoadouts;
	private _finalName = _prefix + _name;
	[_finalName, _loadouts] call _fnc_saveToTemplate;
} forEach _unitTypes;
*/

///////////////////////
//  Military Units   //
///////////////////////
private _prefix = "military";
private _unitTypes = [
	["SquadLeader", _squadLeaderTemplate],
	["Rifleman", _riflemanTemplate],
	["Radioman", _radiomanTemplate],
	["Medic", _medicTemplate, [["medic", true]]],
	["Engineer", _engineerTemplate, [["engineer", true]]],
	["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true]]],
	["Grenadier", _grenadierTemplate],
	["LAT", _latTemplate],
	["AT", _atTemplate],
	["MachineGunner", _machineGunnerTemplate],
	["Sniper", _sniperTemplate]
];

[_prefix, _unitTypes, _militaryLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

///////////////////////
//  Elite Units   //
///////////////////////
private _prefix = "elite";
private _unitTypes = [
	["SquadLeader", _squadLeaderTemplate],
	["Rifleman", _riflemanTemplate],
	["Radioman", _radiomanTemplate],
	["Medic", _medicTemplate, [["medic", true]]],
	["Engineer", _engineerTemplate, [["engineer", true]]],
	["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true]]],
	["Grenadier", _grenadierTemplate],
	["LAT", _latTemplate],
	["AT", _atTemplate],
	["MachineGunner", _machineGunnerTemplate],
	["Sniper", _sniperTemplate]
];

[_prefix, _unitTypes, _eliteLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

////////////////////////
//    Police Units    //
////////////////////////
private _prefix = "police";
private _unitTypes = [
	["SquadLeader", _policeTemplate],
	["Standard", _policeTemplate]
];

[_prefix, _unitTypes, _policeLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

////////////////////////
//    para Units    //
////////////////////////
private _prefix = "para";
private _unitTypes = [
	["SquadLeader", _squadLeaderTemplate],
	["Rifleman", _riflemanTemplate],
	["Radioman", _radiomanTemplate],
	["Medic", _medicTemplate, [["medic", true]]],
	["Engineer", _engineerTemplate, [["engineer", true]]],
	["ExplosivesExpert", _explosivesExpertTemplate, [["explosiveSpecialist", true]]],
	["Grenadier", _grenadierTemplate],
	["LAT", _latTemplate],
	["AT", _atTemplate],
	["MachineGunner", _machineGunnerTemplate],
	["Sniper", _sniperTemplate]
];

[_prefix, _unitTypes, _paraLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

//////////////////////
//    Misc Units    //
//////////////////////


["other", [["Crew", _crewTemplate]], _crewLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

["other", [["Pilot", _pilotTemplate]], _pilotLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

["other", [["Official", _policeTemplate]], _militaryLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

["other", [["Traitor", _traitorTemplate]], _militaryLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;

["other", [["Unarmed", _unarmedTemplate]], _militaryLoadoutData] call _fnc_generateAndSaveUnitsToTemplate;
