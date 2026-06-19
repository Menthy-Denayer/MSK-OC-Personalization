function [f,cot,stats] = compute_fitness(X, R, model_info, params)

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
stats.IKerr = IKerr;
fprintf('Kinematics error is: %.2f\n', IKerr)

% for i = 1:size(IKsync,2)
%     figure 
%     hold on
%     title(desir_coo_names(i))
%     plot(params.IKtime, IKsync(:,i),"red")
%     plot(params.IKtime, params.IKdesired(:,i),"blue")
%     legend(["predicted","desired"])
%     hold off
% end

%% Compute GRF error
if(params.trackGRF)
    GRFpred = [R.ground_reaction.GRF_r R.ground_reaction.GRF_l];                % all ground reaction forces
    GRFsync = interp1(norm_time,GRFpred,params.GRFtime,"linear");
    GRFerr = sum(rmse(GRFsync,params.GRFdesired));
    f = f + GRFerr * params.GRFweight;
    stats.GRFerr = GRFerr;
    fprintf('GRF error is: %.2f\n', GRFerr)
end

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
    stats.pPennAngle = pPennAngle;
    fprintf('Pennation angle penalty is: %.2f\n', pPennAngle)
end

%% Fiber Length Penalty (Physiological)
% limit normalized fibre length for all muscles to physiologically 
% acceptable ranges [ 0.3 - 1.4 ]
if(params.lMoptPenalty)
    lMopt_max = 1.4;
    lMopt_min = 0.4;
    plMopt = compute_range_penalty(R.muscles.lMtilde, lMopt_min, lMopt_max);
    f = f + plMopt * params.lMoptweight;
    stats.plMopt = plMopt;
    fprintf('Fiber length penalty is: %.2f\n', plMopt)
end

%% Fiber Length Penalty (Robustness)
% limit normalized fibre lengths during stance to [0.6-1.35] for 
% sagittal plane muscles
% if(params.lMoptPenalty)
%     muscleNames = ["hamstrings", "bifemsh", "glut_max", "rect_fem", "vasti", "gastroc", "soleus"];
%     muscleIdxsLeft = contains(R.colheaders.muscles,muscleNames + "_l");
%     muscleIdxsRight = contains(R.colheaders.muscles,muscleNames + "_r");
%     leftStanceIdx = R.ground_reaction.idx_stance_l;
%     rightStanceIdx = R.ground_reaction.idx_stance_r;
%     leftMuscleData = R.muscles.lMtilde(leftStanceIdx,muscleIdxsLeft);
%     rightMuscleData = R.muscles.lMtilde(rightStanceIdx,muscleIdxsRight);
% 
%     lMopt_max = 1.35;
%     lMopt_min = 0.5;
%     plMoptRobL = compute_range_penalty(leftMuscleData, lMopt_min, lMopt_max);
%     plMoptRobR = compute_range_penalty(rightMuscleData, lMopt_min, lMopt_max);
%     plMoptRob = (plMoptRobL + plMoptRobR)/2;
%     f = f + plMoptRob * params.lMoptweight;
%     fprintf('Fiber length penalty is: %.2f\n', plMoptRob)
% end

%% Tendon Slack Length
if(params.lTstrainPenalty)
    lTstrain_max = 8;
    lTstrain_min = -1;
    lTstrain = (R.muscles.lT./[model_info.muscle_info.parameters.lTs]-1)*100;

    plTstrain = compute_range_penalty(lTstrain, lTstrain_min, lTstrain_max);
    f = f + plTstrain * params.lTstrainweight;
    stats.plTstrain = plTstrain;
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
    stats.pFpass = pFpass;
    fprintf('Passive muscle force penalty is: %.2f\n', pFpass)
end

%% Passive Muscle Work Penalty
if(params.FpassWorkPenalty)
    Jmax = 2;                                                                   % max allowed passive muscle work
    muscleNames = ["hamstrings", "bifemsh", "glut_max", "rect_fem", "vasti"];   % these muscles cannot generate too much passive muscle work to generalize
    isMuscle = contains(R.colheaders.muscles, muscleNames);
    
    Fpass= R.muscles.Fpass;                                                     % passive fiber force 
    vMTU = R.muscles.vMT;                                                       % MTU velocities
    Wpass = Fpass.*vMTU;                                                        % passive fiber work
    Wpass = Wpass(:,isMuscle);                                                  % select only desired muscles
    dt = R.time.mesh(2)-R.time.mesh_GC(1);                                      % time step
    pFpassWork = sum(sum(max(Wpass-Jmax,0),1)*dt);                              % integrate over time
    
    f = f + pFpassWork * params.FpassWorkweight;
    stats.pFpassWork = pFpassWork;
    fprintf('Passive muscle work penalty is: %.2f\n', pFpassWork)
end

%% Parameter Deviation
% Penalizes deviations from the initial parameters
if(params.paramDeviationPenalty)
    dev = sum( ( (params.initialCoefficients - X)./params.initialCoefficients).^2);
    f = f + dev * params.paramDeviationweight;
    stats.dev = dev;
    fprintf('Parameter deviation penalty is: %.2f\n', dev)
end

%% Return metabolic cost
cot = R.metabolics.Bhargava2004.COT;

end