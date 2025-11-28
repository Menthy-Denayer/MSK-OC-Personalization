function runPredictiveWalking_vBatch(coeffs0,params,modelFile,outputName)
%% Adapt OpenSim Model
muscleVarIdx = 1:params.Nmuscles*2;
adaptMTUparameters(coeffs0(muscleVarIdx),params,modelFile);

%% Set Predictive Walking Settings
S = params.S;
S.misc.result_filename = outputName;
S.solver.IG_selection = fullfile(params.kinematicsGuessFileMot);

%% Run Predictive Simulation
fprintf('Started predictive simulation at %s\n', datetime('now','format','HH:SS:MM'));

% run predictive simulation as batch
runPredSim(S, char(modelFile));

end