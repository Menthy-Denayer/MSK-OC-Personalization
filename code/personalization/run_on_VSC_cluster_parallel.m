% --------------------------------------------------------------------------
% run_on_VSC_cluster_parallel
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

%% OpenSim Libraries
% jlpath = char(java.lang.System.getProperty('java.library.path'));
% newpath = [jlpath ':' getenv('EBROOTOPENSIM') '/sdk/lib'];
% java.lang.System.setProperty('java.library.path', newpath);


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
subj_name = 'SUBJ09mtu3D';
osim_file_name = [subj_name, '.osim'];
osim_file_loc = fullfile(pathPredSimDir,'Subjects',subj_name);
genericModel = Model(fullfile(osim_file_loc,osim_file_name));

%% Choose Generic Model Settings
modelSettings_file_name = ['settings_', subj_name, '.m'];
modelSettings_file_loc = osim_file_loc;

%% Load Kinematics Initial Guess
mot_file_name = 'SUBJ09_gait1422_MTPjoint_11453296_zeroMTP.mot';
% mot_file_name = 'SUBJ06_gait1422-1GC.mot';
mot_file_loc = osim_file_loc;
% KINdata = importdata(fullfile(mot_file_loc,mot_file_name));

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
params.rescaleF = false;
params.FmaxGen = Fmax;
params.includeTendonStiffness = false;
params.tendonStiffnessMuscles = ["gastroc", "soleus"];                      % scale tendon stiffness of these muscles
params.tendonStiffnessDefault = [0.5; 0.5];                                 % default tendon stiffness (initial guess)
tendonStiffnessMin = 0.4;                                                   % min. allowed tendon stiffness
tendonStiffnessMax = 0.6;                                                   % max. allowed tendon stiffness
NtendonStiffnessMuscles = length(params.tendonStiffnessDefault);            % number of muscles to scale tendon stiffness 

% fitness shape
params.trackGRF = false;
params.IKweight = 1;
params.PennAnglePenalty = true;
params.PennAngleweight = 50;
params.lMoptPenalty = true;
params.lMoptweight = 100;
params.lTstrainPenalty = true;
params.lTstrainweight = 1;
params.paramDeviationPenalty = true;
params.paramDeviationweight = 10;
% params.FpassWorkPenalty = false;
% params.FpassWorkweight = 2;
params.FpassPenalty = true;
params.Fpassweight = 50;
% params.StrideFreqPenalty = false;
% params.StrideFreqweight = 50;
% params.desired_stride_freq = 0.8363;                                        % stride frequency for SUBJ11

% plotting
params.plot = false;

% kinematics reference
[IKdata, normTime] = loadIKdata(fullfile(mot_file_loc, mot_file_name),"mtp");
params.IKtime = normTime;
params.IKdesired = IKdata;
params.ExcludeTrackingJoints = 'mtp';

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

% muscle properties
% initialCoefficients = genericMuscleValues;
% bounds = muscleBounds;
% params.initialCoefficients = genericMuscleValues;                           % save generic parameters to use in optimization

% muscles properties + tendon stiffness
% initialCoefficients = [genericMuscleValues; params.tendonStiffnessDefault];
initialCoefficients = genericMuscleValues;

tendonBounds = [ones(NtendonStiffnessMuscles,1)*tendonStiffnessMin ones(NtendonStiffnessMuscles,1)*tendonStiffnessMax];

% bounds = [muscleBounds; tendonBounds];
bounds = muscleBounds;

% params.initialCoefficients = initialCoefficients;                           % save generic parameters to use in optimization
params.initialCoefficients = genericMuscleValues;

%% Choose PredSim Settings
S = initializePredSimSettings(params);
S.subject.TrackKin = false;
S.subject.TrackGRF = false;
S.solver.max_iter = 2e3;                                                    % after 2000 iterations the optimization stops
% S.solver.IG_selection_gaitCyclePercent = 100;                             % IG represents 1 gait cycle

S.solver.run_as_batch_job = true;
S.misc.subject_path = fullfile(osim_file_loc,'active');
params.S = S;

%% Create CMA-ES Results Folder
cmaesResultsFolder = [params.S.subject.name '_' char(strrep(char(datetime("now","Format","MM:DD:HH:mm")),":",""))];
cmaesResultsDir = fullfile(fullfile('results',cmaesResultsFolder));
params.cmaesResultsDir = cmaesResultsDir; 
mkdir(cmaesResultsDir)
mkdir(fullfile(cmaesResultsDir,'best'))                                     % to save best workers
mkdir(fullfile(cmaesResultsDir,'worst'))                                    % to save worst workers

%% Choose CMA-ES Settings
sigma0 = [];                                                                % percentage of change allowed from generic values
% sigma0 = 0.15 * (bounds(:,2)-bounds(:,1));                                  % make sigma0 smaller to account for not wanting to deviate as much from initial parameters

% Options
opts = cmaes('defaults');
opts.EvalParallel = 'on';
opts.MaxFunEvals = 2000;
opts.PopSize = 10;                                                           % matched to number of workers for parallelization
opts.Restarts = 0;
opts.LBounds = bounds(:,1);                                                 % lower bounds
opts.UBounds = bounds(:,2);                                                 % upper bounds
opts.Resume = 0;                                                            % resume from best 
opts.SaveVariables = 'on';
opts.SaveFilename = fullfile(cmaesResultsDir, 'variablescmaes.mat');
opts.LogFilenamePrefix = fullfile(cmaesResultsDir,'outcmaes');

%% Start Parallel Pool
% parpool('Processes', 8);
c = parcluster;
delete(c.Jobs);

%% Run CMA-ES
[xmin, fmin] = cmaes('parallelObjectiveWrapper', initialCoefficients, sigma0, opts, params);

%% Plot CMA-ES Stats
% plotcmaesdat()