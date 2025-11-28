function [f,cot] = compute_fitness(R, model_info, params)

%% Compute Cost Function
% load results data
predictionTime = R.time.mesh_GC;

% resample data to match desired values
duration = predictionTime(end-1)-predictionTime(1);
norm_time = (predictionTime(1:end-1)-predictionTime(1))/duration;

%% Compute kinematics error
f = 0;

% IKpred = R.kinematics.Qs(:,4:end-1);                                      % 2D Tracking
IKpred = R.kinematics.Qs;                                                   % all joint angles
IKsync = interp1(norm_time,IKpred,params.IKtime,"linear");
IKerr = sum(rmse(IKsync,params.IKdesired));
f = f + IKerr * params.IKweight;
fprintf('Kinematics error is: %.2f\n', IKerr)

%% Compute GRF error
if(params.trackGRF)
    GRFpred = [R.ground_reaction.GRF_r R.ground_reaction.GRF_l];                % all ground reaction forces
    GRFsync = interp1(norm_time,GRFpred,params.GRFtime,"linear");
    GRFerr = sum(rmse(GRFsync,params.GRFdesired));
    f = f + GRFerr * params.GRFweight;
    fprintf('GRF error is: %.2f\n', GRFerr)
end

%% Pennation Angle Penalty
if(params.PennAnglePenalty)
    pennation_angles = acos((R.muscles.lMT-R.muscles.lT)./R.muscles.lM)*180/pi;
    penn_angle_max = 35;
    penn_angle_min = -1;
    pPennAngle = compute_range_penalty(pennation_angles, penn_angle_min, penn_angle_max)/90;
    f = f + pPennAngle * params.PennAngleweight;
    fprintf('Pennation angle penalty is: %.2f\n', pPennAngle)
end

%% Fiber Length Penalty
if(params.lMoptPenalty)
    lMopt_max = 1.4;
    lMopt_min = 0.4;
    plMopt = compute_range_penalty(R.muscles.lMtilde, lMopt_min, lMopt_max);
    f = f + plMopt * params.lMoptweight;
    fprintf('Fiber length penalty is: %.2f\n', plMopt)
end

%% Tendon Slack Length
if(params.lTstrainPenalty)
    lTstrain_max = 8;
    lTstrain_min = -1;
    lTstrain = (R.muscles.lT./[model_info.muscle_info.parameters.lTs]-1)*100;

    plTstrain = compute_range_penalty(lTstrain, lTstrain_min, lTstrain_max);
    f = f + plTstrain * params.lTstrainweight;
    fprintf('Tendon strain penalty is: %.2f\n', plTstrain)
end

%% Return metabolic cost
cot = R.metabolics.Bhargava2004.COT;

end