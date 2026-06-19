clear all
clc
close all

%% Load Libraries
addpath("C:\Users\medenaye\Documents\programs\GitHub\OpenSim-Processing\data-processing\utilities")
addpath(pwd + "\helperFunctions")

%% Comments
% - fix kinematics tx/tz because switched labels from experimental and not centered around 0

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];   
NSUBJ = length(SUBJID);
trackKeyWords = "gait1422";
genericKeyWords = "generic";
personalKeyWords = "optTrack";
dhondt2024_3segKeyWords = "Dhondt2024_3seg";
resultsSubFolder = repmat("trackKIN-compliantTendon-3D",1,NSUBJ);
resultsSubFolder = resultsSubFolder + "/" + ["SUBJ04mtu3D_02421031", "SUBJ06mtu3D_02452315", "SUBJ07mtu3D_02462103", "SUBJ09mtu3D_02472054", "SUBJ10mtu3D_02491301", "SUBJ11mtu3D_02501441"];
resampTime = 0:0.01:1;

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = false;
figFileType = ".pdf";
linewidth = 1.5;
colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

%% General Variables
Ndata = length(resampTime);
Nkincol = 19;
Ngrfcol = 6;
Nemgcol = 28;
emg_col_exp = ["bifemsh_r","hamstrings_r","rect_fem_r","vasti_r","","gastroc_r","","soleus_r","bifemsh_l","hamstrings_l","rect_fem_l","vasti_l","","gastroc_l","","soleus_l"];
emg_threshold = 0.15;

%% Load Tracking Results
TrackOneDriveDIR = "C:\Users\medenaye\OneDrive - Vrije Universiteit Brussel\PhD-Main\[01] main\WP1\T1.3\[03] data";
trackDIR = uigetdir(TrackOneDriveDIR,"Choose tracking directory");

%% Load Generic Results
ResultsOneDriveDIR = "C:\Users\medenaye\OneDrive - Vrije Universiteit Brussel\PhD-Main\[01] main\WP1\T1.3\[01] results\PredSim";
resultsDIR = uigetdir(ResultsOneDriveDIR,"Choose generic solution directory");

%% Choose Desired Tracking Folders
TrackFolders = find_desired_folders(trackDIR, SUBJID);
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);

%% Load Experimental Data
[expDataFile, expDataDIR] = uigetfile(".mat","Choose experimental data file");
expData = load(fullfile(expDataDIR, expDataFile));

%% Load Results
% Load tracking data
trackSubFolder = ["gait1422_MTPjoint_11433261", "gait1422_MTPjoint_11448691", "gait1422_MTPjoint_11417571", "gait1422_MTPjoint_11453296", "gait1422_MTPjoint_11454268", "gait1422_MTPjoint_11432683"];
[TrackKinData, TrackGrfData, TrackKitData, TrackEmgData, ~, SUBJmass, ~, TrackIdxHeelL, kinColHeaders, GRFColHeaders, EMGColHeaders] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, trackDIR, TrackFolders, trackSubFolder, trackKeyWords, 1);

% Load generic model results
[GenericKinData, GenericGrfData, GenericKitData, GenericEmgData,~,~,~,GenericIdxHeelL,~,~,~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, resultsSubFolder, genericKeyWords, 1);

% Load personalized model results
[PersonalKinData, PersonalGrfData, PersonalKitData, PersonalEmgData,~,~,~,PersonalIdxHeelL,~,~,~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, resultsSubFolder, personalKeyWords, 1);

% Dhondt2024 3seg 2022 scaled
dhondt2024_3segSubFolders = repmat("Dhondt2024_3seg",1,NSUBJ) + "/" + ["SUBJ04_Dhondt2024_3seg_17062026", "SUBJ06_Dhondt2024_3seg_17062026", "SUBJ07_Dhondt2024_3seg_17062026", "SUBJ09_Dhondt2024_3seg_17062026", "SUBJ10_Dhondt2024_3seg_17062026", "SUBJ11_Dhondt2024_3seg_17062026"];
[Dhondt2024_3segKinData, Dhondt2024_3segGrfData, Dhondt2024_3segKitData,Dhondt2024_3segEmgData,~,~,~,Dhondt2024_3segIdxHeelL,Dhondt2024_3segkinColHeaders,~,Dhondt2024_3segEmgColHeaders] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders, dhondt2024_3segKeyWords, 1);
Dhondt2024_3segisLimKin = ismember(Dhondt2024_3segkinColHeaders, kinColHeaders);

Dhondt2024_3segKinDataLim = Dhondt2024_3segKinData(:,Dhondt2024_3segisLimKin>0,:);
Dhondt2024_3segGrfDataLim = Dhondt2024_3segGrfData(:,:,:);
Dhondt2024_3segKitDataLim = Dhondt2024_3segKitData(:,Dhondt2024_3segisLimKin>0,:);

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
[isLimKINexp,~]=ismember(kin_col_exp,kinColHeaders);
normalWalkingKinExpAvgLim = normalWalkingKinExpAvg(:,isLimKINexp>0,:);
normalWalkingKinExpStdLim = normalWalkingKinExpStd(:,isLimKINexp>0,:);

%% Extract Experimental GRF Data
Ngrfcolexp = length(expData.data.headers.GRF);
normalWalkingGrfExpAvg = NaN(Ndata, Ngrfcolexp, NSUBJ);
normalWalkingGrfExpStd = NaN(Ndata, Ngrfcolexp, NSUBJ);

for i = 1:NSUBJ
    normalWalkingGrfExpAvg(:,:,i) = mean(expData.data.("SUBJ" + SUBJID(i)).GRF.GRFdataNormal,3,"omitnan");
    normalWalkingGrfExpStd(:,:,i) = std(expData.data.("SUBJ" + SUBJID(i)).GRF.GRFdataNormal,0,3,"omitnan");
end

% find corresponding columns
% grf_col_exp = expData.data.headers.GRF;
% isForce = contains(grf_col_exp,"ground_force") & contains(grf_col_exp,"v");
% grf_force_exp = grf_col_exp(isForce);
% [isLimGRFexp,~]=ismember(grf_col_exp,GRFColHeaders);
% normalWalkingGrfExpAvgLim = normalWalkingGrfExpAvg(:,isForce,:);
% normalWalkingGrfExpStdLim = normalWalkingGrfExpStd(:,isForce,:);

%% Assign EMG Columns
[isLimEMG,isLimEMGexp]=ismember(EMGColHeaders,emg_col_exp);
EMGColHeadersLim = EMGColHeaders(isLimEMG>0);                               % simulation data only for muscle with experimental data
TrackEmgDataLim = TrackEmgData(:,isLimEMG>0,:);
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
[Dhondt2024_3seg_isLimEmg, Dhondt2024_3seg_isLimEmgIdxs] = ismember(Dhondt2024_3segEmgColHeaders, EMGColHeadersLim);

Dhondt2024_3segEmgDataLim = NaN(Ndata, NemgcolLim, NSUBJ);
Dhondt2024_3segEmgDataLim(:,Dhondt2024_3seg_isLimEmgIdxs(Dhondt2024_3seg_isLimEmgIdxs>0),:) = Dhondt2024_3segEmgData(:,Dhondt2024_3seg_isLimEmg>0,:);

%% Shift Left EMG Simulation Data
% experimental data starts at left heel strike
for i = 1:NSUBJ
    TrackEmgDataLim(:,NemgcolLim/2+1:end,i) = circshift(TrackEmgDataLim(:,NemgcolLim/2+1:end,i),-TrackIdxHeelL(i),1);
    GenericEmgDataLim(:,NemgcolLim/2+1:end,i) = circshift(GenericEmgDataLim(:,NemgcolLim/2+1:end,i),-GenericIdxHeelL(i),1);
    PersonalEmgDataLim(:,NemgcolLim/2+1:end,i) = circshift(PersonalEmgDataLim(:,NemgcolLim/2+1:end,i),-PersonalIdxHeelL(i),1);
    Dhondt2024_3segEmgDataLim(:,NemgcolLim/2+1:end,i) = circshift(Dhondt2024_3segEmgDataLim(:,NemgcolLim/2+1:end,i),-Dhondt2024_3segIdxHeelL(i),1);
end

%% Average Results
% Tracking reference
TrackKinDataAvg = mean(TrackKinData,3,"omitnan");
TrackKinDataSTD = std(TrackKinData,0,3,"omitnan");
TrackGRFDataAvg = mean(TrackGrfData,3,"omitnan");
TrackGRFDataSTD = std(TrackGrfData,0,3,"omitnan");
TrackKitDataAvg = mean(TrackKitData,3,"omitnan");
TrackKitDataSTD = std(TrackKitData,0,3,"omitnan");
TrackEmgDataAvg = mean(TrackEmgDataLim,3,"omitnan");
TrackEmgDataSTD = std(TrackEmgDataLim,0,3,"omitnan");

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

%% Shift Left Kinematics Simulation Data
% experimental data starts at left heel strike
isLeftKin = contains(kinColHeaders,"_l") & ~contains(kinColHeaders,"pelvis");

GenericKinDataShifted = GenericKinData;
PersonalKinDataShifted = PersonalKinData;
Dhondt2024_3segKinDataShifted = Dhondt2024_3segKinDataLim;

for i = 1:NSUBJ
    GenericKinDataShifted(:,isLeftKin,i) = circshift(GenericKinData(:,isLeftKin,i),-GenericIdxHeelL(i),1);
    PersonalKinDataShifted(:,isLeftKin,i) = circshift(PersonalKinData(:,isLeftKin,i),-PersonalIdxHeelL(i),1);
    Dhondt2024_3segKinDataShifted(:,isLeftKin,i) = circshift(Dhondt2024_3segKinDataLim(:,isLeftKin,i),-Dhondt2024_3segIdxHeelL(i),1);
end

%% Shift Left GRF Simulation Data
% experimental data starts at left heel strike
isLeftGrf = contains(GRFColHeaders,"Left");

GenericGrfDataShifted = GenericGrfData;
PersonalGrfDataShifted = PersonalGrfData;
Dhondt2024_3segGrfDataShifted = Dhondt2024_3segGrfData;
for i = 1:NSUBJ
    GenericGrfDataShifted(:,isLeftGrf,i) = circshift(GenericGrfData(:,isLeftGrf,i),-GenericIdxHeelL(i),1);
    PersonalGrfDataShifted(:,isLeftGrf,i) = circshift(PersonalGrfData(:,isLeftGrf,i),-PersonalIdxHeelL(i),1);
    Dhondt2024_3segGrfDataShifted(:,isLeftGrf,i) = circshift(Dhondt2024_3segGrfData(:,isLeftGrf,i),-Dhondt2024_3segIdxHeelL(i),1);
end

%% Debug Plot
% for i = 1:Nkincol
%     figure
%     hold on
%     for j = 1:NSUBJ
%         % figure
%         % hold on
%         plot_mean_std(resampTime, normalWalkingKinExpAvgLim(:,i,j),normalWalkingKinExpStdLim(:,i,j),"black",1,"-")
%         plot(resampTime, GenericKinDataShifted(:,i,j),"Color","magenta")
%         plot(resampTime, PersonalKinDataShifted(:,i,j),"Color","red")
%         plot(resampTime, Dhondt2024_3segKinDataShifted(:,i,j),"Color","blue")
%         legend(["", "Exp", "Generic", "Personal", "Dhondt2024_3seg"])
%         title(kinColHeaders(i) + " - SUBJECT " + num2str(j))
%         % hold off
%     end
%     hold off
% end

% for i = 1:Ngrfcol
%     figure
%     hold on
%     for j = 1:NSUBJ
%         % figure
%         % hold on
%         plot_mean_std(resampTime, normalWalkingGrfExpAvg(:,i,j),normalWalkingGrfExpStd(:,i,j),"black",1,"-")
%         plot(resampTime, GenericGrfDataShifted(:,i,j),"Color","magenta")
%         plot(resampTime, PersonalGrfDataShifted(:,i,j),"Color","red")
%         plot(resampTime, Dhondt2024_3segGrfDataShifted(:,i,j),"Color","blue")
%         legend(["", "Exp", "Generic", "Personal", "Dhondt2024_3seg"])
%         % hold off
%     end
%     hold off
% end

% for i = 1:Nemgcol
%     figure
%     hold on
%     for j = 1:NSUBJ
%         % figure
%         % hold on
%         plot(resampTime, GenericEmgData(:,i,j),"Color","magenta")
%         plot(resampTime, PersonalEmgData(:,i,j),"Color","red")
%         legend(["Generic", "Personal"])
%         % hold off
%     end
%     title(EMGColHeaders(i))
%     hold off
% end

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

% store tracking metrics
R_list_emg_track = NaN(NSUBJ,NemgcolLim);

for i = 1:NSUBJ
    % kinematics (compared to tracking)
    % [R_list_kin_personal(i,:), rmse_list_kin_personal(i,:), ~] = compute_metrics(PersonalKinData(:,:,i), TrackKinData(:,:,i), NaN);
    % [R_list_kin_generic(i,:), rmse_list_kin_generic(i,:), ~] = compute_metrics(GenericKinData(:,:,i), TrackKinData(:,:,i), NaN);
    % [R_list_kin_dhondt2024_3seg(i,:), rmse_list_kin_dhondt2024_3seg(i,:), ~] = compute_metrics(Dhondt2024_3segKinDataLim(:,:,i), TrackKinData(:,:,i), NaN);

    % kinematics (compared to experimental average)
    [R_list_kin_personal(i,:), rmse_list_kin_personal(i,:), ~] = compute_metrics(PersonalKinDataShifted(:,:,i), normalWalkingKinExpAvgLim(:,:,i), normalWalkingKinExpStdLim(:,:,i));
    [R_list_kin_generic(i,:), rmse_list_kin_generic(i,:), ~] = compute_metrics(GenericKinDataShifted(:,:,i), normalWalkingKinExpAvgLim(:,:,i), normalWalkingKinExpStdLim(:,:,i));
    [R_list_kin_dhondt2024_3seg(i,:), rmse_list_kin_dhondt2024_3seg(i,:), ~] = compute_metrics(Dhondt2024_3segKinDataShifted(:,:,i), normalWalkingKinExpAvgLim(:,:,i), normalWalkingKinExpStdLim(:,:,i));
    
    % GRF (compared to tracking)
    % [R_list_grf_personal(i,:), rmse_list_grf_personal(i,:), ~] = compute_metrics(PersonalGrfData(:,:,i)/SUBJmass(i), TrackGrfData(:,:,i)/SUBJmass(i), NaN);
    % [R_list_grf_generic(i,:), rmse_list_grf_generic(i,:), ~] = compute_metrics(GenericGrfData(:,:,i)/SUBJmass(i), TrackGrfData(:,:,i)/SUBJmass(i), NaN);
    % [R_list_grf_dhondt2024_3seg(i,:), rmse_list_grf_dhondt2024_3seg(i,:), ~] = compute_metrics(Dhondt2024_3segGrfDataLim(:,:,i)/SUBJmass(i), TrackGrfData(:,:,i)/SUBJmass(i), NaN);

    % GRF (compared to experimental average)
    [R_list_grf_personal(i,:), rmse_list_grf_personal(i,:), ~] = compute_metrics(PersonalGrfDataShifted(:,:,i)/SUBJmass(i), normalWalkingGrfExpAvg(:,:,i)/SUBJmass(i), normalWalkingGrfExpStd(:,:,i)/SUBJmass(i));
    [R_list_grf_generic(i,:), rmse_list_grf_generic(i,:), ~] = compute_metrics(GenericGrfDataShifted(:,:,i)/SUBJmass(i), normalWalkingGrfExpAvg(:,:,i)/SUBJmass(i), normalWalkingGrfExpStd(:,:,i)/SUBJmass(i));
    [R_list_grf_dhondt2024_3seg(i,:), rmse_list_grf_dhondt2024_3seg(i,:), ~] = compute_metrics(Dhondt2024_3segGrfDataShifted(:,:,i)/SUBJmass(i), normalWalkingGrfExpAvg(:,:,i)/SUBJmass(i), normalWalkingGrfExpStd(:,:,i)/SUBJmass(i));

    % EMG (compared to experimental average)
    subjectEMGdata = expData.data.("SUBJ" + SUBJID(i)).EMG.EMGdataNormal;
    subjectEMGdataAvg = mean(subjectEMGdata,3,"omitnan");
    subjectEMGdataAvgLim = subjectEMGdataAvg(:,isLimEMGexp(isLimEMGexp>0));

    [R_list_emg_personal(i,:), ~, ~] = compute_metrics(PersonalEmgDataLim(:,:,i), normalWalkingEMGexpLim(:,:,i), NaN);
    [R_list_emg_generic(i,:), ~, ~] = compute_metrics(GenericEmgDataLim(:,:,i), normalWalkingEMGexpLim(:,:,i), NaN);
    [R_list_emg_dhondt2024_3seg(i,:), ~, ~] = compute_metrics(Dhondt2024_3segEmgDataLim(:,:,i), normalWalkingEMGexpLim(:,:,i), NaN);
    [R_list_emg_track(i,:), ~, ~] = compute_metrics(TrackEmgDataLim(:,:,i), normalWalkingEMGexpLim(:,:,i), NaN);

    % EMG (compared to generic model)
    [R_list_emg_per_vs_gen(i,:), ~, ~] = compute_metrics(PersonalEmgData(:,:,i), GenericEmgData(:,:,i), NaN);
end

%% Save Metrics
% % open metrics file
% load("metrics.mat");
% 
% % colheaders
% metrics.colheaders.kinematics = kinColHeaders;
% metrics.colheaders.ground_reaction = GRFColHeaders;
% metrics.colheaders.muscle_activation = EMGColHeadersLim;
% 
% % kinematics, R
% metrics.kinematics.normal.R.personal = R_list_kin_personal;
% metrics.kinematics.normal.R.generic = R_list_kin_generic;
% metrics.kinematics.normal.R.dhondt2024_3seg = R_list_kin_dhondt2024_3seg;
% 
% % kinematics, RMSE
% metrics.kinematics.normal.RMSE.personal = rmse_list_kin_personal;
% metrics.kinematics.normal.RMSE.generic = rmse_list_kin_generic;
% metrics.kinematics.normal.RMSE.dhondt2024_3seg = rmse_list_kin_dhondt2024_3seg;
% 
% % GRFs, R
% metrics.ground_reaction.normal.R.personal = R_list_grf_personal;
% metrics.ground_reaction.normal.R.generic = R_list_grf_generic;
% metrics.ground_reaction.normal.R.dhondt2024_3seg = R_list_grf_dhondt2024_3seg;
% 
% % GRFs, RMSE
% metrics.ground_reaction.normal.RMSE.personal = rmse_list_grf_personal;
% metrics.ground_reaction.normal.RMSE.generic = rmse_list_grf_generic;
% metrics.ground_reaction.normal.RMSE.dhondt2024_3seg = rmse_list_grf_dhondt2024_3seg;
% 
% % EMG, R
% metrics.muscle_activations.normal.R.personal = R_list_emg_personal;
% metrics.muscle_activations.normal.R.generic = R_list_emg_generic;
% metrics.muscle_activations.normal.R.dhondt2024_3seg = R_list_emg_dhondt2024_3seg;
% metrics.muscle_activations.normal.R.tracking = R_list_emg_track;
% metrics.muscle_activations.normal.R.personal_vs_generic = R_list_emg_per_vs_gen;
% 
% % save metrics
% save("metrics.mat", "metrics")

%% Compute Total Average of Metrics
% R over all subjects & kinematics
R_tot_kin_personal = mean(R_list_kin_personal,"all");
R_tot_kin_generic = mean(R_list_kin_generic,"all");
R_tot_kin_dhondt2024_3seg = mean(R_list_kin_dhondt2024_3seg,"all");

% RMSE over all subjects & kinematics (rotational)
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
rmse_tot_kin_personal_rot = mean(rmse_list_kin_personal(:,~isTrans),"all");
rmse_tot_kin_generic_rot = mean(rmse_list_kin_generic(:,~isTrans),"all");
rmse_tot_kin_dhondt2024_3seg_rot = mean(rmse_list_kin_dhondt2024_3seg(:,~isTrans),"all");

% RMSE over all subjects & kinematics (translational)
rmse_tot_kin_personal_trans = mean(rmse_list_kin_personal(:,isTrans),"all");
rmse_tot_kin_generic_trans = mean(rmse_list_kin_generic(:,isTrans),"all");
rmse_tot_kin_dhondt2024_3seg_trans = mean(rmse_list_kin_dhondt2024_3seg(:,isTrans),"all");

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
avg_R_list_emg_track = mean(R_list_emg_track,1,"omitnan");

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
[avg_percent_R_kin, ~] = compute_R_average_improvement(avg_R_list_kin_personal, avg_R_list_kin_generic, avg_R_list_grf_personal, avg_R_list_grf_generic, avg_R_list_emg_personal, avg_R_list_emg_generic,'personal model (all kinematics)');
[avg_percent_R_kin_dhondt2024_3seg, ~] = compute_R_average_improvement(avg_R_list_kin_dhondt2024_3seg, avg_R_list_kin_generic, avg_R_list_grf_dhondt2024_3seg, avg_R_list_grf_generic, avg_R_list_emg_dhondt2024_3seg, avg_R_list_emg_generic, 'dhondt2024_3seg model (all kinematics)');

% compute average RMSE sagittal plane improvements
% negative means RMSE error decreased
[avg_percent_rmse_kin_sagg, avg_percent_rmse_grf] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal(isSagittalPlaneKinematics), avg_rmse_list_kin_generic(isSagittalPlaneKinematics), avg_rmse_list_grf_personal, avg_rmse_list_grf_generic, 'personal model (sagittal plane)');
[avg_percent_rmse_kin_sagg_dhondt2024_3seg, avg_percent_rmse_grf_dhondt2024_3seg] = compute_RMSE_average_improvement(avg_rmse_list_kin_dhondt2024_3seg(isSagittalPlaneKinematics), avg_rmse_list_kin_generic(isSagittalPlaneKinematics), avg_rmse_list_grf_dhondt2024_3seg, avg_rmse_list_grf_generic, 'dhondt2024_3seg model (sagittal plane)');

% compute average RMSE improvements (including not sagittal plane)
% negative means RMSE error decreased
[avg_percent_rmse_kin, ~] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal, avg_rmse_list_kin_generic, avg_rmse_list_grf_personal, avg_rmse_list_grf_generic, 'personal model (all kinematics)');
[avg_percent_rmse_kin_dhondt2024_3seg, ~] = compute_RMSE_average_improvement(avg_rmse_list_kin_dhondt2024_3seg, avg_rmse_list_kin_generic, avg_rmse_list_grf_dhondt2024_3seg, avg_rmse_list_grf_generic, 'dhondt2024_3seg model (all kinematics)');

%% Print Matrix
% print average R kinematics
avg_R_list_kin_matrix = round([avg_R_list_kin_generic; avg_R_list_kin_personal; avg_R_list_kin_dhondt2024_3seg],2)';
max_R_list_kin_matrix = max(avg_R_list_kin_matrix,[],2);
isBestRkin = avg_R_list_kin_matrix == max_R_list_kin_matrix;
print_matrix_latex(avg_R_list_kin_matrix,["Generic", "Personal", "Dhondt2024 3seg"], strrep(kinColHeaders,"_"," "), isBestRkin)

% print average RMSE kinematics
avg_RMSE_list_kin_matrix = round([avg_rmse_list_kin_generic; avg_rmse_list_kin_personal; avg_rmse_list_kin_dhondt2024_3seg],2)';
max_RMSE_list_kin_matrix = min(avg_RMSE_list_kin_matrix,[],2);
isBestRMSEkin = avg_RMSE_list_kin_matrix == max_RMSE_list_kin_matrix;
print_matrix_latex(avg_RMSE_list_kin_matrix,["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(kinColHeaders,"_"," "), isBestRMSEkin)

% print average R GRF
avg_R_list_grf_matrix = round([avg_R_list_grf_generic; avg_R_list_grf_personal; avg_R_list_grf_dhondt2024_3seg],2)';
max_R_list_grf_matrix = max(avg_R_list_grf_matrix,[],2);
isBestRgrf = avg_R_list_grf_matrix == max_R_list_grf_matrix;
print_matrix_latex(avg_R_list_grf_matrix,["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(GRFColHeaders,"_"," "), isBestRgrf)

% print average RMSE GRF
avg_RMSE_list_grf_matrix = round([avg_rmse_list_grf_generic; avg_rmse_list_grf_personal; avg_rmse_list_grf_dhondt2024_3seg],2)';
max_RMSE_list_grf_matrix = min(avg_RMSE_list_grf_matrix,[],2);
isBestRMSEgrf = avg_RMSE_list_grf_matrix == max_RMSE_list_grf_matrix;
print_matrix_latex(avg_RMSE_list_grf_matrix,["Generic", "Personal", "D'Hondt2024 3 seg"], strrep(GRFColHeaders,"_"," "), isBestRMSEgrf)

% print average R EMG
avg_R_list_emg_matrix = round([avg_R_list_emg_generic; avg_R_list_emg_personal; avg_R_list_emg_dhondt2024_3seg; avg_R_list_emg_track],2)';
max_R_list_emg_matrix = max(avg_R_list_emg_matrix,[],2);
isBestRemg = avg_R_list_emg_matrix == max_R_list_emg_matrix;
print_matrix_latex(avg_R_list_emg_matrix,["Generic", "Personal", "D'Hondt2024 3 seg", "Tracking"], strrep(EMGColHeadersLim,"_"," "), isBestRemg)

%% Compute Recall for Sagittal Plane Kinematics
PersonalKinData_sag = PersonalKinData(:,isSagittalPlaneKinematics,:);
GenericKinData_sag = GenericKinData(:,isSagittalPlaneKinematics,:);
TrackKinData_sag = TrackKinData(:,isSagittalPlaneKinematics,:);
Dhondt2024_3segKinData_sag = Dhondt2024_3segKinData(:,isSagittalPlaneKinematics,:);

[recall_pers_R, IDmatrix_pers_R] = compute_recall(PersonalKinData_sag, TrackKinData_sag, "R");
[recall_gen_R, IDmatrix_gen_R] = compute_recall(GenericKinData_sag, TrackKinData_sag, "R");
[recall_fal_R, IDmatrix_fal_R] = compute_recall(Dhondt2024_3segKinData_sag, TrackKinData_sag, "R");

[recall_pers_RMSE, IDmatrix_pers_RMSE] = compute_recall(PersonalKinData_sag, TrackKinData_sag, "RMSE");
[recall_gen_RMSE, IDmatrix_gen_RMSE] = compute_recall(GenericKinData_sag, TrackKinData_sag, "RMSE");
[recall_fal_RMSE, IDmatrix_fal_RMSE] = compute_recall(Dhondt2024_3segKinData_sag, TrackKinData_sag, "RMSE");

%% Print Matrix (Latex)
% print_matrix_latex(IDmatrix_pers_R)
% print_matrix_latex(IDmatrix_gen_R)
% print_matrix_latex(IDmatrix_pers_RMSE)
% print_matrix_latex(IDmatrix_gen_RMSE)

%% Split Labels
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
kinLabels = repmat("[°]",Nkincol,1); kinLabels(isTrans) = "[m]";
grfLabels = repmat("Force [N]", Ngrfcol, 1);
kitLabels = repmat("Moment [Nm]", Nkincol, 1); kitLabels(isTrans) = "Force [N]";
emgLabels = repmat("Activation [-]", Nemgcol, 1);

jointNames = extractBefore(kinColHeaders,"_"); jointNames = strcat(upper(extractBefore(jointNames,2)), extractAfter(jointNames,1));
% kinLabels = jointNames + " " + kinLabels;
kitLabels = jointNames + " " + kitLabels;

muscleNames = extractBefore(EMGColHeaders,"_"); muscleNames = strcat(upper(extractBefore(muscleNames,2)), extractAfter(muscleNames,1));
% emgLabels = muscleNames' + " " + emgLabels;
muscleNamesLim = muscleNames(isLimEMG>0);
emgLabelsLim = emgLabels(isLimEMG>0);

%% Add Labels Directions
sagittalPlaneCols = 1:Nkincol; sagittalPlaneCols = sagittalPlaneCols(isSagittalPlaneKinematics);
kinLabelsExt = strings(Nkincol,2); kinLabelsExt(:,1) = kinLabels;
grfLabelsExt = strings(Ngrfcol,2); grfLabelsExt(:,1) = grfLabels;
kitLabelsExt = strings(Nkincol,2); kitLabelsExt(:,1) = kitLabels;

leftArrow = "\leftarrow";
rightArrow = "\rightarrow";

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

% anteriorposterior force
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
    [-15 20]];      % ankle

bounds(sagittalPlaneCols,:) = repmat(boundsSagg,2,1);
% kinLabelsExt(sagittalPlaneCols(1:3),:) = "";

% switch left/right for more logical visual
sagittalPlaneColsLRswitched = sagittalPlaneCols;
sagittalPlaneColsLRswitched(1:3) = sagittalPlaneCols(4:6);
sagittalPlaneColsLRswitched(4:6) = sagittalPlaneCols(1:3);

% tile layout
tileCnt = 1;
tileNmb = [1:2:6, 2:2:6];

t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.12 0.9 0.7];
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.3])                          % IEEE 1-column: 8.89cm
% for i = 1:Nkincol
for i = sagittalPlaneColsLRswitched(4:6)
    % fig = figure;
    nexttile
    % grid on
    hold on
    XaxisLine = plot([0 1],[0 0],"Color","black","LineWidth",0.5);
    plot_mean_std(resampTime,TrackKinDataAvg(:,i),TrackKinDataSTD(:,i),colors(1,:), linewidth,":")
    plot_mean_std(resampTime,GenericKinDataAvg(:,i),GenericKinDataSTD(:,i),colors(2,:), linewidth,"-")
    plot_mean_std(resampTime,Dhondt2024_3segKinDataAvg(:,i),Dhondt2024_3segKinDataSTD(:,i),colors(4,:), linewidth,"-")
    plot_mean_std(resampTime,PersonalKinDataAvg(:,i),PersonalKinDataSTD(:,i),colors(3,:), linewidth,"-")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    title(jointNames(i) + " Joint Angle")
    ylabel(kinLabelsExt(i,:),"FontWeight","bold", "HorizontalAlignment", "center")
    % title(strrep(kinColHeaders(i),"_"," "))
    ylim(bounds(i,:))

    % figure settings
    % set(findall(t,'-property','FontSize'),'FontSize',8)                     % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                    % times new roman font
    hold off
    tileCnt = tileCnt + 1;
    % set(gca,"Units","centimeters")                                          % cm units for position
    % set(gca,"Position",[1.2 0.8 fig_width fig_height*1.2])                  % axes position (x, y, w, h)
    % hold off
    % axis tight

    % if(export)
    %     figName = "tracking_generic_personal_dhondt2024_3seg_gait2128_kin_" + kinColHeaders(i) + figFileType;
    %     exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    % end

end
lg = legend(["","","reference","", "generic", "", "D'Hondt2024 3seg", "", "personal"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.Box = 'off';
% lg.NumColumns = 2;
set(findall(t,'-property','FontSize'),'FontSize',8)                     % font size

if(export)
    figName = "tracking_generic_personal_dhondt2024_3seg_gait2128_sagg_kin" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Create PPT Animation
% create_ppt_animation(resampTime, sagittalPlaneCols(1:3), TrackKinDataAvg, zeros(Ndata,Nkincol), GenericKinDataAvg, zeros(Ndata,Nkincol), PersonalKinDataAvg, zeros(Ndata,Nkincol), Dhondt2024_3segKinDataAvg, zeros(Ndata,Nkincol), colors, kinLabels, kinColHeaders, "tracking_generic_personal_dhondt2024_3seg_gait1422_kin_", true)

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
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height*1.2])                          % IEEE 1-column: 8.89cm

for i = [4:6 1:3]
    % fig = figure;
    nexttile(tileNmb(tileCnt))
    tileCnt = tileCnt + 1;
    % set(gcf,"Units","centimeters")                                          % cm units for position
    % set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    grid on
    hold on
    plot_mean_std(resampTime,TrackGRFDataAvg(:,i)*grfSigns(i),TrackGRFDataSTD(:,i),colors(1,:), linewidth,"-")
    plot_mean_std(resampTime,GenericGRFDataAvg(:,i)*grfSigns(i),GenericGRFDataSTD(:,i),colors(2,:), linewidth,"-")
    plot_mean_std(resampTime,PersonalGRFDataAvg(:,i)*grfSigns(i),PersonalGRFDataSTD(:,i),colors(3,:), linewidth,"-")
    plot_mean_std(resampTime,Dhondt2024_3segGRFDataAvg(:,i)*grfSigns(i),Dhondt2024_3segGRFDataSTD(:,i),colors(4,:), linewidth,"--")
    % legend(["","Tracking","", "Generic", "", "Personal", "", "Dhondt2024_3seg"],"Location","best")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(grfLabelsExt(i,:),"FontWeight","bold")
    ylim(boundsGrf(i,:))
    % title(GRFColHeaders(i))
    
    % figure settings
    set(findall(t,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Times")                                % times new roman font
    % set(gca,"Units","centimeters")                                          % cm units for position
    % set(gca,"Position",[1.2 0.8 fig_width-1.5 fig_height-1.5])              % axes position (x, y, w, h)
    hold off
    % axis tight

    % if(export)
    %     figName = "tracking_generic_personal_dhondt2024_3seg_gait1422_grf_" + GRFColHeaders(i) + figFileType;
    %     exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    % end
end

lg = legend(["","tracking","", "generic", "", "personal", "", "Dhondt2024 3seg"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.NumColumns = 2;

if(export)
    figName = "tracking_generic_personal_dhondt2024_3seg_gait2128_grf" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Create PPT Animation
% create_ppt_animation(resampTime, 1:Ngrfcol, TrackGRFDataAvg, zeros(Ndata,Nkincol), GenericGRFDataAvg, zeros(Ndata,Nkincol), PersonalGRFDataAvg, zeros(Ndata,Nkincol), Dhondt2024_3segGRFDataAvg, zeros(Ndata,Nkincol), colors, grfLabels, GRFColHeaders, "tracking_generic_personal_dhondt2024_3seg_gait1422_grf_", true)

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
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height*1.2])                          % IEEE 1-column: 8.89cm

for i = sagittalPlaneColsLRswitched
    nexttile(tileNmb(tileCnt))
    tileCnt = tileCnt + 1;
    % set(gcf,"Units","centimeters")                                          % cm units for position
    % set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    grid on
    hold on
    plot_mean_std(resampTime,TrackKitDataAvg(:,i)*fixSign(i),TrackKitDataSTD(:,i),colors(1,:), linewidth, "-")
    plot_mean_std(resampTime,GenericKitDataAvg(:,i)*fixSign(i),GenericKitDataSTD(:,i),colors(2,:), linewidth, "-")
    plot_mean_std(resampTime,PersonalKitDataAvg(:,i)*fixSign(i),PersonalKitDataSTD(:,i),colors(3,:), linewidth, "-")
    plot_mean_std(resampTime,Dhondt2024_3segKitDataAvg(:,i)*fixSign(i),Dhondt2024_3segKitDataSTD(:,i),colors(4,:), linewidth, "-")
    % legend(["","Tracking","", "Generic", "", "Personal", "", "Dhondt2024_3seg"],"Location","best")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(kitLabelsExt(i,:),"FontWeight","bold")
    % ylim(bounds)
    % title(strrep(kinColHeaders(i),"_"," ") + " Joint Moment")

    % figure settings
    set(findall(t,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Times")                                % times new roman font
    % set(gca,"Units","centimeters")                                          % cm units for position
    % set(gca,"Position",[1.2 0.8 fig_width-1.5 fig_height-1.5])              % axes position (x, y, w, h)
    hold off
    % axis tight

    % if(export)
    %     figName = "tracking_generic_personal_dhondt2024_3seg_gait1422_kit_" + kinColHeaders(i) + "_moment" + figFileType;
    %     exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    % end
end

lg = legend(["","tracking","", "generic", "", "personal", "", "Dhondt2024 3seg"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.NumColumns = 2;

if(export)
    figName = "tracking_generic_personal_dhondt2024_3seg_gait2128_sagg_kit" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Create PPT Animation
% fixSignMatrix = repmat(fixSign',Ndata, 1);
% create_ppt_animation(resampTime, sagittalPlaneCols(1:3), fixSignMatrix.*TrackKitDataAvg, zeros(Ndata,Nkincol), fixSignMatrix.*GenericKitDataAvg, zeros(Ndata,Nkincol), fixSignMatrix.*PersonalKitDataAvg, zeros(Ndata,Nkincol), fixSignMatrix.*Dhondt2024_3segKitDataAvg, zeros(Ndata,Nkincol), colors, kitLabels, kinColHeaders + "_moment", "tracking_generic_personal_dhondt2024_3seg_gait1422_kit_", true)

%% Plot Muscle Activations
% NemgcolLim = length(EMGColHeadersLim);

% labels
% muscleNamesPlot = ["Vasti", "Gastrocnemius", "Soleus"];
muscleNamesPlot = ["Hamstrings", "Biceps Femoris", "Rectus Femoris"];

% tile layout
tileCnt = 1;
tileNmb = [1:2:6, 2:2:6];

t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.10 0.14 0.88 0.6];
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height/1.5])                          % IEEE 1-column: 8.89cm

% for i = [10:12,4:6]
% for i = [7:9,1:3]
% for i = 4:6
for i = 1:3
    nexttile
    % set(gcf,"Units","centimeters")                                          % cm units for position
    % set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    % grid on
    hold on
    % plot experimental data
    legendTxt = plot_emg_active(resampTime, normalWalkingEMGavgLim(:,i), 0.05, "black", 0.95, 1);
    % plot_mean_std(resampTime,normalWalkingEMGavgLim(:,i),normalWalkingEMGstdLim(:,i),colors(4,:),1,"-")
    plot_mean_std(resampTime,TrackEmgDataAvg(:,i),TrackEmgDataSTD(:,i),colors(1,:), linewidth,":")
    plot_mean_std(resampTime,GenericEmgDataAvg(:,i),GenericEmgDataSTD(:,i),colors(2,:), linewidth,"-")
    plot_mean_std(resampTime,PersonalEmgDataAvg(:,i),PersonalEmgDataSTD(:,i),colors(3,:), linewidth,"-")
    % plot_mean_std(resampTime,Dhondt2024_3segEmgDataAvg(:,i),Dhondt2024_3segEmgDataSTD(:,i),"magenta", linewidth)
    % legend([legendTxt,"","Tracking","", "Generic", "", "Personal", "", "Dhondt2024_3seg"],"Location","best")
    xlabel("Gait Cycle [-]","FontWeight","bold")
    title(muscleNamesPlot(tileCnt))

    if(mod(tileCnt,3)-1 == 0)
        ylabel(emgLabelsLim(i),"FontWeight","bold")
    end
    ylim([0 1])

    % figure settings
    % set(findall(t,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    % set(gca,"Units","centimeters")                                          % cm units for position
    % set(gca,"Position",[1.2 0.8 fig_width-1.5 fig_height-1.5])              % axes position (x, y, w, h)
    hold off
    tileCnt = tileCnt + 1;

    % if(export)
    %     figName = "tracking_generic_personal_gait1422_emg_" + EMGColHeadersLim(i) + figFileType;
    %     exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    % end
end

lg = legend(["Experimental","","","tracking","", "generic", "", "personal"],"Location","northoutside","Orientation","horizontal");
lg.Layout.Tile = 'north';
lg.Box = 'off';
lg.NumColumns = 2;

set(findall(t,'-property','FontSize'),'FontSize',8)                   % font size

if(export)
    figName = "tracking_generic_personal_dhondt2024_3seg_gait2128_emg" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Muscle Activations (seperate)
NemgcolLim = length(EMGColHeadersLim);
for j = 1:NSUBJ
    t = tiledlayout(figure(j), 4, 3);  
    % set(gcf,"Units","centimeters")                                          % cm units for position
    % set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    % plot experimental data
    for i = 1:NemgcolLim
        nexttile
        grid on
        hold on
        legendTxt = plot_emg_active(resampTime, normalWalkingEMGexpLim(:,i,j), emg_threshold, colors(4,:), 0.95, 1);
        % plot(resampTime, normalWalkingEMGexpLim(:,i,j),"Color",colors(4,:),"LineWidth",1)
        plot(resampTime, TrackEmgDataLim(:,i,j),"Color",colors(1,:),"LineWidth",1)
        plot(resampTime, GenericEmgDataLim(:,i,j),"Color",colors(2,:),"LineWidth",1)
        plot(resampTime, PersonalEmgDataLim(:,i,j),"Color",colors(3,:),"LineWidth",1)
        xlabel("Gait Cycle [-]")
        ylim([0 1])
        title(strrep(EMGColHeadersLim(i),"_"," "))
        ylabel("Muscle Activation [-]")
    end
    legend([legendTxt, "Tracking", "Generic", "Personal"],"Location","best")
    title(t,"SUBJECT " + num2str(SUBJID(j)))

    % figure settings
    set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
    % set(gca,"Units","centimeters")                                          % cm units for position
    % set(gca,"Position",[1.2 0.8 fig_width-1.5 fig_height-1.5])              % axes position (x, y, w, h)
end

%% Create PPT Animation
% create_ppt_animation(resampTime, 1:NemgcolLim/2, normalWalkingEMGavgLim, zeros(Ndata,NemgcolLim), TrackEmgDataAvg, zeros(Ndata,NemgcolLim), GenericEmgDataAvg, zeros(Ndata,NemgcolLim), PersonalEmgDataAvg, zeros(Ndata,NemgcolLim), [colors(4,:); colors(1:3,:)], emgLabelsLim, EMGColHeadersLim, "tracking_generic_personal_dhondt2024_3seg_gait1422_emg_", true)

%% Functions

%% Metric Functions
function [R_list, rmse_list, exp_match_list] = compute_metrics(data1, data2, std_data)
% assumes data1 & data2 represent same part of gait cycle & are synchronized
    Ncolumns = size(data1, 2);
    R_list = zeros(Ncolumns, 1);
    rmse_list = zeros(Ncolumns, 1);
    exp_match_list = zeros(Ncolumns,1);
    for i = 1:Ncolumns
        R_list(i) = compute_pearson_corr_coeff(data1(:,i), data2(:,i));
        rmse_list(i) = compute_rmse(data1(:,i), data2(:,i));
        if(~isnan(std_data))
            exp_match_list(i) = compute_exp_match(data1(:,i), std_data(:,i), data2(:,i));
        end
    end
end

function rmse_res = compute_rmse(data1, data2)
% data 1 & data 2 should represent same part of gait cycle
    rmse_res = rmse(data1, data2);
end

% Compute experimental match
function exp_match = compute_exp_match(exp_mean, exp_std, pred_mean)
% Computes percentage of gait cylce for which pred_mean lies within 
% exp_mean +- exp_std

    if(all(isnan(exp_std)))
        exp_match = NaN;
    else
        
        Ndata = size(pred_mean,1);
    
        low_bound = exp_mean - exp_std;
        upp_bound = exp_mean + exp_std;
    
        withinBounds = (pred_mean >= low_bound) & (pred_mean <= upp_bound);
        exp_match = sum(withinBounds)/Ndata*100;
    end
end

% Compute Pearson Correlation Coefficient
function r = compute_pearson_corr_coeff(data1, data2)
% data 1 & data 2 should represent same part of gait cycle

    % TO ADD: add some synchronization step
    
    n = length(data1);                                  % length of data array

    sumx = sum(data1);                                  % sum of data elements list 1
    sumx2 = sum(data1.^2);                              % data elements squared list 1
    sumy = sum(data2);                                  % sum of data elements list 2
    sumy2 = sum(data2.^2);                              % data elements squared list 2
    sumxy = sum(data1.*data2);                          % dot product list 1 & list 2

    num = n*sumxy - sumx*sumy;                          % numerator
    den2 = (n*sumx2 - (sumx)^2)*(n*sumy2 - (sumy)^2);   % denumerator squared

    r = num/sqrt(den2);                                 % Pearson correlation coefficient 

end

function [recall, IDmatrix] = compute_recall(PredKinData, TrackKinData, metric)
    recall = 0;
    NSUBJ = size(PredKinData,3);
    Ncol = size(PredKinData,2);
    IDmatrix = NaN(NSUBJ,Ncol);
    
    for trackSUBJid = 1:NSUBJ
        for kinID = 1:Ncol
            Rmax = -1;
            RMSEmin = 100;
            IDmax = 0;
            for realSUBJid = 1:NSUBJ
                r = compute_pearson_corr_coeff(PredKinData(:,kinID,realSUBJid), TrackKinData(:,kinID,trackSUBJid));
                rmse = compute_rmse(PredKinData(:,kinID,realSUBJid), TrackKinData(:,kinID,trackSUBJid));
                if(r>Rmax && metric == "R")
                    Rmax = r;
                    IDmax = realSUBJid;
                    IDmatrix(trackSUBJid,kinID) = realSUBJid;
                end
                if(rmse < RMSEmin && metric == "RMSE")
                    RMSEmin = rmse;
                    IDmax = realSUBJid;
                    IDmatrix(trackSUBJid,kinID) = realSUBJid;
                end
            end
            if(trackSUBJid == IDmax)
                recall = recall+1;
            end
        end
    end
    
    recall = recall/(NSUBJ*Ncol)*100;
end

function print_matrix_latex(matrix, colheaders, rownames, dataMask)
% print matrix in Latex format
    Nrow = size(matrix,1);
    Ncol = size(matrix,2);

    % print data
    for i = 1:Nrow+1
        for j = 1:Ncol+1
            if(j < Ncol+1)
                token = '& ';
            elseif(i == 1 && j == Ncol + 1)
                token = '\\\\ \\hline';
            else
                token = '\\\\';
            end

            if(i == 1 && j == 1)
                fprintf(token)
            elseif(i == 1 && j > 1)
                fprintf('\\textbf{' + string(colheaders(j-1)) + '} ' + token)
            elseif(i > 1 && j == 1)
                fprintf('\\textbf{' + string(rownames(i-1)) + '} ' + token)
            elseif(matrix(i-1,j-1) == i || dataMask(i-1,j-1) == 1)
                fprintf(['\\textbf{%.2f} ' token], matrix(i-1,j-1))
            else
                fprintf(['%.2f ' token], matrix(i-1,j-1))
            end
        end
        fprintf('\n')
    end

end

function [avg_percent_R_kin, avg_percent_R_grf] = compute_R_average_improvement(avg_R_list_kin_personal, avg_R_list_kin_generic, avg_R_list_grf_personal, avg_R_list_grf_generic, avg_R_list_emg_personal, avg_R_list_emg_generic, identifier)
    % compute average R sagittal plane improvements
    % postive means R increased
    rel_dR_kin = (avg_R_list_kin_personal - avg_R_list_kin_generic);
    rel_dR_grf = (avg_R_list_grf_personal - avg_R_list_grf_generic);
    rel_dR_emg = (avg_R_list_emg_personal - avg_R_list_emg_generic);
    
    % deltaR = Rpersonal - Rgeneric
    max_dR_kin = 1-avg_R_list_kin_generic;
    max_dR_grf = 1-avg_R_list_grf_generic;
    max_dR_emg = 1-avg_R_list_emg_generic;
    
    % maximum possible change = 1 - Rgeneric
    percent_R_kin = rel_dR_kin./max_dR_kin*100;
    percent_R_grf = rel_dR_grf./max_dR_grf*100;
    percent_R_emg = rel_dR_emg./max_dR_emg*100;
    
    % maximum possible change = deltaR/maxDR 
    avg_percent_R_kin = mean(percent_R_kin);
    avg_percent_R_grf = mean(percent_R_grf);
    avg_percent_R_emg = mean(percent_R_emg);
    
    % print results
    fprintf(['\n** Printing R Metrics for ' identifier ' **\n'])
    fprintf('The pearson correlation coefficient R reached on average %.2f%% of the maximal improvement for the kinematics\n', avg_percent_R_kin)
    fprintf('The pearson correlation coefficient R reached on average %.2f%% of the maximal improvement for the ground reaction forces\n', avg_percent_R_grf)
    fprintf('The pearson correlation coefficient R reached on average %.2f%% of the maximal improvement for the EMG\n', avg_percent_R_emg)
end

function [avg_percent_rmse_kin, avg_percent_rmse_grf] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal, avg_rmse_list_kin_generic, avg_rmse_list_grf_personal, avg_rmse_list_grf_generic, identifier)

    percent_rmse_kin = (avg_rmse_list_kin_personal - avg_rmse_list_kin_generic)./avg_rmse_list_kin_generic*100;
    percent_rmse_grf = (avg_rmse_list_grf_personal - avg_rmse_list_grf_generic)./avg_rmse_list_grf_generic*100;
    
    avg_percent_rmse_kin = mean(percent_rmse_kin);
    avg_percent_rmse_grf = mean(percent_rmse_grf);
    
    % print results
    fprintf(['\n** Printing RMSE Metrics for ' identifier ' **\n'])
    if(avg_percent_rmse_kin > 0)
        fprintf('The RMSE INCREASED on average by %.2f%% for the kinematics\n', avg_percent_rmse_kin)
    else
        fprintf('The RMSE DECREASED on average by %.2f%% for the kinematics\n', -avg_percent_rmse_kin)
    end

    if(avg_percent_rmse_grf > 0)
        fprintf('The RMSE INCREASED on average by %.2f%% for the ground reaction forces\n', avg_percent_rmse_grf)
    else
        fprintf('The RMSE DECREASED on average by %.2f%% for the ground reaction forces\n', -avg_percent_rmse_grf)
    end
end