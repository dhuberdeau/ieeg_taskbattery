function varargout = movement_task(varargin)
Screen('Preference', 'SkipSyncTests', 1);

%% Participant number
SUB_NUM_ = 'LB013';

%% Specify trial list
screen_dims = [1600, 900];

home_position = screen_dims/2;
TARG_LEN = 350;

targ_angles = repmat(((0:120:359) + 10)', 2, 1);
targ_coords_base = TARG_LEN*[cosd(targ_angles), sind(targ_angles)] + repmat(home_position, 6, 1);

%% initialize joystick
joy = HebiJoystick(1);
x = nan(1, 10000);
y = nan(1, 10000);
tim = nan(1, 10000);
delays = nan(5,10000);
%joy = HebiJoystick(1);
kinematics = nan(10000, 3);

%%

im_list = cell(1,4);
% im_list{1}= imread('afasa5.jpg');
% im_list{2}= imread('afasa6.jpg');
% im_list{3}= imread('afasa7.jpg');
% im_list{4}= imread('afasa8.jpg');
% im_list{5}= imread('afasa9.jpg');
% im_list{6}= imread('afasa10.jpg');

CUE_TIME = .750; %sec
RET_TIME = 3; %sec
TR_TIME = 1.1; %sec
MOV_TIME = 1.9; % (1.1 for targ disp, 1.9 for movement)
MOV_LIMIT_TIME = .75; %time limit of movement
TR_TOLERANCE = .15;
FB_TIME = 1;
ITI_TIME = 1; %inter-trial interval time
% TEXT_LOC = [600 525];
TEXT_LOC = home_position;
TEXT_SIZE = 40;
SCREEN_COORD_X = screen_dims(1);
SCREEN_COORD_Y = screen_dims(2);
quit_command = 0;

InitializePsychSound
pahandle = PsychPortAudio('Open');

Ts = 1/44100;
sound_dur = .1;
tone_freq1 = 1000;
tone_freq2 = 1700;
time = Ts:Ts:.1;
tone_signal1 = .1*sin(tone_freq1*time);
tone_signal2 = .1*sin(tone_freq2*time);

sound_data = [zeros(1, round(.1/Ts)), zeros(1, round(.4/Ts)), zeros(1, round(.1/Ts)), zeros(1, round(.4/Ts)), tone_signal2];
sound_data2 = repmat(sound_data, 2, 1);
PsychPortAudio('FillBuffer', pahandle, sound_data2);

cursor_color = [0 0 0]';
cursor_dims = [-17.5 -17.5 17.5 17.5]'; %box dimensions defining circle around center
rect_dims = [-30 -30 30 30]';
target_circle_dims = [-TARG_LEN, -TARG_LEN, TARG_LEN, TARG_LEN];
target_color = [1 53 53]';
target_dims = [-20 -20 20 20]';
bubble_start_diam = 2;
bubble_end_diam = TARG_LEN;
bubble_expand_rate = 700;

%% Intialise digital IO
interSample = .01;
lj = labJack('verbose', false)

%%
% [trial_target_numbers_MASTER, trial_type_MASTER, prescribed_PT_MASTER] = generate_trial_table_E1retention_v5_ECoG_RT(SUB_NUM_);
%load('C:\Users\Scan Computer\Documents\MATLAB\vma_task\vma_retention 2\trial_parameters_P001_RT.mat')
% load('C:\Users\Scan Computer\Documents\MATLAB\task_battery\movement\trial_parameters_ML012.mat')
load(['~/Documents/MATLAB/ieeg_taskbattery/movement/', 'trial_parameters_LB013.mat']);
% RET_TIME = prescribed_ret;
trial_target_numbers_MASTER =  trial_target_numbers;
trial_type_MASTER = trial_type;
prescribed_PT_MASTER = prescribed_PT;

screens=Screen('Screens');
screenNumber=max(screens);
[win, rect] = Screen('OpenWindow', screenNumber, []); %[0 0 1600 900]);
o = Screen('TextSize', win, 24);
for block_num =1%4:8
    switch block_num
        case 1
            this_trials = 1:12;
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 2
            this_trials = 12+(1:12);
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 3
            this_trials = 12+12+(1:12);
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 4
            % mixed block
            this_trials = 12*3+(1:54);
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 5
            % mixed block
            this_trials = 12*3 + 54 + (1:54);
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        case 6
            % mixed block
            this_trials = 12*3 + 54*2 + (1:54);
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);

        case 7
            % mixed block
            this_trials = 12*3 + 54*3 + (1:54);
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);

        case 8
            % mixed block
            this_trials = 12*3 + 54*4 + (1:42);
            trial_type = trial_type_MASTER(this_trials);
            trial_target_numbers = trial_target_numbers_MASTER(this_trials);
            prescribed_PT = prescribed_PT_MASTER(this_trials);
        otherwise
            error('Not a valid block')
    end

    N_TRS = length(trial_target_numbers);
    % N_TRS = 100;

    %% setup data collection
    Data.MT = nan(N_TRS, 1);
    Data.RT = nan(N_TRS, 1);
    Data.Succ = nan(N_TRS, 1);
    % Data.Key = nan(N_TRS, 1);
    Data.pPT = nan(N_TRS, 1);
    Data.time_targ_disp = nan(N_TRS, 1);
    Data.time_precue_disp = nan(N_TRS, 1);
    Data.time_precue_ext = nan(N_TRS, 1);
    Data.time_square_disp = nan(N_TRS, 1);
    Data.time_movement_start = nan(N_TRS, 1);
    Data.Type = nan(N_TRS, 1);
    Data.ViewTime = nan(N_TRS, 1);
    Data.Kinematics = cell(N_TRS, 1);
    Data.Target = nan(N_TRS, 1);
    Data.EventTimes = cell(N_TRS, 1);
    %% initialize kinematics
    kinematics = nan(10000, 3);

    %% wait for subject to begin new block
    Screen('DrawText', win, 'Experiment will start momentarily.', round(screen_dims(1)/2), round(screen_dims(2)/2));
    Screen('Flip', win);
    pause(.2);
    %% run through trial list

    try

%         exp_time = tic;
        exp_time = GetSecs;
        for i_tr = 1:N_TRS

            state = 'prestart';
            entrance = 1;
            kinematics = nan(10000, 3);
            flip_onset_times = nan(10000, 1);
            flip_offset_times = nan(10000, 1);
            stim_times = nan(10000, 1);
            k_samp = 1;
            trial_time = GetSecs; %tic;
            screen_text_buff = {};
            screen_pic_buff = {};
            screen_picDim_buff = cell(2,0);
            screen_oval_buff = nan(4, 0);
            screen_color_buff = nan(3, 0);
            screen_bubble_buff = nan(4, 0);
            draw_text_flag = 0;
            draw_pic_flag = 0;
            draw_bubble_flag = 0;
            draw_red_cursor_flag = 0;
            draw_go_square_flag = 0;
            k_text_buff = 1;
            k_pic_buff = 1;
            k_oval_buff = 0;
            send_trigger = 0;
            trigger_value = 0;

            curr_target = home_position;
            while ~isequal(state, 'end_state')

                [key_press, key_seconds, key_code, ~] = KbCheck;
                if key_press == 1
                    key_hit = KbName(key_code);
                    if isequal(key_hit, 'q') || isequal(key_hit, 'd')
                        % quit command sent
                        quit_command = 1;
                        break
                    end
                end



                %%%%%% joystick read
                [temp_p, temp_jkeys,~] = read(joy);
                temp_p = [(temp_p(1)+1)/2, (temp_p(2)+1)/2];
                temp_jkey = temp_jkeys(1);
                kinematics(k_samp, :) = [(GetSecs - exp_time), temp_p.*[SCREEN_COORD_X, SCREEN_COORD_Y]];% translate to screen coordinates
                %%%%%%

                Screen('FillOval', win, [cursor_color, screen_color_buff],...
                    [[kinematics(k_samp, 2:3), kinematics(k_samp, 2:3)]' + cursor_dims, ...
                    screen_oval_buff]);
                if draw_go_square_flag == 1
                    Screen('FillRect', win, cursor_color, [home_position, home_position]' + rect_dims)
                else
                    % do not draw rectangle
                end
                Screen('FrameOval', win, [74, 96, 96]', [home_position home_position]' + target_circle_dims');
                if draw_text_flag == 1
                    for i_text = 1:length(screen_text_buff)
                        Screen('DrawText', win, screen_text_buff{i_text}, TEXT_LOC(1), TEXT_LOC(2) + (i_text - 1)*15);
                    end
                end
                if draw_pic_flag == 1
                    for i_pic = 1:length(screen_pic_buff)
                        Screen('DrawTexture', win, screen_pic_buff{i_pic}, screen_picDim_buff{1, i_pic}, screen_picDim_buff{2, i_pic});
                    end
                end
                if draw_bubble_flag == -100 %1
                    Screen('FrameOval', win, 1, [home_position home_position]' + screen_bubble_buff(:));
                    if norm(kinematics(k_samp, 2:3) - home_position) < screen_bubble_buff(end)
                        draw_red_cursor_flag = 1;
                    end
                end
                if draw_red_cursor_flag
%                     Screen('FillOval', win, [255, 0, 10]',...
%                         [kinematics(k_samp, 2:3), kinematics(k_samp, 2:3)]' + cursor_dims);
%                   For RT version... don't draw the red cursor
                end

                if send_trigger == 1
                  % send pulse to daq
                    lj.setDIO(trigger_value)
                    [t_flip_0, t_stim, t_flip_f] = Screen('Flip', win);
                    lj.setDIO(0)

                    send_trigger = 0;
                    flip_onset_times(k_samp) = t_flip_0 - exp_time;
                    flip_offset_times(k_samp) = t_flip_f - exp_time;
                    stim_times(k_samp) = t_stim - exp_time;
                else
                    [t_flip_0, t_stim, t_flip_f] = Screen('Flip', win);
                    flip_onset_times(k_samp) = t_flip_0 - exp_time;
                    flip_offset_times(k_samp) = t_flip_f - exp_time;
                    stim_times(k_samp) = t_stim - exp_time;
                end


                switch state
                    case 'prestart'
                        if entrance == 1
                            % first entrance into state
    %                         Screen('DrawText', win, 'Go to Home', 600, 525);
    %                         Screen('Flip', win);
                            screen_text_buff{k_text_buff} = 'Go to Home, and press trigger.';
    %                         k_text_buff = k_text_buff + 1;
                            draw_text_flag = 1;
                            screen_oval_buff(:,1) = [home_position home_position]' + target_dims;
                            screen_color_buff(:,1) = target_color;
                            k_oval_buff = k_oval_buff + 1;
                            Data.pPT(i_tr) = prescribed_PT(i_tr);
                            Data.Type(i_tr) = trial_type(i_tr);
                            Data.retTime(i_tr) = RET_TIME;
                            entrance = 0;
                        else
    %                         [keyIsDown,secs,keyCode]=KbCheck;
    %                         if keyIsDown && keyCode(home)
                            targ_dist = norm(curr_target - kinematics(k_samp, 2:3));
                            if targ_dist <= 15 && temp_jkey
                                % home pos reached: switch to home state
                                entrance = 1;
                                state = 'home';
                                draw_text_flag = 0;
                                draw_pic_flag = 0;

                                trigger_value = 15;
                                send_trigger = 1;
                                Data.time_precue_disp(i_tr) = (GetSecs - exp_time);
                            else
                                % have not reached home & pressed key1 yet
                            end
                        end
                    case 'home'
                        if entrance == 1
                            % first entrance into home state
                            home_start_time = (GetSecs - trial_time);
                            switch trial_type(i_tr)
                                case 4 % catch trial
                                    rnd_ind = randperm(3);
                                    switch trial_target_numbers(i_tr)
                                        case 1
                                            temp_alt_targ = [2 3 4];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        case 2
                                            temp_alt_targ = [1 3 4];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        case 3
                                            temp_alt_targ = [1 2 4];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        case 4
                                            temp_alt_targ = [1 2 3];
                                            temp_tx = Screen('MakeTexture', win, im_list{temp_alt_targ(rnd_ind(1))});
                                            tx_size = size(im_list{temp_alt_targ(rnd_ind(1))});
                                        otherwise
                                            error('Invalid target name listed');
                                    end
                                     screen_picDim_buff{1, k_pic_buff} = [0; 0; tx_size(2); tx_size(1)];
                                     screen_picDim_buff{2, k_pic_buff} = [TEXT_LOC(1) - TEXT_SIZE; TEXT_LOC(2) - TEXT_SIZE;...
                                         TEXT_LOC(1) + TEXT_SIZE; TEXT_LOC(2) + TEXT_SIZE];
                                     screen_pic_buff{k_pic_buff} = temp_tx;
                                     draw_pic_flag = 1;
                                     Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 3 % catch trial
                                    rnd_ind = randperm(3);
                                    k_oval_buff = k_oval_buff + 1;
                                    switch trial_target_numbers(i_tr)
                                        case 1
                                            temp_alt_targ = [2 3 4];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 3;
                                        case 2
                                            temp_alt_targ = [1 3 4];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 4;
                                        case 3
                                            temp_alt_targ = [1 2 4];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 5;
                                        case 4
                                            temp_alt_targ = [1 2 3];
                                            screen_oval_buff(:, k_oval_buff) = [targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'; targ_coords_base(temp_alt_targ(rnd_ind(1)),:)'] + target_dims;
                                            screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                            %Data.Target(i_tr) = 6;
                                        otherwise
                                            error('Invalid target name listed');
                                    end
                                    Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 2
                                    switch trial_target_numbers(i_tr)
                                        case 1
                                            temp_tx = Screen('MakeTexture', win, im_list{1});
                                            tx_size = size(im_list{1});
                                        case 2
                                            temp_tx = Screen('MakeTexture', win, im_list{2});
                                            tx_size = size(im_list{2});
                                        case 3
                                            temp_tx = Screen('MakeTexture', win, im_list{3});
                                            tx_size = size(im_list{3});
                                        case 4
                                            temp_tx = Screen('MakeTexture', win, im_list{4});
                                            tx_size = size(im_list{4});
                                        case 5
                                            temp_tx = Screen('MakeTexture', win, im_list{5});
                                            tx_size = size(im_list{5});
                                        case 6
                                            temp_tx = Screen('MakeTexture', win, im_list{6});
                                            tx_size = size(im_list{6});
                                        otherwise
                                            error('Invalid target name listed');
                                    end
                                     screen_picDim_buff{1, k_pic_buff} = [0; 0; tx_size(2); tx_size(1)];
                                     screen_picDim_buff{2, k_pic_buff} = [TEXT_LOC(1) - TEXT_SIZE; TEXT_LOC(2) - TEXT_SIZE;...
                                         TEXT_LOC(1) + TEXT_SIZE; TEXT_LOC(2) + TEXT_SIZE];
                                     screen_pic_buff{k_pic_buff} = temp_tx;
                                     draw_pic_flag = 1;
                                     Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 1
                                    k_oval_buff = k_oval_buff + 1;
                                    screen_oval_buff(:, k_oval_buff) = [targ_coords_base(trial_target_numbers(i_tr),:)'; targ_coords_base(trial_target_numbers(i_tr),:)'] + target_dims;
                                    screen_color_buff(:, k_oval_buff) = [0; 0; 0];
                                    Data.Target(i_tr) = trial_target_numbers(i_tr);
                                case 0
                                    %show nothing
                                    Data.Target(i_tr) = trial_target_numbers(i_tr);
                                otherwise
                                    error('No valid trial type specified.')
                            end
                            entrance = 0;
                            curr_target = targ_coords_base(trial_target_numbers(i_tr),:);
                        else
                            if ((GetSecs - trial_time) - home_start_time) < CUE_TIME
                                % actually do nothing.. just wait
                            else
                                % extinguish cue and switch to retention state
    %                             Screen('Flip', win);
                                draw_text_flag = 0;
                                draw_pic_flag = 0;
                                switch trial_type(i_tr)
                                    case 4
                                    case 3
                                        k_oval_buff = k_oval_buff - 1;
                                        screen_oval_buff = screen_oval_buff(:, 1:k_oval_buff);
                                        screen_color_buff = screen_color_buff(:, 1:k_oval_buff);
                                    case 2
                                    case 1
                                        k_oval_buff = k_oval_buff - 1;
                                        screen_oval_buff = screen_oval_buff(:, 1:k_oval_buff);
                                        screen_color_buff = screen_color_buff(:, 1:k_oval_buff);
                                    case 0
                                    otherwise
                                        error('invalid trial type')
                                end
                                entrance = 1;
                                state = 'retention';
                                send_trigger = 1;
                                trigger_value = 240;
                                Data.time_precue_ext(i_tr) = (GetSecs - exp_time);
                                %putvalue(dio,240); % send home state trig
                                %pause(interSample);
                                %putvalue(dio,0); %return trigger to 0
                            end
                        end
                    case 'retention'
                        if entrance == 1
                            % just entered state
                            retention_start_time = (GetSecs - trial_time);
                            entrance = 0;
                        else
                            if ((GetSecs - trial_time) - retention_start_time) < RET_TIME
                                % actually do nothing.. just wait
                            else
                                % extinguish cue and switch to TR state
    %                             Screen('Flip', win);
                                entrance = 1;
                                state = 'TR';
                            end
                        end
                    case 'TR'
                        if entrance == 1
                            % just entered TR state
                            TR_state_time = (GetSecs - trial_time);
                            %startTime = PsychPortAudio('Start', pahandle);
                            draw_go_square_flag = 1;
                            target_shown = 0;
                            mov_begun = 0;
                            mov_ended = 0;
                            entrance = 0;
                            move_start_time = nan;
                            move_end_time = nan;
                            send_trigger = 1;
                            trigger_value = 201; %send trig on square appearance
                            Data.time_square_disp(i_tr) = (GetSecs - exp_time);
                        else
                            home_dist = norm(home_position - kinematics(k_samp, 2:3));
    %                         targ_dist = norm(curr_target - kinematics(k_samp, 2:3));
                            state_elapsed_time = ((GetSecs - trial_time) - TR_state_time);
                            if state_elapsed_time >= TR_TIME
                                bubble_rad = (state_elapsed_time - TR_TIME)*bubble_expand_rate;
                                if bubble_rad > TARG_LEN
                                    draw_bubble_flag = 0;
                                else
                                    screen_bubble_buff = [-bubble_rad; -bubble_rad; bubble_rad; bubble_rad];
                                    draw_bubble_flag = 1;
                                end
                            else
                                draw_bubble_flag = 0;
                            end
                            if home_dist > 15 && ~mov_begun
                                % movement just begun
                                mov_begun = 1;
                                move_start_time = (GetSecs - trial_time);
                                send_trigger = 1;
                                trigger_value = 85;
                                Data.time_movement_start(i_tr) = (GetSecs - exp_time);
                                %putvalue(dio,85); % send home state trig
                                %pause(interSample);
                                %putvalue(dio,0); %return trigger to 0
                            end
                            if home_dist > TARG_LEN && ~mov_ended
                                mov_ended = 1;
                                move_end_time = (GetSecs - trial_time);
                            end
                            if ((GetSecs - trial_time) - TR_state_time) > (TR_TIME - prescribed_PT(i_tr))
                                % time to show target once
                                if target_shown == 0
                                    k_oval_buff = k_oval_buff + 1;
                                    screen_oval_buff(:, k_oval_buff) = [targ_coords_base(trial_target_numbers(i_tr),:)'; targ_coords_base(trial_target_numbers(i_tr),:)'] + target_dims;
                                    screen_color_buff(:, k_oval_buff) = [0;0;0];
                                    target_shown = 1;
                                    target_shown_time = (GetSecs - trial_time);
                                    Data.time_targ_disp(i_tr) = (GetSecs - exp_time);
                                    send_trigger = 1;
                                    trigger_value = 170;
                                    %putvalue(dio,170); % send time_targ_disp trig
                                    %pause(interSample);
                                    %putvalue(dio,0); %return trigger to 0
                                else
                                    % no need to do anything
                                end
                            else
                                % wait for PT start time
                            end
                            if ((GetSecs - trial_time) - TR_state_time) > (TR_TIME + MOV_TIME)
                                % transition to ITI state
                                entrance = 1;
                                state = 'ITI';
                                if mov_begun
                                    Data.ViewTime(i_tr) = (target_shown_time - TR_state_time) - (move_start_time - TR_state_time);
                                    Data.RT(i_tr) = (move_start_time - TR_state_time) - TR_TIME;
                                end
                                if mov_ended
                                    Data.MT(i_tr) = move_end_time - move_start_time;
                                    Data.Succ(i_tr) = 1;
                                else
                                    Data.Succ(i_tr) = 0;
                                end
                            end
                        end
                    case 'ITI'
                        if entrance == 1
                            ITI_state_time = (GetSecs - trial_time);
                            draw_red_cursor_flag = 0;
                            draw_go_square_flag = 0;
                            if abs(Data.RT(i_tr)) >= TR_TOLERANCE && Data.RT(i_tr) >= 0
                                % movement was earlier than "go" cue &
                                % outside of tolerance
    %                             screen_text_buff = {'MOVED TOO LATE!'};
    %                             draw_text_flag = 1;
    %                             Screen('DrawText', win, 'MOVED TOO SOON!', 680, 525);
    %                             Screen('Flip', win);
                            elseif abs(Data.RT(i_tr)) > TR_TOLERANCE && Data.RT(i_tr) < 0
                                screen_text_buff = {''};
                                draw_text_flag = 1;
    %                             Screen('DrawText', win, 'MOVED TOO LATE!', 680, 525);
    %                             Screen('Flip', win);
                            else
                                % timing was within tolerance.. disp nothng
                            end
                            if Data.MT(i_tr) > MOV_LIMIT_TIME
    %                             screen_text_buff{length(screen_text_buff) + 1} = 'MOVED TOO SLOW!';
    %                             draw_text_flag = 1;
    %                             Screen('DrawText', win, 'MOVED TOO SLOWLY!', 680, 650);
    %                             Screen('Flip', win);
                            else
                                % MT was within tolerance... disp nothing
                            end
                            % save just in case:
                            Data.ViewTime = Data.pPT - Data.RT;
                            Data.x_track = x; Data.y_track = y; Data.t_track = tim;
                            save('last_trial_ecog_temp', 'Data');

                            % count trials from 1 to 10, repeat:
                            temp_count_tr = mod(i_tr-1, 10) + 1;
                            send_trigger = 1;
                            trigger_value = temp_count_tr;
                            %putvalue(dio,temp_count_tr); % send home state trig
                            %pause(interSample);
                            %putvalue(dio,0); %return trigger to 0

                            entrance = 0;
                        else
                            if ((GetSecs - trial_time) - ITI_state_time) > FB_TIME
                                % extinguish feedback
    %                             Screen('Flip', win);
                                draw_text_flag = 0;
                            end
                            if ((GetSecs - trial_time) - ITI_state_time) > (ITI_TIME)
                                % end trial
    %                             Screen('Flip', win);
                                draw_text_flag = 0;
                                Data.Kinematics{i_tr} = kinematics(~isnan(kinematics(:,1)), :);
                                Data.EventTimes{i_tr} = [flip_onset_times, stim_times, flip_offset_times];
                                state = 'end_state';
                            end
                        end
                    otherwise
                        error('No state specified');
                end
                k_samp = k_samp + 1;
            end
        end

    catch
        try
            warning('An error occured')
            Data.ViewTime = Data.pPT - Data.RT;
            uniqueness_code = now*10000000000;
            save([SUB_NUM_, num2str(uniqueness_code)], 'Data');
            varargout = {0, lasterror, Data, kinematics, delays};
            sca;
            return
        catch
            try
                sca
                return
            catch
                sca;
                clear all; close all; clc
                return
            end
        end
        sca
        return
    end
    Data.ViewTime = Data.pPT - Data.RT;
    Data.x_track = x; Data.y_track = y; Data.t_track = tim;
    varargout = {1, [], Data, kinematics, delays};
    uniqueness_code = now*10000000000;
    save([SUB_NUM_, num2str(uniqueness_code)], 'Data');

    %% between blocks break
    if block_num < 8 && quit_command == 0
        Screen('Flip', win);
        Screen('DrawText', win, 'This is a mandatory 10 second break.', round(screen_dims(1)/2), round(screen_dims(2)/2));
        Screen('Flip', win);

        pause(5);
        Screen('DrawText', win, '...5 more seconds', round(screen_dims(1)/2), round(screen_dims(2)/2));
        Screen('Flip', win);
        pause(5);
        Screen('DrawText', win, 'Beginning new block now...', round(screen_dims(1)/2), round(screen_dims(2)/2));
        Screen('Flip', win);
        pause(1);
    elseif quit_command == 1
        break
    end
end
Screen('Flip', win);
Screen('DrawText', win, 'This now completes the experiment. Thank you for participating.', round(screen_dims(1)/2), round(screen_dims(2)/2));
Screen('Flip', win);
pause(2)
sca;
