% --------------------------------------------------------------------------
% plotMetrics
%   Plot the metrics inside the metrics.mat file
%
% Original author: Menthy Denayer
% Original date: 09/July/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 09/July/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Load Metrics
[file_name, file_loc] = uigetfile(".mat", "Choose metrics structure file.");
load(fullfile(file_loc, file_name));

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
linewidth = 1.5;
export = false;
figFileType = ".pdf";
colors = [[0,51,153]/255; [255,102,0]/255; [51,155,155]/255; [0,0,0]];

%% Define Variables
NSUBJ = size(metrics.kinematics.normal.R.generic, 1);
Njoints = size(metrics.kinematics.normal.R.generic, 2);
Ncases = size(metrics.kinematics.weighted.R.generic, 2)+1;

kinColHeaders = metrics.colheaders.kinematics;
tableHeaders = repmat(string(0:5) + "kg",1,3);

%% Compute Average Kinematics Correlation Metrics
R_list_kin_generic_avg = NaN(NSUBJ, Ncases);
R_list_kin_generic_avg(:,1) = mean(metrics.kinematics.normal.R.generic,2);
R_list_kin_generic_avg(:,2:end) = mean(metrics.kinematics.weighted.R.generic,3);
R_list_kin_generic_avg_avg = mean(R_list_kin_generic_avg, 1);
R_list_kin_generic_avg_std = std(R_list_kin_generic_avg, [], 1);

R_list_kin_personal_avg = NaN(NSUBJ, Ncases);
R_list_kin_personal_avg(:,1) = mean(metrics.kinematics.normal.R.personal,2);
R_list_kin_personal_avg(:,2:end) = mean(metrics.kinematics.weighted.R.personal,3);
R_list_kin_personal_avg_avg = mean(R_list_kin_personal_avg, 1);
R_list_kin_personal_avg_std = std(R_list_kin_personal_avg, [], 1);

R_list_kin_dhondt2024_3seg_avg = NaN(NSUBJ, Ncases);
R_list_kin_dhondt2024_3seg_avg(:,1) = mean(metrics.kinematics.normal.R.dhondt2024_3seg,2);
R_list_kin_dhondt2024_3seg_avg(:,2:end) = mean(metrics.kinematics.weighted.R.dhondt2024_3seg,3);
R_list_kin_dhondt2024_3seg_avg_avg = mean(R_list_kin_dhondt2024_3seg_avg, 1);
R_list_kin_dhondt2024_3seg_avg_std = std(R_list_kin_dhondt2024_3seg_avg, [], 1);

%% Compute Average Kinematics RMSE Metrics
isTrans = contains(kinColHeaders, "pelvis_tx") | contains(kinColHeaders, "pelvis_ty") | contains(kinColHeaders, "pelvis_tz");
isRot = ~isTrans;

rmse_list_kin_generic_avg = NaN(NSUBJ, Ncases);
rmse_list_kin_generic_avg(:,1) = mean(metrics.kinematics.normal.RMSE.generic(:, isRot),2);
rmse_list_kin_generic_avg(:,2:end) = mean(metrics.kinematics.weighted.RMSE.generic(:, :, isRot),3);
rmse_list_kin_generic_avg_avg = mean(rmse_list_kin_generic_avg, 1);
rmse_list_kin_generic_avg_std = std(rmse_list_kin_generic_avg, [], 1);

rmse_list_kin_personal_avg = NaN(NSUBJ, Ncases);
rmse_list_kin_personal_avg(:,1) = mean(metrics.kinematics.normal.RMSE.personal(:, isRot),2);
rmse_list_kin_personal_avg(:,2:end) = mean(metrics.kinematics.weighted.RMSE.personal(:, :, isRot),3);
rmse_list_kin_personal_avg_avg = mean(rmse_list_kin_personal_avg, 1);
rmse_list_kin_personal_avg_std = std(rmse_list_kin_personal_avg, [], 1);

rmse_list_kin_dhondt2024_3seg_avg = NaN(NSUBJ, Ncases);
rmse_list_kin_dhondt2024_3seg_avg(:,1) = mean(metrics.kinematics.normal.RMSE.dhondt2024_3seg(:, isRot),2);
rmse_list_kin_dhondt2024_3seg_avg(:,2:end) = mean(metrics.kinematics.weighted.RMSE.dhondt2024_3seg(:, :, isRot),3);
rmse_list_kin_dhondt2024_3seg_avg_avg = mean(rmse_list_kin_dhondt2024_3seg_avg, 1);
rmse_list_kin_dhondt2024_3seg_avg_std = std(rmse_list_kin_dhondt2024_3seg_avg, [], 1);

%% Plot Metrics Kinematics
% Create figure
fig = figure;
t = tiledlayout(2,1,"TileSpacing","tight");
t.InnerPosition = [0.15 0.08 0.84 0.70];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height/1.5])                          % IEEE 1-column: 8.89cm
nexttile
hold on
b = bar(1:6,[R_list_kin_generic_avg_avg; R_list_kin_personal_avg_avg; R_list_kin_dhondt2024_3seg_avg_avg]);

% assign colors
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xendpoints = [b.XEndPoints];
errorbar(xendpoints(1:Ncases), R_list_kin_generic_avg_avg, R_list_kin_generic_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(Ncases+1:2*Ncases), R_list_kin_personal_avg_avg, R_list_kin_personal_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(Ncases*2+1:3*Ncases), R_list_kin_dhondt2024_3seg_avg_avg, R_list_kin_dhondt2024_3seg_avg_std, '.', "vertical", "Color", "black")
xticks(1:6)
xticklabels(repmat("", 1, Ncases));
ylabel(["Average Correlation"; "Coefficient [-]"], "FontWeight", "bold")
ylim([0 1])
lg = legend(["Generic", "Personal", "D'Hondt2024 3 seg"],"Orientation", "horizontal", "Box", "off", "Location", "northoutside");
lg.IconColumnWidth = 10;
hold off

nexttile
hold on
b = bar(1:6,[rmse_list_kin_generic_avg_avg; rmse_list_kin_personal_avg_avg; rmse_list_kin_dhondt2024_3seg_avg_avg]);

% assign colors
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xendpoints = [b.XEndPoints];
errorbar(xendpoints(1:Ncases), rmse_list_kin_generic_avg_avg, rmse_list_kin_generic_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(Ncases+1:2*Ncases), rmse_list_kin_personal_avg_avg, rmse_list_kin_personal_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(2*Ncases+1:3*Ncases), rmse_list_kin_dhondt2024_3seg_avg_avg, rmse_list_kin_dhondt2024_3seg_avg_std, '.', "vertical", "Color", "black")
xticks(1:6)
xticklabels(["normal", "1 kg", "2 kg", "3 kg", "4 kg", "5 kg"]);
ylabel(["RMSE"; "[°]"], "FontWeight", "bold")
ylim([0 10])

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position
hold off

 
if(export)
    figName = "R_personal_generic_kin" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Compute Average GRF Correlation Metrics
R_list_grf_generic_avg = NaN(NSUBJ, Ncases);
R_list_grf_generic_avg(:,1) = mean(metrics.ground_reaction.normal.R.generic,2);
R_list_grf_generic_avg(:,2:end) = mean(metrics.ground_reaction.weighted.R.generic,3);
R_list_grf_generic_avg_avg = mean(R_list_grf_generic_avg, 1);
R_list_grf_generic_avg_std = std(R_list_grf_generic_avg, [], 1);

R_list_grf_personal_avg = NaN(NSUBJ, Ncases);
R_list_grf_personal_avg(:,1) = mean(metrics.ground_reaction.normal.R.personal,2);
R_list_grf_personal_avg(:,2:end) = mean(metrics.ground_reaction.weighted.R.personal,3);
R_list_grf_personal_avg_avg = mean(R_list_grf_personal_avg, 1);
R_list_grf_personal_avg_std = std(R_list_grf_personal_avg, [], 1);

R_list_grf_dhondt2024_3seg_avg = NaN(NSUBJ, Ncases);
R_list_grf_dhondt2024_3seg_avg(:,1) = mean(metrics.ground_reaction.normal.R.dhondt2024_3seg,2);
R_list_grf_dhondt2024_3seg_avg(:,2:end) = mean(metrics.ground_reaction.weighted.R.dhondt2024_3seg,3);
R_list_grf_dhondt2024_3seg_avg_avg = mean(R_list_grf_dhondt2024_3seg_avg, 1);
R_list_grf_dhondt2024_3seg_avg_std = std(R_list_grf_dhondt2024_3seg_avg, [], 1);

%% Compute Average GRF RMSE Metrics
rmse_list_grf_generic_avg = NaN(NSUBJ, Ncases);
rmse_list_grf_generic_avg(:,1) = mean(metrics.ground_reaction.normal.RMSE.generic,2);
rmse_list_grf_generic_avg(:,2:end) = mean(metrics.ground_reaction.weighted.RMSE.generic,3);
rmse_list_grf_generic_avg_avg = mean(rmse_list_grf_generic_avg, 1);
rmse_list_grf_generic_avg_std = std(rmse_list_grf_generic_avg, [], 1);

rmse_list_grf_personal_avg = NaN(NSUBJ, Ncases);
rmse_list_grf_personal_avg(:,1) = mean(metrics.ground_reaction.normal.RMSE.personal,2);
rmse_list_grf_personal_avg(:,2:end) = mean(metrics.ground_reaction.weighted.RMSE.personal,3);
rmse_list_grf_personal_avg_avg = mean(rmse_list_grf_personal_avg, 1);
rmse_list_grf_personal_avg_std = std(rmse_list_grf_personal_avg, [], 1);

rmse_list_grf_dhondt2024_3seg_avg = NaN(NSUBJ, Ncases);
rmse_list_grf_dhondt2024_3seg_avg(:,1) = mean(metrics.ground_reaction.normal.RMSE.dhondt2024_3seg,2);
rmse_list_grf_dhondt2024_3seg_avg(:,2:end) = mean(metrics.ground_reaction.weighted.RMSE.dhondt2024_3seg,3);
rmse_list_grf_dhondt2024_3seg_avg_avg = mean(rmse_list_grf_dhondt2024_3seg_avg, 1);
rmse_list_grf_dhondt2024_3seg_avg_std = std(rmse_list_grf_dhondt2024_3seg_avg, [], 1);

%% Plot Metrics GRFs
% Create figure
fig = figure;
t = tiledlayout(2,1,"TileSpacing","tight");
t.InnerPosition = [0.15 0.08 0.84 0.70];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height/1.5])                          % IEEE 1-column: 8.89cm
nexttile
hold on
b = bar(1:6,[R_list_grf_generic_avg_avg; R_list_grf_personal_avg_avg; R_list_grf_dhondt2024_3seg_avg_avg]);

% assign colors
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xendpoints = [b.XEndPoints];
errorbar(xendpoints(1:Ncases), R_list_grf_generic_avg_avg, R_list_grf_generic_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(Ncases+1:2*Ncases), R_list_grf_personal_avg_avg, R_list_grf_personal_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(2*Ncases+1:3*Ncases), R_list_grf_dhondt2024_3seg_avg_avg, R_list_grf_dhondt2024_3seg_avg_std, '.', "vertical", "Color", "black")
xticks(1:6)
xticklabels(repmat("", 1, Ncases));
ylabel(["Average Correlation"; "Coefficient [-]"], "FontWeight", "bold")
ylim([0 1])
lg = legend(["Generic", "Personal", "D'Hondt2024 3 seg"],"Orientation", "horizontal", "Box", "off", "Location", "northoutside");
lg.IconColumnWidth = 10;
hold off

nexttile
hold on
b = bar(1:6,[rmse_list_grf_generic_avg_avg; rmse_list_grf_personal_avg_avg; rmse_list_grf_dhondt2024_3seg_avg_avg]);

% assign colors
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xendpoints = [b.XEndPoints];
errorbar(xendpoints(1:Ncases), rmse_list_grf_generic_avg_avg, rmse_list_grf_generic_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(Ncases+1:2*Ncases), rmse_list_grf_personal_avg_avg, rmse_list_grf_personal_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(2*Ncases+1:3*Ncases), rmse_list_grf_dhondt2024_3seg_avg_avg, rmse_list_grf_dhondt2024_3seg_avg_std, '.', "vertical", "Color", "black")
xticks(1:6)
xticklabels(["normal", "1 kg", "2 kg", "3 kg", "4 kg", "5 kg"]);
ylabel(["RMSE"; "[N/kg]"], "FontWeight", "bold")
ylim([0 1])

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position
hold off

 
if(export)
    figName = "R_personal_generic_grf" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Compute Average EMG Correlation Metrics
R_list_emg_generic_avg = NaN(NSUBJ, Ncases);
R_list_emg_generic_avg(:,1) = mean(metrics.muscle_activations.normal.R.generic,2, "omitnan");
R_list_emg_generic_avg(:,2:end) = mean(metrics.muscle_activations.weighted.R.generic,3, "omitnan");
R_list_emg_generic_avg_avg = mean(R_list_emg_generic_avg, 1);
R_list_emg_generic_avg_std = std(R_list_emg_generic_avg, [], 1);

R_list_emg_personal_avg = NaN(NSUBJ, Ncases);
R_list_emg_personal_avg(:,1) = mean(metrics.muscle_activations.normal.R.personal,2, "omitnan");
R_list_emg_personal_avg(:,2:end) = mean(metrics.muscle_activations.weighted.R.personal,3, "omitnan");
R_list_emg_personal_avg_avg = mean(R_list_emg_personal_avg, 1);
R_list_emg_personal_avg_std = std(R_list_emg_personal_avg, [], 1);

R_list_emg_dhondt2024_3seg_avg = NaN(NSUBJ, Ncases);
R_list_emg_dhondt2024_3seg_avg(:,1) = mean(metrics.muscle_activations.normal.R.dhondt2024_3seg,2, "omitnan");
R_list_emg_dhondt2024_3seg_avg(:,2:end) = mean(metrics.muscle_activations.weighted.R.dhondt2024_3seg,3, "omitnan");
R_list_emg_dhondt2024_3seg_avg_avg = mean(R_list_emg_dhondt2024_3seg_avg, 1);
R_list_emg_dhondt2024_3seg_avg_std = std(R_list_emg_dhondt2024_3seg_avg, [], 1);

%% Plot Metrics EMGs
% Create figure
fig = figure;
t = tiledlayout(1,1,"TileSpacing","tight");
t.InnerPosition = [0.15 0.12 0.84 0.75];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height/2.5])                          % IEEE 1-column: 8.89cm
nexttile
hold on
b = bar(1:6,[R_list_emg_generic_avg_avg; R_list_emg_personal_avg_avg; R_list_emg_dhondt2024_3seg_avg_avg]);

% assign colors
for i = 1:length(b)
    b(i).FaceColor = colors(i,:);
end

xendpoints = [b.XEndPoints];
errorbar(xendpoints(1:Ncases), R_list_emg_generic_avg_avg, R_list_emg_generic_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(Ncases+1:2*Ncases), R_list_emg_personal_avg_avg, R_list_emg_personal_avg_std, '.', "vertical", "Color", "black")
errorbar(xendpoints(2*Ncases+1:3*Ncases), R_list_emg_dhondt2024_3seg_avg_avg, R_list_emg_dhondt2024_3seg_avg_std, '.', "vertical", "Color", "black")
xticks(1:6)
xticklabels(["normal", "1 kg", "2 kg", "3 kg", "4 kg", "5 kg"]);
ylabel(["Average Correlation"; "Coefficient [-]"], "FontWeight", "bold")
ylim([0 1])
lg = legend(["Generic", "Personal", "D'Hondt2024 3 seg"],"Orientation", "horizontal", "Box", "off", "Location", "north");
lg.IconColumnWidth = 10;
hold off


% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position
hold off
 
if(export)
    figName = "R_personal_generic_emg" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end