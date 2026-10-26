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

%% Load Libraries
addpath(pwd + "\helperFunctions")

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];   
NSUBJ = length(SUBJID);
meshSubFolder = "100Meshes";
genericKeyWords = "mtu3D";
personalKeyWords = "opt3D";
generic_resultsSubFolder = ["SUBJ04mtu3D", "SUBJ06mtu3D", "SUBJ07mtu3D", "SUBJ09mtu3D", "SUBJ10mtu3D", "SUBJ11mtu3D"] + "/" + meshSubFolder;
personal_resultsSubFolder = ["SUBJ04opt3D", "SUBJ06opt3D", "SUBJ07opt3D", "SUBJ09opt3D", "SUBJ10opt3D", "SUBJ11opt3D"] + "/" + meshSubFolder;
resampTime = 0:0.01:1;

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = false;
figFileType = ".pdf";
linewidth = 1.5;

colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

color_personal = makeGroupColors(24/360, 1, 0.50, 1, 1);
color_generic = makeGroupColors(220/360, 1, 0.50, 1, 1);
colors_generic = makeGroupColors(0.6, 6, 1, 0.6, 0.9)';
colors_personal = makeGroupColors(0.1, 6, 1, 0.6, 0.9)';

%% General Variables
Nemgcol = 28;

%% Load Generic Results
resultsDIR = uigetdir("..\..\..\results\", "Choose generic solution directory");

%% Choose Desired Folders
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);

%% Load Results
% Load generic model results
[lMtilde_generic, lTtilde_generic, FMtildeSync_generic, FMtildeSyncpass_generic, muscleColHeaders] = get_muscle_data(Nemgcol, resampTime, resultsDIR, ResultsFolders, generic_resultsSubFolder, genericKeyWords);

% Load personalized model results
[lMtilde_personal, lTtilde_personal, FMtildeSync_personal, FMtildeSyncpass_personal, ~] = get_muscle_data(Nemgcol, resampTime, resultsDIR, ResultsFolders, personal_resultsSubFolder, personalKeyWords);

%% Create Figure (Optimal Fibre Length & Tendon Slack Length)
muscleLabels = strrep(muscleColHeaders(1:Nemgcol/2), "_r", "");
muscleLabels = strrep(muscleLabels, "_", " ");

fig = figure;
t = tiledlayout(1,2);
t.InnerPosition = [0.09 0.11 0.88 0.70];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.2])                        % IEEE 1-column: 8.89cm

nexttile
plot_mtu_range_minmax(gca, lMtilde_personal(:,1:Nemgcol/2,:), "", "Normalized Fibre Length [-]", muscleLabels, "", color_personal, 4, 0.3)
plot_mtu_range_minmax(gca, lMtilde_generic(:,1:Nemgcol/2,:), "", "Normalized Fibre Length [-]", muscleLabels, "", color_generic, 4, -0.3)
plot_mtu_range(gca, lMtilde_personal(:,1:Nemgcol/2,:), "", "Normalized Fibre Length [-]", muscleLabels, "", colors_personal, 0.5, 1, 0.3)
plot_mtu_range(gca, lMtilde_generic(:,1:Nemgcol/2,:), "", "Normalized Fibre Length [-]", muscleLabels, "", colors_generic, 0.5, 1, -0.3)
ylim([0 Nemgcol])

nexttile
plot_mtu_range_minmax(gca, lTtilde_personal(:,1:Nemgcol/2,:), "", "Normalized Tendon Length [-]", muscleLabels, "", color_personal, 4, 0.3)
plot_mtu_range_minmax(gca, lTtilde_generic(:,1:Nemgcol/2,:), "", "Normalized Tendon Length [-]", muscleLabels, "", color_generic, 4, -0.3)
plot_mtu_range(gca, lTtilde_personal(:,1:Nemgcol/2,:), "", "Normalized Tendon Length [-]", muscleLabels, "", colors_personal, 0.5, 1, 0.3)
plot_mtu_range(gca, lTtilde_generic(:,1:Nemgcol/2,:), "", "Normalized Tendon Length [-]", muscleLabels, "", colors_generic, 0.5, 1, -0.3)
ylim([0 Nemgcol])

l = legend([repmat("", 1, Nemgcol/2-1), "personal", repmat("", 1, Nemgcol/2-1), "generic"], "Box", "off", "Orientation", "horizontal");
l.Layout.Tile = "north";

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position

if(export)
    figName = "personal_generic_lMopt_lTslack_range" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end