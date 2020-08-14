% Make the UD .NET assembly visible in MATLAB.
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;


% Open the first found LabJack U3.
[ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);

% set output to 0
ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

lngErrorcode = ljudObj.ePutS(ljhandle, 'LJ_ioPUT_DAC', 0, 5, 0);
pause(.5)
ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);