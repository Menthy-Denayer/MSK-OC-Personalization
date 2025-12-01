% --------------------------------------------------------------------------
% run_on_VSC_cluster
%   Run personalization on the VSC cluster. VUB provides compute resources to 
%   researchers in the High Performance Computing service. The HPC clusters 
%   of VUB are part of the Vlaams Supercomputer Centrum  (VSC).
% 
%   https://hpc.vub.be/
%   https://www.vscentrum.be/
%
% Original author: Lars D'Hondt
% Original date: 01/October/2025
%
% Last edit by: Menthy Denayer
% Last edit date: 29/11/2025 
% 
% --------------------------------------------------------------------------

clear
close all
clc

%% Add PredSim Path
[pathPerDir,~,~] = fileparts(mfilename('fullpath'));
[pathVSC_DATADir,~,~] = fileparts(pathPerDir);
pathPredSimDir = fullfile(pathVSC_DATADir,'PredSim');
addpath(pathPredSimDir);
addpath(pathPerDir);

%% Required Paths 
% Check BLAS/LAPACK version; add functions from LinearAlgebra subdirectory
% to path in case Intel is *not* used
blas_version = version('-blas');
lapack_version = version('-lapack');
if ~startsWith(lapack_version, 'Intel')
    % addpath(fullfile(getenv('PWD'), 'LinearAlgebra'))
    addpath(fullfile(pathPredSimDir,'LinearAlgebra'))
end

% [pathExDir,~,~] = fileparts(mfilename('fullpath'));
% [pathRepo,~,~] = fileparts(pathExDir);
% [pathRepoFolder,~,~] = fileparts(pathRepo);

addpath(fullfile(pathPredSimDir,'DefaultSettings'))
% addpath(pathRepo)

% if the OpenSim module is loaded, make its Java library available
if isenv('EBROOTOPENSIM')
    javaclasspath(fullfile(getenv('EBROOTOPENSIM'), 'sdk', 'Java', 'org-opensim-modeling.jar'));
end

% if the CasADi-MATLAB module is loaded, expose its matlab bindings
if isenv('EBROOTCASADI')
    addpath(fullfile(getenv('EBROOTCASADI'), 'matlab'))
end

%% Import Libraries
import org.opensim.modeling.*

%% Choose Initial Settings
init_option = 'Scaled Model';

%% Choose Output Directory
pathOutputFolder = fullfile(pathVSC_DATADir, 'PredSimResults');

%% Load Generic Model
subj_name = 'SUBJ06mtu3D';
osim_file_name = [subj_name, '.osim'];
osim_file_loc = fullfile(pathPredSimDir,'Subjects',subj_name);
genericModel = Model(fullfile(osim_file_loc,osim_file_name));

%% Choose Generic Model Settings
modelSettings_file_name = ['settings_', subj_name, '.mat'];
modelSettings_file_loc = osim_file_loc;

%% Load Kinematics Initial Guess
mot_file_name = 'SUBJ06_gait1422_vTrackCost2e7-5e7-1GC.mot';
mot_file_loc = osim_file_loc;
KINdata = importdata(fullfile(mot_file_loc,mot_file_name));

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
% optimization parameters
params.rescaleF = true;
params.FmaxGen = Fmax;

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

% kinematics reference
kinTime = KINdata.data(:,1); 
kinDuration = kinTime(end)-kinTime(1);
params.IKtime = kinTime/kinDuration;
% params.IKdesired = KINdata.data(:,5:10);                                    % 2D Tracking (hip, knee, ankle angles)
params.IKdesired = KINdata.data(:,2:20);                                      % all joint angles

% general settings
params.adaptedModelPath = fullfile(osim_file_loc,'active',osim_file_name);
params.Nmuscles = size(lMoptGen,1);
params.pathRepo = pathPredSimDir;
params.kinematicsGuessFileMot = fullfile(mot_file_loc, mot_file_name); 
params.predsimResultFolder = pathOutputFolder;
params.modelPath = fullfile(osim_file_loc, osim_file_name);
params.modelSettings = fullfile(modelSettings_file_loc, modelSettings_file_name);

%% Choose Initial Conditions
% muscle initial values
genericMuscleValues = [lMoptGen; lTslackGen];
MusclesAllowedChange = 0.20;    
muscleBounds = [genericMuscleValues-MusclesAllowedChange*genericMuscleValues, ...
    genericMuscleValues+MusclesAllowedChange*genericMuscleValues];

initialCoefficients = genericMuscleValues;
bounds = muscleBounds;
params.initialCoefficients = genericMuscleValues;                           % save generic parameters to use in optimization

%% Choose PredSim Settings
S = initializePredSimSettings(params);
S.subject.TrackKin = false;
S.subject.TrackGRF = false;
S.solver.max_iter = 2e3;                                                    % after 2000 iterations the optimization stops
% S.solver.IG_selection_gaitCyclePercent = 100;                             % IG represents 1 gait cycle

S.solver.run_as_batch_job = true;
S.misc.subject_path = fullfile(osim_file_loc,'active');
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
opts.Resume = 0;                                                            % resume from best 
opts.SaveVariables = 'on';

%% Run CMA-ES
[xmin, fmin] = cmaes('parallelObjectiveWrapper', initialCoefficients, sigma0, opts, params);

%% Plot CMA-ES Stats
% plotcmaesdat()
