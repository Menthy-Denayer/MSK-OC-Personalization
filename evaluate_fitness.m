clear all
clc
close all

%% Select Result File
[file_name, DIR] = uigetfile(".mat", "Choose results file");
results = load(fullfile(DIR, file_name));

%% Select Desired Kinematics
[mot_file_name, mot_file_loc] = uigetfile(".mot", "Choose kinematics initial guess.");
KINdata = importdata(fullfile(mot_file_loc, mot_file_name));

%% Define Parameters
% kinematics reference
kinTime = KINdata.data(:,1); 
kinDuration = kinTime(end)-kinTime(1);
params.IKtime = kinTime/kinDuration;
% params.IKdesired = KINdata.data(:,5:10);                                    % 2D Tracking (hip, knee, ankle angles)
params.IKdesired = KINdata.data(:,2:20);                                      % all joint angles

% fitness shape
params.trackGRF = false;
params.IKweight = 1;
params.PennAnglePenalty = true;
params.PennAngleweight = 100;
params.lMoptPenalty = true;
params.lMoptweight = 100;
params.lTstrainPenalty = true;
params.lTstrainweight = 100;

% plotting
params.plot = false;

%% Compute Fitness
[f, cot] = compute_fitness(results.R, results.model_info, params);