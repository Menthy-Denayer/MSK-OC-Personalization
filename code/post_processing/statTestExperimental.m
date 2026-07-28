% --------------------------------------------------------------------------
% statTestExperimental
%   Perform the statistical tests for the experimental data and plot the
%   averaged kinematics.
%
%   Use the data structure from:
%
%   Denayer, M. (Creator), Turcksin, T. (Researcher), De Pauw, K. 
%   (Supervisor), Verstraten, T. (Supervisor) (2026). 
%   A Full-body Motion Capture Dataset for Bilateral Weighted Shank Walking. 
%   figshare Academic Research System. 10.6084/m9.figshare.30316372
%
%   Requires the Statistical Parameter Mapping Toolbox: spm1dmatlab-master
%
% Original author: Menthy Denayer
% Original date: 08/July/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 08/July/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Load Libraries
addpath(pwd + "\helperFunctions")

% SPM1D
addpath(genpath("spm1dmatlab-master"))

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
linewidth = 1.5;
export = false;
figFileType = ".jpg";
colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

%% Define Variables
resampTime = 0:0.01:1;
Ndata = length(resampTime);
SUBJID = [1,2, 4:14];
NSUBJ = length(SUBJID);
Ntrials = 10;
Nweights = 5; 

statsSummaryKin.version = datetime("now","Format","d-MM-y");
statsSummaryEMG.version = datetime("now","Format","d-MM-y");
statsSummaryVel.version = datetime("now","Format","d-MM-y");

%% Load Experimental Data (Rajagopal Model)
[expDataFileRajagopal, expDataDIRRajagopal] = uigetfile(".mat","Choose Rajagopal experimental data file");
expDataRajagopal = load(fullfile(expDataDIRRajagopal, expDataFileRajagopal));

%% Extract Sagittal Plane Data
kinColHeaders = expDataRajagopal.data.headers.kinematics;
Nkincol = length(kinColHeaders);

isSagittalPlaneKinematics = (contains(kinColHeaders,"knee_angle")  & ~contains(kinColHeaders,"beta")) | contains(kinColHeaders,"hip_flexion") | contains(kinColHeaders,"ankle_angle");
sagittalPlaneCols = 1:Nkincol; sagittalPlaneCols = sagittalPlaneCols(isSagittalPlaneKinematics);

%% Store data
% Rajagopal
[normalWalkingKinExpAvgLim, normalWalkingKinExpStdLim, weightedWalkingKinExpAvgLim, weightedWalkingKinExpStdLim] = extract_experimental_data(expDataRajagopal, "kinematics", "Ikdata", SUBJID, Ndata, Nweights, true, 3);
[normalWalkingVelExpAvgLim, normalWalkingVelExpStdLim, weightedWalkingVelExpAvgLim, weightedWalkingVelExpStdLim] = extract_experimental_data(expDataRajagopal, "speed", "speed", SUBJID, 1, Nweights, false, 1);
[normalWalkingEmgExpAvgLim, normalWalkingEmgExpStdLim, weightedWalkingEmgExpAvgLim, weightedWalkingEmgExpStdLim] = extract_experimental_data(expDataRajagopal, "EMG", "EMGdata", SUBJID, Ndata, Nweights, true, 3);

%% Compute Experimental AVG & STD Across Subjects
normalWalkingExpKinAvg = mean(normalWalkingKinExpAvgLim,3,"omitnan");
normalWalkingExpKinStd = std(normalWalkingKinExpAvgLim,0,3,"omitnan");
normalWalkingExpEmgAvg = mean(normalWalkingEmgExpAvgLim,3,"omitnan");
normalWalkingExpEmgStd = std(normalWalkingEmgExpAvgLim,0,3,"omitnan");

weightedWalkingExpKinAvg = mean(weightedWalkingKinExpAvgLim,3,"omitnan");
weightedWalkingExpKinStd = std(weightedWalkingKinExpAvgLim,0,3,"omitnan");
weightedWalkingExpEmgAvg = mean(weightedWalkingEmgExpAvgLim,3,"omitnan");
weightedWalkingExpEmgStd = std(weightedWalkingEmgExpAvgLim,0,3,"omitnan");

%% Perform Tests for Sagittal Plane Peaks
% ankle angle
isJointAngleRajagopal = contains(expDataRajagopal.data.headers.kinematics,"ankle_angle");
[hListAnklePlantar, pListAnklePlantar, ~, ~, dzListAnklePlantar, deltaListAvgAnklePlantar, deltaListStdAnklePlantar] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, -1, SUBJID, Ntrials, 50:80, "Ikdata", "kinematics", true);
[hListAnkleDorsi, pListAnkleDorsi, ~, ~, dzListAnkleDorsi, deltaListAvgAnkleDorsi, deltaListStdAnkleDorsi] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, 1, SUBJID, Ntrials, [], "Ikdata", "kinematics", true);

includeAnklePlantar = hListAnklePlantar & dzListAnklePlantar>1;
includeAnkleDorsi = hListAnkleDorsi & dzListAnkleDorsi>1;

% knee angle
isJointAngleRajagopal = contains(expDataRajagopal.data.headers.kinematics,"knee_angle") & ~contains(expDataRajagopal.data.headers.kinematics,"beta");
[hListKneeFlex, pListKneeFlex, ~, ~, dzListKneeFlex, deltaListAvgKneeFlex, deltaListStdKneeFlex] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, 1, SUBJID, Ntrials, [], "Ikdata", "kinematics", true);

includeKneeFlex = hListKneeFlex & dzListKneeFlex>1;

% hip angle
isJointAngleRajagopal = contains(expDataRajagopal.data.headers.kinematics,"hip_flexion");
[hListHipFlex, pListHipFlex, ~, ~, dzListHipFlex, deltaListAvgHipFlex, deltaListStdHipFlex] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, 1, SUBJID, Ntrials, [], "Ikdata", "kinematics", true);
[hListHipExt, pListHipExt, ~, ~, dzListHipExt, deltaListAvgHipExt, deltaListStdHipExt] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, -1, SUBJID, Ntrials, [], "Ikdata", "kinematics", true);

includeHipFlex = hListHipFlex & dzListHipFlex>1;
includeHipExt = hListHipExt & dzListHipExt>1;

%% Perform Tests for Frontal Plane Peaks
% hip adduction
isJointAngleRajagopal = contains(expDataRajagopal.data.headers.kinematics,"hip_adduction");
[hListHipAdd, pListHipAdd, ~, ~, dzListHipAdd, deltaListAvgHipAdd, deltaListStdHipAdd] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, 1, SUBJID, Ntrials, 1:60, "Ikdata", "kinematics", true);

% pelvis list
isJointAngleRajagopal = contains(expDataRajagopal.data.headers.kinematics,"pelvis_tilt");
[hListPelvisListPos, pListPelvisListPos, ~, ~, dzListPelvisListPos, deltaListAvgPelvisListPos, deltaListStdPelvisListPos] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, 1, SUBJID, Ntrials, 1:50, "Ikdata", "kinematics", true);
[hListPelvisListNeg, pListPelvisListNeg, ~, ~, dzListPelvisListNeg, deltaListAvgPelvisListNeg, deltaListStdPelvisListNeg] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, -1, SUBJID, Ntrials, 50:Ndata, "Ikdata", "kinematics", true);

% lumbar bending
isJointAngleRajagopal = contains(expDataRajagopal.data.headers.kinematics,"lumbar_bending");
[hListLumbarBendPos, pListLumbarBendPos, ~, ~, dzListLumbarBendPos, deltaListAvgLumbarBendPos, deltaListStdLumbarBendPos] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, 1, SUBJID, Ntrials, 1:50, "Ikdata", "kinematics", true);
[hListLumbarBendNeg, pListLumbarBendNeg, ~, ~, dzListLumbarBendNeg, deltaListAvgLumbarBendNeg, deltaListStdLumbarBendNeg] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, -1, SUBJID, Ntrials, 50:Ndata, "Ikdata", "kinematics", true);

% arm flexion
isJointAngleRajagopal = contains(expDataRajagopal.data.headers.kinematics,"arm_flex");
[hListArmFlex, pListArmFlex, ~, ~, dzListArmFlex, deltaListAvgArmFlex, deltaListStdArmFlex] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, 1, SUBJID, Ntrials, [], "Ikdata", "kinematics", true);
[hListArmExt, pListArmExt, ~, ~, dzListArmExt, deltaListAvgArmExt, deltaListStdArmExt] = perform_ttest_kin(expDataRajagopal, isJointAngleRajagopal, -1, SUBJID, Ntrials, [], "Ikdata", "kinematics", true);

%% Save TTest Results for Kinematics
% sagittal plane 
statsSummaryKin = save_stats(statsSummaryKin, "ankle_peak_plantar", pListAnklePlantar, dzListAnklePlantar, deltaListAvgAnklePlantar, deltaListStdAnklePlantar);
statsSummaryKin = save_stats(statsSummaryKin, "ankle_peak_dorsi", pListAnkleDorsi, dzListAnkleDorsi, deltaListAvgAnkleDorsi, deltaListStdAnkleDorsi);
statsSummaryKin = save_stats(statsSummaryKin, "knee_peak_flexion", pListKneeFlex, dzListKneeFlex, deltaListAvgKneeFlex, deltaListStdKneeFlex);
statsSummaryKin = save_stats(statsSummaryKin, "hip_peak_flexion", pListHipFlex, dzListHipFlex, deltaListAvgHipFlex, deltaListStdHipFlex);
statsSummaryKin = save_stats(statsSummaryKin, "hip_peak_extension", pListHipExt, dzListHipExt, deltaListAvgHipExt, deltaListStdHipExt);

% frontal plane & arms
statsSummaryKin = save_stats(statsSummaryKin, "hip_angle_adduction", pListHipAdd, dzListHipAdd, deltaListAvgHipAdd, deltaListStdHipAdd);
statsSummaryKin = save_stats(statsSummaryKin, "pelvis_peak_list_pos", pListPelvisListPos, dzListPelvisListPos, deltaListAvgPelvisListPos, deltaListStdPelvisListPos);
statsSummaryKin = save_stats(statsSummaryKin, "pelvis_peak_list_neg", pListPelvisListNeg, dzListPelvisListNeg, deltaListAvgPelvisListNeg, deltaListStdPelvisListNeg);
statsSummaryKin = save_stats(statsSummaryKin, "lumbar_peak_bending_pos", pListLumbarBendPos, dzListLumbarBendPos, deltaListAvgLumbarBendPos, deltaListStdLumbarBendPos);
statsSummaryKin = save_stats(statsSummaryKin, "lumbar_peak_bending_neg", pListLumbarBendNeg, dzListLumbarBendNeg, deltaListAvgLumbarBendNeg, deltaListStdLumbarBendNeg);
statsSummaryKin = save_stats(statsSummaryKin, "arm_peak_flexion_pos", pListArmFlex, dzListArmFlex, deltaListAvgArmFlex, deltaListStdArmFlex);
statsSummaryKin = save_stats(statsSummaryKin, "arm_peak_extension_neg", pListArmExt, dzListArmExt, deltaListAvgArmExt, deltaListStdArmExt);

%% Perform TTest EMG
isBF = contains(expDataRajagopal.data.headers.EMG,"Biceps_Femoris");
[hListBF, pListBF, ~, ~, dzListBF, deltaListAvgBF, deltaListStdBF] = perform_ttest_kin(expDataRajagopal, isBF, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

isSEMI = contains(expDataRajagopal.data.headers.EMG,"Semitendinosus");
[hListSEMI, pListSEMI, ~, ~, dzListSEMI, deltaListAvgSEMI, deltaListStdSEMI] = perform_ttest_kin(expDataRajagopal, isSEMI, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

isRF = contains(expDataRajagopal.data.headers.EMG,"Rectus_Femoris");
[hListRF, pListRF, ~, ~, dzListRF, deltaListAvgRF, deltaListStdRF] = perform_ttest_kin(expDataRajagopal, isRF, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

isVASLAT = contains(expDataRajagopal.data.headers.EMG,"Vastus_Lateralis");
[hListVASLAT, pListVASLAT, ~, ~, dzListVASLAT, deltaListAvgVASLAT, deltaListStdVASLAT] = perform_ttest_kin(expDataRajagopal, isVASLAT, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

isVASMED = contains(expDataRajagopal.data.headers.EMG,"Vastus_Medialis");
[hListVASMED, pListVASMED, ~, ~, dzListVASMED, deltaListAvgVASMED, deltaListStdVASMED] = perform_ttest_kin(expDataRajagopal, isVASMED, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

isGASMED = contains(expDataRajagopal.data.headers.EMG,"Gastrocnemius_Medialis");
[hListGASMED, pListGASMED, ~, ~, dzListGASMED, deltaListAvgGASMED, deltaListStdGASMED] = perform_ttest_kin(expDataRajagopal, isGASMED, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

isGASLAT = contains(expDataRajagopal.data.headers.EMG,"Gastrocnemius_Lateralis");
[hListGASLAT, pListGASLAT, ~, ~, dzListGASLAT, deltaListAvgGASLAT, deltaListStdGASLAT] = perform_ttest_kin(expDataRajagopal, isGASLAT, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

isSOL = contains(expDataRajagopal.data.headers.EMG,"Soleus");
[hListSOL, pListSOL, ~, ~, dzListSOL, deltaListAvgSOL, deltaListStdSOL] = perform_ttest_kin(expDataRajagopal, isSOL, 1, SUBJID, Ntrials, [], "EMGdata", "EMG", false);

%% Save TTest Results for EMG
statsSummaryEMG = save_stats(statsSummaryEMG, "Biceps Femoris Peak", pListBF, dzListBF, deltaListAvgBF, deltaListStdBF);
statsSummaryEMG = save_stats(statsSummaryEMG, "Semitendinosus Peak", pListSEMI, dzListSEMI, deltaListAvgSEMI, deltaListStdSEMI);
statsSummaryEMG = save_stats(statsSummaryEMG, "Rectus Femoris Peak", pListRF, dzListRF, deltaListAvgRF, deltaListStdRF);
statsSummaryEMG = save_stats(statsSummaryEMG, "Vastus Medialis Peak", pListVASMED, dzListVASMED, deltaListAvgVASMED, deltaListStdVASMED);
statsSummaryEMG = save_stats(statsSummaryEMG, "Vastus Lateralis Peak", pListVASLAT, dzListVASLAT, deltaListAvgVASLAT, deltaListStdVASLAT);
statsSummaryEMG = save_stats(statsSummaryEMG, "Gastrocnemius Medialis Peak", pListGASMED, dzListGASMED, deltaListAvgGASMED, deltaListStdGASMED);
statsSummaryEMG = save_stats(statsSummaryEMG, "Gastrocnemius Lateralis Peak", pListGASLAT, dzListGASLAT, deltaListAvgGASLAT, deltaListStdGASLAT);
statsSummaryEMG = save_stats(statsSummaryEMG, "Soleus Peak", pListSOL, dzListSOL, deltaListAvgSOL, deltaListStdSOL);

%% Perform TTest Speeds
[hVel1kg, pVel1kg, ~, ~, dzVel1kg, deltaVel1kgAvg, deltaVel1kgStd] = perform_ttest(squeeze(normalWalkingVelExpAvgLim), squeeze(weightedWalkingVelExpAvgLim(:,:,:,1)), NSUBJ);
[hVel2kg, pVel2kg, ~, ~, dzVel2kg, deltaVel2kgAvg, deltaVel2kgStd] = perform_ttest(squeeze(normalWalkingVelExpAvgLim), squeeze(weightedWalkingVelExpAvgLim(:,:,:,2)), NSUBJ);
[hVel3kg, pVel3kg, ~, ~, dzVel3kg, deltaVel3kgAvg, deltaVel3kgStd] = perform_ttest(squeeze(normalWalkingVelExpAvgLim), squeeze(weightedWalkingVelExpAvgLim(:,:,:,3)), NSUBJ);
[hVel4kg, pVel4kg, ~, ~, dzVel4kg, deltaVel4kgAvg, deltaVel4kgStd] = perform_ttest(squeeze(normalWalkingVelExpAvgLim), squeeze(weightedWalkingVelExpAvgLim(:,:,:,4)), NSUBJ);
[hVel5kg, pVel5kg, ~, ~, dzVel5kg, deltaVel5kgAvg, deltaVel5kgStd] = perform_ttest(squeeze(normalWalkingVelExpAvgLim), squeeze(weightedWalkingVelExpAvgLim(:,:,:,5)), NSUBJ);
statsSummaryVel = save_stats(statsSummaryVel, "Avg Forward Velocity", [pVel1kg pVel2kg pVel3kg pVel4kg pVel5kg], ...
    [dzVel1kg dzVel2kg dzVel3kg dzVel4kg dzVel5kg], ...
    [deltaVel1kgAvg deltaVel2kgAvg deltaVel3kgAvg deltaVel4kgAvg deltaVel5kgAvg], ...
    [deltaVel1kgStd deltaVel2kgStd deltaVel3kgStd deltaVel4kgStd deltaVel5kgStd]);

%% Test Assymetry
isRight = contains(kinColHeaders,"_r");
isLeft = contains(kinColHeaders,"_l");

for i = 1:NSUBJ
    % maxErr = test_assymetry(resampTime, expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataNormal(:,isSagittalPlaneKinematics & isRight,:), expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataNormal(:,isSagittalPlaneKinematics & isLeft,:));
    % maxErr = test_assymetry(resampTime, expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted1kg(:,isSagittalPlaneKinematics & isRight,:), expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted1kg(:,isSagittalPlaneKinematics & isLeft,:));
    % maxErr = test_assymetry(resampTime, expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted2kg(:,isSagittalPlaneKinematics & isRight,:), expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted2kg(:,isSagittalPlaneKinematics & isLeft,:));
    % maxErr = test_assymetry(resampTime, expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted3kg(:,isSagittalPlaneKinematics & isRight,:), expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted3kg(:,isSagittalPlaneKinematics & isLeft,:));
    % maxErr = test_assymetry(resampTime, expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted4kg(:,isSagittalPlaneKinematics & isRight,:), expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted4kg(:,isSagittalPlaneKinematics & isLeft,:));
    maxErr = test_assymetry(resampTime, expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted5kg(:,isSagittalPlaneKinematics & isRight,:), expDataRajagopal.data.("SUBJ" + SUBJID(i)).kinematics.IkdataWeighted5kg(:,isSagittalPlaneKinematics & isLeft,:));

    fprintf('Max errors for SUBJ %.0f are: hip: %.2f knee: %.2f ankle: %.2f\n', SUBJID(i), maxErr(1), maxErr(2), maxErr(3))

end

%% Print Statistics Results
% print_struct_latex(statsSummaryKin, "version", "p", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 0.05, -1, '%.4f')
% print_struct_latex(statsSummaryKin, "version", "dz", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 1, 1, '%.4f')
% print_struct_latex(statsSummaryEMG, "version", "p", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 0.05, -1, '%.4f')
% print_struct_latex(statsSummaryEMG, "version", "dz", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 1, 1, '%.4f')
print_struct_latex(statsSummaryVel, "version", "p", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"],0.05,-1, '%.4f')
print_struct_latex(statsSummaryVel, "version", "dz", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"],1,1, '%.4f')


% print_struct_latex(statsSummaryKin, "version", "delta", "std", ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 100, 1, [])
% print_struct_latex(statsSummaryEMG, "version", "delta", "std", ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 100, 1, [])
print_struct_latex(statsSummaryVel, "version", "delta", "std", ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 100, 1, [])

%% Split Labels
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
kinLabels = repmat("[°]",Nkincol,1); kinLabels(isTrans) = "[m]";
jointNames = extractBefore(kinColHeaders,"_"); jointNames = strcat(upper(extractBefore(jointNames,2)), extractAfter(jointNames,1));

%% Add Labels Directions
kinLabelsExt = strings(Nkincol,2); kinLabelsExt(:,1) = kinLabels;

% ankle
isAnkle = contains(kinColHeaders,"ankle_angle");
kinLabelsExt(isAnkle,:) = [kinLabelsExt(isAnkle,1), repmat("plantar flexion (-) / dorsiflexion (+)",2,1)]; 

% knee
isKnee = contains(kinColHeaders,"knee_angle") & ~contains(kinColHeaders,"beta");
kinLabelsExt(isKnee,:) = [kinLabelsExt(isKnee,1), repmat("flexion (-) / extension (+)",2,1)]; 
normalWalkingExpKinAvg(:,isKnee) = normalWalkingExpKinAvg(:,isKnee) *-1;
weightedWalkingExpKinAvg(:,isKnee,:,:) = weightedWalkingExpKinAvg(:,isKnee,:,:) * -1;

% hip
isHip = contains(kinColHeaders,"hip_flexion");
kinLabelsExt(isHip,:) = [kinLabelsExt(isHip,1), repmat("extension (-) / flexion (+)",2,1)]; 

%% Plot Kinematics Results Experiments
% define legend (w/o STD)
legendtxt = strings(Nweights+1,1);
legendtxt(1) = "normal";
legendtxt(2:end) = string(1:Nweights) + " kg";

% define color
color = makeGroupColors(0.5,Nweights+1,0,0,0.7)';

% define bounds
% joint-specific bounds
bounds = NaN(Nkincol,2);
boundsSagg = [[-15 35]; % hip
    [-70 -10];       % knee      
    [-20 25]];      % ankle
bounds(sagittalPlaneCols,:) = repmat(boundsSagg,2,1);

% create tiled layour
t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.15 0.75 0.75];
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.5])                          % IEEE 1-column: 8.89cm

% find max anke plantar/dorsi
isAnkleR = contains(kinColHeaders,"ankle_angle_r");
maxAnkleDorsi = NaN(Nweights+1,1); maxAnkleDorsiIdx = NaN(Nweights+1);
maxAnklePlantar = NaN(Nweights+1,1); maxAnklePlantarIdx = NaN(Nweights+1);
[maxAnkleDorsi(1),maxAnkleDorsiIdx(1)] = max(normalWalkingExpKinAvg(:,isAnkleR));
[maxAnklePlantar(1),maxAnklePlantarIdx(1)] = max(normalWalkingExpKinAvg(:,isAnkleR)*-1);

% find max knee flexion
isKneeR = contains(kinColHeaders,"knee_angle_r") & ~contains(kinColHeaders,"beta");
maxKneeFlex = NaN(Nweights+1,1); maxKneeFlexIdx = NaN(Nweights+1);
[maxKneeFlex(1),maxKneeFlexIdx(1)] = max(normalWalkingExpKinAvg(:,isKneeR)*-1);

% find max hip flexion
isHipR = contains(kinColHeaders,"hip_flexion_r");
maxHipFlex = NaN(Nweights+1,1); maxHipFlexIdx = NaN(Nweights+1);
maxHipExt = NaN(Nweights+1,1); maxHipExtIdx = NaN(Nweights+1);
[maxHipFlex(1),maxHipFlexIdx(1)] = max(normalWalkingExpKinAvg(:,isHipR));
[maxHipExt(1),maxHipExtIdx(1)] = max(normalWalkingExpKinAvg(:,isHipR)*-1);

for i = 1:Nweights
    [maxKneeFlex(i+1),maxKneeFlexIdx(i+1)] = max(weightedWalkingExpKinAvg(:,isKneeR,:,i)*-1);
    [maxHipFlex(i+1),maxHipFlexIdx(i+1)] = max(weightedWalkingExpKinAvg(:,isHipR,:,i));
    [maxHipExt(i+1),maxHipExtIdx(i+1)] = max(weightedWalkingExpKinAvg(:,isHipR,:,i)*-1);
    [maxAnkleDorsi(i+1),maxAnkleDorsiIdx(i+1)] = max(weightedWalkingExpKinAvg(:,isAnkleR,:,i));
    [maxAnklePlantar(i+1),maxAnklePlantarIdx(i+1)] = max(weightedWalkingExpKinAvg(:,isAnkleR,:,i)*-1);
end

% create figure
for i = sagittalPlaneCols(1:3)
    tile = nexttile;
    hold on
    if(~isKnee(i))
        XaxisLine = plot([0 1],[0 0],"Color","black","LineWidth",0.5);
    end
    plot(resampTime,normalWalkingExpKinAvg(:,i),"Color",color(:,1)', "LineWidth", linewidth, "LineStyle", "-")
    for j = 1:Nweights
        plot(resampTime,weightedWalkingExpKinAvg(:,i,:,j),"Color",color(:,j+1)', "LineWidth", linewidth, "LineStyle", "-")
    end
    
    if(isHip(i))
        % draw arrows
        draw_weight_arrow(includeHipExt, Nweights, maxHipExt, deltaListAvgHipExt, -1, color, 0.4, 0.15, 4, 2, 0.02)
        draw_weight_arrow(includeHipFlex, Nweights, maxHipFlex, deltaListAvgHipFlex, 1, color, 0.85, 0.15, 5, 2, 0.02)
        
    elseif(isKnee(i))
        % draw arrows
        draw_weight_arrow(includeKneeFlex, Nweights, maxKneeFlex, deltaListAvgKneeFlex, -1, color, 0.1, 0.15, 4, 2, 0.02)

    elseif(isAnkle(i))
        % draw arrows
        draw_weight_arrow(includeAnkleDorsi, Nweights, maxAnkleDorsi, deltaListAvgAnkleDorsi, 1, color, 0.05, 0.15, 4, 2, 0.02)
        draw_weight_arrow(includeAnklePlantar, Nweights, maxAnklePlantar, deltaListAvgAnklePlantar, -1, color, 0.05, 0.15, 4, 2, 0.02)
    end
    
    xlim([0 1])
    ylim(bounds(i,:))
    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(kinLabelsExt(i,:),"FontWeight","bold")
    title(jointNames(i) + " Joint Angle")

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
end

lg = legend([""; legendtxt],"Location","bestoutside");
lg.Layout.Tile = 'East';
lg.Box = "off";

set(findall(t,'-property','FontSize'),'FontSize',8)                   % font size

if(export)
    figName = "experimental_kin_weightedWalking" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot EMG
for i = 1:size(normalWalkingExpEmgAvg,2)
    figure
    hold on
    plot_mean_std(resampTime,normalWalkingExpEmgAvg(:,i),normalWalkingExpEmgStd(:,i),"blue",1,"-")
    plot_mean_std(resampTime,weightedWalkingExpEmgAvg(:,i,:,1),weightedWalkingExpEmgStd(:,i,:,1),[0 0 0],1,"-")
    plot_mean_std(resampTime,weightedWalkingExpEmgAvg(:,i,:,2),weightedWalkingExpEmgStd(:,i,:,2),[0.25 0 0],1,"-")
    plot_mean_std(resampTime,weightedWalkingExpEmgAvg(:,i,:,3),weightedWalkingExpEmgStd(:,i,:,3),[0.50 0 0],1,"-")
    plot_mean_std(resampTime,weightedWalkingExpEmgAvg(:,i,:,4),weightedWalkingExpEmgStd(:,i,:,4),[0.75 0 0],1,"-")
    plot_mean_std(resampTime,weightedWalkingExpEmgAvg(:,i,:,5),weightedWalkingExpEmgStd(:,i,:,5),[1 0 0],1,"-")
    title(expDataRajagopal.data.headers.EMG(i))
    legend(["" "normal" "" "1kg" "" "2kg" "" "3kg" "" "4kg" "" "5kg"])
    hold off
end

%% Functions
function [hList, pList, ciList, statsList, dzList, deltaListAvg, deltaListStd] = perform_ttest_kin(expData, isJointAngle, sign, SUBJID, Ntrials, IdxRange, dataPrefix, dataDelim, filterBool)
    %% Define variables
    NSUBJ = length(SUBJID);
    Ndata = size(expData.data.SUBJ4.kinematics.IkdataNormal,1);
    Nsides = length(isJointAngle(isJointAngle>0));

    %% Store data
    normalWalkingJointExp = NaN(NSUBJ, Ndata, Nsides, Ntrials);
    WeightedWalking1kgJointExp = NaN(NSUBJ, Ndata, Nsides, Ntrials);
    WeightedWalking2kgJointExp = NaN(NSUBJ, Ndata, Nsides, Ntrials);
    WeightedWalking3kgJointExp = NaN(NSUBJ, Ndata, Nsides, Ntrials);
    WeightedWalking4kgJointExp = NaN(NSUBJ, Ndata, Nsides, Ntrials);
    WeightedWalking5kgJointExp = NaN(NSUBJ, Ndata, Nsides, Ntrials);
    
    for subjID = 1:NSUBJ
        normalWalkingJointExp(subjID,:,:,:) = load_data(expData, SUBJID(subjID), isJointAngle, "Normal", Nsides, Ntrials, dataPrefix, dataDelim, filterBool);
        WeightedWalking1kgJointExp(subjID,:,:,:) = load_data(expData, SUBJID(subjID), isJointAngle, "1kg", Nsides, Ntrials, dataPrefix, dataDelim, filterBool);
        WeightedWalking2kgJointExp(subjID,:,:,:) = load_data(expData, SUBJID(subjID), isJointAngle, "2kg", Nsides, Ntrials, dataPrefix, dataDelim, filterBool);
        WeightedWalking3kgJointExp(subjID,:,:,:) = load_data(expData, SUBJID(subjID), isJointAngle, "3kg", Nsides, Ntrials, dataPrefix, dataDelim, filterBool);
        WeightedWalking4kgJointExp(subjID,:,:,:) = load_data(expData, SUBJID(subjID), isJointAngle, "4kg", Nsides, Ntrials, dataPrefix, dataDelim, filterBool);
        WeightedWalking5kgJointExp(subjID,:,:,:) = load_data(expData, SUBJID(subjID), isJointAngle, "5kg", Nsides, Ntrials, dataPrefix, dataDelim, filterBool);
    end

    %% Create Plot
    % for i = 1:Nsides
    %     figure
    %     hold on
    %     for j = 1:NSUBJ
    %         for k = 1:Ntrials
    %             plot(normalWalkingJointExp(j,:,i,k),"Color","blue")
    %             plot(WeightedWalking1kgJointExp(j,:,i,k),"Color",[0 0 0])
    %             plot(WeightedWalking2kgJointExp(j,:,i,k),"Color",[0.25 0 0])
    %             plot(WeightedWalking3kgJointExp(j,:,i,k),"Color",[0.50 0 0])
    %             plot(WeightedWalking4kgJointExp(j,:,i,k),"Color",[0.75 0 0])
    %             plot(WeightedWalking5kgJointExp(j,:,i,k),"Color",[1.00 0 0])
    %         end
    %     end
    %     hold off
    % end

    %% Compute Max
    normalWalkingJointMaxExp = compute_peak_exp(normalWalkingJointExp, sign, IdxRange);
    WeightedWalking1kgJointMaxExp = compute_peak_exp(WeightedWalking1kgJointExp, sign, IdxRange);
    WeightedWalking2kgJointMaxExp = compute_peak_exp(WeightedWalking2kgJointExp, sign, IdxRange);
    WeightedWalking3kgJointMaxExp = compute_peak_exp(WeightedWalking3kgJointExp, sign, IdxRange);
    WeightedWalking4kgJointMaxExp = compute_peak_exp(WeightedWalking4kgJointExp, sign, IdxRange);
    WeightedWalking5kgJointMaxExp = compute_peak_exp(WeightedWalking5kgJointExp, sign, IdxRange);

    %% Compute Mean Over Trials Per Subject
    normalWalkingJointMaxExpPerSUBJ = mean(normalWalkingJointMaxExp,2,"omitnan");
    WeightedWalking1kgJointMaxExpPerSUBJ = mean(WeightedWalking1kgJointMaxExp,2,"omitnan");
    WeightedWalking2kgJointMaxExpPerSUBJ = mean(WeightedWalking2kgJointMaxExp,2,"omitnan");
    WeightedWalking3kgJointMaxExpPerSUBJ = mean(WeightedWalking3kgJointMaxExp,2,"omitnan");
    WeightedWalking4kgJointMaxExpPerSUBJ = mean(WeightedWalking4kgJointMaxExp,2,"omitnan");
    WeightedWalking5kgJointMaxExpPerSUBJ = mean(WeightedWalking5kgJointMaxExp,2,"omitnan");

    %% Perform TTest
    [h1, p1, CI1, stats1, dz1, delta1kgAvg, delta1kgStd] = perform_ttest(normalWalkingJointMaxExpPerSUBJ, WeightedWalking1kgJointMaxExpPerSUBJ, NSUBJ);
    [h2, p2, CI2, stats2, dz2, delta2kgAvg, delta2kgStd] = perform_ttest(normalWalkingJointMaxExpPerSUBJ, WeightedWalking2kgJointMaxExpPerSUBJ, NSUBJ);
    [h3, p3, CI3, stats3, dz3, delta3kgAvg, delta3kgStd] = perform_ttest(normalWalkingJointMaxExpPerSUBJ, WeightedWalking3kgJointMaxExpPerSUBJ, NSUBJ);
    [h4, p4, CI4, stats4, dz4, delta4kgAvg, delta4kgStd] = perform_ttest(normalWalkingJointMaxExpPerSUBJ, WeightedWalking4kgJointMaxExpPerSUBJ, NSUBJ);
    [h5, p5, CI5, stats5, dz5, delta5kgAvg, delta5kgStd] = perform_ttest(normalWalkingJointMaxExpPerSUBJ, WeightedWalking5kgJointMaxExpPerSUBJ, NSUBJ);

    %% Combine Delta
    % average
    deltaListAvg = [delta1kgAvg, delta2kgAvg, delta3kgAvg, delta4kgAvg, delta5kgAvg];
    deltaListStd = [delta1kgStd, delta2kgStd, delta3kgStd, delta4kgStd, delta5kgStd];
    
    %% Combine Statistics
    hList = [h1, h2, h3, h4, h5];
    pList = [p1, p2, p3, p4, p5];
    ciList = [CI1, CI2, CI3, CI4, CI5];
    statsList = [stats1, stats2, stats3, stats4, stats5];
    dzList = abs([dz1, dz2, dz3, dz4, dz5]);

end

function [h, p, ci, stats, dz, deltaAvg, deltaStd] = perform_ttest(data1, data2, NSUBJ)
    %% Compute Delta
    % average
    deltaAvg = mean(data2-data1,"omitnan");

    % std
    deltaStd = std(data2-data1,"omitnan");
    
    %% Evaluate Significant Personal Simulation Reductions
    % paired t-test for 2 recordings of the same subjects in different conditions
    % h = 1 indicates significant difference in population means
    [h,p,ci,stats] = ttest(data1, data2,"Alpha", 0.05);

    % Cohen's dz 
    % represents mean change between conditions, scaled by inter-subject variability
    % larger than 1 indicates large changes
    dz = stats.tstat/sqrt(NSUBJ);
end

function WalkingKneeMaxAvg = compute_peak_exp(data, sign, IdxRange)
% returns peak knee flexion angle, averaged over left/right
    
    if(isempty(IdxRange))
        IdxRange = 1:size(data,2);
    end
    
    % compute max over trials
    WalkingKneeKin = data(:,IdxRange,:,:)*sign;
    [WalkingKneeMaxLR,b] = max(WalkingKneeKin,[],2);
    WalkingKneeMaxAvg = squeeze(mean(WalkingKneeMaxLR,3));

    % debug
    % for j = 1:size(WalkingKneeKin, 1)
    %     figure
    %     tiledlayout(2,6)
    %     for i = 1:size(WalkingKneeKin,4)
    %         nexttile
    %         hold on
    %         plot(squeeze(WalkingKneeKin(j,:,:,i)))
    %         plot(squeeze(b(j,:,:,i)), squeeze(WalkingKneeMaxLR(j,:, :, i)), "*")
    %         hold off
    %     end
    % end

end

function WalkingKin = load_data(expData, SUBJID, isJoint, weight, Nsides, Ntrials, dataPrefix, dataDelim, filterBool)
% returns peak knee flexion angle, averaged over left/right

    Ndata = size(expData.data.SUBJ4.kinematics.IkdataNormal,1);
    lowpassSettings.lowpassFreq = 6;                                            % default in OpenSim
    lowpassSettings.lowpassFilterOrder = 2;                                     % default in OpenSim

    WalkingKin = NaN(Ndata,Nsides,Ntrials);
    if(weight == "Normal")
        dataColumn = dataPrefix + "Normal";
    else
        dataColumn = dataPrefix + "Weighted" + weight;
    end

    dataKin = expData.data.("SUBJ" + SUBJID).(dataDelim).(dataColumn);
    NtrialsSUBJ = size(dataKin,3);
    if(NtrialsSUBJ < Ntrials)
        Ncol = NtrialsSUBJ;
    else
        Ncol = Ntrials;
    end

     % lowpass filter data
    if(filterBool)
        dataKinFil = lowpassFilterWrapper(dataKin, 100, lowpassSettings);
    else
        dataKinFil = dataKin;
    end

    WalkingKin(:,:,1:Ncol) = dataKinFil(:,isJoint,1:Ncol);
end

function [normalWalkingExpAvg, normalWalkingExpStd, weightedWalkingExpAvg, weightedWalkingExpStd] = extract_experimental_data(expData, dataDelim, dataPrefix, SUBJID, Ndata, Nweights, filterBool, meanIdx)
    
    % define variables
    if(isfield(expData.data.headers,dataDelim))
        Ncolexp = length(expData.data.headers.(dataDelim));
    else
        Ncolexp = 1;
    end
    NSUBJ = length(SUBJID);
    lowpassSettings.lowpassFreq = 6;                                            % default in OpenSim
    lowpassSettings.lowpassFilterOrder = 2;                                     % default in OpenSim
    
    % initialize lists
    normalWalkingExpAvg = NaN(Ndata, Ncolexp, NSUBJ);
    normalWalkingExpStd = NaN(Ndata, Ncolexp, NSUBJ);
    weightedWalkingExpAvg = NaN(Ndata, Ncolexp, NSUBJ, Nweights);
    weightedWalkingExpStd = NaN(Ndata, Ncolexp, NSUBJ, Nweights);
    
    for i = 1:NSUBJ
        % load data
        normalWalkingExpRaw = expData.data.("SUBJ"+ SUBJID(i)).(dataDelim).(dataPrefix+"Normal");
        weightedWalking1kgExpRaw = expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"Weighted1kg");
        weightedWalking2kgExpRaw = expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"Weighted2kg");
        weightedWalking3kgExpRaw = expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"Weighted3kg");
        weightedWalking4kgExpRaw = expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"Weighted4kg");
        weightedWalking5kgExpRaw = expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"Weighted5kg");

        % lowpass filter data
        if(filterBool)
            normalWalkingExpFil = lowpassFilterWrapper(normalWalkingExpRaw, 100, lowpassSettings);
            weightedWalking1kgExpFil = lowpassFilterWrapper(weightedWalking1kgExpRaw, 100, lowpassSettings);
            weightedWalking2kgExpFil = lowpassFilterWrapper(weightedWalking2kgExpRaw, 100, lowpassSettings);
            weightedWalking3kgExpFil = lowpassFilterWrapper(weightedWalking3kgExpRaw, 100, lowpassSettings);
            weightedWalking4kgExpFil = lowpassFilterWrapper(weightedWalking4kgExpRaw, 100, lowpassSettings);
            weightedWalking5kgExpFil = lowpassFilterWrapper(weightedWalking5kgExpRaw, 100, lowpassSettings);
        else
            normalWalkingExpFil = normalWalkingExpRaw;
            weightedWalking1kgExpFil = weightedWalking1kgExpRaw;
            weightedWalking2kgExpFil = weightedWalking2kgExpRaw;
            weightedWalking3kgExpFil = weightedWalking3kgExpRaw;
            weightedWalking4kgExpFil = weightedWalking4kgExpRaw;
            weightedWalking5kgExpFil = weightedWalking5kgExpRaw;
        end

        % compute mean
        normalWalkingExpAvg(:,:,i) = mean(normalWalkingExpFil,meanIdx,"omitnan");
        weightedWalkingExpAvg(:,:,i,1) = mean(weightedWalking1kgExpFil,meanIdx,"omitnan");
        weightedWalkingExpAvg(:,:,i,2) = mean(weightedWalking2kgExpFil,meanIdx,"omitnan");
        weightedWalkingExpAvg(:,:,i,3) = mean(weightedWalking3kgExpFil,meanIdx,"omitnan");
        weightedWalkingExpAvg(:,:,i,4) = mean(weightedWalking4kgExpFil,meanIdx,"omitnan");
        weightedWalkingExpAvg(:,:,i,5) = mean(weightedWalking5kgExpFil,meanIdx,"omitnan");
    
        % compute std
        normalWalkingExpStd(:,:,i) = std(normalWalkingExpFil,0,meanIdx,"omitnan");
        weightedWalkingExpStd(:,:,i,1) = std(weightedWalking1kgExpFil,0,meanIdx,"omitnan");
        weightedWalkingExpStd(:,:,i,2) = std(weightedWalking2kgExpFil,0,meanIdx,"omitnan");
        weightedWalkingExpStd(:,:,i,3) = std(weightedWalking3kgExpFil,0,meanIdx,"omitnan");
        weightedWalkingExpStd(:,:,i,4) = std(weightedWalking4kgExpFil,0,meanIdx,"omitnan");
        weightedWalkingExpStd(:,:,i,5) = std(weightedWalking5kgExpFil,0,meanIdx,"omitnan");
    end
end

function filteredData = lowpassFilterWrapper(data, Fs, settings)
    Ntrials = size(data,3);
    filteredData = NaN(size(data));

    for i = 1:Ntrials
        filteredData(:,:,i) = lowpassFilter(data(:,:,i), Fs, settings);
    end
end

function maxErrList = test_assymetry(resampTime, dataRight, dataLeft)
    
    Njoints = size(dataRight,2);
    maxErrList = NaN(Njoints,1);
    for i = 1:Njoints
        subjDataR = squeeze(dataRight(:,i,:))';
        subjDataL = squeeze(dataLeft(:,i,:))';

        spm = spm1d.stats.ttest_paired(subjDataR, subjDataL);
        inference = spm.inference(0.05, 'two_tailed', true);

        timeIdx = zeros(size(inference.clusters,2),2);
        for j = 1:size(timeIdx,1)
            timePoints = inference.clusters{j}.endpoints/100;
            timeIdx(j,:) = [findTimeIdx(resampTime, timePoints(1)), findTimeIdx(resampTime, timePoints(2))];
        end

        % create plot
        % figure
        % hold on
        % plot(resampTime, subjDataR, "blue")
        % plot(resampTime, subjDataL, "red")
        % 
        % % plot significant difference rectangle
        % ax = gca;
        % 
        % if (~isempty(timeIdx))
        %     for j = 1:size(timeIdx,1)
        %         plotRectangle(ax, resampTime(timeIdx(j,1)), resampTime(timeIdx(j,2)));
        %     end
        % end
        % hold off

        % compute max difference
        maxErrList(i) = max(abs(mean(subjDataR,2) - mean(subjDataL,2)));
    end


end

function idx = findTimeIdx(timeVector, timePoint)
    [dist,idx] = min(abs(timeVector-timePoint));
    if(dist > 0.5)
        warning(['Time distance is larger than 0.5 (' num2str(dist) ')!'])
        idx = 1;
    end
end

function plotRectangle(ax, xstart, xend)
    rectangle('Position', [xstart, ax.YLim(1), xend-xstart, ax.YLim(2)-ax.YLim(1)], 'FaceColor', [1,0,0,0.1], 'EdgeColor', 'none', 'FaceAlpha',0.1)
end

function draw_weight_arrow(includeBool, Nweights, peakVal, deltaList, sign, color, xstart, xstep, ycorr, alpha, beta)
    % draw arrows
    for j = 1:Nweights
        if(includeBool(j))
        
        draw_arrow(xstart+xstep*(j-2), xstart+xstep*(j-2),peakVal(1)*sign, peakVal(j+1)*sign, alpha, beta, color(:,j+1)')
        text(xstart+xstep*(j-2),peakVal(j+1)*sign+ycorr,num2str(round(deltaList(j)))+"°",...
            "HorizontalAlignment","center","Color",color(:,j+1)')
        end
    end

end