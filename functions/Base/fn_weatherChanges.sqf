/*
 * Name:	fn_weatherChanges
 * Date:	1/01/2024
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

_setRandom = [0,0.025,0.05,0.075,0.1,0.125,0.15,0.175,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.6,0.7,0.8,0.9,1.0];

while { true } do {
	0 setOvercast (selectRandom _setRandom);

	sleep 0.5;

	simulWeatherSync;

	sleep 5400;
};

