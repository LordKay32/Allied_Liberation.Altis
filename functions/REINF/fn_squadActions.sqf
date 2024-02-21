if (count hcSelected player == 0) exitWith {["Squad Actions", "You must select one group on the HC bar."] call A3A_fnc_customHint;};

private ["_groupX","_veh","_textX","_unitsX","_cargoArray"];

if (_this select 0 == "hold") exitWith {
	{	
	if (combatMode _x != "GREEN") then {_x setCombatMode "GREEN"} else {_x setCombatMode "YELLOW"};
	} forEach hcSelected player;
};

if (_this select 0 == "flee") exitWith {
	{
	_x allowFleeing 1;
	} forEach hcSelected player;
};

if (_this select 0 == "waypoint") exitWith {
	if (count hcSelected player > 1) exitWith {["Squad Actions", "Select only one group on the HC bar."] call A3A_fnc_customHint;};
	private _groupX = hcSelected player select 0;
	if !(typeOf assignedVehicle (leader _groupX) in ["LIB_C47_Skytrain","LIB_C47_RAF","LIB_LCM3_Armed","LIB_LCVP"]) exitWith {["Squad Actions", "Select a transport plane group or landing craft group."] call A3A_fnc_customHint;};
	
	private _paras = [];
	private _nonParas = [];
	private _numNonParas = 0;
	if (typeOf assignedVehicle (leader _groupX) in ["LIB_C47_Skytrain","LIB_C47_RAF"]) then {
		_veh = vehicle (leader _groupX);
		private _unitsInCargo = (crew _veh) - ([driver _veh]) - ([_veh turretUnit [0]]);
		{
		if ((_x getVariable "unitType") in (SASTroops + paraTroops)) then {
			_paras pushBack _x;
		} else {
			_nonParas pushBack _x;
		};
		if (isPlayer _x) then {_paras pushBackUnique _x};
		} forEach _unitsInCargo;

		_numNonParas = count _nonParas;
		
		_numWPs = count	(waypoints _groupX);	

		["Paradrop", "Select the paradrop waypoint, use Right Ctrl + LMB to designate."] call A3A_fnc_customHint;
		_veh flyInHeight 250;
		waitUntil {sleep 0.5; ((count (waypoints _groupX) > _numWPs) or (not visiblemap))};

		if (!visibleMap) exitWith {["Paradrop", "Paradrop canceled."] call A3A_fnc_customHint;};
	
		private _wpPos = waypointPosition [_groupX, _numWPs];
	
		private _paraMarker = createMarker [format ["paradrop%1", random 1000], _wpPos];
		_paraMarker setMarkerType "plp_icon_parachute";
		_paraMarker setMarkerColor colorTeamPlayer;
		waitUntil {sleep 1; ((_veh distance2D _wpPos < 100) or (!alive _veh))} ;
		
		if (_veh distance2D _wpPos < 100) then {
			[_groupX, _paraMarker, _wpPos, _paras, _numNonParas] execVM "functions\AI\paraAmphib.sqf";	
		};
		if (!alive _veh) exitWith {["Paradrop", "Transport destroyed, paradrop canceled."] call A3A_fnc_customHint; deleteMarker _paraMarker};
	
	} else {
		_veh = vehicle (leader _groupX);
		_numWPs = count	(waypoints _groupX);	

		["Amphibious Landing", "Select the amphibious landing waypoint, use Ctrl LMB to designate."] call A3A_fnc_customHint;
				waitUntil {sleep 0.5; ((count (waypoints _groupX) > _numWPs) or (not visiblemap))};

		if (!visibleMap) exitWith {["Amphibious Landing", "Amphibious landing canceled."] call A3A_fnc_customHint;};
	
		private _wpPos = waypointPosition [_groupX, _numWPs];
	
		private _amphibMarker = createMarker [format ["amphib%1", random 1000], _wpPos];
		_amphibMarker setMarkerType "LIB_hd_pickup";
		_amphibMarker setMarkerColor colorTeamPlayer;
		waitUntil {sleep 1; ((_veh distance2D _wpPos < 100) or (!alive _veh))} ;
		
		if (_veh distance2D _wpPos < 100) then {
			[_groupX, _amphibMarker, _wpPos, _paras, _numNonParas] execVM "functions\AI\paraAmphib.sqf";	
		
			if (!alive _veh) exitWith {["Amphibious Landing", "Transport destroyed, Amphibious landing canceled."] call A3A_fnc_customHint; deleteMarker _amphibMarker};
		};
	};
};

if (_this select 0 == "path") exitWith {
	{
		_group = _x;
		if (units _group findIf {_x checkAIFeature "PATH" == false} != -1) then {
			{_x enableAI "PATH"} forEach units _group;
			["Group Movement", "Movement Enabled"] call A3A_fnc_customHint;
		} else {
			if (vehicle (leader _group) == leader _group) then {leader _group disableAI "PATH"} else {{_x disableAI "PATH"} forEach units _group};
			["Group Movement", "Movement Disabled"] call A3A_fnc_customHint;
		};
	} forEach hcSelected player;
};
