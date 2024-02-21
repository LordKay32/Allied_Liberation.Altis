/*
Maintainer: Wurzel0701
    Activates undercover if possible and controls its status till undercover is broken/ended

Arguments:
    <NIL>

Return Value:
    <NIL>

Scope: Local
Environment: Scheduled
Public: Yes
Dependencies:
    <OBJECT> A3A_faction_civ
    <ARRAY> reportedVehs
    <ARRAY> controlsX
    <ARRAY> airportsX
    <ARRAY> milbases
    <ARRAY> outposts
    <ARRAY> seaports
    <ARRAY> undercoverVehicles
    <BOOL> A3A_hasACE
    <SIDE> Occupants
    <STRING> civHeli
    <ARRAY> civBoats
    <SIDE> Invaders
    <ARRAY> detectionAreas
    <NAMESPACE> sidesX
    <SIDE> teamPlayer
    <NUMBER> aggressionOccupants
    <NUMBER> aggressionInvaders
    <NUMBER> tierWar

Example:
    [] call A3A_fnc_goUndercover;
*/

private _fileName = "fn_goUndercover";

private _undercoverType = "";
private _reason = "";
private _voice = speaker player;

if (
	uniform player in wehrmachtUniforms &&
	vest player in wehrmachtVests &&
	headgear player in wehrmachtHelmets &&
	backpack player in (wehrmachtBackpacks + [""]) &&
	primaryWeapon player in (wehrmachtWeapons + [""]) &&
	secondaryWeapon player in (wehrmachtLaunchers + [""]) &&
	handgunWeapon player in (wehrmachtWeapons + [""])
	) then {_undercoverType = "MILITARY"} else {_undercoverType = "CIVILIAN"};


private _result = [_undercoverType] call A3A_fnc_canGoUndercover;

if(!(_result select 0)) exitWith
{
    if((_result select 1) == "Spotted by enemies") then
    {
        if !(isNull (objectParent player)) then
        {
            reportedVehs pushBackUnique (objectParent player);
            publicVariable "reportedVehs";
            {
                if ((isPlayer _x) && (captive _x)) then
                {
                    [_x, false] remoteExec["setCaptive"];
                    _x setCaptive false;
                };
            } forEach ((crew(objectParent player)) + (assignedCargo(objectParent player)) - [player]);
        };
    };
};
	
["Undercover ON", 0, 0, 4, 0, 0, 4] spawn bis_fnc_dynamicText;

[player, true] remoteExec["setCaptive", 0, player];
player setCaptive true;
if (_undercoverType == "MILITARY") then {player setVariable ["militaryUndercover",true,true]};
[] spawn A3A_fnc_statistics;
if (player == leader group player) then
{
    {
        if ((!isplayer _x) && (local _x) && (_x getVariable["owner", _x] == player)) then
        {
            [_x] spawn A3A_fnc_undercoverAI;
        };
    } forEach units group player;
};

switch (_undercoverType) do
{
    case "MILITARY":
    {

		[] spawn {
			private _base = [];
			while {true} do {
				waitUntil {sleep 1; _base = [((airportsX + milbases + outposts + seaports + citiesX) select { sidesX getVariable [_x, sideUnknown] != teamPlayer }), player] call BIS_fnc_nearestPosition; player inArea _base || captive player == false};
				if (captive player == false) exitWith {};
				[_base] spawn A3A_fnc_baseUndercover;

				waitUntil {sleep 1; !(player inArea _base) || captive player == false};
				if (captive player == false) exitWith {};				
			};
		};
		
		player addEventHandler ["FiredMan", {
			params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
			if (_muzzle in [["LIB_US_TNT_4pound_Muzzle","LIB_Ladung_Big_Muzzle","LIB_Ladung_Small_Muzzle","PipeBombMuzzle","LIB_US_M1A1_ATMINE_Muzzle","LIB_M3_Muzzle","LIB_US_M3_Muzzle","LIB_shumine_42_Muzzle","DemoChargeMuzzle","LIB_SMI_35_Muzzle","LIB_SMI_35_1_Muzzle","LIB_TMI_42_Muzzle"]]) then {
				if ({((side _x == Invaders) || (side _x == Occupants)) && (_x knowsAbout player > 3.9)} count allUnits > 0) then {player setCaptive false; player removeEventHandler [_thisEvent, _thisEventHandler]};
			} else {
				player setCaptive false; player removeEventHandler [_thisEvent, _thisEventHandler];
			};
		}];
		
		player setSpeaker "NoVoice";

		while {_reason == ""} do
		{
			private _secureBases = (airportsX + milbases + outposts + seaports + factories + resourcesX) select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
			private _lastBaseInside = [_secureBases, player] call BIS_fnc_nearestPosition;

			private _healingTarget = objNull;
		    if !(isNil {player getVariable "ace_medical_treatment_endInAnim"}) then
		    {
		        _healingTarget = currentAceTarget;
		    };
	
		    sleep 1;
	
		    if (!captive player) exitWith
		    {
		        _reason = "Reported";
		    };

			if ((units group player) findIf {(_x getVariable "unitType") in (alliedTroops - SASTroops)} != -1) exitWith 
			{
				_reason = "NonSAS";
			};
		
			if ((units group player) findIf {(_x getVariable "unitType") in SASTroops} == -1) exitWith 
			{
				_reason = "NoSAS";
			};

			{
	        _unit = _x;
	        if ((!(primaryWeapon _unit in (wehrmachtWeapons + [""]))) || (!(secondaryWeapon _unit in (WehrmachtLaunchers + [""]))) || (!(handgunWeapon _unit in (wehrmachtWeapons + [""]))) || (!(vest _unit in wehrmachtVests)) || (!(backpack _unit in (wehrmachtBackpacks + [""]))) || (!(uniform _unit in wehrmachtUniforms))) exitWith
	        {
	            if ({((side _x == Invaders) or (side _x == Occupants)) and ((_x knowsAbout player > 1.4) or (_x distance player < 350))} count allUnits > 0) then
	            {
	                _reason = "Wclothes2"
	            }
	            else
	            {
	                _reason = "Wclothes"
	            };
	        };
	        } forEach (units group player);

		    private _veh = objectParent player;
		    if !(isNull _veh) then
		    {
		        private _vehType = typeOf _veh;
		        if (!(_vehType in (vehNATONormal + vehNATOAPC))) exitWith
		        {
		            _reason = "VNoWehrmact"
		        };
		
		        if (_veh getVariable ["A3A_reported", false]) exitWith
		        {
		            _reason = "VCompromised"
		        };
		        
		        if ((_veh inArea _lastBaseInside) && !(_veh getVariable ["friendly", false])) exitWith
		        {
		            _reason = "VEnemy"
		        };

		        if(_reason != "") exitWith {};
		
		        if (_vehType isKindOf "Land") then
		        {
		            if (!(isOnRoad position _veh) && {count (_veh nearRoads 50) == 0}) then
		            {
		                if ({((side _x == Invaders) || (side _x == Occupants)) && ((_x knowsAbout player > 1.4) || (_x distance player < 350))} count allUnits > 0) then
		                {
		                    _reason = "Highway";
		                };
		            };
		        };
		    }
		    else
		    {
		        if (_healingTarget != objNull && {side _healingTarget != civilian && {_healingTarget isKindOf "Man"}}) exitWith
		        {
		            if ({((side _x == Invaders) or(side _x == Occupants)) and((_x knowsAbout player > 1.4) or(_x distance player < 350))} count allUnits > 0) then
		            {
		                _reason = "BadMedic2";
		            }
		            else
		            {
		                _reason = "BadMedic";
		            };
		        };
		        if (dateToNumber date < (player getVariable ["compromised", 0])) exitWith
		        {
		            _reason = "Compromised";
		        };
		    };
		    if (_reason != "") exitWith {};
		};	    
	};
	
	case "CIVILIAN":
    {

		private _roadblocks = controlsX select {isOnRoad(getMarkerPos _x)};
		private _secureBases = airportsX + outposts + seaports + milbases + _roadblocks;
		private _isInRoadblock = false;

		while {_reason == ""} do
		{
		    private _healingTarget = objNull;
		    if !(isNil {player getVariable "ace_medical_treatment_endInAnim"}) then
		    {
		        _healingTarget = currentAceTarget;
		    };

		    sleep 1;

		    if (!captive player) exitWith
		    {
		        _reason = "Reported";
		    };

			if ((units group player) findIf {(_x getVariable "unitType") in (alliedTroops - SDKTroops)} != -1) exitWith 
			{
				_reason = "NonSDK";
			};
			
			if ((units group player) findIf {(_x getVariable "unitType") in SDKTroops} == -1) exitWith 
			{
				_reason = "NoSDK";
			};
			
			if ((primaryWeapon player != "") || (secondaryWeapon player != "") || (handgunWeapon player != "") || (vest player != "") || (getNumber(configfile >> "CfgWeapons" >> headgear player >> "ItemInfo" >> "HitpointsProtectionInfo" >> "Head" >> "armor") > 2) || (hmd player != "") || (!(uniform player in (A3A_faction_civ getVariable "uniforms")))) exitWith
        	{
	            if ({((side _x == Invaders) or (side _x == Occupants)) and ((_x knowsAbout player > 1.4) or (_x distance player < 350))} count allUnits > 0) then
       		    {
       		        _reason = "clothes2"
       		    }
       		    else
       		    {
       		        _reason = "clothes"
       		    };
       		};
			
		    private _veh = objectParent player;
		    if !(isNull _veh) then
		    {
		        private _vehType = typeOf _veh;
		        if (!(_vehType in undercoverVehicles)) exitWith
		        {
		            _reason = "VNoCivil"
		        };

		        if (_veh in reportedVehs) exitWith
		        {
		            _reason = "VCompromised"
		        };

		        if (A3A_hasACE) then
		        {
		            if (((position player nearObjects["DemoCharge_Remote_Ammo", 5]) select 0) mineDetectedBy Occupants) exitWith
		            {
		                _reason = "SpotBombTruck";
		            };
		            if (((position player nearObjects["SatchelCharge_Remote_Ammo", 5]) select 0) mineDetectedBy Occupants) exitWith
		            {
		                _reason = "SpotBombTruck";
		            };
		        };

		        if(_reason != "") exitWith {};
	
		        if(_veh getVariable ["NoFlyZoneDetected", ""] != "") exitWith
		        {
		            _reason = "NoFly";
		        };
	
		        if ((_vehType != civHeli) && (!(_vehType in civBoats))) then
		        {
		            if (!(isOnRoad position _veh) && {count (_veh nearRoads 50) == 0}) then
		            {
		                if ({((side _x == Invaders) || (side _x == Occupants)) && ((_x knowsAbout player > 1.4) || (_x distance player < 350))} count allUnits > 0) then
		                {
		                    _reason = "Highway";
		                };
		            };

		            if(_reason != "") exitWith {};

		            private _base = [_secureBases, player] call BIS_fnc_nearestPosition;
		            private _onDetectionMarker = (detectionAreas findIf {player inArea _x} != -1);
		            private _onBaseMarker = (player inArea _base);
		            private _baseSide = (sidesX getVariable [_base, sideUnknown]);
		            if ((_onBaseMarker || _onDetectionMarker) && (_baseSide != teamPlayer)) then
		            {
		                if !(_isInRoadblock) then
		                {
		                    private _aggro = if (_baseSide == Occupants) then {aggressionOccupants + (tierWar * 10)} else {aggressionInvaders + (tierWar * 10)};
		                    //Probability of being spotted. Unless we're in an any "military" type outpost - then we're always spotted.
		                    if (_base in (airportsX + milbases + outposts + seaports) || _onDetectionMarker || random 100 < _aggro) then
		                    {
		                        if (_base in _roadblocks) then
		                        {
		                            _reason = "distanceX";
		                        }
		                        else
		                        {
		                            _reason = "Control";
		                        };
		                    }
		                    else
		                    {
		                        _isInRoadblock = true;
		                    };
		                };
		            }
		            else
		            {
		                _isInRoadblock = false;
		            };
		        };
		    }
		    else
		    {
		        if (_healingTarget != objNull && {side _healingTarget != civilian && {_healingTarget isKindOf "Man"}}) exitWith
		        {
		            if ({((side _x == Invaders) or(side _x == Occupants)) and((_x knowsAbout player > 1.4) or(_x distance player < 350))} count allUnits > 0) then
		            {
		                _reason = "BadMedic2";
		            }
		            else
		            {
		                _reason = "BadMedic";
		            };
		        };
        		if (dateToNumber date < (player getVariable ["compromised", 0])) exitWith
        		{
        		    _reason = "Compromised";
        		};
		    };
		};
	};
};

if (captive player) then
{
    [player, false] remoteExec["setCaptive"];
    player setCaptive false;
    if (speaker player == "NoVoice") then {player setSpeaker _voice};
};

if !(isNull (objectParent player)) then
{
    {
        if (isPlayer _x) then
        {
            [_x, false] remoteExec["setCaptive", 0, _x];
            _x setCaptive false;
        }
    } forEach((assignedCargo(vehicle player)) + (crew(vehicle player)) - [player]);
};

["Undercover OFF", 0, 0, 4, 0, 0, 4] spawn bis_fnc_dynamicText;
[] spawn A3A_fnc_statistics;

switch (_reason) do
{
    case "Reported":
    {
        ["Undercover", "You have been reported by the enemy!"] call A3A_fnc_customHint;
        if (vehicle player != player) then
        {
            reportedVehs pushBackUnique (objectParent player);
            publicVariable "reportedVehs";
        }
        else
        {
            player setVariable["compromised", (dateToNumber[date select 0, date select 1, date select 2, date select 3, (date select 4) + 30])];
        };
    };
    case "NonSAS":
    {
        ["Undercover", "You have non SAS units in your group!"] call A3A_fnc_customHint;
    };
    case "NonSDK":
    {
        ["Undercover", "You have non partizan units in your group!"] call A3A_fnc_customHint;
    };
    case "NoSAS":
    {
        ["Undercover", "You have no SAS units in your group!"] call A3A_fnc_customHint;
    };
    case "NoSDK":
    {
        ["Undercover", "You have no partizan units in your group!"] call A3A_fnc_customHint;
    };
    case "VNoWehrmact":
    {
        ["Undercover", "You entered a non Wehrmacht vehicle!"] call A3A_fnc_customHint;
    };
    case "VEnemy":
    {
        ["Undercover", "You cannot get into any other than your own vehicle on an enemy base!"] call A3A_fnc_customHint;
    };
    case "Wclothes":
    {
        ["Undercover", "You or units in your group have non Wehrmacht gear equipped!"] call A3A_fnc_customHint;
    };
    case "Wclothes2":
    {
        ["Undercover", "You or units in your group have non Wehrmacht gear equipped!"] call A3A_fnc_customHint;
    };
    case "VNoCivil":
    {
        ["Undercover", "You entered a non civilian vehicle!"] call A3A_fnc_customHint;
    };
    case "VCompromised":
    {
        ["Undercover", "You entered a reported vehicle!"] call A3A_fnc_customHint;
    };
    case "SpotBombTruck":
    {
        ["Undercover", "Explosives have been spotted on your vehicle!"] call A3A_fnc_customHint;
        reportedVehs pushBackUnique (objectParent player);
        publicVariable "reportedVehs";
    };
    case "Highway":
    {
        ["Undercover", "You went too far away from any roads and have been spotted!"] call A3A_fnc_customHint;
        reportedVehs pushBackUnique (objectParent player);
        publicVariable "reportedVehs";
    };
    case "clothes":
    {
        ["Undercover", "You cannot stay Undercover while:<br/><br/>A weapon is visible<br/>Wearing a vest<br/>Wearing a helmet<br/>Wearing NVGs<br/>Wearing a mil uniform!"] call A3A_fnc_customHint;
    };
    case "clothes2":
    {
        ["Undercover", "You cannot stay Undercover while showing:<br/><br/>A weapon is visible<br/>Wearing a vest<br/>Wearing a helmet<br/>Wearing NVGs<br/>Wearing a mil uniform<br/><br/>The enemy added you to their Wanted List!"] call A3A_fnc_customHint;
        player setVariable["compromised", dateToNumber[date select 0, date select 1, date select 2, date select 3, (date select 4) + 30]];
    };
    case "BadMedic":
    {
        ["Undercover", "You cannot stay Undercover while healing a compromised Allied soldier!"] call A3A_fnc_customHint;
    };
    case "BadMedic2":
    {
        ["Undercover", "You cannot stay Undercover while healing a compromised Allied soldier<br/><br/>The enemy added you to their Wanted List!"] call A3A_fnc_customHint;
        player setVariable["compromised", dateToNumber[date select 0, date select 1, date select 2, date select 3, (date select 4) + 30]];
    };
    case "Compromised":
    {
        ["Undercover", "You left your vehicle and you are still on the Wanted List!"] call A3A_fnc_customHint;
    };
    case "distanceX":
    {
        ["Undercover", "You have gotten too close to an enemy Base, Outpost or Roadblock!"] call A3A_fnc_customHint;
        if !(isNull objectParent player) then
        {
            reportedVehs pushBackUnique (objectParent player);
            publicVariable "reportedVehs";
        }
        else
        {
            player setVariable["compromised", (dateToNumber[date select 0, date select 1, date select 2, date select 3, (date select 4) + 30])];
        };
    };
    case "NoFly":
    {
        private _veh = objectParent player;
        private _detectedBy = _veh getVariable "NoFlyZoneDetected";
        ["Undercover", format ["You have violated the airspace of %1!", [_detectedBy] call A3A_fnc_localizar]] call A3A_fnc_customHint;
        reportedVehs pushBackUnique _veh;
        publicVariable "reportedVehs";
        _veh setVariable ["NoFlyZoneDetected", nil, true];
    };
    case "Control":
    {
        ["Undercover", "The Installation Garrison has recognised you!"] call A3A_fnc_customHint;
        reportedVehs pushBackUnique(vehicle player);
        publicVariable "reportedVehs";
    };
    default
    {
        [3, format ["Unknown reason given, was %1", _reason], _fileName] call A3A_fnc_log;
        ["Undercover", "Unknown error occured in undercover execution routine!"] call A3A_fnc_customHint;
    };
};
