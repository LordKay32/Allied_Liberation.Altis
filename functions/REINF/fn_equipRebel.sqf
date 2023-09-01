// Fully equips a rebel infantry unit based on their class and unlocked gear
// _recruitType param allows some variation based on recruiting method: 0 recruit, 1 HC squad, 2 garrison

params ["_unit", "_recruitType", ["_forceClass", ""]];
private ["_randomNumber","_SDKWeapon","_SDKMagazine","_SDKRounds"];
private _filename = "fn_equipRebel";

private _unitClass = if (_forceClass != "") then {_forceClass} else {_unit getVariable "unitType"};

// Clear everything except standard items and empty uniform
// Actually fast, unlike a setUnitLoadout with a full loadout
_unit setUnitLoadout [ [], [], [],    ["", []], [], [],    "", "", [],
	["ItemMap","","","ItemCompass","ItemWatch",""] ];		// no GPS, radio, NVG

if (_unitClass in [UKExp, UKEng, SASExp, USExp, USEng, paraExp, paraEng]) then {
		_unit enableAIFeature ["MINEDETECTION", true]; //This should prevent them from Stepping on the Mines as an "Expert" (It helps, they still step on them)
	};

	private _SDKUniforms = ["U_GELIB_FRA_MGunner_gvnpFF13","U_GELIB_FRA_MGunner_gvmpFF14","U_GELIB_FRA_SoldierFF_gvmpFF15","U_GELIB_FRA_SoldierFF_gvmpFF16"];
	private _SDKVests = ["V_LIB_GER_VestMG_7b","V_LIB_GER_Vest_Vide","V_LIB_FIN_VestKar98brun_0b"];
	private _SDKBackpacks = ["B_LIB_SOV_RA_Rucksack","B_LIB_GER_Tonister34_cowhide"];
	private _SDKHats = ["H_LIB_SOV_RA_PrivateCap_VDVse","GEH_Beret_blue","GERDS_Beret1"];
	
	if (_unitClass in [SDKMil,SDKMedic,SDKEng]) then {
		_randomNumber = random 100;
		if (_randomNumber < 20) then {
			_SDKWeapon = "LIB_LeeEnfield_No4";
			_SDKMagazine = "LIB_10Rnd_770x56";
			_SDKRounds = 6;
			};
		if ((_randomNumber >= 20) &&(_randomNumber < 60)) then {
			_SDKWeapon = "LIB_Sten_Mk2";
			_SDKMagazine = "LIB_32Rnd_9x19_Sten";
			_SDKRounds = 4;
			};
		if ((_randomNumber >= 60) &&(_randomNumber < 80)) then {
			_SDKWeapon = "LIB_K98";
			_SDKMagazine = "LIB_5Rnd_792x57";
			_SDKRounds = 10;
			};
		if ((_randomNumber >= 80) &&(_randomNumber < 100)) then {
			_SDKWeapon = "LIB_MP40";
			_SDKMagazine = "LIB_32Rnd_9x19";
			_SDKRounds = 4;
			};
	};
	if (_unitClass in [SDKMG]) then {
		_randomNumber = random 100;
		if (_randomNumber < 50) then {
			_SDKWeapon = "LIB_Bren_Mk2";
			_SDKMagazine = "LIB_30Rnd_770x56";
			_SDKRounds = 5;
			};
		if (_randomNumber >= 50) then {
			_SDKWeapon = "LIB_MG34";
			_SDKMagazine = "LIB_50Rnd_792x57";
			_SDKRounds = 3;
			};
	};

	private _UKHelmets = ["H_LIB_UK_Helmet_Mk2", "H_LIB_UK_Helmet_Mk2_Bowed"];
	private _USHelmets = ["H_LIB_US_Helmet", "H_LIB_US_Helmet_os"];
	private _USParaHelmets = ["H_LIB_US_AB_Helmet_Jump_1", "H_LIB_US_AB_Helmet_Clear_3", "H_LIB_US_AB_Helmet_5"];

switch (true) do {
	
	//Partisans
	case (_unitClass == SDKUnarmed): {
		_unit forceAddUniform (selectRandom _SDKUniforms);
	};
	case (_unitClass == SDKMil): {
		_unit forceAddUniform (selectRandom _SDKUniforms);
		if (uniform _unit in ["U_GELIB_FRA_MGunner_gvnpFF13","U_GELIB_FRA_MGunner_gvmpFF14"]) then {
			_unit addVest (selectRandom _SDKVests)} else {
			_unit addBackpack (selectRandom _SDKBackpacks)
		};
		_unit addHeadgear selectRandom _SDKHats;
		_unit addMagazine _SDKMagazine;
		_unit addWeapon _SDKWeapon;
		_unit addItemToUniform (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addItemToUniform "LIB_MillsBomb";
		if (random 100 > 85) then {
			_unit addBackpack "fow_b_heer_ammo_belt";
		};
		_unit addMagazines [_SDKMagazine, _SDKRounds];
		if (random 100 > 80) then {
			_unit addWeapon (selectRandom ["LIB_PzFaust_30m","LIB_PzFaust_60m"])
		};
	};
	case (_unitClass == SDKMG): {
		_unit forceAddUniform (selectRandom _SDKUniforms);
		if (uniform _unit in ["U_GELIB_FRA_MGunner_gvnpFF13","U_GELIB_FRA_MGunner_gvmpFF14"]) then {
			_unit addVest (selectRandom _SDKVests);
			_unit addBackpack "fow_b_heer_ammo_belt"} else {
			_unit addBackpack (selectRandom _SDKBackpacks)
		};
		_unit addHeadgear selectRandom _SDKHats;
		_unit addMagazine _SDKMagazine;
		_unit addWeapon _SDKWeapon;
		_unit addItemToUniform (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addItemToUniform "LIB_MillsBomb";
		_unit addMagazines [_SDKMagazine, _SDKRounds];
	};
	case (_unitClass == SDKEng): {
		_unit forceAddUniform (selectRandom _SDKUniforms);
		if (uniform _unit in ["U_GELIB_FRA_MGunner_gvnpFF13","U_GELIB_FRA_MGunner_gvmpFF14"]) then {
			_unit addVest (selectRandom _SDKVests)
		};
		_unit addBackpack (selectRandom _SDKBackpacks);
		_unit addHeadgear selectRandom _SDKHats;
		_unit addMagazine _SDKMagazine;
		_unit addWeapon _SDKWeapon;
		_unit addItemToUniform (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addItemToUniform "LIB_MillsBomb";
		_unit addItemToBackpack "ToolKit";
		_unit addItemToBackpack "LIB_Ladung_Small_MINE_mag";
		_unit addMagazines [_SDKMagazine, _SDKRounds];
	};
	case (_unitClass == SDKMedic): {
		_unit forceAddUniform (selectRandom _SDKUniforms);
		if (uniform _unit in ["U_GELIB_FRA_MGunner_gvnpFF13","U_GELIB_FRA_MGunner_gvmpFF14"]) then {
			_unit addVest (selectRandom _SDKVests)
		};
		_unit addBackpack "B_LIB_GER_Tonister34_cowhide";
		_unit addHeadgear selectRandom _SDKHats;
		_unit addMagazine _SDKMagazine;
		_unit addWeapon _SDKWeapon;
		_unit addItemToUniform (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addItemToUniform "LIB_MillsBomb";
		_unit addItemToBackpack "Medikit";
		_unit addItemToBackpack (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addItemToBackpack (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addMagazines [_SDKMagazine, _SDKRounds];
	};
		case (_unitClass == SDKSL): {
		_unit forceAddUniform (selectRandom ["U_GELIB_FRA_MGunner_gvnpFF13","U_GELIB_FRA_MGunner_gvmpFF14"]);
		_unit addVest "V_LIB_FIN_VestUnterofficerbrun_6S1";
		_unit addHeadgear selectRandom _SDKHats;
		_unit addMagazine "LIB_30Rnd_45ACP";
		_unit addWeapon "LIB_M1A1_Thompson";
		_unit addMagazine "LIB_6Rnd_455";
		_unit addWeapon "LIB_Webley_mk6";
		_unit addItemToUniform (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addItemToUniform (selectRandom ["fow_i_fak_uk","fow_i_fak_ger"]);
		_unit addItemToVest "LIB_MillsBomb";
		_unit addItemToVest "LIB_MillsBomb";
		_unit addMagazines ["LIB_30Rnd_45ACP", 4];
		_unit addMagazines ["LIB_6Rnd_455", 2];
	};
	
	//UK Infantry
	case (_unitClass == UKUnarmed): {
		_unit forceAddUniform "U_LIB_UK_P37";
	};		
	case ((_unitClass == UKMil) || (_unitClass == UKstaticCrewTeamPlayer)): {
		_unit forceAddUniform "U_LIB_UK_P37";
		_unit addVest "V_LIB_UK_P37_Rifleman";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_MillsBomb";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == UKMedic): {
		_unit forceAddUniform "U_LIB_UK_P37";
		_unit addVest "V_LIB_UK_P37_Rifleman";
		_unit addBackpack "B_LIB_UK_HSack";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addItemToBackpack "Medikit";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_MillsBomb";
			_unit addItemToVest "LIB_US_M18_Green";
			_unit addItemToBackpack "fow_i_fak_uk";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == UKMG): {
		_unit forceAddUniform "U_LIB_UK_P37_LanceCorporal";
		_unit addVest "V_LIB_UK_P37_Heavy";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_30Rnd_770x56";
		_unit addWeapon "LIB_Bren_Mk2";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_30Rnd_770x56_MKVIII";
			_unit addItemToVest "LIB_MillsBomb";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_30Rnd_770x56";
			};
	};
	case (_unitClass == UKExp): {
		_unit forceAddUniform "U_LIB_UK_P37";
		_unit addVest "V_LIB_UK_P37_Rifleman";
		_unit addBackpack "B_LIB_UK_HSack";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addItemToUniform "LIB_US_M18_Yellow";
		_unit addItemToBackpack "LIB_M3_MINE_mag";
		_unit addItemToBackpack "LIB_US_M1A1_ATMINE_mag";
		_unit addItemToBackpack "fow_e_tnt_onepound_mag";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_MillsBomb";
			_unit addItemToVest"LIB_No77";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == UKGL): {
		_unit forceAddUniform "U_LIB_UK_P37_LanceCorporal";
		_unit addVest "V_LIB_UK_P37_Heavy";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addWeaponItem ["LIB_LeeEnfield_No4", "LIB_ACC_GL_Enfield_CUP_Empty"];
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_MillsBomb";
			};
		for "_i" from 1 to 6 do
			{
			_unit addItemToVest "LIB_1Rnd_G_MillsBomb";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == UKSL): {
		_unit addWeapon "LIB_Binocular_UK";
		_unit forceAddUniform "U_LIB_UK_P37_Sergeant";
		_unit addVest "V_LIB_UK_P37_Officer";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_32Rnd_9x19_Sten";
		_unit addWeapon "LIB_Sten_Mk2";
		_unit addMagazine "LIB_6Rnd_455";
		_unit addWeapon "LIB_Webley_mk6";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_6Rnd_455";
			_unit addItemToVest "LIB_MillsBomb";
			};
		for "_i" from 1 to 6 do
			{
			_unit addItemToVest "LIB_32Rnd_9x19_Sten";
			};
	};
	case (_unitClass == UKEng): {
		_unit forceAddUniform "U_LIB_UK_P37";
		_unit addVest "V_LIB_UK_P37_Rifleman";
		_unit addBackpack "B_LIB_UK_HSack";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addItemToBackpack "ToolKit";
		_unit addItemToBackpack "MineDetector";
		_unit addItemToUniform "LIB_US_M18_Yellow";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_MillsBomb";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
		case (_unitClass == UKATman): {
		_unit forceAddUniform "U_LIB_UK_P37";
		_unit addVest "V_LIB_UK_P37_Rifleman";
		_unit addBackpack "B_LIB_UK_HSack";
		_unit addHeadgear (selectRandom _UKHelmets);
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addMagazine "LIB_1Rnd_89m_PIAT";
		_unit addWeapon "LIB_PIAT";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_MillsBomb";
			};
			for "_i" from 1 to 3 do
			{
			_unit addItemToBackpack "LIB_1Rnd_89m_PIAT";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
		case (_unitClass == UKsniper): {
		_unit addWeapon "LIB_Binocular_UK";
		_unit forceAddUniform "U_LIB_UK_P37_LanceCorporal";
		_unit addVest "V_LIB_UK_P37_Rifleman";
		_unit addHeadgear "H_LIB_UK_Helmet_Mk2_Camo";
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4_Scoped";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_MillsBomb";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == UKPilot): {
		_unit forceAddUniform "U_LIB_US_Pilot";
		_unit addVest "V_LIB_US_LifeVest";
		_unit addBackpack "B_LIB_US_TypeA3";
		_unit addHeadgear "H_LIB_US_Helmet_Pilot_Glasses_Down";
		_unit addMagazine "LIB_6Rnd_455";
		_unit addWeapon "LIB_Webley_mk6";
		_unit addItemToUniform "LIB_US_M18_Yellow";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_6Rnd_455";
			};
	};
		case (_unitClass == UKCrew): {
		_unit addWeapon "LIB_Binocular_UK";
		_unit forceAddUniform "U_LIB_UK_P37_Sergeant";
		_unit addVest "V_LIB_UK_P37_Crew";
		_unit addHeadgear "H_LIB_UK_Beret_Headset";
		_unit addMagazine "LIB_32Rnd_9x19_Sten";
		_unit addWeapon "LIB_Sten_Mk2";
		_unit addMagazine "LIB_6Rnd_455";
		_unit addWeapon "LIB_Webley_mk6";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_uk";
			_unit addItemToVest "LIB_32Rnd_9x19_Sten";
			_unit addItemToVest "LIB_6Rnd_455";
			};
	};

	//UK SAS
	case (_unitClass == SASMil): {
		_unit forceAddUniform "fow_u_uk_parasmock";
		_unit addVest "fow_v_uk_para_base";
		_unit addHeadgear "fow_h_uk_beret_sas_2";
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToUniform "fow_i_fak_uk";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == SASMedic): {
		_unit forceAddUniform "fow_u_uk_parasmock";
		_unit addVest "fow_v_uk_para_base";
		_unit addBackpack "B_Carryall_cbr";
		_unit addHeadgear "fow_h_uk_beret_sas_2";
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addItemToBackpack "Medikit";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToVest "LIB_US_M18_Green";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToUniform "fow_i_fak_uk";
			};
		for "_i" from 1 to 5 do
			{
			_unit addItemToBackpack "fow_i_fak_uk";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == SASMG): {
		_unit forceAddUniform "fow_u_uk_parasmock";
		_unit addVest "fow_v_uk_para_bren";
		_unit addHeadgear "fow_h_uk_beret_sas_2";
		_unit addMagazine "LIB_30Rnd_770x56";
		_unit addWeapon "LIB_Bren_Mk2";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToUniform "fow_i_fak_uk";
			};
		for "_i" from 1 to 6 do
			{
			_unit addItemToVest "LIB_30Rnd_770x56";
			};
	};
	case (_unitClass == SASExp): {
		_unit forceAddUniform "fow_u_uk_parasmock";
		_unit addVest "fow_v_uk_para_base";
		_unit addBackpack "B_Carryall_cbr";
		_unit addHeadgear "fow_h_uk_beret_sas_2";
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addMagazine "LIB_30Rnd_45ACP";
		_unit addWeapon "LIB_M1A1_Thompson";
		_unit addItemToBackpack "ToolKit";
		_unit addItemToBackpack "MineDetector";
		_unit addItemToBackpack "LIB_US_M1A1_ATMINE_mag";
		_unit addItemToBackpack "LIB_M3_MINE_mag";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "LIB_US_M18_Yellow";
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest"LIB_No77";
			_unit addItemToBackpack "fow_e_tnt_twopound_mag";
			_unit addItemToBackpack "fow_e_tnt_onepound_mag";
			_unit addItemToUniform "fow_i_fak_uk";
			};
		for "_i" from 1 to 5 do
			{
			_unit addItemToVest "LIB_30Rnd_45ACP";
			};
	};
	case (_unitClass == SASATman): {
		_unit forceAddUniform "fow_u_uk_parasmock";
		_unit addVest "fow_v_uk_para_base";
		_unit addBackpack "B_LIB_US_Backpack_RocketBag";
		_unit addHeadgear "fow_h_uk_beret_sas_2";
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4";
		_unit addMagazine "LIB_1Rnd_60mm_M6";
		_unit addWeapon "LIB_M1A1_Bazooka";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest "LIB_No82";
			};
		for "_i" from 1 to 3 do
			{
			_unit addItemToBackpack "LIB_1Rnd_60mm_M6";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == SASsniper): {
		_unit addWeapon "LIB_Binocular_UK";
		_unit forceAddUniform "fow_u_uk_parasmock";
		_unit addVest "fow_v_uk_para_base";
		_unit addHeadgear "fow_h_uk_beret_sas_2";
		_unit addMagazine "LIB_10Rnd_770x56";
		_unit addWeapon "LIB_LeeEnfield_No4_Scoped";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToUniform "fow_i_fak_uk";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_10Rnd_770x56";
			};
	};
	case (_unitClass == SASSL): {
		_unit addWeapon "LIB_Binocular_UK";
		_unit forceAddUniform "fow_u_uk_parasmock";
		_unit addVest "fow_v_uk_officer";
		_unit addHeadgear "fow_h_uk_beret_sas_2";
		_unit addMagazine "LIB_30Rnd_45ACP";
		_unit addWeapon "LIB_M1A1_Thompson";
		_unit addMagazine "LIB_6Rnd_455";
		_unit addWeapon "LIB_Webley_mk6";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToUniform "LIB_US_M18";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest "fow_e_no69";
			_unit addItemToVest "LIB_6Rnd_455";
			};
		for "_i" from 1 to 5 do
			{
			_unit addItemToVest "LIB_30Rnd_45ACP";
			};
	};
	
	//US Infantry
	case (_unitClass == USUnarmed): {
		_unit forceAddUniform "U_LIB_US_Private";
	};
	case ((_unitClass == USMil) || (_unitClass == USstaticCrewTeamPlayer)): {
		_unit forceAddUniform "U_LIB_US_Private";
		_unit addVest "V_LIB_US_Vest_Garand";
		_unit addHeadgear (selectRandom _USHelmets);
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
	case (_unitClass == USMedic): {
		_unit forceAddUniform "U_LIB_US_Med";
		_unit addVest "V_LIB_US_Vest_Medic";
		_unit addBackpack "B_LIB_US_Backpack";
		_unit addHeadgear (selectRandom ["H_LIB_US_Helmet_Med", "H_LIB_US_Helmet_Med_os"]);
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addItemToBackpack "Medikit";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			_unit addItemToBackpack "fow_i_fak_us";
			_unit addItemToVest "LIB_US_M18_Green";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
	case (_unitClass == USMG): {
		_unit forceAddUniform "U_LIB_US_Private_1st";
		_unit addVest "V_LIB_US_Vest_Bar";
		_unit addHeadgear (selectRandom _USHelmets);
		_unit addMagazine "LIB_20Rnd_762x63";
		_unit addWeapon "LIB_M1918A2_BAR";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_20Rnd_762x63_M1";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_20Rnd_762x63";
			};
	};
	case (_unitClass == USExp): {
		_unit forceAddUniform "U_LIB_US_Eng";
		_unit addVest "V_LIB_US_Vest_Carbine_eng";
		_unit addBackpack "B_LIB_US_Backpack";
		_unit addHeadgear (selectRandom _USHelmets);
		_unit addMagazine "LIB_15Rnd_762x33";
		_unit addWeapon "LIB_M1_Carbine";
		_unit addItemToBackpack "LIB_M3_MINE_mag";
		_unit addItemToBackpack "LIB_US_M1A1_ATMINE_mag";
		_unit addItemToBackpack "fow_e_tnt_onepound_mag";
		_unit addItemToUniform "LIB_US_M18_Yellow";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_15Rnd_762x33";
			};
	};
	case (_unitClass == USGL): {
		_unit forceAddUniform "U_LIB_US_Private_1st";
		_unit addVest "V_LIB_US_Vest_Grenadier";
		_unit addHeadgear (selectRandom _USHelmets);
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addWeaponItem ["LIB_M1_Garand","LIB_ACC_GL_M7"];
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_1Rnd_G_Mk2";
			_unit addItemToVest "LIB_1Rnd_G_Mk2";
			_unit addItemToVest "LIB_1Rnd_G_M9A1";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
	case (_unitClass == USSL): {
		_unit addWeapon "LIB_Binocular_US";
		_unit forceAddUniform "U_LIB_US_Off";
		_unit addVest "V_LIB_US_Vest_Thompson_nco";
		_unit addHeadgear "H_LIB_US_Helmet_Second_lieutenant";
		_unit addMagazine "LIB_30Rnd_45ACP";
		_unit addWeapon "LIB_M1A1_Thompson";
		_unit addMagazine "LIB_7Rnd_45ACP";
		_unit addWeapon "LIB_Colt_M1911";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToUniform "LIB_7Rnd_45ACP";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_30Rnd_45ACP";
			};
	};
	case (_unitClass == USEng): {
		_unit forceAddUniform "U_LIB_US_Eng";
		_unit addVest "V_LIB_US_Vest_Carbine_eng";
		_unit addBackpack "B_LIB_US_Backpack";
		_unit addHeadgear selectRandom _USHelmets;
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addItemToVest "LIB_US_M18_Yellow";
		_unit addItemToBackpack "ToolKit";
		_unit addItemToBackpack "MineDetector";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
		case (_unitClass == USATman): {
		_unit forceAddUniform "U_LIB_US_Private_1st";
		_unit addVest "V_LIB_US_Vest_Carbine";
		_unit addBackpack "B_LIB_US_Backpack_RocketBag";
		_unit addHeadgear (selectRandom _USHelmets);
		_unit addMagazine "LIB_15Rnd_762x33";
		_unit addWeapon "LIB_M1_Carbine";
		_unit addMagazine "LIB_1Rnd_60mm_M6";
		_unit addWeapon "LIB_M1A1_Bazooka";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
			for "_i" from 1 to 3 do
			{
			_unit addItemToBackpack "LIB_1Rnd_60mm_M6";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_15Rnd_762x33";
			};
	};
		case (_unitClass == USsniper): {
		_unit addWeapon "LIB_Binocular_US";
		_unit forceAddUniform "U_LIB_US_Sergeant";
		_unit addVest "V_LIB_US_Vest_Garand";
		_unit addHeadgear (selectRandom _USHelmets);
		_unit addMagazine "LIB_5Rnd_762x63";
		_unit addWeapon "LIB_M1903A4_Springfield";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 12 do
			{
			_unit addItemToVest "LIB_5Rnd_762x63";
			};
	};
	case (_unitClass == USPilot): {
		_unit forceAddUniform "U_LIB_US_Pilot_2";
		_unit addVest "V_LIB_US_LifeVest";
		_unit addBackpack "B_LIB_US_TypeA3";
		_unit addHeadgear "H_LIB_US_Helmet_Pilot_Glasses_Up";
		_unit addMagazine "LIB_7Rnd_45ACP";
		_unit addWeapon "LIB_Colt_M1911";
		_unit addItemToUniform "LIB_US_M18_Yellow";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_7Rnd_45ACP";
			};
	};
		case (_unitClass == USCrew): {
		_unit addWeapon "LIB_Binocular_US";
		_unit forceAddUniform "U_LIB_US_Tank_Crew2";
		_unit addVest "V_LIB_US_Vest_Thompson";
		_unit addHeadgear "H_LIB_US_Helmet_Tank";
		_unit addMagazine "LIB_30Rnd_M3_GreaseGun_45ACP";
		_unit addWeapon "LIB_M3_GreaseGun";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_30Rnd_M3_GreaseGun_45ACP";
			};
	};
	
	//US 82nd Airborne
	case (_unitClass == paraMil): {
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_FC";
		_unit addVest "V_LIB_US_AB_Vest_Garand";
		_unit addHeadgear (selectRandom _USParaHelmets);
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
	case (_unitClass == paraMedic): {
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_Medic_82AB";
		_unit addVest "V_LIB_US_Vest_Medic";
		_unit addBackpack "B_LIB_US_M36_Bandoleer";
		_unit addHeadgear "H_LIB_US_AB_Helmet_Medic_1";
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addItemToBackpack "Medikit";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			_unit addItemToBackpack "fow_i_fak_us";
			_unit addItemToVest "LIB_US_M18_Green";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
	case (_unitClass == paraMG): {
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_FC";
		_unit addVest "V_LIB_US_AB_Vest_M1919";
		_unit addHeadgear (selectRandom _USParaHelmets);
		_unit addMagazine "LIB_50Rnd_762x63";
		_unit addWeapon "LIB_M1919A4";
		_unit addMagazine "LIB_7Rnd_45ACP";
		_unit addWeapon "LIB_Colt_M1911";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToUniform "LIB_7Rnd_45ACP";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 3 do
			{
			_unit addItemToVest "LIB_50Rnd_762x63";
			};
	};
	case (_unitClass == paraExp): {
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_corporal";
		_unit addVest "V_LIB_US_Vest_Carbine_eng";
		_unit addBackpack "B_LIB_US_M36_Bandoleer";
		_unit addHeadgear (selectRandom _USParaHelmets);
		_unit addMagazine "LIB_15Rnd_762x33";
		_unit addWeapon "LIB_M1A1_Carbine";
		_unit addItemToBackpack "LIB_M3_MINE_mag";
		_unit addItemToBackpack "LIB_US_M1A1_ATMINE_mag";
		_unit addItemToBackpack "fow_e_tnt_onepound_mag";
		_unit addItemToUniform "LIB_US_M18_Yellow";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_15Rnd_762x33";
			};
	};
	case (_unitClass == paraGL): {
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_FC";
		_unit addVest "V_LIB_US_AB_Vest_Grenadier";
		_unit addHeadgear (selectRandom _USParaHelmets);
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addWeaponItem ["LIB_M1_Garand","LIB_ACC_GL_M7"];
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_1Rnd_G_Mk2";
			_unit addItemToVest "LIB_1Rnd_G_Mk2";
			_unit addItemToVest "LIB_1Rnd_G_M9A1";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
	case (_unitClass == paraSL): {
		_unit addWeapon "LIB_Binocular_US";
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_Flag";
		_unit addVest "V_LIB_US_AB_Vest_Thompson_nco";
		_unit addHeadgear "H_LIB_US_AB_Helmet_CO_1";
		_unit addMagazine "LIB_30Rnd_45ACP";
		_unit addWeapon "LIB_M1A1_Thompson";
		_unit addMagazine "LIB_7Rnd_45ACP";
		_unit addWeapon "LIB_Colt_M1911";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToUniform "LIB_7Rnd_45ACP";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 4 do
			{
			_unit addItemToVest "LIB_30Rnd_45ACP";
			};
	};
	case (_unitClass == paraEng): {
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_corporal";
		_unit addVest "V_LIB_US_Vest_Carbine_eng";
		_unit addBackpack "B_LIB_US_M36_Bandoleer";
		_unit addHeadgear selectRandom _USParaHelmets;
		_unit addMagazine "LIB_8Rnd_762x63";
		_unit addWeapon "LIB_M1_Garand";
		_unit addItemToVest "LIB_US_M18_Yellow";
		_unit addItemToBackpack "ToolKit";
		_unit addItemToBackpack "MineDetector";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 10 do
			{
			_unit addItemToVest "LIB_8Rnd_762x63";
			};
	};
		case (_unitClass == paraATman): {
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_FC";
		_unit addVest "V_LIB_US_AB_Vest_Carbine";
		_unit addBackpack "B_LIB_US_M36_Rocketbag";
		_unit addHeadgear (selectRandom _USParaHelmets);
		_unit addMagazine "LIB_15Rnd_762x33";
		_unit addWeapon "LIB_M1A1_Carbine";
		_unit addMagazine "LIB_1Rnd_60mm_M6";
		_unit addWeapon "LIB_M1A1_Bazooka";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
			for "_i" from 1 to 2 do
			{
			_unit addItemToBackpack "LIB_1Rnd_60mm_M6";
			};
		for "_i" from 1 to 8 do
			{
			_unit addItemToVest "LIB_15Rnd_762x33";
			};
	};
		case (_unitClass == parasniper): {
		_unit addWeapon "LIB_Binocular_US";
		_unit forceAddUniform "U_LIB_US_AB_Uniform_M43_NCO";
		_unit addVest "V_LIB_US_AB_Vest_Garand";
		_unit addHeadgear (selectRandom _USParaHelmets);
		_unit addMagazine "LIB_5Rnd_762x63";
		_unit addWeapon "LIB_M1903A4_Springfield";
		_unit addItemToUniform "LIB_US_M18";
		for "_i" from 1 to 2 do
			{
			_unit addItemToUniform "fow_i_fak_us";
			_unit addItemToVest "LIB_US_Mk_2";
			};
		for "_i" from 1 to 12 do
			{
			_unit addItemToVest "LIB_5Rnd_762x63";
			};
	};
};

// remove backpack if empty, otherwise squad troops will throw it on the ground
if (backpackItems _unit isEqualTo []) then { removeBackpack _unit };

[4, format["Class %1, type %2, loadout %3", _unitClass, _recruitType, str (getUnitLoadout _unit)], _filename] call A3A_fnc_log;