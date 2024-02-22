//Define results for small intel
#define TIME_LEFT       101
#define DECRYPTION_KEY  102
#define GARRISON        103
#define REVEAL_MAP		104


//Define results for medium intel
#define CONVOYS         201
#define CONVOY_ROUTE    202

//Define results for large intel
#define MONEY           301

//Define results for (mostly) any intel
#define TASK          500
#define DISCOUNT      501

params ["_intelType", "_side"];

/*  Selects, creates and executes the intel of the given type and side
*   Params:
*       _intelType : STRING : One of "Small", "Medium" or "Large"
*       _side : SIDE : The enemy side, which the intel belongs to
*
*   Returns:
*       _text : STRING : The text of the selected intel
*/

private _fileName = "selectIntel";
if(isNil "_intelType") exitWith
{
    [1, "No intel type given!", _fileName] call A3A_fnc_log;
};
if(isNil "_side") exitWith
{
    [1, "No side given!", _fileName] call A3A_fnc_log;
};

private _text = "";
private _sideName = "";
private _intelContent = "";
if(_side == Occupants) then
{
    _sideName = nameOccupants
}
else
{
    _sideName = nameInvaders
};

if(_intelType == "Small") then
{
    _intelContent = selectRandomWeighted [REVEAL_MAP, 0.15, TIME_LEFT, 0.15, DECRYPTION_KEY, 0.15, GARRISON, 0.15, TASK, 0.4];

    switch (_intelContent) do
    {
    	case (REVEAL_MAP):
        {
            _selectedMarker = selectRandom (baseMarkersX select {markerAlpha _x == 0});
            
			if !(isNil "_selectedMarker") then {           
	            _selectedMarker setMarkerAlpha 1;
	          	_text = format ["We have discovered the location of a %1 base!", _sideName];	
          	
	          	{
					if (getMarkerPos _x inArea _selectedMarker) then {
						_x setMarkerAlpha 1;
					};
				} forEach mrkAntennas;
	          
				[_selectedMarker] spawn {
					_selectedMarker = _this select 0;
					_num = round random 1000;
					_task = format ["Task_%1", _num];
					[[teamPlayer, civilian], _task, ["", "New Wehrmacht base discovered", ""], objNull, "ASSIGNED", 2, true] call BIS_fnc_taskCreate;
					[_task,"SUCCEEDED", true] call BIS_fnc_taskSetState;
					
					private _circleMrk = createMarker [format ["MrkCircle_%1", _num], (getMarkerPos _selectedMarker)];
					_circleMrk setMarkerShape "ICON";
					_circleMrk setMarkerType "mil_circle";
					_circleMrk setMarkerSize [1.5, 1.5];		
	
					_time = time + 30;
					while {true} do {
						_circleMrk setMarkerColor "ColorYellow";
						sleep 1;
						_circleMrk setMarkerColor "colorBLUFOR";
						sleep 1;
						if (time > _time) exitWith {deleteMarker _circleMrk, [_task] call BIS_fnc_deleteTask};
					};
				};
			} else {  
        		_intelPts = server getVariable "intelPoints";
				private _intel = (round (random [20, 25, 30]));
    	      	_text = format ["We have gained some intelligence information, %1 intel points addedd.", _intel];
    	      	server setVariable ["intelPoints", _intelPts + _intel, true];
    	      	[] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
    	    };
        };
        case (TIME_LEFT):
        {
            private _nextAttack = 0;
            if(_side == Occupants) then
            {
                _nextAttack = attackCountdownOccupants + (random 600) - 300;
            }
            else
            {
                _nextAttack = attackCountdownInvaders + (random 600) - 300;
            };
            private _sideName = if (_side == Occupants) then {nameOccupants} else {nameInvaders};
            if(_nextAttack < 300) then
            {
                _text = format ["%1 attack is imminent!", _sideName];
            }
            else
            {
                _text = format ["%1 attack expected in %2 minutes", _sideName, round (_nextAttack / 60)];
            };
        };
        case (DECRYPTION_KEY):
        {
            if(_side == Occupants) then
            {
                occupantsRadioKeys = occupantsRadioKeys + 1;
                publicVariable "occupantsRadioKeys";
            }
            else
            {
                invaderRadioKeys = invaderRadioKeys + 1;
                publicVariable "invaderRadioKeys";
            };
            _text = format ["You found a %1 radio decryption key!<br/>It allows you to fully decrypt the next %1 support call.", _sideName];
        };
        case (GARRISON):
        {
        	private _sideColor = if (_side == Occupants) then {colorOccupants} else {colorInvaders};
			private _enemyMarkers = baseMarkersX select {markerColor _x == _sideColor && markerAlpha _x == 1};
			private _selectedMarker = selectRandom _enemyMarkers;
			
			if !(isNil "_selectedMarker") then {
				private _markerX = [markersX, getMarkerPos _selectedMarker] call BIS_fnc_nearestPosition;
				private _garrison = garrison getVariable [_markerX,[]];
				private _garrCount = count _garrison;
				private _nameDest = [_markerX] call A3A_fnc_localizar;
				
				_text = format ["We have obtained some garrison information, the %1 has a garrison of %2 men.", _nameDest, _garrCount];
			} else {
				_intelPts = server getVariable "intelPoints";
				private _intel = (round (random [20, 25, 30]));
    	      	_text = format ["We have gained some intelligence information, %1 intel points addedd.", _intel];
    	      	server setVariable ["intelPoints", _intelPts + _intel, true];
    	      	[] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
			};
        };
        case (TASK):
        {  
        	_intelPts = server getVariable "intelPoints";
			private _intel = (round (random [20, 25, 30]));
            _text = format ["We have gained some intelligence information, %1 intel points addedd.", _intel];
            server setVariable ["intelPoints", _intelPts + _intel, true];
            [] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
        };
    };
};
if(_intelType == "Medium") then
{
    _intelContent = selectRandomWeighted [CONVOYS, 0.5, TASK, 0.5];

    switch (_intelContent) do
    {
        case (CONVOYS):
        {
            if (!("CONVOY" in A3A_activeTasks) && !bigAttackInProgress) then
			{
                private _potentials = (outposts + milbases + airportsX + seaports);
	            _potentials = _potentials select { sidesX getVariable [_x, sideUnknown] != teamPlayer };
                private _site = [_potentials, petros] call BIS_fnc_nearestPosition;
                private _possibleBases = (airportsX + milbases) select {sidesX getVariable [_x, sideUnknown] != teamPlayer};
                _possibleBases = _possibleBases select {[_x] call A3A_fnc_isFrontline == false};
				private _base = [_site, _possibleBases] call A3A_fnc_findBasesForConvoy;
                private _fromName = [_base] call A3A_fnc_localizar;
                private _toName = [_site] call A3A_fnc_localizar;
                if (_base != "") then {
                	_text = format ["We found some information about possible convoy route from %1 to %2. We can prepare an ambush on it.", _fromName, _toName];
					[[_site,_base, "", -1, true],"A3A_fnc_convoy"] call A3A_fnc_scheduler;
				} else {
                	_worldName = [] call SCRT_fnc_misc_getWorldName;
                	private _money = (round (random [20, 35, 50]) * 100);
                	_text = format ["We found some intelligence on %1 operations in Europe, we have transferred it to Allied high command. %2 command points received.", _sideName, _money];
                	[0, _money, 0] remoteExec ["A3A_fnc_resourcesFIA",2]; 
				};
			} else {
                _worldName = [] call SCRT_fnc_misc_getWorldName;
                private _money = (round (random [20, 35, 50]) * 100);
                _text = format ["We found some intelligence on %1 operations in Europe, we have transferred it to Allied high command. %2 command points received.", _sideName, _money];
                [0, _money, 0] remoteExec ["A3A_fnc_resourcesFIA",2];    
            };
        };
        case (TASK):
        {
			if ((random 100 < 75) || (count A3A_activeTasks > 2)) then {
	        	_intelPts = server getVariable "intelPoints";
				private _intel = (round (random [40, 50, 60]));
	            _text = format ["We have gained some intelligence information, %1 intel points added.", _intel];
	            server setVariable ["intelPoints", _intelPts + _intel, true];
	            [] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
			} else {
				_text = format ["We have gained intelligence on %1 activities occuring on Altis. A mission has been tasked.", _sideName];
				[] spawn A3A_fnc_missionRequest;
			};
        };
    };
};
if(_intelType == "Large") then
{
	_intelContent = selectRandomWeighted [MONEY, 0.5, TASK, 0.5];

    switch (_intelContent) do
    {
        case (MONEY):
        {
            private _money = ((round (random [20, 35, 50])) + (10 * tierWar)) * 100;
            _text = format ["We found radio protocols on %1 communications throughout Europe, we have transferred it to Allied high command. %2 command points received.", _sideName, _money];
            [0, _money, 0] remoteExec ["A3A_fnc_resourcesFIA",2];
        };
        case (TASK):
        {
			if ((random 100 < 50) || (count A3A_activeTasks > 2)) then {
	        	_intelPts = server getVariable "intelPoints";
				private _intel = (round (random [80, 100, 120]));
	            _text = format ["We have gained some significant intelligence information, %1 intel points added.", _intel];
	            server setVariable ["intelPoints", _intelPts + _intel, true];
				[] remoteExec ["A3A_fnc_statistics",[teamPlayer,civilian]];
			} else {
				_text = format ["We have gained valuable intelligence on %1 activities occuring on Altis. Missions have been tasked.", _sideName];
				[] spawn A3A_fnc_missionRequest;
				sleep 8;
				[] spawn A3A_fnc_missionRequest;
			};
        };
    };
};

_text;
