function runPredictiveWalking_vBatch(coeffs0,params,modelFile,outputName)
%% runPredictiveWalking_vBatch 
% - Starts the predictive PredSim simulations for the desired set of 
%   parameters
%
%------------------------------------------------------------- INPUTS ---------------------------------------------------------------------------------
% coeffs0                       | Nmuscles x 1 Double Array                 | OpenSim model to read parameters from
% params                        | struct                                    | Optimization settings structure
%   S                           | struct                                    | PredSim settings structure
%   includeTendonStiffness      | boolean                                   | Whether to include the tendon stiffness scale as an adjustable parameter
%   tendonStiffnessDefault      | boolean                                   | Default muscle tendon stiffness
%   tendonStiffnessMuscles      | string                                    | Names of muscle to adapt muscle tendon stiffness for
%   kinematicsGuessFileMot      | string                                    | Path of the IK initial guess
%   Nmuscles                    | double                                    | Number of muscles in the model
% modelFile                     | string                                    | Path to the OpenSim model file
% outputName                    | string                                    | Name of the PredSim results files
%
%------------------------------------------------------------- OUTPUTS --------------------------------------------------------------------------------
%
%
%----------------------------------------------------------- REQUIREMENTS -----------------------------------------------------------------------------
% 
%
%------------------------------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 29/November/2025

% Last Update: Menthy Denayer
% Date: 24/June/2026

%% Adapt OpenSim Model
muscleVarIdx = 1:params.Nmuscles*2;
adaptMTUparameters(coeffs0(muscleVarIdx),params,modelFile);

%% Set Predictive Walking Settings
S = params.S;
S.misc.result_filename = outputName;
S.solver.IG_selection = fullfile(params.kinematicsGuessFileMot);

%% Change Tendon Stiffness Scale
if(params.includeTendonStiffness)
    Nmuscles = length(params.tendonStiffnessDefault);
    stiff_cell = [];
    for m = 1:Nmuscles
        stiff_cell = [stiff_cell, {{char(params.tendonStiffnessMuscles(m))}, coeffs0(params.Nmuscles*2+m)}];
    end
    S.subject.tendon_stiff_scale = stiff_cell;  
end

%% Run Predictive Simulation
fprintf('Started predictive simulation at %s\n', datetime('now','format','HH:mm:ss'));

% run predictive simulation as batch
runPredSim(S, char(modelFile));

end