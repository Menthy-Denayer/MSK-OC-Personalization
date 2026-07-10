clear all
clc
close all

%% Import OpenSim Libraries
import org.opensim.modeling.*

%% Select Result File
[res_file_name, res_DIR] = uigetfile(".mat", "Choose results file");
results = load(fullfile(res_DIR, res_file_name));

%% Select Generic File
[gen_file_name, gen_DIR] = uigetfile(".mat", "Choose results file");
generic = load(fullfile(gen_DIR, gen_file_name));

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
[IKdata, normTime] = loadIKdata(fullfile(mot_file_loc, mot_file_name),"mtp");
paramsOpt.IKtime = normTime;
paramsOpt.IKdesired = IKdata;
paramsOpt.ExcludeTrackingJoints = 'mtp';

% fitness shape
paramsOpt.trackGRF = false;
paramsOpt.IKweight = 1;
paramsOpt.PennAnglePenalty = true;
paramsOpt.PennAngleweight = 50;
paramsOpt.lMoptPenalty = true;
paramsOpt.lMoptweight = 100;
paramsOpt.lTstrainPenalty = true;
paramsOpt.lTstrainweight = 1;
paramsOpt.paramDeviationPenalty = true;
paramsOpt.paramDeviationweight = 10;
paramsOpt.FpassPenalty = true;
paramsOpt.Fpassweight = 50;
paramsOpt.FpassWorkPenalty = false;
paramsOpt.FpassWorkweight = 50;

% plotting
paramsOpt.plot = false;

%% Read Initial Coefficients
[lMoptGen, lTslackGen, ~] = readMTUparameters(genericModel);
[lMoptOpt, lTslackOpt, ~] = readMTUparameters(optimalModel);

%% Add Results to Parameters
sol = [lMoptOpt; lTslackOpt];
gen = [lMoptGen; lTslackGen];
paramsOpt.initialCoefficients = [lMoptGen; lTslackGen];

paramsGen = paramsOpt;

%% Compute Fitness
[fOpt, cotOpt] = compute_fitness(sol, results.R, results.model_info, paramsOpt);
[fGen, cotGen] = compute_fitness(gen, generic.R, generic.model_info, paramsGen);