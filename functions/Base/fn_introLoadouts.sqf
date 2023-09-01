/*
 * Name:	fn_introLoadouts
 * Date:	30/08/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * %DESCRIPTION%
 *
 * Parameter(s):
 * _PARAM1 (TYPE): DESCRIPTION.
 * _PARAM2 (TYPE): DESCRIPTION.
 *
 * Returns:
 * %RETURNS%
 */


private _description = roleDescription player;
switch (_description) do
    {
    	case "Commander": {
    		player addWeapon "LIB_Binocular_UK";
			player forceAddUniform "U_LIB_UK_P37";
			player addVest "V_LIB_UK_P37_Officer";
			player addBackpack "B_LIB_UK_HSack";
			player addHeadgear "H_LIB_UK_Helmet_Mk2";
			player addMagazine "LIB_10Rnd_770x56";
			player addWeapon "LIB_LeeEnfield_No4";
			player addMagazine "LIB_6Rnd_455";
			player addWeapon "LIB_Webley_mk6";
			player addMagazine "LIB_1Rnd_89m_PIAT";
			player addWeapon "LIB_PIAT";
			player addItemToUniform "LIB_US_M18";
			for "_i" from 1 to 2 do
			{
				player addItemToUniform "fow_i_fak_uk";
				player addItemToVest "LIB_6Rnd_455";
				player addItemToVest "LIB_MillsBomb";
			};
			for "_i" from 1 to 3 do
				{
				player addItemToBackpack "LIB_1Rnd_89m_PIAT";
				};
			for "_i" from 1 to 8 do
				{
				player addItemToVest "LIB_10Rnd_770x56";
				};
    	};
		
		case "UK Officer (Medic)": {
			player addWeapon "LIB_Binocular_UK";
			player forceAddUniform "U_LIB_UK_P37";
			player addVest "V_LIB_UK_P37_Officer";
			player addBackpack "B_LIB_UK_HSack";
			player addHeadgear "H_LIB_UK_Helmet_Mk2";
			player addMagazine "LIB_10Rnd_770x56";
			player addWeapon "LIB_LeeEnfield_No4";
			player addMagazine "LIB_6Rnd_455";
			player addWeapon "LIB_Webley_mk6";
			player addMagazine "LIB_1Rnd_89m_PIAT";
			player addWeapon "LIB_PIAT";
			player addItemToUniform "LIB_US_M18";
			for "_i" from 1 to 2 do
				{
				player addItemToUniform "fow_i_fak_uk";
				player addItemToVest "LIB_6Rnd_455";
				player addItemToVest "LIB_MillsBomb";
				};
			for "_i" from 1 to 3 do
				{
				player addItemToBackpack "LIB_1Rnd_89m_PIAT";
				};
			for "_i" from 1 to 8 do
				{
				player addItemToVest "LIB_10Rnd_770x56";
				};
		};
		
		case "UK Officer (Engineer)": {
			player addWeapon "LIB_Binocular_UK";
			player forceAddUniform "U_LIB_UK_P37";
			player addVest "V_LIB_UK_P37_Heavy";
			player addBackpack "B_LIB_UK_HSack";
			player addHeadgear "H_LIB_UK_Helmet_Mk2";
			player addMagazine "LIB_30Rnd_770x56";
			player addWeapon "LIB_Bren_Mk2";
			player addMagazine "LIB_6Rnd_455";
			player addWeapon "LIB_Webley_mk6";
			player addItemToUniform "LIB_US_M18";
			player addItemToBackpack "ToolKit";
			for "_i" from 1 to 2 do
				{
				player addItemToUniform "fow_i_fak_uk";
				player addItemToVest "LIB_6Rnd_455";
				};
			for "_i" from 1 to 4 do {
				player addItemToVest "LIB_30Rnd_770x56";
				player addItemToBackpack "LIB_30Rnd_770x56";
			};
		};
		
		case "US Officer (Medic)": {
			player addWeapon "LIB_Binocular_US";
			player forceAddUniform "U_LIB_US_Off";
			player addVest "V_LIB_US_Vest_Carbine_nco";
			player addBackpack "B_LIB_US_Backpack_RocketBag";
			player addHeadgear "H_LIB_US_Helmet_Second_lieutenant";
			player addMagazine "LIB_15Rnd_762x33";
			player addWeapon "LIB_M1_Carbine";
			player addMagazine "LIB_7Rnd_45ACP";
			player addWeapon "LIB_Colt_M1911";
			player addMagazine "LIB_1Rnd_60mm_M6";
			player addWeapon "LIB_M1A1_Bazooka";
			player addItemToUniform "LIB_US_M18";
			for "_i" from 1 to 2 do
				{
				player addItemToUniform "fow_i_fak_us";
				player addItemToUniform "LIB_7Rnd_45ACP";
				player addItemToVest "LIB_US_Mk_2";
				};
				for "_i" from 1 to 3 do
				{
				player addItemToBackpack "LIB_1Rnd_60mm_M6";
				};
			for "_i" from 1 to 8 do
				{
				player addItemToVest "LIB_15Rnd_762x33";
				};
		};
		
		case "US Officer (Engineer)": {
			player addWeapon "LIB_Binocular_US";
			player forceAddUniform "U_LIB_US_Off";
			player addVest "V_LIB_US_Vest_Garand";
			player addHeadgear "H_LIB_US_Helmet_Second_lieutenant";
			player addMagazine "LIB_5Rnd_762x63";
			player addWeapon "LIB_M1903A4_Springfield";
			player addMagazine "LIB_7Rnd_45ACP";
			player addWeapon "LIB_Colt_M1911";
			player addItemToUniform "LIB_US_M18";
			for "_i" from 1 to 2 do
				{
				player addItemToUniform "fow_i_fak_us";
				player addItemToUniform "LIB_7Rnd_45ACP";
				player addItemToVest "LIB_US_Mk_2";
				};
			for "_i" from 1 to 12 do
				{
				player addItemToVest "LIB_5Rnd_762x63";
				};
		};
};