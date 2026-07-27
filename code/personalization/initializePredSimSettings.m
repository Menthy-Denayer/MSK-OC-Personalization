function S = initializePredSimSettings(params)
%% initializePredSimSettings 
% - Initializes some settings for running PredSim simulations
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% params                        | struct                        | Structure with settings
%   pathRepo                    | string                        | Path to the PredSim repository
%   modelSettings               | string                        | Path to the model settings file
%   modelPath                   | string                        | Path to the OpenSim model
%   predsimResultFolder         | string                        | Path to the PredSim results folder
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% S                             | struct                        | PredSim settings structure
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 29/November/2025

% Last Update: Menthy Denayer
% Date: 24/June/2026 

%% Add Path to Repository
addpath(params.pathRepo)

%% Find Repository Folder 
% path to the folder that contains the repository folder
% [pathRepoFolder,~,~] = fileparts(pathRepo);

%% Initialize Settings S
addpath(fullfile(params.pathRepo,'DefaultSettings'))

% if no reference path is specified, model settings are ignored
[S] = initializeSettings(params.modelSettings);

%% Settings

% CasADi path
S.solver.CasADi_path = "C:\Users\menth\Documents\Programmas\casadi-3.6.7-windows64-matlab2018b";

% name of the subject
[~,model_name,~] = fileparts(params.modelPath);
S.subject.name = model_name;

% path to folder where you want to store the results of the OCP
S.misc.save_folder = char(fullfile(params.predsimResultFolder, model_name)); 

% either choose "quasi-random" or give the path to a .mot file you want to use as initial guess
% S.solver.IG_selection = fullfile(S.misc.main_path,'OCP','IK_Guess_Full_GC.mot');
S.solver.IG_selection_gaitCyclePercent = 100;
% S.solver.IG_selection = 'quasi-random';

% choose speed
% S.misc.forward_velocity = params.forwardSpeed;

% solver settings
S.solver.run_as_batch_job = false;                                          % default false
S.solver.tol_ipopt = 1e-3;                                                  % default 4, equivalent to NLP err < 1-1e-2
S.solver.ipopt_options.print_level = 0;                                     % limit printing info
% S.solver.ipopt_options.warm_start_init_point = 'yes';
% S.solver.ipopt_options.warm_start_bound_push = 1e-6;
% S.solver.ipopt_options.warm_start_mult_bound_push = 1e-6;

end