#define OFFSET      250

/*  Creates the bombs for airstrikes, should be started 250 meters before the actual bomb run

*/

params ["_pilot", "_bombType", "_bombRunLength"];
private _filename = "fn_airbomb";
[3, format ["Executing on: %1", clientOwner], _filename] call A3A_fnc_log;

//Ensure reasonable bomb run lenght
if(_bombRunLength < 100) then {_bombRunLength = 100};
private _speedInMeters = (speed _pilot) / 3.6;
private _metersPerBomb = _bombRunLength / 8;
//Decrease it a bit, to avoid scheduling erros
private _timeBetweenBombs = (_metersPerBomb / _speedInMeters) - 0.05;

private _plane = vehicle _pilot;
switch (_bombType) do {
    case ("HE"):
    {
	  	for "_i" from 1 to 8 do {  
	  		_bombPos = (getPos _plane) vectorAdd [0, 0, -6];
			_bomb = "sab_fl_bomb_allies_1000_ammo" createvehicle _bombPos;
            _bomb setDir (getDir _plane);
            _bomb setVelocityModelSpace [1,100,0];
            sleep (_timeBetweenBombs / 2);
            _bombPos = (getPos _plane) vectorAdd [0, 0, -6];
			_bomb = "sab_fl_bomb_allies_1000_ammo" createvehicle _bombPos;
            _bomb setDir (getDir _plane);
            _bomb setVelocityModelSpace [-1,100,0];
			sleep (_timeBetweenBombs / 2);
		};
    };

    case ("CLUSTER"): 
    {
	  	for "_i" from 1 to 8 do {
	  		_bombPos = (getPos _plane) vectorAdd [0, 0, -6];
			_bomb = "ammo_Bomb_SDB" createvehicle _bombPos;
            _bomb setDir (getDir _plane);
            _bomb setVelocityModelSpace [1,100,0];
			sleep (_timeBetweenBombs / 2);
			_bombPos = (getPos _plane) vectorAdd [0, 0, -6];
			_bomb = "ammo_Bomb_SDB" createvehicle _bombPos;
            _bomb setDir (getDir _plane);
            _bomb setVelocityModelSpace [-1,100,0];
			sleep (_timeBetweenBombs / 2);
        };
    };

	default
    {
		[1, format ["Invalid bomb type, given was %1", _bombType], _filename] call A3A_fnc_log;
	};
};



