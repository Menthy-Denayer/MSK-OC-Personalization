clear all
clc
close all

%% Add Path
addpath("helperFunctions")

%% Load Metrics
load("metrics.mat")

%% Define Variables
NSUBJ = size(metrics.kinematics.normal.R.generic, 1);
Njoints = size(metrics.kinematics.normal.R.generic, 2);
Ncases = size(metrics.kinematics.weighted.R.generic, 2)+1;

kinColHeaders = metrics.colheaders.kinematics;
tableHeaders = repmat(string(0:5) + "kg",1,3);

%% Save R
R_list_kin_generic = NaN(NSUBJ, Ncases, Njoints);
R_list_kin_generic(:,1,:) = metrics.kinematics.normal.R.generic;
R_list_kin_generic(:,2:end,:) = metrics.kinematics.weighted.R.generic;

R_list_kin_personal = NaN(NSUBJ, Ncases, Njoints);
R_list_kin_personal(:,1,:) = metrics.kinematics.normal.R.personal;
R_list_kin_personal(:,2:end,:) = metrics.kinematics.weighted.R.personal;

R_list_kin_falisse2022 = NaN(NSUBJ, Ncases, Njoints);
R_list_kin_falisse2022(:,1,:) = metrics.kinematics.normal.R.falisse2022;
R_list_kin_falisse2022(:,2:end,:) = metrics.kinematics.weighted.R.falisse2022;

%% Write Results to Tex File
for i = 1:NSUBJ
    % choose output name
    outputFileName = "tables/SUBJ" + i + "_R_kin.tex";

    % print average R kinematics
    R_list_kin_matrix = round([squeeze(R_list_kin_generic(i,:,:)); squeeze(R_list_kin_personal(i,:,:)); squeeze(R_list_kin_falisse2022(i,:,:))],2)';
    write_tex_latex(R_list_kin_matrix, [], tableHeaders, strrep(kinColHeaders,"_"," "), [], outputFileName, [])
end

%% Compute Average Kinematics Correlation Metrics
R_list_kin_generic_avg = NaN(NSUBJ, Ncases);
R_list_kin_generic_avg(:,1) = mean(metrics.kinematics.normal.R.generic,2);
R_list_kin_generic_avg(:,2:end) = mean(metrics.kinematics.weighted.R.generic,3);

R_list_kin_personal_avg = NaN(NSUBJ, Ncases);
R_list_kin_personal_avg(:,1) = mean(metrics.kinematics.normal.R.personal,2);
R_list_kin_personal_avg(:,2:end) = mean(metrics.kinematics.weighted.R.personal,3);

%% Compute Average GRF Correlation Metrics
R_list_grf_generic_avg = NaN(NSUBJ, Ncases);
R_list_grf_generic_avg(:,1) = mean(metrics.ground_reaction.normal.R.generic,2);
R_list_grf_generic_avg(:,2:end) = mean(metrics.ground_reaction.weighted.R.generic,3);

R_list_grf_personal_avg = NaN(NSUBJ, Ncases);
R_list_grf_personal_avg(:,1) = mean(metrics.ground_reaction.normal.R.personal,2);
R_list_grf_personal_avg(:,2:end) = mean(metrics.ground_reaction.weighted.R.personal,3);

%% Compute Average EMG Correlation Metrics
R_list_emg_generic_avg = NaN(NSUBJ, Ncases);
R_list_emg_generic_avg(:,1) = mean(metrics.muscle_activations.normal.R.generic,2, "omitnan");
R_list_emg_generic_avg(:,2:end) = mean(metrics.muscle_activations.weighted.R.generic,3, "omitnan");

R_list_emg_personal_avg = NaN(NSUBJ, Ncases);
R_list_emg_personal_avg(:,1) = mean(metrics.muscle_activations.normal.R.personal,2, "omitnan");
R_list_emg_personal_avg(:,2:end) = mean(metrics.muscle_activations.weighted.R.personal,3, "omitnan");

%% Compute Average Kinematics RMSE Metrics
isTrans = contains(kinColHeaders, "pelvis_tx") | contains(kinColHeaders, "pelvis_ty") | contains(kinColHeaders, "pelvis_tz");
isRot = ~isTrans;

rmse_trans_list_kin_generic_avg = NaN(NSUBJ, Ncases);
rmse_trans_list_kin_generic_avg(:,1) = mean(metrics.kinematics.normal.RMSE.generic(:,isTrans),2);
rmse_trans_list_kin_generic_avg(:,2:end) = mean(metrics.kinematics.weighted.RMSE.generic(:,:,isTrans),3);

rmse_rot_list_kin_generic_avg = NaN(NSUBJ, Ncases);
rmse_rot_list_kin_generic_avg(:,1) = mean(metrics.kinematics.normal.RMSE.generic(:,isRot),2);
rmse_rot_list_kin_generic_avg(:,2:end) = mean(metrics.kinematics.weighted.RMSE.generic(:,:,isRot),3);

rmse_trans_list_kin_personal_avg = NaN(NSUBJ, Ncases);
rmse_trans_list_kin_personal_avg(:,1) = mean(metrics.kinematics.normal.RMSE.personal(:,isTrans),2);
rmse_trans_list_kin_personal_avg(:,2:end) = mean(metrics.kinematics.weighted.RMSE.personal(:,:,isTrans),3);

rmse_rot_list_kin_personal_avg = NaN(NSUBJ, Ncases);
rmse_rot_list_kin_personal_avg(:,1) = mean(metrics.kinematics.normal.RMSE.personal(:,isRot),2);
rmse_rot_list_kin_personal_avg(:,2:end) = mean(metrics.kinematics.weighted.RMSE.personal(:,:,isRot),3);

%% Compute Average GRF RMSE Metrics
rmse_list_grf_generic_avg = NaN(NSUBJ, Ncases);
rmse_list_grf_generic_avg(:,1) = mean(metrics.ground_reaction.normal.RMSE.generic,2);
rmse_list_grf_generic_avg(:,2:end) = mean(metrics.ground_reaction.weighted.RMSE.generic,3);

rmse_list_grf_personal_avg = NaN(NSUBJ, Ncases);
rmse_list_grf_personal_avg(:,1) = mean(metrics.ground_reaction.normal.RMSE.personal,2);
rmse_list_grf_personal_avg(:,2:end) = mean(metrics.ground_reaction.weighted.RMSE.personal,3);

%% Write Average Kinematics Correlation Results to Tex File
subjectHeaders = strrep("S" + num2str([4; 6; 7; 9; 10; 11])," ","");

% choose output name
outputFileName = "tables/SUBJavg_R_kin.tex";

% print average R kinematics
dataMask = R_list_kin_generic_avg < R_list_kin_personal_avg;
dataMask = [~dataMask dataMask];

R_list_kin_matrix = round([squeeze(R_list_kin_generic_avg); squeeze(R_list_kin_personal_avg)],2)';
write_tex_latex(R_list_kin_matrix, [], tableHeaders, subjectHeaders, dataMask, outputFileName, '%.1f')

%% Write Average GRF Correlation Results to Tex File
subjectHeaders = strrep("S" + num2str([4; 6; 7; 9; 10; 11])," ","");

% choose output name
outputFileName = "tables/SUBJavg_R_grf.tex";

% print average R kinematics
dataMask = R_list_grf_generic_avg < R_list_grf_personal_avg;
dataMask = [~dataMask dataMask];
R_list_grf_matrix = round([squeeze(R_list_grf_generic_avg); squeeze(R_list_grf_personal_avg)],2)';
write_tex_latex(R_list_grf_matrix, [], tableHeaders, subjectHeaders, dataMask, outputFileName, '%.1f')

%% Write Average Muscle Activations Correlation Results to Tex File
subjectHeaders = strrep("S" + num2str([4; 6; 7; 9; 10; 11])," ","");

% choose output name
outputFileName = "tables/SUBJavg_R_emg.tex";

% print average R kinematics
dataMask = R_list_emg_generic_avg < R_list_emg_personal_avg;
dataMask = [~dataMask dataMask];
R_list_emg_matrix = round([squeeze(R_list_emg_generic_avg); squeeze(R_list_emg_personal_avg)],2)';
write_tex_latex(R_list_emg_matrix, [], tableHeaders, subjectHeaders, dataMask, outputFileName, '%.1f')

%% Write Average Kinematics RMSE Results to Tex File
subjectHeaders = strrep("S" + num2str([4; 6; 7; 9; 10; 11])," ","");

% choose output name
outputFileName = "tables/SUBJavg_rmse_kin.tex";

% print average R kinematics
dataMask = rmse_rot_list_kin_personal_avg < rmse_rot_list_kin_generic_avg;
dataMask = [~dataMask dataMask];
rmse_list_kin_matrix = round([squeeze(rmse_rot_list_kin_generic_avg); squeeze(rmse_rot_list_kin_personal_avg)],2)';
write_tex_latex(rmse_list_kin_matrix, [], tableHeaders, subjectHeaders, dataMask, outputFileName, '%.1f')

%% Write Average GRF RMSE Results to Tex File
subjectHeaders = strrep("S" + num2str([4; 6; 7; 9; 10; 11])," ","");

% choose output name
outputFileName = "tables/SUBJavg_rmse_grf.tex";

% print average R kinematics
dataMask = rmse_list_grf_personal_avg < rmse_list_grf_generic_avg;
dataMask = [~dataMask dataMask];
rmse_list_grf_matrix = round([squeeze(rmse_list_grf_generic_avg); squeeze(rmse_list_grf_personal_avg)],2)';
write_tex_latex(rmse_list_grf_matrix, [], tableHeaders, subjectHeaders, dataMask, outputFileName, '%.1f')