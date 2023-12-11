private _title = call SCRT_fnc_misc_getMissionTitle;

_credits = [ 
	[ _title, [antistasiPlusVersion]], 
	[ "Antistasi Version:", [antistasiVersion]], 
	[ "Antistasi Plus Authors:", ["Socrates"]], 
	[ "Antistasi Authors:", ["Barbolani","Official Antistasi Community"]] 
];
_layer = "credits1" call bis_fnc_rscLayer;
_delay = 4;
_duration = 4;
{
	_title = _x param [0,""];
	_names = _x select 1;
	_text = format ["<t size=1.5 font='PuristaBold'>%1</t>",toUpper (_title)] + "<br />";
	{
		//Second line break controls size of gap between authors. &#160; is a non-breaking space character, which prevents the size being ignored.
		_text = _text + _x + "<br /><t size='0.2'>&#160;</t><br />";
	} foreach _names;
	_text = format ["<t size='1' shadow='2'>%1</t>",_text];
	_index = _foreachindex % 2;
	[_layer,_text,_index,_duration] spawn {
		disableserialization;
		_layer = _this select 0;
		_text = _this select 1;
		_index = _this select 2;
		_duration = _this select 3;
		_fadeTime = 0.5;
		_time = time + _duration - _fadeTime;
		_layer cutrsc ["RscDynamicText","plain"];
		_display = uinamespace getvariable ["BIS_dynamicText",displaynull];
		_ctrlText = _display displayctrl 9999;
		_ctrlText ctrlsetstructuredtext parsetext _text;
		_offsetX = 0.1;
		_offsetY = 0.3;

		_width = safeZoneW;
		_height = ctrltextheight _ctrlText;
		_pos = [safezoneX, safeZoneY + _offsetY,_width,_height];

		_ctrlText ctrlsetposition _pos;
		_ctrlText ctrlsetfade 1;
		_ctrlText ctrlcommit 0;
		_ctrlText ctrlsetfade 0;
		_ctrlText ctrlcommit _fadeTime;
		waituntil {time > _time};
		_ctrlText ctrlsetfade 1;
		_ctrlText ctrlcommit _fadeTime;
	};
	_time = time + _delay;
	waituntil {time > _time};
} foreach _credits;

if (introFinished == true) exitWith{};

sleep 1;

titleText ["<t color='#ffffff' size='5'>June 1st 1943", "PLAIN", 1, true, true];

sleep 4;

titleFadeOut 2;

sleep 3;

titleText ["<t color='#ffffff' size='5'>Altis", "PLAIN", 1, true, true];

sleep 4;

titleFadeOut 2;

sleep 3;

titleText ["<t color='#ffffff' size='2.4'>The Western Desert Campaign is over. Rommel and the Afrika Korps are defeated.", "PLAIN", 1, true, true]; 

sleep 9;

titleFadeOut 2;

sleep 3;

titleText ["<t color='#ffffff' size='2.4'>Now the Allies turn their attention towards Sicily, and Italy beyond.", "PLAIN", 1, true, true]; 

sleep 9;

titleFadeOut 2;

sleep 3;

titleText ["<t color='#ffffff' size='2.4'>In their way stands Altis, an occupied British colony east of Sicily.", "PLAIN", 1, true, true];

sleep 9;

titleFadeOut 2;

sleep 3;

titleText ["<t color='#ffffff' size='2.4'>With her airfields, harbours and radar station, Altis represents a strategic threat, and must be taken before an invasion of Italy.", "PLAIN", 1, true, true];

sleep 9;

titleFadeOut 2;

sleep 3;

titleText ["<t color='#ffffff' size='2.4'>The Germans have reinforced and fortified the island.", "PLAIN", 1, true, true];

sleep 9;

titleFadeOut 2;

sleep 3;

titleText ["<t color='#ffffff' size='2.4'>At dawn, the Allies launch their assault...", "PLAIN", 1, true, true];
