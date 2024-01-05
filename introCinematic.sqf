/*
 * Name:	introCinematic
 * Date:	30/08/2023
 * Version: 1.0
 * Author:  JB
 *
 * Description:
 * Intro Cinematic
 *
 * Parameter(s):
 * _PARAM1 (TYPE): - DESCRIPTION.
 * _PARAM2 (TYPE): - DESCRIPTION.
 */

scriptName "introCinematic";
enableRadio false;
playMusic "02";
sleep 13;
setViewDistance 8000;
setObjectViewDistance [8000,50];
sleep 2;
["StartingIntro", true, 5] call BIS_fnc_blackIn;
private _camera = "camera" camCreate [3392.56,293.307,300]; 
_camera camPrepareTarget getMarkerPos "camtarget"; 
_camera camCommitPrepared 0; // needed for relative position 
_camera camPrepareRelPos [-300, -300, 150]; 
_camera cameraEffect ["internal", "back"]; 
_camera camCommitPrepared 90; 
waitUntil { camCommitted _camera };
sleep 1;
["EndingIntro", true, 3] call BIS_fnc_blackOut;
sleep 5; 
_camera cameraEffect ["terminate", "back"]; 
camDestroy _camera;
setViewDistance 3200;
setObjectViewDistance [2000,50];
["EndingIntro", true, 3] call BIS_fnc_blackIn;
enableRadio true;
disableSerialization;
_layer = ["statisticsX"] call bis_fnc_rscLayer;
_layer cutRsc ["H8erHUD","PLAIN",0,false];
[] spawn A3A_fnc_statistics;
