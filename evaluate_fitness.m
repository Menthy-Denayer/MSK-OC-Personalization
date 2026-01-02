clear all
clc
close all

%% Import OpenSim Libraries
import org.opensim.modeling.*

%% Select Result File
[file_name, DIR] = uigetfile(".mat", "Choose results file");
results = load(fullfile(DIR, file_name));

%% Select Desired Kinematics
[mot_file_name, mot_file_loc] = uigetfile(".mot", "Choose kinematics initial guess.");
KINdata = importdata(fullfile(mot_file_loc, mot_file_name));

%% Select Generic OpenSim Model
[osim_file_name_generic, osim_file_loc_generic] = uigetfile(".osim","Choose Generic OpenSim model.");
genericModel = Model(fullfile(osim_file_loc_generic,osim_file_name_generic));

%% Select Optimal OpenSim Model
[osim_file_name_optimal, osim_file_loc_optimal] = uigetfile(".osim","Choose Optimal OpenSim model.");
optimalModel = Model(fullfile(osim_file_loc_optimal,osim_file_name_optimal));

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
params.PennAngleweight = 50;
params.lMoptPenalty = true;
params.lMoptweight = 25;
params.lTstrainPenalty = false;
params.lTstrainweight = 100;
params.paramDeviationPenalty = true;
params.paramDeviationweight = 10;

% plotting
params.plot = false;

%% Read Initial Coefficients
[lMoptGen, lTslackGen, ~] = readMTUparameters(genericModel);
[lMoptOpt, lTslackOpt, ~] = readMTUparameters(optimalModel);

%% Add Results to Parameters
sol = [lMoptOpt; lTslackOpt];
params.initialCoefficients = [lMoptGen; lTslackGen];

%% Compute Fitness
[f, cot] = compute_fitness(sol, results.R, results.model_info, params);