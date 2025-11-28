function [f,cot] = runPredictiveWalking(coeffs0,params,modelFile,outputName)
%% Adapt OpenSim Model
muscleVarIdx = 1:params.Nmuscles*2;
adaptMTUparameters(coeffs0(muscleVarIdx),params,modelFile);

%% Set Predictive Walking Settings
S = params.S;
S.misc.result_filename = outputName;
S.solver.IG_selection = fullfile(params.kinematicsGuessFileMot);
% S.solver.IG_selection_gaitCyclePercent = 200;

%% Set Cost Function Weights
% S.weights.E = coeffs0(params.Nmuscles*2+1)*500;
% S.weights.E_exp = coeffs0(params.Nmuscles*2+2)*2;
% S.weights.q_dotdot = coeffs0(params.Nmuscles*2+2)*5e4;
% S.weights.e_torqAct = coeffs0(params.Nmuscles*2+3)*1e6;
% S.weights.pass_torq = coeffs0(params.Nmuscles*2+4)*1e3;
% S.weights.pass_torq_includes_damping = 0;
% S.weights.a = coeffs0(params.Nmuscles*2+5)*2e3;
% S.weights.a_exp = coeffs0(params.Nmuscles*2+7)*2;
% S.weights.slack_ctrl = coeffs0(params.Nmuscles*2+6)*1e-3;

%% Run Predictive Simulation
fprintf('Started predictive simulation at %s\n', datetime('now','format','HH:SS:MM'));

% run predictive simulation for at most 20min
[~,R,model_info] = runPredSim(S, char(modelFile));

%% Compute Cost Function
% load results data
predictionTime = R.time.mesh_GC;

% lMpred = R.muscles.lMtilde;
% vMpred = predictionResults.R.muscles.vMtilde;
% lTslack = [model_info.muscle_info.parameters.lTs];
% lTpred = R.muscles.lT./lTslack;

% resample data to match desired values
duration = predictionTime(end-1)-predictionTime(1);
norm_time = (predictionTime(1:end-1)-predictionTime(1))/duration;

% lMsyn = interp1(norm_time, lMpred, params.mtuTime, "linear");
% vMsyn = interp1(norm_time, vMpred, params.mtuTime, "linear");
% lTsyn = interp1(norm_time, lTpred, params.mtuTime, "linear");

% muscleNames = strrep(string(model_info.muscle_info.muscle_names),"_"," ");
% Nmuscles = length(muscleNames);
% 
% for i = 1:Nmuscles
%     figure
%     hold on
%     plot(params.mtuTime, lMsyn(:,i), "red")
%     plot(params.mtuTime, params.lMdesired(:,i), "blue")
%     legend(["predicted", "desired"])
%     title(muscleNames(i) + " fiber length")
%     hold off
% 
%     figure
%     hold on
%     plot(params.mtuTime, lTsyn(:,i), "red")
%     plot(params.mtuTime, params.lTdesired(:,i), "blue")
%     legend(["predicted", "desired"])
%     title(muscleNames(i) + " tendon slack length")
%     hold off
% end

%% Compute kinematics error
f = 0;
% f = f + sum(rmse(lMsyn, params.lMdesired, 1));
% f = f + sum(rmse(lTsyn, params.lTdesired, 1));
% f = f + sum(rmse(vMsyn, params.vMdesired, 1));

% IKpred = R.kinematics.Qs(:,4:end-1);                                      % 2D Tracking
IKpred = R.kinematics.Qs;                                                   % all joint angles
IKsync = interp1(norm_time,IKpred,params.IKtime,"linear");
IKerr = sum(rmse(IKsync,params.IKdesired));

f = f + IKerr;

%% Compute GRF error
if(params.trackGRF)
    GRFpred = [R.ground_reaction.GRF_r R.ground_reaction.GRF_l];                % all ground reaction forces
    GRFsync = interp1(norm_time,GRFpred,params.GRFtime,"linear");
    GRFerr = sum(rmse(GRFsync,params.GRFdesired));
    f = f + GRFerr*0.2;
end

%% Create plot
if(params.plot)
    Nkin = size(IKpred,2);
    % kinNames = string(R.colheaders.coordinates(4:end-1));                 % 2D Tracking joint angle names
    kinNames = string(R.colheaders.coordinates);                            % joint angle names
    for i = 1:Nkin
        figure
        hold on
        plot(params.IKtime, IKsync(:,i), "red")
        plot(params.IKtime, params.IKdesired(:,i), "blue")
        legend(["predicted", "desired"])
        title(kinNames(i))
        hold off
    end

    if(params.trackGRF)
        Ngrf = size(GRFpred,2);
        grfNames = ["GRF Right X" "GRF Right Y" "GRF Right Z" "GRF Left X" "GRF Left Y" "GRF Left Z"];                            
        for i = 1:Ngrf
            figure
            hold on
            plot(params.GRFtime, GRFsync(:,i), "red")
            plot(params.GRFtime, params.GRFdesired(:,i), "blue")
            legend(["predicted", "desired"])
            title(grfNames(i))
            hold off
        end
    end
end

%% Return metabolic cost
cot = R.metabolics.Bhargava2004.COT;

end