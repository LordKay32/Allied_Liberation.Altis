/*
 * Name:	fn_endGame
 * Date:	21/08/2023
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

sleep 10;

AlliesWon = true;

disableUserInput true;

enableEnvironment false;

[] spawn {
private _camera = "camera" camCreate [0, 0, 0]; 
_camera camPrepareTarget player; 
_camera camCommitPrepared 0; // needed for relative position 
_camera camPrepareRelPos [0, -1, 2]; 
_camera cameraEffect ["internal", "back"]; 
_camera camCommitPrepared 0; 
waitUntil { camCommitted _camera }; 
 
_camera camPrepareRelPos [-10, -16, 10]; 
_camera camCommitPrepared 12; 
waitUntil { camCommitted _camera }; 
 
_camera camPrepareRelPos [10, -60, 20];
[] spawn {
sleep 10;
["TAG_aVeryUniqueID", true, 3] call BIS_fnc_blackOut;
};
_camera camCommitPrepared 14; 
waitUntil { camCommitted _camera }; 

_camera cameraEffect ["terminate", "back"]; 
camDestroy _camera;
};

sleep 8;

titleText ["<t color='#ffffff' size='6'>VICTORY!", "PLAIN", 1, true, true];

sleep 4;

titleFadeOut 3;

sleep 4;

titleText ["<t color='#ffffff' size='2.4'>The German Army on Altis has been defeated. The remaining German soldiers are surrendering to Allied forces.", "PLAIN", 1, true, true];

sleep 8;

titleFadeOut 3;

sleep 4;


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

titleText [format["<t color='#ffffff' size='2.4'>Wehrmacht soldiers killed: %1<br />Wehrmacht soldiers killed by players: %2<br /><br /><br />Wehrmacht vehicles destroyed: %3<br />Wehrmacht vehicles destroyed by players: %4",occupantKilled,occupantKilledByPlayers,occupantVehKilled,occupantVehKilledByPlayers], "PLAIN", 1, true, true]; 

sleep 7.5;

titleFadeOut 3;

waitUntil { scriptDone _video2};


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

titleText [format["<t color='#ffffff' size='2.4'>Player deaths: %1<br /><br /><br /><br />Players killed by player friendly fire: %2",playerDeaths,playerDeathsFF], "PLAIN", 1, true, true]; 

sleep 7.5;

titleFadeOut 3;
	
waitUntil { scriptDone _video2};


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

titleText [format["<t color='#ffffff' size='2.4'>Allied soldiers deployed: %1<br />Allied soldiers stood down: %2<br /><br /><br />Allied soldiers killed: %3<br />Allied soldiers killed by player friendly fire: %4",teamPlayerDeployed,teamPlayerStoodDown,teamPlayerKilled,teamPlayerKilledFF], "PLAIN", 1, true, true]; 

sleep 7.5;

titleFadeOut 3;
	
waitUntil { scriptDone _video2};


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

titleText [format["<t color='#ffffff' size='2.4'>Partizans killed: %1<br /><br /><br /><br />Partizans killed by player friendly fire: %2",partizanKilled,partizanKilledFF], "PLAIN", 1, true, true]; 

sleep 7.5;

titleFadeOut 3;
	
waitUntil { scriptDone _video2};


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

titleText [format["<t color='#ffffff' size='2.4'>Allied vehicles deployed: %1<br /><br /><br />Wehrmacht vehicles captured: %2<br /><br /><br />Allied vehicles destroyed: %3",teamPlayerVehDeployed,vehiclesCaptured,teamPlayerVehKilled], "PLAIN", 1, true, true]; 

sleep 7.5;

titleFadeOut 3;
	
waitUntil { scriptDone _video2};


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

titleText [format["<t color='#ffffff' size='2.4'>Civilians killed by the Wehrmacht: %1<br /><br /><br /><br />Civilians killed by the Allies: %2",civilianKilledByOccupant,civilianKilledByteamPlayer], "PLAIN", 1, true, true]; 

sleep 7.5;

titleFadeOut 3;
	
waitUntil { scriptDone _video2};


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

titleText [format["<t color='#ffffff' size='2.4'>Sectors liberated: %1<br /><br />Sectors lost: %2<br /><br /><br />Prisoners captured: %3",sectorsLiberated,sectorsLost,prisonersCaptured], "PLAIN", 1, true, true]; 

sleep 7.5;

titleFadeOut 3;
	
waitUntil { scriptDone _video2};


private _video2 = ["Music\EndVid.ogv"] spawn BIS_fnc_playVideo;

sleep 7.5;

titleFadeOut 3;
	
waitUntil { scriptDone _video2};


disableUserInput false;

enableEnvironment true;

["TAG_aVeryUniqueID", true, 3] call BIS_fnc_blackIn;