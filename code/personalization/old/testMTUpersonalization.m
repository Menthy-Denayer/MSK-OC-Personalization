clear all
clc
close all

%% Add Path
addpath('C:\Users\menth\Documents\Programmas\GitHub\MSK-OC-Personalization')
addpath("C:\Users\menth\Documents\Programmas\PredSim")

%% Import Libraries
import org.opensim.modeling.*

%% Choose Output Directory
pathOutputFolder = uigetdir("","Choose the output directory.");

%% Load Generic Model
[osim_file_name, osim_file_loc] = uigetfile(".osim","Choose OpenSim model.");
genericModel = Model(fullfile(osim_file_loc,osim_file_name));

%% Choose Generic Model Settings
[modelSettings_file_name, modelSettings_file_loc] = uigetfile(".m","Choose model settings file.");

%% Load Kinematics Initial Guess
[kin_file_name, kin_file_loc] = uigetfile(".mot", "Choose kinematics initial guess.");
KINdata = importdata(fullfile(kin_file_loc,kin_file_name));

%% Load GRF Initial Guess
% [grf_file_name, grf_file_loc] = uigetfile(".mot", "Choose GRF initial guess.");
% GRFdata = importdata(fullfile(grf_file_loc,grf_file_name));

%% Load Desired MTU Values
% [mtu_file_name, mtu_file_loc] = uigetfile(".mat", "Choose MTU desired values.");
% MTUdata = load(fullfile(mtu_file_loc, mtu_file_name));

%% Load Optimization Results
% CMAESres = load("variablescmaes.mat");
% optCoeffs = CMAESres.out.solutions.bestever.x;
% optCoeffs = CMAESres.xmin;

% optCoeffs = [optCoeffs; ones(9,1)];

CMASres = load("workerparam.mat");
optCoeffs = CMASres.data.xhist(:,1,161);

%% Choose Initial Conditions
[lMoptGen, lTslackGen, Fmax] = readMTUparameters(genericModel);
% initialCoefficients = [lMoptGen; lTslackGen; ones(9,1)*1.2];
initialCoefficients = [lMoptGen; lTslackGen];

%% Choose Simulation Parameters
% optimization parameters
params.rescaleF = false;
params.FmaxGen = Fmax;
params.initialCoefficients = initialCoefficients;                           % save generic parameters to use in optimization

% fitness shape
params.trackGRF = false;
params.IKweight = 1;
params.PennAnglePenalty = true;
params.PennAngleweight = 50;
params.lMoptPenalty = true;
params.lMoptweight = 25;
params.lTstrainPenalty = false;
params.lTstrainweight = 100;

% params.lMdesired = MTUdata.data.TracklMtilde;
% params.vMdesired = MTUdata.data.TrackvMtilde;
% params.lTdesired = MTUdata.data.TracklTtilde;
% params.FmaxGen = Fmax;

% normalize mtu time
% mtuTime = MTUdata.data.TrackTime; 
% mtuDuration = mtuTime(end)-mtuTime(1);
% params.mtuTime = mtuTime/mtuDuration;

% kinematics reference
kinTime = KINdata.data(:,1); 
kinDuration = kinTime(end)-kinTime(1);
params.IKtime = kinTime/kinDuration;
% params.IKdesired = KINdata.data(:,5:10); 
params.IKdesired = KINdata.data(:,2:20);

% GRF reference
% grfTime = GRFdata.data(:,1); 
% grfDuration = grfTime(end)-grfTime(1);
% params.GRFtime = grfTime/grfDuration;
% params.GRFdesired = GRFdata.data(:,[2:4,8:10]);

params.Nmuscles = size(lMoptGen,1);

% general settings
params.pathRepo = "C:\Users\menth\Documents\Programmas\PredSim";
params.kinematicsGuessFileMot = fullfile(kin_file_loc, kin_file_name); 
params.predsimResultFolder = pathOutputFolder;
params.modelPath = fullfile(osim_file_loc, osim_file_name);
params.modelSettings = fullfile(modelSettings_file_loc, modelSettings_file_name);
params.adaptedModelPath = "C:\Users\menth\Documents\Programmas\PredSim\Subjects\SUBJ06mtu3D\active\SUBJ06mtu3D.osim";
params.Nmuscles = size(lMoptGen,1);

%% Choose PredSim Settings
S = initializePredSimSettings(params);
S.subject.TrackKin = false;
S.subject.TrackGRF = false;
% S.solver.max_iter = 2e3; % temporary
S.misc.subject_path = 'C:\Users\menth\Documents\Programmas\PredSim\Subjects\SUBJ06mtu3D\active';
params.S = S;

%% Create Optimal Model
% outputName = 'optTrack';
% modelFile = replace(params.adaptedModelPath,'.osim','_optTrack.osim');
% adaptMTUparameters(optCoeffs, params, modelFile)
% adaptMTUparameters(initialCoefficients, params, "test.osim")

%% Create Parameter Plot
% Nparam = 1:9;
% modelMuscles = genericModel.getMuscles();
% Nmuscles = modelMuscles.getSize();
% muscleNames = strings(Nmuscles,1);
% for i = 1:Nmuscles
%     muscleNames(i) = modelMuscles.get(i-1).getName();
% end
% 
% baseMuscleNames = strrep(muscleNames,"_"," ");
% paramLabels = [strrep(baseMuscleNames(1:9)," r"," ") + " opt. fiber length"; 
%     strrep(baseMuscleNames(1:9)," r"," ") + " tendon slack length"];
% 
% % figure
% % hold on
% % bar(Nparam, [initialCoefficients(1:18) optCoeffs(1:18)],"grouped")
% % xticks(Nparam)
% % xticklabels(paramLabels)
% % hold off
% 
% difflM = (optCoeffs(1:9)-initialCoefficients(1:9))./initialCoefficients(1:9)*100;
% difflT = (optCoeffs(10:18)-initialCoefficients(10:18))./initialCoefficients(10:18)*100;
% 
% difflMbig = NaN(9,1); difflMbig(abs(difflM) > 15) = difflM(abs(difflM)>15);
% difflTbig = NaN(9,1); difflTbig(abs(difflT) > 15) = difflT(abs(difflT)>15);
% 
% figure
% hold on
% grid on
% bar(Nparam, difflM,"grouped")
% bar(Nparam, difflMbig,"grouped","red")
% xticks(Nparam)
% xticklabels(strrep(baseMuscleNames," r",""))
% ylabel("Relative Change [%]")
% title("Optimal Fibre Length")
% hold off
% 
% figure
% hold on
% grid on
% bar(Nparam, difflT,"grouped")
% bar(Nparam, difflTbig,"grouped","red")
% xticks(Nparam)
% xticklabels(strrep(baseMuscleNames," r",""))
% ylabel("Relative Change [%]")
% title("Tendon Slack Length")
% hold off

%% Run Predictive Simulation
outputName = 'optTrack';
modelFile = replace(params.adaptedModelPath,'.osim','_optTrack.osim');
% [f,cot] = runPredictiveWalking(initialCoefficients,params,modelFile,outputName);
[f,cot] = runPredictiveWalking(optCoeffs,params,modelFile,outputName);