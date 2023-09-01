private ["_siteX","_textX","_garrison","_size","_positionX"];

_siteX = _this select 0;

_garrison = garrison getVariable [_siteX,[]];

_size = [_siteX] call A3A_fnc_sizeMarker;
_positionX = getMarkerPos _siteX;
_estatic = if (_siteX in roadblocksFIA) then {"Technicals"} else {"Statics"};

_statics = garrison getVariable [(_siteX + "_statics"), []];

if (_siteX in (["Synd_HQ"] + citiesX + airportsX + resourcesX + factories + outposts + seaports + milbases)) then {
	_textX = format [
    	"<br/>Garrison soldiers: %1<br/>Static Weap: %10<br/><br/>US/UK Squad Leaders: %2/%12<br/>%11: %3/%13<br/>US/UK Riflemen: %4/%14<br/>US/UK Machine Gunners: %5/%15<br/>US/UK Medics: %6/%16<br/>US/UK Grenadiers: %7/%17<br/>US/UK Snipers: %8/%18<br/>US/UK AT Men: %9/%19", 
	    count _garrison, 
	    {_x == USSL} count _garrison, 
	    {_x == USstaticCrewTeamPlayer} count _garrison, 
	    {_x == USMil} count _garrison, 
	    {_x == USMG} count _garrison,
	    {_x == USMedic} count _garrison,
	    {_x == USGL} count _garrison,
	    {_x == USsniper} count _garrison,
	    {_x == USATman} count _garrison,
	    {_x distance _positionX < _size} count staticsToSave, 
	    _estatic,
	    {_x == UKSL} count _garrison, 
	    {_x == UKstaticCrewTeamPlayer} count _garrison, 
	    {_x == UKMil} count _garrison, 
	    {_x == UKMG} count _garrison,
	    {_x == UKMedic} count _garrison,
	    {_x == UKGL} count _garrison,
	    {_x == UKSniper} count _garrison,
	    {_x == UKATman} count _garrison 
	];
};

if (_siteX in watchpostsFIA) then {
	_textX = format [
    	"<br/>Recon soldiers: %1", 
	    count _garrison
	];
};

if (_siteX in (roadblocksFIA + aapostsFIA + atpostsFIA + mortarpostsFIA + hmgpostsFIA)) then {
	_textX = format [
    	"<br/>Garrison soldiers: %1<br/>Static Weap: %10<br/><br/>US/UK Squad Leaders: %2/%12<br/>US/UK Riflemen: %4/%14<br/>US/UK Machine Gunners: %5/%15<br/>US/UK Medics: %6/%16<br/>US/UK Grenadiers: %7/%17<br/>US/UK Snipers: %8/%18<br/>US/UK AT Men: %9/%19", 
	    count _garrison, 
	    {_x == USSL} count _garrison, 
	    {_x == USstaticCrewTeamPlayer} count _garrison, 
	    {_x == USMil} count _garrison, 
	    {_x == USMG} count _garrison,
	    {_x == USMedic} count _garrison,
	    {_x == USGL} count _garrison,
	    {_x == USsniper} count _garrison,
	    {_x == USATman} count _garrison, 
	    count _statics,
	    _estatic,
	    {_x == UKSL} count _garrison, 
	    {_x == UKstaticCrewTeamPlayer} count _garrison, 
	    {_x == UKMil} count _garrison, 
	    {_x == UKMG} count _garrison,
	    {_x == UKMedic} count _garrison,
	    {_x == UKGL} count _garrison,
	    {_x == UKSniper} count _garrison,
	    {_x == UKATman} count _garrison 
	];
};

if (_siteX in (lightroadblocksFIA)) then {
	_textX = format [
    	"<br/>Garrison soldiers: %1<br/>MG Jeep: %10<br/><br/>US/UK Squad Leaders: %2/%12<br/>US/UK Riflemen: %4/%14<br/>US/UK Machine Gunners: %5/%15<br/>US/UK Medics: %6/%16<br/>US/UK Grenadiers: %7/%17<br/>US/UK Snipers: %8/%18<br/>US/UK AT Men: %9/%19", 
	    count _garrison, 
	    {_x == USSL} count _garrison, 
	    {_x == USstaticCrewTeamPlayer} count _garrison, 
	    {_x == USMil} count _garrison, 
	    {_x == USMG} count _garrison,
	    {_x == USMedic} count _garrison,
	    {_x == USGL} count _garrison,
	    {_x == USsniper} count _garrison,
	    {_x == USATman} count _garrison, 
	    count _statics,
	    _estatic,
	    {_x == UKSL} count _garrison, 
	    {_x == UKstaticCrewTeamPlayer} count _garrison, 
	    {_x == UKMil} count _garrison, 
	    {_x == UKMG} count _garrison,
	    {_x == UKMedic} count _garrison,
	    {_x == UKGL} count _garrison,
	    {_x == UKSniper} count _garrison,
	    {_x == UKATman} count _garrison 
	];
};

if (_siteX in (supportpostsFIA)) then {
	_textX = format [
    	"<br/>Garrison soldiers: %1<br/>Support Vehicles: %10<br/>Static Weap: %20<br/><br/>US/UK Squad Leaders: %2/%12<br/>US/UK Riflemen: %4/%14<br/>US/UK Machine Gunners: %5/%15<br/>US/UK Medics: %6/%16<br/>US/UK Grenadiers: %7/%17<br/>US/UK Snipers: %8/%18<br/>US/UK AT Men: %9/%19", 
	    count _garrison, 
	    {_x == USSL} count _garrison, 
	    {_x == USstaticCrewTeamPlayer} count _garrison, 
	    {_x == USMil} count _garrison, 
	    {_x == USMG} count _garrison,
	    {_x == USMedic} count _garrison,
	    {_x == USGL} count _garrison,
	    {_x == USsniper} count _garrison,
	    {_x == USATman} count _garrison, 
	    {_x isNotEqualTo USMGStatic} count _statics,
	    _estatic,
	    {_x == UKSL} count _garrison, 
	    {_x == UKstaticCrewTeamPlayer} count _garrison, 
	    {_x == UKMil} count _garrison, 
	    {_x == UKMG} count _garrison,
	    {_x == UKMedic} count _garrison,
	    {_x == UKGL} count _garrison,
	    {_x == UKSniper} count _garrison,
	    {_x == UKATman} count _garrison,
	    {_x == USMGStatic} count _statics
	];
};

_textX