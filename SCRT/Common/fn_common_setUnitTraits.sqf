/*
Author: Barbolani, DoomMetal, MeltedPixel, Bob-Murphy, Wurzel0701, Socrates
    Sets the units traits (camouflage, medic, engineer) for the selected role of the player
    THIS FUNCTION DEPENDS ON ONLY THE DEFAULT COMMANDER HAVING A ROLE DESCRIPTION!

Arguments:
    <NULL>

Return Value:
    <NULL>

Scope: Local
Environment: Any
Public: No
Dependencies:
    <NULL>

Example:
    [] spawn SCRT_fnc_common_setUnitTraits;
*/

private _type = typeOf player;
private _text = "";
if (roleDescription player == "Commander") then {
    player setUnitTrait ["camouflageCoef",1];
    player setUnitTrait ["audibleCoef",1];
    player setUnitTrait ["loadCoef",1];
    _text = "Commander role.<br/><br/>The commander is a unit with the access to exclusive Commander Menu (CTRL+T). Additional high command squads can be recruited and given orders by the commander.";
	player addEventHandler ["SlotItemChanged", {
		params ["_unit", "_name", "_slot", "_assigned"];
    	if (uniform _unit in ["U_LIB_UK_P37","U_LIB_UK_P37_LanceCorporal","U_LIB_UK_P37_Sergeant","U_LIB_UK_DenisonSmock","fow_u_uk_bd40_commando_01_private","fow_u_uk_parasmock"]) then {
    		player setSpeaker "Male04ENGB";
    	} else {
			player setSpeaker "Male03ENG";
		};
	}];
}
else
{
    switch (_type) do
    {
    	case typePetros: {player setUnitTrait ["UAVHacker",true]};
    	//cases for greenfor missions
    	
    	case "LIB_UK_Officer":  {
    		if ((roleDescription player == "UK Officer (Medic)") || (roleDescription player == "US Officer (Medic)")) then {
    			if (roleDescription player == "UK Officer (Medic)") then {player setSpeaker "Male02ENGB"};
    			if (roleDescription player == "US Officer (Medic)") then {player setSpeaker "Male01ENG"};
    			_text = "Medic role.<br/><br/>Medics do not have any bonus or penalties, but have the ability to use certain medical items for full health restoration.";
    			player setUnitTrait ["Medic",true];
    		}; 
    		if ((roleDescription player == "UK Officer (Engineer)") || (roleDescription player == "US Officer (Engineer)")) then  {
    			if (roleDescription player == "UK Officer (Engineer)") then {
    				player setSpeaker "Male01ENGB";
    			};
    			if (roleDescription player == "US Officer (Engineer)") then {
    				player setSpeaker "Male11ENG";
    			};
    			player setUnitTrait ["Engineer",true];
    			player setUnitTrait ["ExplosiveSpecialist",true];
    			player setUnitTrait ["audibleCoef",1.15];
    			player setUnitTrait ["camouflageCoef",1.15];
    			player setUnitTrait ["loadCoef",0.8];
    			_text = "Engineer role.<br/><br/>Engineers have a bonus to carrying capacity but a decrease to stealth, and have the ability to repair vehicles and defuse mines.";
    		};;
    	};
	};
};

if (isDiscordRichPresenceActive) then {
	if(player != theBoss) then {
		private _roleName = getText (configFile >> "CfgVehicles" >> _type >> "displayName");
		[["UpdateDetails", _roleName]] call SCRT_fnc_misc_updateRichPresence;
	} else {
		[["UpdateDetails", format ["%1 Commander", nameTeamPlayer]]] call SCRT_fnc_misc_updateRichPresence;
	};
};

player addEventHandler ["GetInMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	if (typeOf _vehicle in [vehUSPayloadPlane, vehUKPayloadPlane, vehSDKPlaneUK1, vehSDKPlaneUK2, vehSDKPlaneUK3, vehSDKPlaneUS1, vehSDKPlaneUS2, vehSDKPlaneUS3, vehSDKTransPlaneUK, vehSDKTransPlaneUS]) then {
		setViewDistance 8000;
		setObjectViewDistance [4000,50];
	};
}];

player addEventHandler ["GetOutMan", {
	params ["_unit", "_role", "_vehicle", "_turret", "_isEject"];
		if (typeOf _vehicle in [vehUSPayloadPlane, vehUKPayloadPlane, vehSDKPlaneUK1, vehSDKPlaneUK2, vehSDKPlaneUK3, vehSDKPlaneUS1, vehSDKPlaneUS2, vehSDKPlaneUS3, vehSDKTransPlaneUK, vehSDKTransPlaneUS]) then {
		setViewDistance 3200;
		setObjectViewDistance [2000,50];
	};
}];

["Unit Traits", format ["You have selected %1.",_text]] call A3A_fnc_customHint;