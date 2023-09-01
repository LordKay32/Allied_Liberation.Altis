private ["_hr","_resourcesFIA","_hrT","_resourcesFIAT"];
waitUntil {!resourcesIsChanging};
resourcesIsChanging = true;
_hr = _this select 0;
_resourcesFIA = _this select 1;
_unitType = _this select 2;
if (isNil "_resourcesFIA") then {diag_log "Tienes algún costs sin definit en las tablas de FIA"};
if ((isNil "_hr") or (isNil "_resourcesFIA")) exitWith {resourcesIsChanging = false};
if ((floor _resourcesFIA == 0) and (floor _hr == 0)) exitWith {resourcesIsChanging = false};

if (_unitType isEqualType []) then {
	private _UKhr = server getVariable "UKhr";
	private _UShr = server getVariable "UShr";
	private _SAShr = server getVariable "SAShr";
	private _parahr = server getVariable "parahr";
	private _SDKhr = server getVariable "SDKhr";
	{
		if (_x in UKTroops) then {_UKhr = _UKhr + (1 * (_hr/abs _hr))};
		if (_x in USTroops) then {_UShr = _UShr + (1 * (_hr/abs _hr))};
		if (_x in SASTroops) then {_SAShr = _SAShr + (1 * (_hr/abs _hr))};
		if (_x in paraTroops) then {_parahr = _parahr + (1 * (_hr/abs _hr))};
		if (_x in SDKTroops) then {_SDKhr = _SDKhr + (1 * (_hr/abs _hr))};
	} forEach _unitType;
	server setVariable ["UKhr", _UKhr, true];
	server setVariable ["UShr", _UShr, true];
	server setVariable ["SAShr", _SAShr, true];
	server setVariable ["parahr", _parahr, true];
	server setVariable ["SDKhr", _SDKhr, true];	

} else {

	switch (true) do {
	
		case (_unitType in UKTroops) : {
		_hrT = server getVariable "UKhr";
		};

		case (_unitType in SASTroops) : {
		_hrT = server getVariable "SAShr";
		};

		case (_unitType in USTroops) : {
		_hrT = server getVariable "UShr";
		};
	
		case (_unitType in paraTroops) : {
		_hrT = server getVariable "parahr";
		};
	
		case (_unitType in SDKTroops) : {
		_hrT = server getVariable "SDKhr";
		};
	
		case (_unitType == 0) : {
		_hrT = 0
		};
	};

	_hrT = _hrT + _hr;

	if (_hrT < 0) then {_hrT = 0};


	switch (true) do {
	
		case (_unitType in UKTroops) : {
		server setVariable ["UKhr",_hrT,true];
		};

		case (_unitType in SASTroops) : {
		server setVariable ["SAShr",_hrT,true];
		};

		case (_unitType in USTroops) : {
		server setVariable ["UShr",_hrT,true];
		};
	
		case (_unitType in paraTroops) : {
		server setVariable ["parahr",_hrT,true];
		};
	
		case (_unitType in SDKTroops) : {
		server setVariable ["SDKhr",_hrT,true];
		};
	
		case (_unitType == 0) : {
		_hrT = 0
		};	
	};
};

_resourcesFIAT = server getVariable "resourcesFIA";
_resourcesFIAT = round (_resourcesFIAT + _resourcesFIA);
if (_resourcesFIAT < 0) then {_resourcesFIAT = 0};

server setVariable ["resourcesFIA",_resourcesFIAT,true];
resourcesIsChanging = false;

_textX = "";
_hrSim = "";
if (_hr > 0) then {_hrSim = "+"};
_resourcesFIASim = "";
if (_resourcesFIA > 0) then {_resourcesFIASim = "+"};

switch (true) do {
	case ((_hr != 0) && (_resourcesFIA != 0)): {
		_textX = format ["<t size='0.6' color='#C1C0BB'>%5 Resources.<br/> <t size='0.5' color='#C1C0BB'><br/>HR: %3%1<br/>CP: %4%2 %6",_hr,_resourcesFIA,_hrSim,_resourcesFIASim,nameTeamPlayer,currencySymbol];
	};
	case (_hr != 0): {
		_textX = format ["<t size='0.6' color='#C1C0BB'>%5 Resources.<br/> <t size='0.5' color='#C1C0BB'><br/>HR: %3%1",_hr,_resourcesFIA,_hrSim,nameTeamPlayer];
	};
	case (_resourcesFIA != 5): {
		_textX = format ["<t size='0.6' color='#C1C0BB'>%5 Resources.<br/> <t size='0.5' color='#C1C0BB'><br/>CP: %4%2 %6",_hr,_resourcesFIA,_hrSim,_resourcesFIASim,nameTeamPlayer,currencySymbol];
	};
};

if (_textX != "") then {
	[petros,"income",_textX] remoteExec ["A3A_fnc_commsMP",theBoss];
};