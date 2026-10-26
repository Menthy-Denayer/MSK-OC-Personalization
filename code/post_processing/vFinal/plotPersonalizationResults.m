% --------------------------------------------------------------------------
% plotPersonalizationResults
%   Process the results of the personalization framework and create all
%   the related plots from the manuscript.
%
% Original author: Menthy Denayer
% Original date: 08/July/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 22/Oct/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Load Libraries
addpath(pwd + "\helperFunctions")

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];   
NSUBJ = length(SUBJID);
meshSubFolder = "100Meshes";
genericKeyWords = "mtu3D";
personalKeyWords = "opt3D";
dhondt2024_3segKeyWords = "Dhondt2024_3seg";
generic_resultsSubFolder = ["SUBJ04mtu3D", "SUBJ06mtu3D", "SUBJ07mtu3D", "SUBJ09mtu3D", "SUBJ10mtu3D", "SUBJ11mtu3D"] + "\" + meshSubFolder;
personal_resultsSubFolder = ["SUBJ04opt3D", "SUBJ06opt3D", "SUBJ07opt3D", "SUBJ09opt3D", "SUBJ10opt3D", "SUBJ11opt3D"] + "\" + meshSubFolder;
dhondt2024_3segSubFolders = ["SUBJ04_Dhondt2024_3seg", "SUBJ06_Dhondt2024_3seg", "SUBJ07_Dhondt2024_3seg", "SUBJ09_Dhondt2024_3seg", "SUBJ10_Dhondt2024_3seg", "SUBJ11_Dhondt2024_3seg"] + "\" + meshSubFolder;
resampTime = 0:0.01:1;

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = false;
figFileType = ".jpg";
linewidth = 1.5;
colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

%% General Variables
Ndata = length(resampTime);
Nkincol = 19;
Ngrfcol = 6;
Nemgcol = 28;
emg_col_exp = ["bifemsh_r","hamstrings_r","rect_fem_r","vasti_r","","gastroc_r","","soleus_r","bifemsh_l","hamstrings_l","rect_fem_l","vasti_l","","gastroc_l","","soleus_l"];

%% Load Generic Results
resultsDIR = uigetdir("..\..\..\results\", "Choose solution directory");

%% Find Desired Folders
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);

%% Load Experimental Data
[expDataFile, expDataDIR] = uigetfile(".mat","Choose experimental data file");
expData = load(fullfile(expDataDIR, expDataFile));

%% Load Results
% Load generic model results
[GenericKinData, GenericGrfData, GenericKitData, GenericEmgData,~,SUBJmass,~,GenericIdxHeelL,kinColHeaders,GRFColHeaders,EMGColHeaders] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, generic_resultsSubFolder, genericKeyWords, 1);

% Load personalized model results
[PersonalKinData, PersonalGrfData, PersonalKitData, PersonalEmgData,~,~,~,PersonalIdxHeelL,~,~,~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, personal_resultsSubFolder, personalKeyWords, 1);

% Dhondt2024 3seg scaled
[Dhondt2024_3segKinData, Dhondt2024_3segGrfData, Dhondt2024_3segKitData, Dhondt2024_3segEmgData,~,~,~,Dhondt2024_3segIdxHeelL,Dhondt2024_3segkinColHeaders,~,Dhondt2024_3segEmgColHeaders] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders, dhondt2024_3segKeyWords, 1);
[~,Dhondt2024_3segisLimKin] = ismember(kinColHeaders, Dhondt2024_3segkinColHeaders);

Dhondt2024_3segKinDataLim = Dhondt2024_3segKinData(:,Dhondt2024_3segisLimKin,:);
Dhondt2024_3segGrfDataLim = Dhondt2024_3segGrfData(:,:,:);
Dhondt2024_3segKitDataLim = Dhondt2024_3segKitData(:,Dhondt2024_3segisLimKin,:);

%% Extract Experimental Kinematics Data
Nkincolexp = length(expData.data.headers.kinematics);
normalWalkingKinExpAvg = NaN(Ndata, Nkincolexp, NSUBJ);
normalWalkingKinExpStd = NaN(Ndata, Nkincolexp, NSUBJ);

for i = 1:NSUBJ
    normalWalkingKinExpAvg(:,:,i) = mean(expData.data.("SUBJ" + SUBJID(i)).kinematics.IkdataNormal,3,"omitnan");
    normalWalkingKinExpStd(:,:,i) = std(expData.data.("SUBJ" + SUBJID(i)).kinematics.IkdataNormal,0,3,"omitnan");
end

% find corresponding columns
kin_col_exp = expData.data.headers.kinematics;
[~,isLimKINexp]=ismember(kinColHeaders,kin_col_exp);
normalWalkingKinExpAvgLim = normalWalkingKinExpAvg(:,isLimKINexp,:);
normalWalkingKinExpStdLim = normalWalkingKinExpStd(:,isLimKINexp,:);

%% Extract Experimental GRF Data
Ngrfcolexp = length(expData.data.headers.GRF);
normalWalkingGrfExpAvg = NaN(Ndata, Ngrfcolexp, NSUBJ);
normalWalkingGrfExpStd = NaN(Ndata, Ngrfcolexp, NSUBJ);

for i = 1:NSUBJ
    normalWalkingGrfExpAvg(:,:,i) = mean(expData.data.("SUBJ" + SUBJID(i)).GRF.GRFdataNormal,3,"omitnan");
    normalWalkingGrfExpStd(:,:,i) = std(expData.data.("SUBJ" + SUBJID(i)).GRF.GRFdataNormal,0,3,"omitnan");
end

%% Assign EMG Columns
[isLimEMG,isLimEMGexp]=ismember(EMGColHeaders,emg_col_exp);
EMGColHeadersLim = EMGColHeaders(isLimEMG>0);                               % simulation data only for muscle with experimental data
GenericEmgDataLim = GenericEmgData(:,isLimEMG>0,:);
PersonalEmgDataLim = PersonalEmgData(:,isLimEMG>0,:);

%% Extract Subject-Specific EMG Data
Nemgcolexp = length(emg_col_exp);
normalWalkingEMGexp = NaN(Ndata, Nemgcolexp, NSUBJ);
for subjID = 1:NSUBJ
    subjEMGdata = expData.data.("SUBJ" + SUBJID(subjID)).EMG.EMGdataNormal;
    normalWalkingEMGexp(:,:,subjID) = mean(subjEMGdata,3,"omitnan");
end

% select columns corresponding to simulation muscles
NemgcolLim = length(EMGColHeadersLim);
normalWalkingEMGexpLim = normalWalkingEMGexp(:,isLimEMGexp(isLimEMGexp>0),:);

% extract average EMG data
normalWalkingEMGavgLim = mean(normalWalkingEMGexpLim,3,"omitnan");
normalWalkingEMGstdLim = std(normalWalkingEMGexpLim,0,3,"omitnan");

%% Assign Dhondt2024 3seg EMG Columns
emg_col_dhondt2024 = ["semiten_r", "bifemsh_r", "rect_fem_r", "vas_lat_r", "med_gas_r", "soleus_r","semiten_l", "bifemsh_l", "rect_fem_l", "vas_lat_l", "med_gas_l", "soleus_l"];
[~, Dhondt2024_3seg_isLimEmgIdxs] = ismember(emg_col_dhondt2024, Dhondt2024_3segEmgColHeaders);
Dhondt2024_3segEmgDataLim = Dhondt2024_3segEmgData(:,Dhondt2024_3seg_isLimEmgIdxs,:);

%% Average Results
% Generic model
GenericKinDataAvg = mean(GenericKinData,3,"omitnan");
GenericKinDataSTD = std(GenericKinData,0,3,"omitnan");
GenericGRFDataAvg = mean(GenericGrfData,3,"omitnan");
GenericGRFDataSTD = std(GenericGrfData,0,3,"omitnan");
GenericKitDataAvg = mean(GenericKitData,3,"omitnan");
GenericKitDataSTD = std(GenericKitData,0,3,"omitnan");
GenericEmgDataAvg = mean(GenericEmgDataLim,3,"omitnan");
GenericEmgDataSTD = std(GenericEmgDataLim,0,3,"omitnan");

% Personal model
PersonalKinDataAvg = mean(PersonalKinData,3,"omitnan");
PersonalKinDataSTD = std(PersonalKinData,0,3,"omitnan");
PersonalGRFDataAvg = mean(PersonalGrfData,3,"omitnan");
PersonalGRFDataSTD = std(PersonalGrfData,0,3,"omitnan");
PersonalKitDataAvg = mean(PersonalKitData,3,"omitnan");
PersonalKitDataSTD = std(PersonalKitData,0,3,"omitnan");
PersonalEmgDataAvg = mean(PersonalEmgDataLim,3,"omitnan");
PersonalEmgDataSTD = std(PersonalEmgDataLim,0,3,"omitnan");

% D'Hondt 2024 3 segments model
Dhondt2024_3segKinDataAvg = mean(Dhondt2024_3segKinDataLim,3,"omitnan");
Dhondt2024_3segKinDataSTD = std(Dhondt2024_3segKinDataLim,0,3,"omitnan");
Dhondt2024_3segGRFDataAvg = mean(Dhondt2024_3segGrfDataLim,3,"omitnan");
Dhondt2024_3segGRFDataSTD = std(Dhondt2024_3segGrfDataLim,0,3,"omitnan");
Dhondt2024_3segKitDataAvg = mean(Dhondt2024_3segKitDataLim,3,"omitnan");
Dhondt2024_3segKitDataSTD = std(Dhondt2024_3segKitDataLim,0,3,"omitnan");
Dhondt2024_3segEmgDataAvg = mean(Dhondt2024_3segEmgDataLim,3,"omitnan");
Dhondt2024_3segEmgDataSTD = std(Dhondt2024_3segEmgDataLim,0,3,"omitnan");

%% Shift Pelvis Tz To Start at Zero
GenericKinDataShifted = GenericKinData;
PersonalKinDataShifted = PersonalKinData;
Dhondt2024_3segKinDataShifted = Dhondt2024_3segKinDataLim;

isPelvisTz = contains(kinColHeaders, "pelvis_tz");
for i = 1:NSUBJ
    GenericKinDataShifted(:,isPelvisTz,i) = GenericKinDataShifted(:,isPelvisTz,i) - GenericKinDataShifted(1,isPelvisTz,i);
    PersonalKinDataShifted(:,isPelvisTz,i) = PersonalKinDataShifted(:,isPelvisTz,i) - PersonalKinDataShifted(1,isPelvisTz,i);
    Dhondt2024_3segKinDataShifted(:,isPelvisTz,i) = Dhondt2024_3segKinDataShifted(:,isPelvisTz,i) - Dhondt2024_3segKinDataShifted(1,isPelvisTz,i);
end

%% Shift Pelvis Ty To Have Mean at Zero
isPelvisTy = contains(kinColHeaders, "pelvis_ty");
for i = 1:NSUBJ
    GenericKinDataShifted(:,isPelvisTy,i) = GenericKinDataShifted(:,isPelvisTy,i) - mean(GenericKinDataShifted(:,isPelvisTy,i));
    PersonalKinDataShifted(:,isPelvisTy,i) = PersonalKinDataShifted(:,isPelvisTy,i) - mean(PersonalKinDataShifted(:,isPelvisTy,i));
    Dhondt2024_3segKinDataShifted(:,isPelvisTy,i) = Dhondt2024_3segKinDataShifted(:,isPelvisTy,i) - mean(Dhondt2024_3segKinDataShifted(:,isPelvisTy,i));

    normalWalkingKinExpAvgLim(:,isPelvisTy,i) = normalWalkingKinExpAvgLim(:,isPelvisTy,i) - mean(normalWalkingKinExpAvgLim(:,isPelvisTy,i));
end

%% Compute Metrics
% store personalization metrics
R_list_kin_personal = NaN(NSUBJ,Nkincol);
rmse_list_kin_personal = NaN(NSUBJ,Nkincol);
R_list_grf_personal = NaN(NSUBJ,Ngrfcol);
rmse_list_grf_personal = NaN(NSUBJ,Ngrfcol);
R_list_emg_personal = NaN(NSUBJ,NemgcolLim);
R_list_emg_per_vs_gen = NaN(NSUBJ,Nemgcol);

% store generic metrics
R_list_kin_generic = NaN(NSUBJ,Nkincol);
rmse_list_kin_generic = NaN(NSUBJ,Nkincol);
R_list_grf_generic = NaN(NSUBJ,Ngrfcol);
rmse_list_grf_generic = NaN(NSUBJ,Ngrfcol);
R_list_emg_generic = NaN(NSUBJ,NemgcolLim);

% store D'Hondt2024 3seg metrics
R_list_kin_dhondt2024_3seg = NaN(NSUBJ,Nkincol);
rmse_list_kin_dhondt2024_3seg = NaN(NSUBJ,Nkincol);
R_list_grf_dhondt2024_3seg = NaN(NSUBJ,Ngrfcol);
rmse_list_grf_dhondt2024_3seg = NaN(NSUBJ,Ngrfcol);
R_list_emg_dhondt2024_3seg = NaN(NSUBJ,NemgcolLim);

for i = 1:NSUBJ
    % kinematics (compared to experimental average)
    [R_list_kin_personal(i,:), rmse_list_kin_personal(i,:), ~] = compute_metrics(PersonalKinDataShifted(:,:,i), normalWalkingKinExpAvgLim(:,:,i), normalWalkingKinExpStdLim(:,:,i));
    [R_list_kin_generic(i,:), rmse_list_kin_generic(i,:), ~] = compute_metrics(GenericKinDataShifted(:,:,i), normalWalkingKinExpAvgLim(:,:,i), normalWalkingKinExpStdLim(:,:,i));
    [R_list_kin_dhondt2024_3seg(i,:), rmse_list_kin_dhondt2024_3seg(i,:), ~] = compute_metrics(Dhondt2024_3segKinDataShifted(:,:,i), normalWalkingKinExpAvgLim(:,:,i), normalWalkingKinExpStdLim(:,:,i));

    % GRF (compared to experimental average)
    [R_list_grf_personal(i,:), rmse_list_grf_personal(i,:), ~] = compute_metrics(PersonalGrfData(:,:,i)/SUBJmass(i), normalWalkingGrfExpAvg(:,:,i)/SUBJmass(i), normalWalkingGrfExpStd(:,:,i)/SUBJmass(i));
    [R_list_grf_generic(i,:), rmse_list_grf_generic(i,:), ~] = compute_metrics(GenericGrfData(:,:,i)/SUBJmass(i), normalWalkingGrfExpAvg(:,:,i)/SUBJmass(i), normalWalkingGrfExpStd(:,:,i)/SUBJmass(i));
    [R_list_grf_dhondt2024_3seg(i,:), rmse_list_grf_dhondt2024_3seg(i,:), ~] = compute_metrics(Dhondt2024_3segGrfDataLim(:,:,i)/SUBJmass(i), normalWalkingGrfExpAvg(:,:,i)/SUBJmass(i), normalWalkingGrfExpStd(:,:,i)/SUBJmass(i));

    % EMG (compared to experimental average)
    [R_list_emg_personal(i,:), ~, ~] = compute_metrics(PersonalEmgDataLim(:,:,i), normalWalkingEMGexpLim(:,:,i), NaN);
    [R_list_emg_generic(i,:), ~, ~] = compute_metrics(GenericEmgDataLim(:,:,i), normalWalkingEMGexpLim(:,:,i), NaN);
    [R_list_emg_dhondt2024_3seg(i,:), ~, ~] = compute_metrics(Dhondt2024_3segEmgDataLim(:,:,i), normalWalkingEMGexpLim(:,:,i), NaN);

    % EMG (compared to generic model)
    [R_list_emg_per_vs_gen(i,:), ~, ~] = compute_metrics(PersonalEmgData(:,:,i), GenericEmgData(:,:,i), NaN);
end

%% Save Metrics
% open metrics file
load("metrics.mat");

% colheaders
metrics.colheaders.kinematics = kinColHeaders;
metrics.colheaders.ground_reaction = GRFColHeaders;
metrics.colheaders.muscle_activation = EMGColHeadersLim;

% kinematics, R
metrics.kinematics.normal.R.personal = R_list_kin_personal;
metrics.kinematics.normal.R.generic = R_list_kin_generic;
metrics.kinematics.normal.R.dhondt2024_3seg = R_list_kin_dhondt2024_3seg;

% kinematics, RMSE
metrics.kinematics.normal.RMSE.personal = rmse_list_kin_personal;
metrics.kinematics.normal.RMSE.generic = rmse_list_kin_generic;
metrics.kinematics.normal.RMSE.dhondt2024_3seg = rmse_list_kin_dhondt2024_3seg;

% GRFs, R
metrics.ground_reaction.normal.R.personal = R_list_grf_personal;
metrics.ground_reaction.normal.R.generic = R_list_grf_generic;
metrics.ground_reaction.normal.R.dhondt2024_3seg = R_list_grf_dhondt2024_3seg;

% GRFs, RMSE
metrics.ground_reaction.normal.RMSE.personal = rmse_list_grf_personal;
metrics.ground_reaction.normal.RMSE.generic = rmse_list_grf_generic;
metrics.ground_reaction.normal.RMSE.dhondt2024_3seg = rmse_list_grf_dhondt2024_3seg;

% EMG, R
metrics.muscle_activations.normal.R.personal = R_list_emg_personal;
metrics.muscle_activations.normal.R.generic = R_list_emg_generic;
metrics.muscle_activations.normal.R.dhondt2024_3seg = R_list_emg_dhondt2024_3seg;
metrics.muscle_activations.normal.R.personal_vs_generic = R_list_emg_per_vs_gen;

% save metrics
save("metrics.mat", "metrics")

%% Compute Total Average of Metrics
% R over all subjects & kinematics
R_tot_kin_personal = mean(R_list_kin_personal,"all");
R_tot_kin_generic = mean(R_list_kin_generic,"all");
R_tot_kin_dhondt2024_3seg = mean(R_list_kin_dhondt2024_3seg,"all");

% RMSE over all subjects & DOF (rotational)
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
rmse_tot_kin_personal_rot = mean(rmse_list_kin_personal(:,~isTrans),"all");
rmse_tot_kin_generic_rot = mean(rmse_list_kin_generic(:,~isTrans),"all");
rmse_tot_kin_dhondt2024_3seg_rot = mean(rmse_list_kin_dhondt2024_3seg(:,~isTrans),"all");

rmse_tot_kin_personal_rot_std = std(mean(rmse_list_kin_personal(:,~isTrans),2));
rmse_tot_kin_generic_rot_std = std(mean(rmse_list_kin_generic(:,~isTrans),2));
rmse_tot_kin_dhondt2024_3seg_rot_std = std(mean(rmse_list_kin_dhondt2024_3seg(:,~isTrans),2));

% RMSE over all subjects & DOF (translational)
rmse_tot_kin_personal_trans = mean(rmse_list_kin_personal(:,isTrans),"all");
rmse_tot_kin_generic_trans = mean(rmse_list_kin_generic(:,isTrans),"all");
rmse_tot_kin_dhondt2024_3seg_trans = mean(rmse_list_kin_dhondt2024_3seg(:,isTrans),"all");

rmse_tot_kin_personal_trans_std = std(mean(rmse_list_kin_personal(:,isTrans),2));
rmse_tot_kin_generic_trans_std = std(mean(rmse_list_kin_generic(:,isTrans),2));
rmse_tot_kin_dhondt2024_3seg_trans_std = std(mean(rmse_list_kin_dhondt2024_3seg(:,isTrans),2));

% R over all subjects & muscles
R_tot_emg_per_vs_gen = mean(R_list_emg_per_vs_gen,"all");

%% Compute Average Improvements
isSagittalPlaneKinematics = contains(kinColHeaders,"knee_angle") | contains(kinColHeaders,"hip_flexion") | contains(kinColHeaders,"ankle_angle");

% average R over all subjects
avg_R_list_kin_generic = mean(R_list_kin_generic,1,"omitnan");
avg_R_list_kin_personal = mean(R_list_kin_personal,1,"omitnan");
avg_R_list_kin_dhondt2024_3seg = mean(R_list_kin_dhondt2024_3seg,1,"omitnan");
avg_R_list_grf_generic = mean(R_list_grf_generic,1,"omitnan");
avg_R_list_grf_personal = mean(R_list_grf_personal,1,"omitnan");
avg_R_list_grf_dhondt2024_3seg = mean(R_list_grf_dhondt2024_3seg,1,"omitnan");
avg_R_list_emg_generic = mean(R_list_emg_generic,1,"omitnan");
avg_R_list_emg_personal = mean(R_list_emg_personal,1,"omitnan");
avg_R_list_emg_dhondt2024_3seg = mean(R_list_emg_dhondt2024_3seg,1,"omitnan");

% average RMSE over all subjects
avg_rmse_list_kin_generic = mean(rmse_list_kin_generic,1,"omitnan");
avg_rmse_list_kin_personal = mean(rmse_list_kin_personal,1,"omitnan");
avg_rmse_list_kin_dhondt2024_3seg = mean(rmse_list_kin_dhondt2024_3seg,1,"omitnan");
avg_rmse_list_grf_generic = mean(rmse_list_grf_generic,1,"omitnan");
avg_rmse_list_grf_personal = mean(rmse_list_grf_personal,1,"omitnan");
avg_rmse_list_grf_dhondt2024_3seg = mean(rmse_list_grf_dhondt2024_3seg,1,"omitnan");

% compute average R sagittal plane improvements
% postive means R increased
[avg_percent_R_kin_sagg, avg_percent_R_grf] = compute_R_average_improvement(avg_R_list_kin_personal(isSagittalPlaneKinematics), avg_R_list_kin_generic(isSagittalPlaneKinematics), avg_R_list_grf_personal, avg_R_list_grf_generic, avg_R_list_emg_personal, avg_R_list_emg_generic, 'personal model (sagittal plane)');
[avg_percent_R_kin_sagg_dhondt2024_3seg, avg_percent_R_grf_dhondt2024_3seg] = compute_R_average_improvement(avg_R_list_kin_dhondt2024_3seg(isSagittalPlaneKinematics), avg_R_list_kin_generic(isSagittalPlaneKinematics), avg_R_list_grf_dhondt2024_3seg, avg_R_list_grf_generic, avg_R_list_emg_dhondt2024_3seg, avg_R_list_emg_generic, 'dhondt2024_3seg model (sagittal plane)');

% compute average R improvements (including not sagittal plane)
% positive means R increased
[avg_percent_R_kin, ~] = compute_R_average_improvement(avg_R_list_kin_personal, avg_R_list_kin_generic, avg_R_list_grf_personal, avg_R_list_grf_generic, avg_R_list_emg_personal, avg_R_list_emg_generic,'personal model (all DOF)');
[avg_percent_R_kin_dhondt2024_3seg, ~] = compute_R_average_improvement(avg_R_list_kin_dhondt2024_3seg, avg_R_list_kin_generic, avg_R_list_grf_dhondt2024_3seg, avg_R_list_grf_generic, avg_R_list_emg_dhondt2024_3seg, avg_R_list_emg_generic, 'dhondt2024_3seg model (all DOF)');

% compute average RMSE sagittal plane improvements
% negative means RMSE error decreased
[avg_percent_rmse_kin_sagg, avg_percent_rmse_grf] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal(isSagittalPlaneKinematics), avg_rmse_list_kin_generic(isSagittalPlaneKinematics), avg_rmse_list_grf_personal, avg_rmse_list_grf_generic, 'personal model (sagittal plane)');
[avg_percent_rmse_kin_sagg_dhondt2024_3seg, avg_percent_rmse_grf_dhondt2024_3seg] = compute_RMSE_average_improvement(avg_rmse_list_kin_dhondt2024_3seg(isSagittalPlaneKinematics), avg_rmse_list_kin_generic(isSagittalPlaneKinematics), avg_rmse_list_grf_dhondt2024_3seg, avg_rmse_list_grf_generic, 'dhondt2024_3seg model (sagittal plane)');

% compute average RMSE improvements (including not sagittal plane)
% negative means RMSE error decreased
[avg_percent_rmse_kin, ~] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal, avg_rmse_list_kin_generic, avg_rmse_list_grf_personal, avg_rmse_list_grf_generic, 'personal model (all DOF)');
[avg_percent_rmse_kin_dhondt2024_3seg, ~] = compute_RMSE_average_improvement(avg_rmse_list_kin_dhondt2024_3seg, avg_rmse_list_kin_generic, avg_rmse_list_grf_dhondt2024_3seg, avg_rmse_list_grf_generic, 'dhondt2024_3seg model (all DOF)');

% compute average RMSE improvements (D'Hondt vs. Personal)
% negative means RMSE error decreased
[avg_percent_rmse_kin_vs_dhondt2024_3seg, ~] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal, avg_rmse_list_kin_dhondt2024_3seg, avg_rmse_list_grf_personal, avg_rmse_list_grf_dhondt2024_3seg, 'personal model vs dhondt 2024 (all DOF)');

%% Print Matrix
% print average R kinematics
avg_R_list_kin_matrix = [avg_R_list_kin_generic; avg_R_list_kin_personal; avg_R_list_kin_dhondt2024_3seg]';
max_R_list_kin_matrix = max(avg_R_list_kin_matrix,[],2);
isBestRkin = avg_R_list_kin_matrix == max_R_list_kin_matrix;
print_matrix_latex(avg_R_list_kin_matrix,[],["Generic", "Personal", "Dhondt2024 3seg"], strrep(kinColHeaders,"_"," "), isBestRkin,[])

% print average RMSE kinematics
avg_RMSE_list_kin_matrix = [avg_rmse_list_kin_generic; avg_rmse_list_kin_personal; avg_rmse_list_kin_dhondt2024_3seg]';
max_RMSE_list_kin_matrix = min(avg_RMSE_list_kin_matrix,[],2);
isBestRMSEkin = avg_RMSE_list_kin_matrix == max_RMSE_list_kin_matrix;
print_matrix_latex(avg_RMSE_list_kin_matrix,[],["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(kinColHeaders,"_"," "), isBestRMSEkin,[])

% print average R GRF
avg_R_list_grf_matrix = [avg_R_list_grf_generic; avg_R_list_grf_personal; avg_R_list_grf_dhondt2024_3seg]';
max_R_list_grf_matrix = max(avg_R_list_grf_matrix,[],2);
isBestRgrf = avg_R_list_grf_matrix == max_R_list_grf_matrix;
print_matrix_latex(avg_R_list_grf_matrix,[],["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(GRFColHeaders,"_"," "), isBestRgrf,[])

% print average RMSE GRF
avg_RMSE_list_grf_matrix = [avg_rmse_list_grf_generic; avg_rmse_list_grf_personal; avg_rmse_list_grf_dhondt2024_3seg]';
max_RMSE_list_grf_matrix = min(avg_RMSE_list_grf_matrix,[],2);
isBestRMSEgrf = avg_RMSE_list_grf_matrix == max_RMSE_list_grf_matrix;
print_matrix_latex(avg_RMSE_list_grf_matrix,[],["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(GRFColHeaders,"_"," "), isBestRMSEgrf,[])

% print average R EMG
avg_R_list_emg_matrix = [avg_R_list_emg_generic; avg_R_list_emg_personal; avg_R_list_emg_dhondt2024_3seg]';
max_R_list_emg_matrix = max(avg_R_list_emg_matrix,[],2);
isBestRemg = avg_R_list_emg_matrix == max_R_list_emg_matrix;
print_matrix_latex(avg_R_list_emg_matrix,[],["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(EMGColHeadersLim,"_"," "), isBestRemg,[])

%% Print Matrix (Left/Right Average)
isLeftKin = endsWith(kinColHeaders,"_l"); isRightKin = endsWith(kinColHeaders,"_r");

% print average R kinematics
avg_R_list_kin_matrix_lr = (avg_R_list_kin_matrix(isLeftKin,:)+avg_R_list_kin_matrix(isRightKin,:))/2;
max_R_list_kin_matrix_lr = max(avg_R_list_kin_matrix_lr,[],2);
isBestRkin_lr = avg_R_list_kin_matrix_lr == max_R_list_kin_matrix_lr;
print_matrix_latex(avg_R_list_kin_matrix_lr,[],["Generic", "Personal", "Dhondt2024 3seg"], strrep(kinColHeaders(isLeftKin),"_l"," "), isBestRkin_lr,[])

% print average R kinematics
avg_RMSE_list_kin_matrix_lr = (avg_RMSE_list_kin_matrix(isLeftKin,:)+avg_RMSE_list_kin_matrix(isRightKin,:))/2;
max_RMSE_list_kin_matrix_lr = min(avg_RMSE_list_kin_matrix_lr,[],2);
isBestRMSEkin_lr = avg_RMSE_list_kin_matrix_lr == max_RMSE_list_kin_matrix_lr;
print_matrix_latex(avg_RMSE_list_kin_matrix_lr,[],["Generic", "Personal", "Dhondt2024 3seg"], strrep(kinColHeaders(isLeftKin),"_l"," "), isBestRMSEkin_lr,[])

% print average R GRF
avg_R_list_grf_matrix_lr = (avg_R_list_grf_matrix(1:3,:)+avg_R_list_grf_matrix(4:6,:))/2;
max_R_list_grf_matrix_lr = max(avg_R_list_grf_matrix_lr,[],2);
isBestRgrf_lr = avg_R_list_grf_matrix_lr == max_R_list_grf_matrix_lr;
print_matrix_latex(avg_R_list_grf_matrix_lr,[],["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(GRFColHeaders(1:3),"Right",""), isBestRgrf_lr,[])

% print average RMSE GRF
avg_RMSE_list_grf_matrix_lr = (avg_RMSE_list_grf_matrix(1:3,:)+avg_RMSE_list_grf_matrix(4:6,:))/2;
max_RMSE_list_grf_matrix_lr = min(avg_RMSE_list_grf_matrix_lr,[],2);
isBestRMSEgrf_lr = avg_RMSE_list_grf_matrix_lr == max_RMSE_list_grf_matrix_lr;
print_matrix_latex(avg_RMSE_list_grf_matrix_lr,[],["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(GRFColHeaders,"_"," "), isBestRMSEgrf_lr,[])

% print average R EMG
isLeftEMG = endsWith(EMGColHeadersLim,"_l");
isRightEMG = endsWith(EMGColHeadersLim,"_r");
avg_R_list_emg_matrix_lr = (avg_R_list_emg_matrix(isLeftEMG,:)+avg_R_list_emg_matrix(isRightEMG,:))/2;
max_R_list_emg_matrix_lr = max(avg_R_list_emg_matrix_lr,[],2);
isBestRemg_lr = avg_R_list_emg_matrix_lr == max_R_list_emg_matrix_lr;
print_matrix_latex(avg_R_list_emg_matrix_lr,[],["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(EMGColHeadersLim(isLeftEMG),"_l"," "), isBestRemg_lr,[])

%% Split Labels
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
kinLabels = repmat("[°]",Nkincol,1); kinLabels(isTrans) = "[m]";
grfLabels = repmat("Force [N]", Ngrfcol, 1);
kitLabels = repmat("Moment [Nm]", Nkincol, 1); kitLabels(isTrans) = "Force [N]";
emgLabels = repmat("Activation [-]", Nemgcol, 1);

jointNames = extractBefore(kinColHeaders,"_"); jointNames = strcat(upper(extractBefore(jointNames,2)), extractAfter(jointNames,1));
kitLabels = jointNames + " " + kitLabels;

muscleNames = extractBefore(EMGColHeaders,"_"); muscleNames = strcat(upper(extractBefore(muscleNames,2)), extractAfter(muscleNames,1));
muscleNamesLim = muscleNames(isLimEMG>0);
emgLabelsLim = emgLabels(isLimEMG>0);

%% Add Labels Directions
sagittalPlaneCols = 1:Nkincol; sagittalPlaneCols = sagittalPlaneCols(isSagittalPlaneKinematics);
kinLabelsExt = strings(Nkincol,2); kinLabelsExt(:,1) = kinLabels;
grfLabelsExt = strings(Ngrfcol,2); grfLabelsExt(:,1) = grfLabels;
kitLabelsExt = strings(Nkincol,2); kitLabelsExt(:,1) = kitLabels;

% ankle
isAnkle = contains(kinColHeaders,"ankle_angle");
kinLabelsExt(isAnkle,:) = [kinLabelsExt(isAnkle,1), repmat("plantar flexion (-) / dorsiflexion (+)",2,1)]; 
kitLabelsExt(isAnkle,:) = [kitLabelsExt(isAnkle,1), repmat("dorsiflexion (-) / plantar flexion (+)",2,1)]; 

% knee
isKnee = contains(kinColHeaders,"knee_angle");
kinLabelsExt(isKnee,:) = [kinLabelsExt(isKnee,1), repmat("flexion (-) / extension (+)",2,1)]; 
kitLabelsExt(isKnee,:) = [kitLabelsExt(isKnee,1), repmat("extension (-) / flexion (+)",2,1)]; 

% hip
isHip = contains(kinColHeaders,"hip_flexion");
kinLabelsExt(isHip,:) = [kinLabelsExt(isHip,1), repmat("extension (-) / flexion (+)",2,1)]; 
kitLabelsExt(isHip,:) = [kitLabelsExt(isHip,1), repmat("flexion (-) / extension (+)",2,1)]; 

% anterior-posterior force
isFx = contains(GRFColHeaders,"x");
grfLabelsExt(isFx,:) = [grfLabelsExt(isFx,1), repmat("posterior (-) / anterior (+)",2,1)];

% mediolateral force
isFz = contains(GRFColHeaders,"z");
grfLabelsExt(isFz,:) = [grfLabelsExt(isFz,1), repmat("lateral (-) / medial (+)",2,1)];

%% Plot Kinematics Results
% joint-specific bounds
bounds = NaN(Nkincol,2);
boundsSagg = [[-20 40]; % hip
    [-75 10];       % knee      
    [-16 21]];      % ankle

bounds(sagittalPlaneCols,:) = repmat(boundsSagg,2,1);

% switch left/right for more logical visual
sagittalPlaneColsLRswitched = sagittalPlaneCols;
sagittalPlaneColsLRswitched(1:3) = sagittalPlaneCols(4:6);
sagittalPlaneColsLRswitched(4:6) = sagittalPlaneCols(1:3);

% tile layout
tileCnt = 1;

t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.12 0.9 0.7];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.3])                        % IEEE 1-column: 8.89cm

for i = sagittalPlaneColsLRswitched(4:6)
    nexttile
    hold on
    XaxisLine = plot([0 1],[0 0],"Color","black","LineWidth",0.5);
    plot_mean_std(resampTime,mean(normalWalkingKinExpAvgLim(:,i,:),3),std(normalWalkingKinExpAvgLim(:,i,:),0,3),colors(1,:), linewidth,":")
    plot_mean_std(resampTime,GenericKinDataAvg(:,i),GenericKinDataSTD(:,i),colors(2,:), linewidth,"-")
    plot_mean_std(resampTime,Dhondt2024_3segKinDataAvg(:,i),Dhondt2024_3segKinDataSTD(:,i),colors(4,:), linewidth,"-")
    plot_mean_std(resampTime,PersonalKinDataAvg(:,i),PersonalKinDataSTD(:,i),colors(3,:), linewidth,"-")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    title(jointNames(i) + " Joint Angle")
    ylabel(kinLabelsExt(i,:),"FontWeight","bold", "HorizontalAlignment", "center")
    ylim(bounds(i,:))

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
    tileCnt = tileCnt + 1;

end
lg = legend(["","","experimental","", "generic", "", "D'Hondt2024 3seg", "", "personal"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.Box = 'off';
set(findall(t,'-property','FontSize'),'FontSize',8)                         % font size

if(export)
    figName = "experimental_generic_personal_dhondt2024_3seg_gait2128_sagg_kin" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Ground Reaction Forces
% force-specific bounds
boundsGrf = repmat([[-150 150]; % X
    [0 800];       % Y      
    [-40 60]],2,1);      % Z

grfLabelsExt(1:3,:) = "";
grfSigns = ones(Ngrfcol,1); grfSigns(3) = -1;

% tile layout
tileCnt = 1;
tileNmb = [1:2:6, 2:2:6];

t = tiledlayout(3,2,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.14 0.1 0.85 0.78];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height*1.2])                          % IEEE 1-column: 8.89cm

for i = [4:6 1:3]
    nexttile(tileNmb(tileCnt))
    tileCnt = tileCnt + 1;
    grid on
    hold on
    plot_mean_std(resampTime,GenericGRFDataAvg(:,i)*grfSigns(i),GenericGRFDataSTD(:,i),colors(2,:), linewidth,"-")
    plot_mean_std(resampTime,PersonalGRFDataAvg(:,i)*grfSigns(i),PersonalGRFDataSTD(:,i),colors(3,:), linewidth,"-")
    plot_mean_std(resampTime,Dhondt2024_3segGRFDataAvg(:,i)*grfSigns(i),Dhondt2024_3segGRFDataSTD(:,i),colors(4,:), linewidth,"--")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(grfLabelsExt(i,:),"FontWeight","bold")
    ylim(boundsGrf(i,:))
    
    % figure settings
    set(findall(t,'-property','FontSize'),'FontSize',8)                     % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Times")                                    % times new roman font
    hold off
end

lg = legend(["", "generic", "", "personal", "", "Dhondt2024 3seg"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.NumColumns = 2;

if(export)
    figName = "generic_personal_dhondt2024_3seg_gait2128_grf" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Joint Moments
isAnkle = contains(kinColHeaders,"ankle");
fixSign = ones(Nkincol,1);
fixSign(isAnkle) = -1;

% joint-specific bounds
bounds = NaN(Nkincol,2);
boundsSagg = [[-60 50]; % hip
    [-42 25];       % knee      
    [-25 110]];      % ankle

bounds(sagittalPlaneCols,:) = repmat(boundsSagg,2,1);
kitLabelsExt(sagittalPlaneCols(1:3),:) = "";

% switch left/right for more logical visual
sagittalPlaneColsLRswitched = sagittalPlaneCols;
sagittalPlaneColsLRswitched(1:3) = sagittalPlaneCols(4:6);
sagittalPlaneColsLRswitched(4:6) = sagittalPlaneCols(1:3);

% tile layout
tileCnt = 1;
tileNmb = [1:2:6, 2:2:6];

t = tiledlayout(3,2,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.14 0.1 0.85 0.78];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height*1.2])                          % IEEE 1-column: 8.89cm

for i = sagittalPlaneColsLRswitched
    nexttile(tileNmb(tileCnt))
    tileCnt = tileCnt + 1;
    grid on
    hold on
    plot_mean_std(resampTime,GenericKitDataAvg(:,i)*fixSign(i),GenericKitDataSTD(:,i),colors(2,:), linewidth, "-")
    plot_mean_std(resampTime,PersonalKitDataAvg(:,i)*fixSign(i),PersonalKitDataSTD(:,i),colors(3,:), linewidth, "-")
    plot_mean_std(resampTime,Dhondt2024_3segKitDataAvg(:,i)*fixSign(i),Dhondt2024_3segKitDataSTD(:,i),colors(4,:), linewidth, "-")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(kitLabelsExt(i,:),"FontWeight","bold")

    % figure settings
    set(findall(t,'-property','FontSize'),'FontSize',8)                     % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Times")                                    % times new roman font
    hold off

end

lg = legend(["", "generic", "", "personal", "", "Dhondt2024 3seg"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.NumColumns = 2;

if(export)
    figName = "generic_personal_dhondt2024_3seg_gait2128_sagg_kit" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Muscle Activations
% labels
muscleNamesPlot = ["Vasti", "Gastrocnemius", "Soleus", "Hamstrings", "Biceps Femoris", "Rectus Femoris"];

% tile layout
tileCnt = 1;

t = tiledlayout(1,6,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.05 0.12 0.94 0.68];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.4])                        % IEEE 1-column: 8.89cm

for i = 4:6
    nexttile
    hold on
    % plot experimental data
    legendTxt = plot_emg_active(resampTime, normalWalkingEMGavgLim(:,i), 0.15, "black", 0.95, 1);
    plot_mean_std(resampTime,GenericEmgDataAvg(:,i),GenericEmgDataSTD(:,i),colors(2,:), linewidth,"-")
    plot_mean_std(resampTime,PersonalEmgDataAvg(:,i),PersonalEmgDataSTD(:,i),colors(3,:), linewidth,"-")
    plot_mean_std(resampTime,Dhondt2024_3segEmgDataAvg(:,i),Dhondt2024_3segEmgDataSTD(:,i),colors(4,:), linewidth, "-")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    title(muscleNamesPlot(tileCnt))

    if(mod(tileCnt,3)-1 == 0)
        ylabel(emgLabelsLim(i),"FontWeight","bold")
    end
    ylim([0 1])

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
    tileCnt = tileCnt + 1;

end

for i = 1:3
    nexttile
    hold on
    % plot experimental data
    legendTxt = plot_emg_active(resampTime, normalWalkingEMGavgLim(:,i), 0.05, "black", 0.95, 1);
    plot_mean_std(resampTime,GenericEmgDataAvg(:,i),GenericEmgDataSTD(:,i),colors(2,:), linewidth,"-")
    plot_mean_std(resampTime,PersonalEmgDataAvg(:,i),PersonalEmgDataSTD(:,i),colors(3,:), linewidth,"-")
    plot_mean_std(resampTime,Dhondt2024_3segEmgDataAvg(:,i),Dhondt2024_3segEmgDataSTD(:,i),colors(4,:), linewidth, "-")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    title(muscleNamesPlot(tileCnt))
    ylim([0 1])

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
    tileCnt = tileCnt + 1;

end

lg = legend(["Experimental","","", "generic", "", "personal", "", "D'Hondt2024 3seg"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.Box = 'off';
set(findall(t,'-property','FontSize'),'FontSize',8)                   % font size

if(export)
    figName = "experimental_generic_personal_dhondt2024_3seg_gait2128_emg2" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

