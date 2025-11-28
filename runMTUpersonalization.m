clear all
clc
close all

%% Add Path
addpath('C:\Users\menth\Documents\Universiteit\FWO\T1.3')
addpath("C:\Users\menth\Documents\Programmas\PredSim")

%% Import Libraries
import org.opensim.modeling.*

%% Choose Initial Settings
init_option = questdlg('How to initialize muscle parameters?', ...
	'Initial Coefficients', ...
	'Scaled Model','Existing Solution','cancel','cancel');

%% Choose Output Directory
pathOutputFolder = uigetdir("","Choose the output directory.");

%% Load Generic Model
[osim_file_name, osim_file_loc] = uigetfile(".osim","Choose OpenSim model.");
genericModel = Model(fullfile(osim_file_loc,osim_file_name));

%% Choose Generic Model Settings
[modelSettings_file_name, modelSettings_file_loc] = uigetfile(".m","Choose model settings file.");

%% Load Kinematics Initial Guess
% [mot_file_name, mot_file_loc] = uigetfile(".sto", "Choose kinematics initial guess.");
[mot_file_name, mot_file_loc] = uigetfile(".mot", "Choose kinematics initial guess.");
KINdata = importdata(fullfile(mot_file_loc,mot_file_name));

%% Load GRF Initial Guess
% [grf_file_name, grf_file_loc] = uigetfile(".mot", "Choose GRF initial guess.");
% GRFdata = importdata(fullfile(grf_file_loc,grf_file_name));

%% Load Desired MTU Values
% [mtu_file_name, mtu_file_loc] = uigetfile(".mat", "Choose MTU desired values.");
% MTUdata = load(fullfile(mtu_file_loc, mtu_file_name));

%% Initialize Optimization 

switch init_option
    case 'Scaled Model'
        [lMoptGen, lTslackGen, Fmax] = readMTUparameters(genericModel);
    case 'Existing Solution'
        [solFile, solDIR] = uigetfile(".mat","Choose existing solution.");
        sol = load(fullfile(solDIR, solFile));
        param = sol.bestever.x;
        lMoptGen = param(1:14); 
        lTslackGen = param(15:end);
end
max_ce_vel = 10;                                                            % standard value

%% Choose Simulation Parameters
params.rescaleF = true;
params.FmaxGen = Fmax;
params.plot = false;
params.trackGRF = false;
params.pathRepo = "C:\Users\menth\Documents\Programmas\PredSim";
params.kinematicsGuessFileMot = fullfile(mot_file_loc, mot_file_name);
% params.kinematicsGuessFileMot = "C:\Users\menth\Documents\Programmas\PredSim\OCP\IK_Guess_Full_GC.mot"; 
params.predsimResultFolder = pathOutputFolder;
params.modelPath = fullfile(osim_file_loc, osim_file_name);
params.modelSettings = fullfile(modelSettings_file_loc, modelSettings_file_name);

% params.lMdesired = MTUdata.data(:,20:37);
% params.vMdesired = MTUdata.data(:,38:end)/max_ce_vel;
% params.lTdesired = 1+MTUdata.data(:,2:19);
% params.mtuTime = MTUdata.data(:,1);
% params.lMdesired = MTUdata.data.TracklMtilde;
% params.vMdesired = MTUdata.data.TrackvMtilde;
% params.lTdesired = MTUdata.data.TracklTtilde;

% normalize mtu time
% mtuTime = MTUdata.data.TrackTime; 
% mtuDuration = mtuTime(end)-mtuTime(1);
% params.mtuTime = mtuTime/mtuDuration;

% kinematics reference
kinTime = KINdata.data(:,1); 
kinDuration = kinTime(end)-kinTime(1);
params.IKtime = kinTime/kinDuration;
% params.IKdesired = KINdata.data(:,5:10);                                    % 2D Tracking (hip, knee, ankle angles)
params.IKdesired = KINdata.data(:,2:20);                                      % all joint angles
% params.IKtime = KINdata.data(:,1);

% GRF reference
% grfTime = KINdata.data(:,1); 
% grfDuration = grfTime(end)-grfTime(1);
% params.GRFtime = grfTime/grfDuration;
% params.GRFdesired = GRFdata.data(:,[2:4,8:10]);

params.adaptedModelPath = "C:\Users\menth\Documents\Programmas\PredSim\Subjects\SUBJ06mtu3D\active\SUBJ06mtu3D.osim";
params.Nmuscles = size(lMoptGen,1);

%% Choose Initial Conditions
% muscle initial values
genericMuscleValues = [lMoptGen; lTslackGen];
MusclesAllowedChange = 0.20;    
muscleBounds = [genericMuscleValues-MusclesAllowedChange*genericMuscleValues, ...
    genericMuscleValues+MusclesAllowedChange*genericMuscleValues];

% maximal isometric force initial values
% genericMaxForce = ones(params.Nmuscles,1);
% maxForceBounds = ones(params.Nmuscles,2); maxForceBounds(:,1) = maxForceBounds(:,1)*0.5;
% maxForceBounds(:,2) = maxForceBounds(:,2)*1.5;

% cost function initial values
% wE = 500;
% wEexp = 2;
% wqdotdot = 5e4;
% wetorqAct = 1e6;
% wpasstorq = 1e3;
% wpasstorq_includesdamping = 0;
% wa = 2e3;
% waexp = 2;
% wslack_ctrl = 1e-3;

% initialCostWeights = ones(6,1);
% CostAllowedChange = 0.50;    
% costBounds = [initialCostWeights-CostAllowedChange*initialCostWeights, ...
%     initialCostWeights+CostAllowedChange*initialCostWeights];

% all initial values
% initialCoefficients = [genericMuscleValues; genericMaxForce];
% bounds = [muscleBounds; maxForceBounds];
% initialCoefficients = [genericMuscleValues; initialCostWeights];
% bounds = [muscleBounds; costBounds];
initialCoefficients = genericMuscleValues;
bounds = muscleBounds;
params.initialCoefficients = genericMuscleValues;                           % save generic parameters to use in optimization

%% Choose PredSim Settings
S = initializePredSimSettings(params);
S.subject.TrackKin = false;
S.subject.TrackGRF = false;
S.solver.max_iter = 2e3;                                                    % after 2000 iterations the optimization stops
% S.solver.IG_selection_gaitCyclePercent = 100;                               % IG represents 2 gait cycles

% S.weights.q_dotdot = 0;
% S.weights.pass_torq = 0;

S.solver.run_as_batch_job = true;
S.misc.subject_path = 'C:\Users\menth\Documents\Programmas\PredSim\Subjects\SUBJ06mtu3D\active';
params.S = S;

%% Choose CMA-ES Settings
sigma0 = [];                                                                % percentage of change allowed from generic values

% Options
opts = cmaes('defaults');
opts.EvalParallel = 'on';
opts.MaxFunEvals = 2000;
opts.PopSize = 8;                                                           % matched to number of workers for parallelization
opts.Restarts = 0;
opts.LBounds = bounds(:,1);                                                 % lower bounds
opts.UBounds = bounds(:,2);                                                 % upper bounds
opts.Resume = 1;                                                            % resume from best 
opts.SaveVariables = 'on';

%% Start Parallel Pool
% parpool('local');

%% Run CMA-ES
[xmin, fmin] = cmaes('parallelObjectiveWrapper', initialCoefficients, sigma0, opts, params);

%% Plot CMA-ES Stats
plotcmaesdat()

%% Plot Results

% figure
% hold on
% plot(1:Nvar)
% hold off