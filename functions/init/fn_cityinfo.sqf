
private ["_textX","_dataX","_numCiv","_prestigeOPFOR","_prestigeBLUFOR","_power","_busy","_siteX","_positionTel","_garrison"];
positionTel = [];

_popFIA = 0;
_popAAF = 0;
_popCSAT = 0;
_pop = 0;
{
	_dataX = server getVariable _x;
	_numCiv = _dataX select 0;
	_prestigeOPFOR = _dataX select 2;
	_prestigeBLUFOR = _dataX select 3;
	_popFIA = _popFIA + (_numCiv * (_prestigeBLUFOR / 100));
	_popAAF = _popAAF + (_numCiv * (_prestigeOPFOR / 100));
	_pop = _pop + _numCiv;
	if (_x in destroyedSites) then {_popCSAT = _popCSAT + _numCIV};
} forEach citiesX;

_popFIA = round _popFIA;
_popAAF = round _popAAF;

["City Information", format ["%7<br/><br/>Total pop: %1<br/>%6 Support: %2<br/><br/>Murdered Pop: %4<br/><br/>Click on the zone",_pop, _popFIA, _popAAF, _popCSAT,nameOccupants,nameTeamPlayer,worldName]] call A3A_fnc_customHint;

if (!visibleMap) then {openMap true};

onMapSingleClick "positionTel = _pos;";

while {visibleMap} do {
	sleep 1;
	if (count positionTel > 0) then {
		_positionTel = positionTel;
		_siteX = [markersX, _positionTel] call BIS_Fnc_nearestPosition;
		_textX = "Click on the zone";
		_nameFaction = if (sidesX getVariable [_siteX,sideUnknown] == teamPlayer) then {
			nameTeamPlayer
		} else {
			if (sidesX getVariable [_siteX,sideUnknown] == Occupants) then {
				nameOccupants
			} else {
				nameInvaders
			};
		};
		if (_siteX == "Synd_HQ") then {
			_textX = format ["%2 HQ%1",[_siteX] call A3A_fnc_garrisonInfo,nameTeamPlayer];
		};
		if (_siteX in citiesX) then {
			_dataX = server getVariable _siteX;

			_numCiv = _dataX select 0;
			_prestigeOPFOR = round (_dataX select 2);
			_prestigeBLUFOR = round (_dataX select 3);
			_power = [_siteX] call A3A_fnc_getSideRadioTowerInfluence;
			_textX = format ["%1<br/><br/>Pop %2<br/>%7 Support: %4 %5",[_siteX,false] call A3A_fnc_location,_numCiv,_prestigeOPFOR,_prestigeBLUFOR,"%",_nameFaction,nameTeamPlayer];
			_positionX = getMarkerPos _siteX;
			_result = "NONE";
			switch (_power) do {
				case teamPlayer: {_result = format ["%1",nameTeamPlayer]};
				case Occupants: {_result = format ["%1",nameOccupants]};
				case Invaders: {_result = format ["%1",nameInvaders]};
			};

			_textX = format ["%1<br/>Influence: %2",_textX,_result];
			if (_siteX in destroyedSites) then {_textX = format ["%1<br/>DESTROYED",_textX]};
			if (sidesX getVariable [_siteX,sideUnknown] == teamPlayer) then {_textX = format ["%1<br/>%2",_textX,[_siteX] call A3A_fnc_garrisonInfo]};
		};
		if (_siteX in airportsX) then {
			if (not(sidesX getVariable [_siteX,sideUnknown] == teamPlayer)) then {
				_textX = format ["%1 Airport",_nameFaction];
				_busy = [_siteX,true] call A3A_fnc_airportCanAttack;
				if (_busy) then {_textX = format ["%1<br/>Status: Idle",_textX]} else {_textX = format ["%1<br/>Status: Busy",_textX]};
				_garrison = count (garrison getVariable [_siteX, []]);
				if (_garrison >= 40) then {_textX = format ["%1<br/>Garrison: Good",_textX]} else {if (_garrison >= 20) then {_textX = format ["%1<br/>Garrison: Weakened",_textX]} else {_textX = format ["%1<br/>Garrison: Decimated",_textX]}};
			}
			else {
				_textX = format ["%2 Airport%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
			};
		};
		if (_siteX in resourcesX) then {
			if (not(sidesX getVariable [_siteX,sideUnknown] == teamPlayer)) then {
				_textX = format ["%1 Resources",_nameFaction];
				_garrison = count (garrison getVariable [_siteX, []]);
				if (_garrison >= 30) then {_textX = format ["%1<br/>Garrison: Good",_textX]} else {if (_garrison >= 10) then {_textX = format ["%1<br/>Garrison: Weakened",_textX]} else {_textX = format ["%1<br/>Garrison: Decimated",_textX]}};
			}
			else {
				_textX = format ["%2 Resources%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
			};
			if (_siteX in destroyedSites) then {_textX = format ["%1<br/>DESTROYED",_textX]};
		};
		if (_siteX in factories) then {
			if (not(sidesX getVariable [_siteX,sideUnknown] == teamPlayer)) then {
				_textX = format ["%1 Factory",_nameFaction];
				_garrison = count (garrison getVariable [_siteX, []]);
				if (_garrison >= 16) then {_textX = format ["%1<br/>Garrison: Good",_textX]} else {if (_garrison >= 8) then {_textX = format ["%1<br/>Garrison: Weakened",_textX]} else {_textX = format ["%1<br/>Garrison: Decimated",_textX]}};
			}
			else {
				_textX = format ["%2 Factory%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
			};
			if (_siteX in destroyedSites) then {_textX = format ["%1<br/>DESTROYED",_textX]};
		};
		if (_siteX in outposts) then {
			if (not(sidesX getVariable [_siteX,sideUnknown] == teamPlayer)) then {
				_textX = format ["%1 Grand Outpost",_nameFaction];
				_busy = [_siteX,true] call A3A_fnc_airportCanAttack;
				if (_busy) then {_textX = format ["%1<br/>Status: Idle",_textX]} else {_textX = format ["%1<br/>Status: Busy",_textX]};
				_garrison = count (garrison getVariable [_siteX, []]);
				if (_garrison >= 16) then {_textX = format ["%1<br/>Garrison: Good",_textX]} else {if (_garrison >= 8) then {_textX = format ["%1<br/>Garrison: Weakened",_textX]} else {_textX = format ["%1<br/>Garrison: Decimated",_textX]}};
			}
			else {
				_textX = format ["%2 Grand Outpost%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
			};
		};
		if (_siteX in seaports) then {
			if (not(sidesX getVariable [_siteX,sideUnknown] == teamPlayer)) then {
				_textX = format ["%1 Seaport",_nameFaction];
				_garrison = count (garrison getVariable [_siteX, []]);
				if (_garrison >= 20) then {_textX = format ["%1<br/>Garrison: Good",_textX]} else {if (_garrison >= 8) then {_textX = format ["%1<br/>Garrison: Weakened",_textX]} else {_textX = format ["%1<br/>Garrison: Decimated",_textX]}};
			}
			else {
				_textX = format ["%2 Seaport%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
			};
		};
		if (_siteX in milbases) then {
			if (not(sidesX getVariable [_siteX,sideUnknown] == teamPlayer)) then {
				_textX = format ["%1 Military Base",_nameFaction];
				_busy = [_siteX,true] call A3A_fnc_airportCanAttack;
				if (_busy) then {_textX = format ["%1<br/>Status: Idle",_textX]} else {_textX = format ["%1<br/>Status: Busy",_textX]};
				_garrison = count (garrison getVariable [_siteX, []]);
				if (_garrison >= 40) then {_textX = format ["%1<br/>Garrison: Good",_textX]} else {if (_garrison >= 20) then {_textX = format ["%1<br/>Garrison: Weakened",_textX]} else {_textX = format ["%1<br/>Garrison: Decimated",_textX]}};
			}
			else {
				_textX = format ["%2 Military Base%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
			};
		};
		if (_siteX in watchpostsFIA) then {
			_garrison = count (garrison getVariable [_siteX, []]);
			_textX = format ["%1 Watchpost<br/>Garrison men: %2",_nameFaction, _garrison];
		};
		if (_siteX in roadblocksFIA) then {
			_textX = format ["%2 Heavy Roadblock%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
		};
		if (_siteX in aapostsFIA) then {
			_textX = format ["%2 AA Emplacement%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
		};
		if (_siteX in atpostsFIA) then {
			_textX = format ["%2 AT Emplacement%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
		};
		if (_siteX in mortarpostsFIA) then {
			_textX = format ["%2 Artillery Emplacement%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
		};
		if (_siteX in hmgpostsFIA) then {
			_textX = format ["%2 HMG Emplacement%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
		};
		if (_siteX in lightroadblocksFIA) then {
			_textX = format ["%2 Light Roadblock%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
		};
		if (_siteX in supportpostsFIA) then {
		_textX = format ["%2 Support Post%1",[_siteX] call A3A_fnc_garrisonInfo,_nameFaction];
		};
		["City Information", _textX] call A3A_fnc_customHint;
	};
	positionTel = [];
};
onMapSingleClick "";
