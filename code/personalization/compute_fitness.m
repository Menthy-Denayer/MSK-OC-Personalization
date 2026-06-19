function [f,cot] = compute_fitness(X, R, model_info, params)
%% compute_fitness 
% - Computes the fitness during the optimization process
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% X                             | Nmuscles x 1 Double Array     | Desired MTU parameters (first Nmuscles/2 lMopt, next lTslack) 
% R                             | struct                        | PredSim results structure
% model_info                    | struct                        | PredSim model info structure
% params                        | struct                        | Structure with settings
%   IKtime                      | 100x1 Double Array            | Normalized reference time
%   IKdesired                   | 100xNjoints Double Array      | Desired kinematics reference
%   IKweight                    | Double                        | Weight of the IK tracking term
%   PennAnglePenalty            | Boolean                       | Whether to penalize the pennation angle range
%   PennAngleweight             | Double                        | Weight of the pennation angle range penalty term
%   lMoptPenalty                | Boolean                       | Whether to penalize the optimal fibre length range
%   lMoptweight                 | Double                        | Weight of the optimal fibre length range penalty term
%   lTstrainPenalty             | Boolean                       | Whether to penalize the tendon slack length range
%   lTstrainweight              | Double                        | Weight of the tendon slack length range penalty term
%   FpassPenalty                | Boolean                       | Whether to penalize the passive muscle force range
%   Fpassweight                 | Double                        | Weight of the passive muscle force range penalty term
%   paramDeviationPenalty       | Boolean                       | Whether to penalize deviations from the initial parameters
%   paramDeviationweight        | Double                        | Weight of the parameter deviation penalty term
%   initialCoefficients         | Nmuscles x 1 Double Array     | Initial muscle parameters
%   ExcludeTrackingJoints       | string                        | Optional: exclude joints inside error computation
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% f                             | Double                        | Total computed fitness value
% cot                           | Double                        | Cost of transport (J/(kg * m))
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 05/December/2025

% Last Update: Menthy Denayer
% Date: 02/February/2026

%% Compute Cost Function
% load results data
predictionTime = R.time.mesh_GC;
kinColheaders = R.colheaders.coordinates;
desir_coo_names = string(kinColheaders);

% exclude joints to not track
if(isfield(params,'ExcludeTrackingJoints'))
    excludeBool = contains(desir_coo_names,params.ExcludeTrackingJoints);
    desir_coo_names = desir_coo_names(~excludeBool);
end

[~,desir_joint_idx] = ismember(desir_coo_names,kinColheaders);              % get desired joint indices  

% resample data to match desired values
duration = predictionTime(end-1)-predictionTime(1);
norm_time = (predictionTime(1:end-1)-predictionTime(1))/duration;

%% Compute kinematics error
f = 0;

% IKpred = R.kinematics.Qs(:,4:end-1);                                      % 2D Tracking
IKpred = R.kinematics.Qs;                                                   % all joint angles
IKsync = interp1(norm_time,IKpred(:,desir_joint_idx(desir_joint_idx>0)),params.IKtime,"linear");
IKerr = sum(rmse(IKsync,params.IKdesired));
f = f + IKerr * params.IKweight;
fprintf('Kinematics error is: %.2f\n', IKerr)

%% Pennation Angle Penalty
if(params.PennAnglePenalty)

    muscleNames = ["soleus","gastroc"];                                         % these muscles should have a lower pennation angle
    isPlantar = contains(R.colheaders.muscles, muscleNames);
    isNotPlantar = ~isPlantar;

    pennation_angles = acos((R.muscles.lMT-R.muscles.lT)./R.muscles.lM)*180/pi;
    
    penn_angle_max_not_plantar = 30;
    penn_angle_max_plantar = 25;
    penn_angle_min = -1;
    
    pPennAngle_not_plantar = compute_range_penalty(pennation_angles(:,isNotPlantar), penn_angle_min, penn_angle_max_not_plantar)/90;
    pPennAngle_plantar = compute_range_penalty(pennation_angles(:,isPlantar), penn_angle_min, penn_angle_max_plantar)/90;
    
    pPennAngle = pPennAngle_not_plantar + pPennAngle_plantar;
    f = f + pPennAngle * params.PennAngleweight;
    fprintf('Pennation angle penalty is: %.2f\n', pPennAngle)
end

%% Fiber Length Penalty
if(params.lMoptPenalty)
    lMopt_max = 1.4;                                                            % before 1.5
    lMopt_min = 0.4;                                                            % before 0.5
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

%% Passive Muscle Force
if(params.FpassPenalty)

    muscleNames = ["soleus","gastroc","iliopsoas","extobl","intobl","ercspn"];  % these muscles are allowed to generate more passive muscle force for better convergence
    isPlantar = contains(R.colheaders.muscles, muscleNames);
    isNotPlantar = ~isPlantar;

    Fpass_max_not_plantar = 0.10;
    Fpass_max_plantar = 0.40;                                                   % plantarflexors allowed to generate more passive muscle force
    Fpass_min = -1;
    Fpass_norm = R.muscles.Fpass./[model_info.muscle_info.parameters.FMo];

    pFpassNotPlantar = compute_range_penalty(Fpass_norm(:,isNotPlantar), Fpass_min, Fpass_max_not_plantar);
    pFpassPlantar = compute_range_penalty(Fpass_norm(:,isPlantar), Fpass_min, Fpass_max_plantar);
    pFpass = pFpassNotPlantar + pFpassPlantar;
    f = f + pFpass * params.Fpassweight;
    fprintf('Passive muscle force penalty is: %.2f\n', pFpass)
end


%% Parameter Deviation
% Penalizes deviations from the initial parameters
if(params.paramDeviationPenalty)
    dev = sum( ( (params.initialCoefficients - X)./params.initialCoefficients).^2);
    f = f + dev * params.paramDeviationweight;
    fprintf('Parameter deviation penalty is: %.2f\n', dev)
end

%% Return metabolic cost
cot = R.metabolics.Bhargava2004.COT;

end