%
% Send a trigger value (255) through the labjack daq to test it out.
%
%
% David Huberdeau

%% the functions in this section would be needed at the top of any script:
% Make the UD .NET assembly visible in MATLAB.
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;


% Open the first found LabJack U3.
[ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);


%% the functions / code below would be needed for sending triggers within a script:
value = 255;
% convert decimal value input to an 8-bit binary
b_value_ = dec2bin(value, 8);
% flip the order of bits so the first bit gets indexed from (1)
b_value = fliplr(b_value_);


% set output of LabJack channels FIO0 - FIO7:
CH_OFFSET = 8;
for i_bit = 1:8
    an_error = ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', CH_OFFSET + i_bit-1, str2double(b_value(i_bit)), 0, 0);
end
ljudObj.GoOne(ljhandle);
pause(.1) % how long to keep the trigger going.
for i_bit = 1:8
    an_error = ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', CH_OFFSET + i_bit-1, 0, 0, 0);
end
ljudObj.GoOne(ljhandle);
