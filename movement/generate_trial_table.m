function [trial_target_numbers, trial_type, prescribed_PT] = generate_trial_table(subject_code)

% *v7* randomizes trial type across blocks 4 - 6 (the experiment blocks)

%% Block 1 (Symbolic practice)
trial_type_begin_ = [ones(1,12)];
trial_type_begin_S1 = trial_type_begin_(randperm(length(trial_type_begin_)));
trial_target_numbers_begin_ = [ones(1,3), 2*ones(1,3), 3*ones(1,3), 4*ones(1,3)];
trial_target_numbers_begin_S1 = trial_target_numbers_begin_(randperm(length(trial_target_numbers_begin_)));
prescribed_PT_begin_S1 = .5*rand(1,12);%linspace(.8, 0, 12);

%% Block 2 (Direct practice)
% No catch trials
trial_type_begin_ = [zeros(1,12)];
trial_type_begin_D1 = trial_type_begin_(randperm(length(trial_type_begin_)));
trial_target_numbers_begin_ = [ones(1,3), 2*ones(1,3), 3*ones(1,3), 4*ones(1,3)];
trial_target_numbers_begin_D1 = trial_target_numbers_begin_(randperm(length(trial_target_numbers_begin_)));
prescribed_PT_begin_D1 = .5*rand(1,12); %linspace(.8, 0, 12);

%% Block 3 (No cue practice)
trial_type_begin_ = [zeros(1,6), ones(1,6)];
trial_type_begin_N1 = trial_type_begin_(randperm(length(trial_type_begin_)));
trial_target_numbers_begin_ = [ones(1,3), 2*ones(1,3), 3*ones(1,3), 4*ones(1,3)];
trial_target_numbers_begin_N1 = trial_target_numbers_begin_(randperm(length(trial_target_numbers_begin_)));
prescribed_PT_begin_N1 = .5*rand(1,12);%zeros(1,12); %linspace(.8, 0, 12);

%% Blocks 4, 7, 10 (Symbolic Main)
trial_target_seed = repmat(repmat(reshape(repmat(1:4, 3, 1), 1, 4*3), 1, 5), 1, 3);
trial_type_seed = repmat(repmat(repmat([1, 0, 1, 0], 1, 3), 1, 5), 1, 3);

trial_randomize = randperm(length(trial_target_seed));
trial_target_numbers_ = trial_target_seed(trial_randomize);
trial_type_ = trial_type_seed(trial_randomize);

gen_rand_PT = @() .5*rand(1,15); %zeros(1,15);%linspace(.8, 0, 15) + .015*(rand(1, 15) - .5);

prescribed_PT_ = [gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT()];

trial_target_catch_seed = [1:4, 1:4, 1:4, 1:4, 1:4];
trial_type_catch_seed = [[3*ones(1,4)], [3*ones(1,4)], [3*ones(1,4)], [3*ones(1,4)], [3*ones(1,4)]];
trial_catch_randomize = randperm(length(trial_target_catch_seed));
trial_target_catch = trial_target_catch_seed(trial_catch_randomize);
trial_type_catch = trial_type_catch_seed(trial_catch_randomize);
prescribed_PT_catch = .400+.200*rand(1,length(trial_target_catch_seed));

l1 = length([trial_type_begin_S1, trial_type_begin_D1, trial_type_begin_N1]);
l2 = length(trial_type_)/3;
l3 = length(trial_type_catch);

all_trial_inds = 1:(l1 + l2*3 + l3);
catch_trial_patches = l1+[((l1+1):(l2+5)), (l2+5)+((l1+1):(l2+5)), (l2+5)*2+((l1+1):(l2+6))];
rand_inds = randperm(length(catch_trial_patches));
catch_trial_inds = catch_trial_patches(rand_inds(1:l3));
non_catch_trial_inds = setdiff(all_trial_inds, catch_trial_inds);

trial_type_S = nan(1, length(all_trial_inds));
trial_target_numbers_S = nan(1, length(all_trial_inds));
prescribed_PT_S = nan(1, length(all_trial_inds));

trial_type_S(non_catch_trial_inds) = [trial_type_begin_S1, trial_type_begin_D1, trial_type_begin_N1, trial_type_];
trial_target_numbers_S(non_catch_trial_inds) = [trial_target_numbers_begin_S1, trial_target_numbers_begin_D1, trial_target_numbers_begin_N1, trial_target_numbers_];
prescribed_PT_S(non_catch_trial_inds) = [prescribed_PT_begin_S1, prescribed_PT_begin_D1, prescribed_PT_begin_N1, prescribed_PT_];
trial_type_S(catch_trial_inds) = trial_type_catch;
trial_target_numbers_S(catch_trial_inds) = trial_target_catch;
prescribed_PT_S(catch_trial_inds) = prescribed_PT_catch;

%% Blocks 5, 8, 11 (Direct Main)
trial_target_seed = repmat(repmat(reshape(repmat(1:4, 3, 1), 1, 4*3), 1, 5), 1, 3);
trial_type_seed = repmat(repmat(repmat([1, 1, 1], 1, 4), 1, 5), 1, 3);

trial_randomize = randperm(length(trial_target_seed));
trial_target_numbers_ = trial_target_seed(trial_randomize);
trial_type_ = trial_type_seed(trial_randomize);

gen_rand_PT = @() .5*rand(1,15); %zeros(1,15);%linspace(.8, 0, 15) + .015*(rand(1, 15) - .5);

prescribed_PT_ = [gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT()];

trial_target_catch_seed = [1:4, 1:4, 1:4, 1:4, 1:4];
trial_type_catch_seed = [[3*ones(1,4)], [3*ones(1,4)], [3*ones(1,4)], [3*ones(1,4)], [3*ones(1,4)]];
trial_catch_randomize = randperm(length(trial_target_catch_seed));
trial_target_catch = trial_target_catch_seed(trial_catch_randomize);
trial_type_catch = trial_type_catch_seed(trial_catch_randomize);
prescribed_PT_catch = .400+.200*rand(1,length(trial_target_catch_seed));

l1 = length([trial_type_S]);
l2 = length(trial_type_)/3;
l3 = length(trial_type_catch);

all_trial_inds = 1:(l1 + l2*3 + l3);
catch_trial_patches = l1+[((1):(l2+5)), (l2+5)+((1):(l2+5)), (l2+5)*2+((1):(l2+6))];
rand_inds = randperm(length(catch_trial_patches));
catch_trial_inds = catch_trial_patches(rand_inds(1:l3));
non_catch_trial_inds = setdiff(all_trial_inds, catch_trial_inds);

trial_type_D = nan(1, length(all_trial_inds));
trial_target_numbers_D = nan(1, length(all_trial_inds));
prescribed_PT_D = nan(1, length(all_trial_inds));

trial_type_D(non_catch_trial_inds) = [trial_type_S, trial_type_];
trial_target_numbers_D(non_catch_trial_inds) = [trial_target_numbers_S, trial_target_numbers_];
prescribed_PT_D(non_catch_trial_inds) = [prescribed_PT_S, prescribed_PT_];
trial_type_D(catch_trial_inds) = trial_type_catch;
trial_target_numbers_D(catch_trial_inds) = trial_target_catch;
prescribed_PT_D(catch_trial_inds) = prescribed_PT_catch;

%% Blocks 6, 9, 12 (Direct Main)
trial_target_seed = repmat(repmat(reshape(repmat(1:4, 3, 1), 1, 4*3), 1, 5), 1, 3);
trial_type_seed = repmat(repmat(repmat([0, 0, 0], 1, 4), 1, 5), 1, 3);

trial_randomize = randperm(length(trial_target_seed));
trial_target_numbers_ = trial_target_seed(trial_randomize);
trial_type_ = trial_type_seed(trial_randomize);

gen_rand_PT = @() .5*rand(1,15); %zeros(1,15);%linspace(.8, 0, 15) + .015*(rand(1, 15) - .5);

prescribed_PT_ = [gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT(),...
    gen_rand_PT(), gen_rand_PT(), gen_rand_PT()];

trial_target_catch_seed = [1:4, 1:4, 1:4, 1:4, 1:4];
trial_type_catch_seed = [[0*ones(1,4)], [0*ones(1,4)], [0*ones(1,4)], [0*ones(1,4)], [0*ones(1,4)]];
trial_catch_randomize = randperm(length(trial_target_catch_seed));
trial_target_catch = trial_target_catch_seed(trial_catch_randomize);
trial_type_catch = trial_type_catch_seed(trial_catch_randomize);
prescribed_PT_catch = .400+.200*rand(1,length(trial_target_catch_seed));

l1 = length([trial_type_D]);
l2 = length(trial_type_)/3;
l3 = length(trial_type_catch);

all_trial_inds = 1:(l1 + l2*3 + l3);
catch_trial_patches = l1+[((1):(l2+5)), (l2+5)+((1):(l2+5)), (l2+5)*2+((1):(l2+6))];
rand_inds = randperm(length(catch_trial_patches));
catch_trial_inds = catch_trial_patches(rand_inds(1:l3));
non_catch_trial_inds = setdiff(all_trial_inds, catch_trial_inds);

trial_type = nan(1, length(all_trial_inds));
trial_target_numbers = nan(1, length(all_trial_inds));
prescribed_PT = nan(1, length(all_trial_inds));

trial_type(non_catch_trial_inds) = [trial_type_D, trial_type_];
trial_target_numbers(non_catch_trial_inds) = [trial_target_numbers_D, trial_target_numbers_];
prescribed_PT(non_catch_trial_inds) = [prescribed_PT_D, prescribed_PT_];
trial_type(catch_trial_inds) = trial_type_catch;
trial_target_numbers(catch_trial_inds) = trial_target_catch;
prescribed_PT(catch_trial_inds) = prescribed_PT_catch;
prescribed_retTime = 2 + rand(1,length(prescribed_PT));

%% save subject data
rind_ = randperm(length(trial_type) - 36);
rind = rind_ + 36;
trial_type = [trial_type(1:36), trial_type(rind)];

save(['trial_parameters_', subject_code], 'trial_target_numbers', 'trial_type', 'prescribed_PT', 'prescribed_retTime');


