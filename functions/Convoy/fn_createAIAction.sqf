params ["_destination", "_type", "_side", ["_arguments", []]];

/*  Handles the creation of any AI Action
*   Params
*     _destination : MARKER or POS; the marker or position the AI should take AI on
*     _type : STRING; (not case sensitive) one of "ATTACK", "PATROL", "REINFORCE", "CONVOY", "AIRSTRIKE" more to add
*     _side : SIDE; the side of the AI forces to send
*     _arguments : ARRAY; any further argument needed for the operation
*        -here should be some manual for each _type, but it is currently unfinished
*   Returns:
*     Nothing
*/

if(!serverInitDone) then
{
  diag_log "CreateAIAction: Waiting for server init to be completed!";
  waitUntil {sleep 1; serverInitDone};
};

if(isNil "_destination") exitWith {diag_log "CreateAIAction: No destination given for AI Action"};
_acceptedTypes = ["attack", "patrol", "reinforce", "airstrike"];
if(isNil "_type" || {!((toLower _type) in _acceptedTypes)}) exitWith {diag_log "CreateAIAction: Type is not in the accepted types"};
if(isNil "_side" || {!(_side == Occupants || _side == Invaders)}) exitWith {diag_log "CreateAIAction: Can only create AI for Inv and Occ"};

private _isFia = if (random 10 > (tierWar + difficultyCoef)) then {true} else {false};

_convoyID = round (random 1000);
_IDinUse = server getVariable [format ["Con%1", _convoyID], false];
sleep 0.1;
while {_IDinUse} do
{
  _convoyID = round (random 1000);
  _IDinUse = server getVariable [format ["Con%1", _convoyID], false];
};
server setVariable [format ["Con%1", _convoyID], true, true];

_convoyID spawn
{
  sleep (30 * 60);
  server setVariable [format ["Con%1", _this], nil, true];
};

_type = toLower _type;
_isMarker = _destination isEqualType "";
_targetString = if(_isMarker) then {_destination} else {str _destination};
diag_log format ["CreateAIAction[%1]: Started creation of %2 action to %3", _convoyID, _type, _targetString];

_nearestMarker = if(_isMarker) then {_destination} else {[markersX,_destination] call BIS_fnc_nearestPosition};
if ([_nearestMarker,false] call A3A_fnc_fogCheck < 0.3) exitWith
{
  diag_log format ["CreateAIAction[%1]: AI Action on %2 cancelled because of heavy fog", _convoyID, _targetString];
  server setVariable [format ["Con%1", _convoyID], nil, true];
};

_abort = false;
_attackDistance = distanceSPWN2;
if (_isMarker) then
{
  if(_destination in attackMrk) then {_abort = true};
}
else
{
  if(count attackPos != 0) then
  {
    _nearestAttack = [attackPos, _destination] call BIS_fnc_nearestPosition;
    if ((_nearestAttack distance _destination) < _attackDistance) then {_abort = true;};
  }
  else
  {
    if(count attackMrk != 0) then
    {
      _nearestAttack = [attackMrk, _destination] call BIS_fnc_nearestPosition;
      if (getMarkerPos _nearestAttack distance _destination < _attackDistance) then {_abort = true};
    };
  };
};
if(_abort) exitWith
{
  diag_log format ["CreateAIAction[%1]: Aborting creation of AI action because, there is already a action close by!", _convoyID];
  server setVariable [format ["Con%1", _convoyID], nil, true];
};

_destinationPos = if(_isMarker) then {getMarkerPos _destination} else {_destination};
_originPos = [];
_origin = "";
_units = [];
_vehicleCount = 0;
_cargoCount = 0;
if(_type == "patrol") then
{
  //TODO rework the origin selection!!
  _threatEvalLand = [_destinationPos, _side] call A3A_fnc_landThreatEval;
	_airportsX = airportsX select {(sidesX getVariable [_x,sideUnknown] == _side) and ([_x,true] call A3A_fnc_airportCanAttack) and (getMarkerPos _x distance2D _destinationPos < distanceForAirAttack)};
	_outposts = if (_threatEvalLand <= 15) then {outposts select {(sidesX getVariable [_x,sideUnknown] == _side) and ([_destinationPos, getMarkerPos _x] call A3A_fnc_arePositionsConnected) and (getMarkerPos _x distance _destinationPos < distanceForLandAttack)  and ([_x,true] call A3A_fnc_airportCanAttack)}} else {[]};
	_airportsX = _airportsX + _outposts;
  if (_isMarker) then
	{
		if (_markerX in blackListDest) then
		{
			_airportsX = _airportsX - outposts;
		};
		_airportsX = _airportsX - [_markerX];
		_airportsX = _airportsX select {({_x == _markerX} count (killZones getVariable [_x,[]])) < 3};
	}
	else
	{
		if (!_super) then
		{
			_siteX = [(resourcesX + factories + airportsX + outposts + seaports + milbases),_posDestination] call BIS_fnc_nearestPosition;
			_airportsX = _airportsX select {({_x == _siteX} count (killZones getVariable [_x,[]])) < 3};
		};
	};
	if (_airportsX isEqualTo []) then
	{
		_exit = true;
	}
	else
	{
		_origin = [_airportsX,_posDestination] call BIS_fnc_nearestPosition;
		_originPos = getMarkerPos _origin;
	};
  if (!_exit) then
  {
    //This line detects air or land attack
    _isLand =
    (
      (_threatEvalLand <= 15) &&
      {(_originPos distance _destinationPos < distanceForLandAttack) &&
      {([_originPos, _destinationPos] call A3A_fnc_arePositionsConnected)}}
    );
    if(_isLand) then
    {
      if (_origin in outposts) then {[_origin, 10] call A3A_fnc_addTimeForIdle} else {[_origin, 5] call A3A_fnc_addTimeForIdle};
      _count = 1;
      _vehPool = [];
      //Select vehicle count and pool
      switch (true) do
      {
        case (tierWar < 3):
        {
          _count = 1;
          _vehPool = if(_side == Occupants) then {
            if(_isFia) then {
              vehFIACars + vehFIAArmedCars
            } else {
              vehNATOLight
            };
          } else {
            if(_isFia) then {
              vehWAMArmedCars
            } else {
              vehCSATLightArmed
            };
          };
        };
        case (tierWar < 6 && {tierWar > 2}):
        {
          _count = 2 + (round (random 1));
          _vehPool = if(_side == Occupants) then {
            if(_isFia) then {
              vehFIAArmedCars + vehFIAAPC
            } else {
              vehNATOLightArmed + vehNATOAPC
            };
          } else {
            if(_isFia) then {
              vehWAMArmedCars + vehWAMAPC
            } else {
              vehCSATLightArmed + vehCSATAPC
            };
          };
        };
        case (tierWar > 5):
        {
          _count = 3 + (round (random 2));
          _vehPool = if(_side == Occupants) then {vehNATOAttack} else {vehCSATAttack};
        };
      };

      for "_i" from 1 to _count do
      {
        _veh = [_vehPool, _side] call A3A_fnc_selectAndCreateVehicle;
        _vehPool = _veh select 1;
        _units pushBack (_veh select 0);
        _vehicleCount = _vehicleCount + 1;
        _cargoCount = _cargoCount + count ((_veh select 0) select 1) + count ((_veh select 0) select 2);
      };
    }
    else
    {
      [_origin, 10] call A3A_fnc_addTimeForIdle;
      _count = if(_isMarker) then {1 + (round (random 1))} else {1};
      _vehPool = [];
      switch (true) do
      {
        case (tierWar < 3):
        {
          _vehPool = if(_side == Occupants) then {vehNATOPatrolHeli} else {vehCSATPatrolHeli};
        };
        case (tierWar > 2 && tierWar < 7):
        {
          _vehPool = if(_side == Occupants) then {vehNATOTransportHelis} else {vehCSATTransportHelis};
        };
        case (tierWar > 6):
        {
          _vehPool = if(_side == Occupants) then {vehNATOAttackHelis} else {vehCSATAttackHelis};
        };
      };
      for "_i" from 1 to _count do
      {
        _veh = [_vehPool, _side, true] call A3A_fnc_selectAndCreateVehicle;
        _vehPool = _veh select 1;
        _units pushBack (_veh select 0);
        _vehicleCount = _vehicleCount + 1;
        _cargoCount = _cargoCount + count ((_veh select 0) select 1) + count ((_veh select 0) select 2);
      };
    };
  }
  else
  {
    diag_log format ["CreateAIAction[%1]: Patrol aborted as no base is available!", _convoyID];
    _abort = true;
  };
};
if(_type == "reinforce") then
{
  _arguments params ["_canReinf"];
  _possibleBases = _canReinf select {[_x, _destination] call A3A_fnc_shouldReinforce};
  if((count _possibleBases) != 0) then
  {

    _selectedBase = [_possibleBases, _destination] call BIS_fnc_nearestPosition;
    //Found base to reinforce, selecting units now
    _units = [_selectedBase, _destination] call A3A_fnc_selectReinfUnits;

    if(_units isEqualTo []) then
    {
      diag_log format ["CreateAIAction[%1]: No units given for reinforcements!", _convoyID];
      _abort = true;
    }
    else
    {
      _origin = _selectedBase;
      _originPos = getMarkerPos _origin;

      _countUnits = [_units, false] call A3A_fnc_countGarrison;

      _vehicleCount = _vehicleCount + (_countUnits select 0);
      _cargoCount = _cargoCount + (_countUnits select 1) + (_countUnits select 2);
    };
  }
  else
  {
    diag_log format ["CreateAIAction[%1]: Reinforcement aborted as no base is available!", _convoyID];
    _abort = true;
  };
};
if(_type == "attack") then
{

};
if(_type == "airstrike") then
{
  _airport = [_destination, _side] call A3A_fnc_findAirportForAirstrike;
  if(_airport != "") then
  {
    _friendlies = if (_side == Occupants) then
    {
      allUnits select
      {
        (alive _x) &&
        {((side (group _x) == _side) || (side (group _x) == civilian)) &&
        {_x distance _destinationPos < 200}}
      };
    }
    else
    {
      allUnits select
      {
        (side (group _x) == _side) &&
        {(_x distance _destinationPos < 100) &&
        {[_x] call A3A_fnc_canFight}}
      };
    };
    //NATO accepts 2 casulties, CSAT does not really care
    if((_side == Occupants && {count _friendlies < 3}) || {_side == Invaders && {count _friendlies < 8}}) then
    {
      private _planePool = if (_side == Occupants) then {vehNATOPlanes} else {vehCSATPlanes};
      private _casPlaneIndex = _planePool findIf {[_x] call A3A_fnc_vehAvailable};
      _crewUnits = if(_side == Occupants) then {NATOCrew} else {CSATCrew};
    	if (_casPlaneIndex != -1) then
    	{
        _bombType = "";
        if(count _arguments != 0) then
        {
          _bombType = _arguments select 0;
        }
        else
        {
          _distanceSpawn2 = distanceSPWN2;
          _enemies = allUnits select
          {
            (alive _x) &&
            {(_x distance _destinationPos < _distanceSpawn2) &&
            {(side (group _x) != _side) and (side (group _x) != civilian)}}
          };
          if(isNil "napalmEnabled") then
          {
            //This seems to be a merge bug
            diag_log "CreateAIAction: napalmEnabled does not contains a value, assuming false!";
            napalmEnabled = false;
          };
          _bombType = if (napalmEnabled) then {"NAPALM"} else {"CLUSTER"};
    			{
    			  if (vehicle _x isKindOf "Tank") then
    				{
    				   _bombType = "HE" //Why should it attack tanks with HE?? TODO find better solution
    				}
    			  else
    				{
    				  if (vehicle _x != _x) then
    					{
    					  if !(vehicle _x isKindOf "StaticWeapon") then {_bombType = "CLUSTER"}; //TODO test if vehicle _x isKindOf Static is not also vehicle _x != _x
    					};
    				};
    			  if (_bombTypeX == "HE") exitWith {};
    			} forEach _enemies;
        };
        if (!_isMarker) then {airstrike pushBack _destinationPos};
        diag_log format ["CreateAIAction[%1]: Selected airstrike of bombType %2 from %3",_convoyID, _bombType, _airport];
        _origin = _airport;
        _originPos = getMarkerPos _airport;
        _units pushBack [(_planePool select _casPlaneIndex), [_crewUnits],[]];
        _vehicleCount = 1;
        _cargoCount = 1;
      }
      else
      {
        diag_log format ["CreateAIAction[%1]: Aborting airstrike as the airplane is currently not available", _convoyID];
        _abort = true;
      };
    }
    else
    {
      diag_log format ["CreateAIAction[%1]: Aborting airstrike, cause there are too many friendly units in the area", _convoyID];
      _abort = true;
    };
  }
  else
  {
    diag_log format ["CreateAIAction[%1]: Aborting airstrike due to no avialable airport", _convoyID];
    _abort = true;
  };
};
if(_type == "convoy") then
{
  //Heavy will call in more and better vehicles
  _isHeavy = if (random 10 < tierWar) then {true} else {false};
  //Easy will call in only FIA (police) vehicles (We really have to rename this)
  _isEasy = if (!(_isHeavy) && {_side == Occupants && {random 10 >= tierWar}}) then {true} else {false};
  _sideCheck = sidesX getVariable [_destination, sideUnknown];
  if(_sideCheck == _side) then
  {
    _origin = [_destination] call A3A_fnc_findBasesForConvoy;
    _originPos = getMarkerPos _origin;
    if(!_abort && !(_origin isEqualTo "")) then
    {
      _typeConvoy = [];
      if ((_destination in airportsX) or (_destination in outposts) or (_destination in milbases)) then
      {
      	_typeConvoy = ["Ammunition","Armor"];
      }
      else
      {
      	if (_destination in citiesX) then
      	{
          _typeConvoy = ["Supplies"];
      	}
      	else
      	{
      		if ((_destinationX in resourcesX) or (_destinationX in factories)) then
          {
            _typeConvoy = ["Fuel"];
          }
          else
          {
            _typeConvoy = ["Prisoners"];
          };
          //Same here, not sure about it
      		if (((count (garrison getVariable [_destinationX, []]))/2) >= [_destinationX] call A3A_fnc_garrisonSize) then
          {
            _typeConvoy pushBack "Reinforcements"
          };
      	};
    	};
      _selectedType = selectRandom _typeConvoy;

      private ["_timeLimit", "_dateLimitNum", "_displayTime", "_nameDest", "_nameOrigin" ,"_timeToFinish", "_dateFinal"];
      //The time the convoy will wait before starting
      _timeLimit = if (_isHeavy) then {0} else {round random 10};// timeX for the convoy to come out, we should put a random round 15
      _timeLimit = _timeLimit * settingsTimeMultiplier;

      _timeToFinish = 120 * settingsTimeMultiplier;
      _dateTemp = date;
      _dateFinal = [_dateTemp select 0, _dateTemp select 1, _dateTemp select 2, _dateTemp select 3, (_dateTemp select 4) + _timeToFinish];
      _dateLimit = [_dateTemp select 0, _dateTemp select 1, _dateTemp select 2, _dateTemp select 3, (_dateTemp select 4) + _timeLimit];
      _dateLimitNum = dateToNumber _dateLimit;
      _dateLimit = numberToDate [_dateTemp select 0, _dateLimitNum];//converts datenumber back to date array so that time formats correctly when put through the function
      _displayTime = [_dateLimit] call A3A_fnc_dateToTimeString;//Converts the time portion of the date array to a string for clarity in hints

      _nameDest = [_destination] call A3A_fnc_localizar;
      _nameOrigin = [_origin] call A3A_fnc_localizar;
      [_origin, 30] call A3A_fnc_addTimeForIdle;

      private ["_text", "_taskState", "_taskTitle", "_taskIcon", "_taskState1", "_typeVehEsc", "_typeVehObj", "_typeVehLead"];

      _text = "";
      _taskState = "CREATED";
      _taskTitle = "";
      _taskIcon = "";
      _taskState1 = "CREATED";

      _typeVehLead = "";
      _typeVehEsc = "";
      _typeVehObj = "";

      switch (_selectedType) do
      {
      	case "Ammunition":
      	{
      		_text = format ["A convoy from %1 is about to depart at %2. It will provide ammunition to %3. Try to intercept it. Steal or destroy that truck before it reaches it's destination.",_nameOrigin,_displayTime,_nameDest];
      		_taskTitle = "Ammo Convoy";
      		_taskIcon = "rearm";
      		_typeVehObj = if (_side == Occupants) then {vehNATOAmmoTruck} else {vehCSATAmmoTruck};
      	};
        case "Fuel":
      	{
      		_text = format ["A convoy from %1 is about to depart at %2. It will provide fuel to %3. Try to intercept it. Steal or destroy that truck before it reaches it's destination.",_nameOrigin,_displayTime,_nameDest];
      		_taskTitle = "Fuel Convoy";
      		_taskIcon = "refuel";
      		_typeVehObj = if (_side == Occupants) then {vehNATOFuelTruck} else {vehCSATFuelTruck};
      	};
      	case "Armor":
      	{
      		_text = format ["A convoy from %1 is about to depart at %2. It will reinforce %3 with armored vehicles. Try to intercept it. Steal or destroy that thing before it reaches it's destination.",_nameOrigin,_displayTime,_nameDest];
      		_taskTitle = "Armored Convoy";
      		_taskIcon = "Destroy";
      		_typeVehObj = if (_side == Occupants) then {selectRandom vehNATOAA} else {selectRandom vehCSATAA};
      	};
      	case "Prisoners":
      	{
      		_text = format ["A group os POW's is being transported from %1 to %3, and it's about to depart at %2. Try to intercept it. Kill or capture the truck driver to make them join you and bring them to HQ. Alive if possible.",_nameOrigin,_displayTime,_nameDest];
      		_taskTitle = "Prisoner Convoy";
      		_taskIcon = "run";
      		_typeVehObj = if (_side == Occupants) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
      	};
      	case "Reinforcements":
      	{
      		_text = format ["Reinforcements are being sent from %1 to %3 in a convoy, and it's about to depart at %2. Try to intercept and kill all the troops and vehicle objective.",_nameOrigin,_displayTime,_nameDest];
      		_taskTitle = "Reinforcements Convoy";
      		_taskIcon = "run";
      		_typeVehObj = if (_side == Occupants) then {selectRandom vehNATOTrucks} else {selectRandom vehCSATTrucks};
      	};
      	case "Money":
      	{
      		_text = format ["A truck plenty of money is being moved from %1 to %3, and it's about to depart at %2. Steal that truck and bring it to HQ. Those funds will be very welcome.",_nameOrigin,_displayTime,_nameDest];
      		_taskTitle = "Money Convoy";
      		_taskIcon = "move";
      		_typeVehObj = civSupplyVehicle;
      	};
      	case "Supplies":
      	{
      		_text = format ["A truck with medical supplies destination %3 it's about to depart at %2 from %1. Steal that truck bring it to %3 and let people in there know it is %4 who's giving those supplies.",_nameOrigin,_displayTime,_nameDest,nameTeamPlayer];
      		_taskTitle = "Supply Convoy";
      		_taskIcon = "heal";
      		_typeVehObj = civSupplyVehicle;
      	};
        default
        {
          diag_log format ["CreateAIAction[%1]: Aborting convoy, selected type not found, type was %2", _convoyID, _selectedType];
          _abort = true;
        };
      };
      if(!_abort) then
      {
        sleep (_timeLimit * 60);
        _crewUnits = if(_side == Occupants) then {NATOCrew} else {CSATCrew};

        //Creating convoy lead vehicle
        _typeVehLead = if (_side == Occupants) then {if (!_isEasy) then {selectRandom vehNATOLightArmed} else {selectRandom vehPoliceCars}} else {selectRandom vehCSATLightArmed};
        _crew = [_typeVehLead, _crewUnits] call A3A_fnc_getVehicleCrew;
        _units pushBack [_typeVehLead, _crew, []];
        _vehicleCount = _vehicleCount + 1;
        _cargoCount = _cargoCount + (count _crew);
        //Convoy lead created

        //Prepared vehicle pool
        private _count = 1;
        if (_isHeavy) then
        {
          _count = 3;
        }
        else
        {
          if ([_destination] call A3A_fnc_isFrontline) then
          {
            _count = (round random 2) + 1;
          };
        };

        _vehPool = if (_side == Occupants) then
        {
          if (!_isEasy) then
          {
            vehNATOAttack
          }
          else
          {
            vehMilitia
          };
        }
        else
        {
          vehCSATAttack;
        };

        //Delete MBT from array if aggro is not high enough
        if (!_isEasy) then
        {
        	_rnd = random 100;
        	if (_side == Occupants) then
        	{
        		if (_rnd > aggressionOccupants) then
        		{
        			_vehPool = _vehPool - vehNATOTanks;
        		};
        	}
        	else
        	{
        		if (_rnd > aggressionInvaders) then
        		{
        			_vehPool = _vehPool - vehCSATTanks;
        		};
        	};
        	if (count _vehPool == 0) then {if (_side == Occupants) then {_vehPool = vehNATOTrucks} else {_vehPool = vehCSATTrucks}};
        };
        //Vehicle pool prepared

        //Select escort vehicles and their groups
        for "_i" from 1 to _count do
        {
          _veh = [_vehPool, _side] call A3A_fnc_selectAndCreateVehicle;
          _vehPool = _veh select 1;
          _units pushBack (_veh select 0);
          _vehicleCount = _vehicleCount + 1;
          _cargoCount = _cargoCount + count ((_veh select 0) select 1) + count ((_veh select 0) select 2);
        };
        //Escorts and groups added

        //Add objective vehicle and cargo
        _typeGroup = [];
        if(_selectedType == "Reinforcements") then
        {
          _typeGroup = [_typeVehObj,_side] call A3A_fnc_cargoSeats;
        };
        if(_selectedType == "Prisoners") then
        {
          for "_i" from 1 to (1 + round (random 11)) do
          {
            _typeGroup pushBack SDKUnarmed;
          };
        };
        _crew = [_typeVehObj, _crewUnits] call A3A_fnc_getVehicleCrew;
        _units pushBack [_typeVehObj, _crew, _typeGroup];
        _vehicleCount = _vehicleCount + 1;
        _cargoCount = _cargoCount + (count _typeGroup) + (count _crew);
        //Objective and its cargo added

        //Last escort vehicle
        _veh = [_vehPool, _side] call A3A_fnc_selectAndCreateVehicle;
        _vehPool = _veh select 1;
        _units pushBack (_veh select 0);
        _vehicleCount = _vehicleCount + 1;
        _cargoCount = _cargoCount + count ((_veh select 0) select 1) + count ((_veh select 0) select 2);
        //Last escrot vehicle added
      };
    }
    else
    {
      diag_log format ["CreateAIAction[%1]: Aborting convoy, as no base is available to send a convoy", _convoyID];
      _abort = true;
    };
  }
  else
  {
    diag_log format ["CreateAIAction[%1]: Side of convoy does not match side of destination, aborting!", _convoyID];
    _abort = true;
  };
};

if(_abort) exitWith
{
  server setVariable [format ["Con%1", _convoyID], nil, true];
  false
};

_target = if(_destination isEqualType "") then {_destination} else {str _destination};
diag_log format ["CreateAIAction[%1]: Created AI action to %2 from %3 to %4 with %5 vehicles, %6 units, units: %7", _convoyID, _type, _origin, _targetString, _vehicleCount , _cargoCount, str _units];

[_convoyID, _units, _originPos, _destinationPos, [_origin, if(_isMarker) then {_destination} else {""}], _type, _side] spawn A3A_fnc_createConvoy;
true;
