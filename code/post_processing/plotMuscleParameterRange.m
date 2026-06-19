clear all
clc
close all

%% Load Libraries
addpath("C:\Users\medenaye\Documents\programs\GitHub\OpenSim-Processing\data-processing\utilities")
addpath(pwd + "\helperFunctions")

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];   
NSUBJ = length(SUBJID);
trackKeyWords = "gait1422";
genericKeyWords = "generic";
personalKeyWords = "optTrack";
falisseKeyWords = "Falisse2022";
resultsSubFolder = repmat("trackKIN-compliantTendon-3D",1,NSUBJ);
resultsSubFolder = resultsSubFolder + "/" + ["SUBJ04mtu3D_02421031", "SUBJ06mtu3D_02452315", "SUBJ07mtu3D_02462103", "SUBJ09mtu3D_02472054", "SUBJ10mtu3D_02491301", "SUBJ11mtu3D_02501441"];
resampTime = 0:0.01:1;

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = true;
figFileType = ".pdf";
linewidth = 1.5;

colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

color_personal = makeGroupColors(24/360, 1, 0.50, 1, 1);
color_generic = makeGroupColors(220/360, 1, 0.50, 1, 1);
colors_generic = makeGroupColors(0.6, 6, 1, 0.6, 0.9)';
colors_personal = makeGroupColors(0.1, 6, 1, 0.6, 0.9)';

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

%% Load Results
% Load tracking data
trackSubFolder = ["gait1422_MTPjoint_11433261", "gait1422_MTPjoint_11448691", "gait1422_MTPjoint_11417571", "gait1422_MTPjoint_11453296", "gait1422_MTPjoint_11454268", "gait1422_MTPjoint_11432683"];
[lMtilde_tracking, lTtilde_tracking, FMtildeSync_tracking, FMtildepassSync_tracking, muscleColHeaders] = get_muscle_data(Nemgcol, resampTime, trackDIR, TrackFolders, trackSubFolder, trackKeyWords);

% Load generic model results
[lMtilde_generic, lTtilde_generic, FMtildeSync_generic, FMtildeSyncpass_generic, ~] = get_muscle_data(Nemgcol, resampTime, resultsDIR, ResultsFolders, resultsSubFolder, genericKeyWords);

% Load personalized model results
[lMtilde_personal, lTtilde_personal, FMtildeSync_personal, FMtildeSyncpass_personal, ~] = get_muscle_data(Nemgcol, resampTime, resultsDIR, ResultsFolders, resultsSubFolder, personalKeyWords);


%% Create Figure (Optimal Fibre Length & Tendon Slack Length)
muscleLabels = strrep(muscleColHeaders(1:Nemgcol/2), "_r", "");
muscleLabels = strrep(muscleLabels, "_", " ");

fig = figure;
t = tiledlayout(1,2);
t.InnerPosition = [0.09 0.11 0.9 0.75];
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.2])                          % IEEE 1-column: 8.89cm

nexttile
plot_mtu_range_minmax(gca, lMtilde_personal(:,1:Nemgcol/2,:), "", "Optimal Fibre Length [-]", muscleLabels, "", color_personal, 4, 0.3)
plot_mtu_range_minmax(gca, lMtilde_generic(:,1:Nemgcol/2,:), "", "Normalized Optimal Fibre Length [-]", muscleLabels, "", color_generic, 4, -0.3)
plot_mtu_range(gca, lMtilde_personal(:,1:Nemgcol/2,:), "", "Optimal Fibre Length [-]", muscleLabels, "", colors_personal, 0.5, 1, 0.3)
plot_mtu_range(gca, lMtilde_generic(:,1:Nemgcol/2,:), "", "Optimal Fibre Length [-]", muscleLabels, "", colors_generic, 0.5, 1, -0.3)
ylim([0 Nemgcol])

nexttile
plot_mtu_range_minmax(gca, lTtilde_personal(:,1:Nemgcol/2,:), "", "Normalized Tendon Slack Length [-]", muscleLabels, "", color_personal, 4, 0.3)
plot_mtu_range_minmax(gca, lTtilde_generic(:,1:Nemgcol/2,:), "", "Normalized Tendon Slack Length [-]", muscleLabels, "", color_generic, 4, -0.3)
plot_mtu_range(gca, lTtilde_personal(:,1:Nemgcol/2,:), "", "Normalized Tendon Slack Length [-]", muscleLabels, "", colors_personal, 0.5, 1, 0.3)
plot_mtu_range(gca, lTtilde_generic(:,1:Nemgcol/2,:), "", "Normalized Tendon Slack Length [-]", muscleLabels, "", colors_generic, 0.5, 1, -0.3)
ylim([0 Nemgcol])

l = legend([repmat("", 1, Nemgcol/2-1), "personal", repmat("", 1, Nemgcol/2-1), "generic"], "Box", "off", "Orientation", "horizontal");
l.Layout.Tile = "north";

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
set(0,"DefaultFigureColor","w")                                         % white background
set(0,"defaulttextinterpreter","tex")                                   % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
set(gca,"Units","centimeters")                                          % cm units for position
% set(gca,"Position",[1.5 0.8 fig_width*2-2 fig_height-1.5])              % axes position (x, y, w, h)

if(export)
    figName = "personal_generic_lMopt_lTslack_range" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Create Figure (Passive Muscle Force)
fig = figure;
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height])                          % IEEE 1-column: 8.89cm
plot_mtu_range(gca, FMtildeSyncpass_generic(:,1:Nemgcol/2,:), "", "Passive Muscle Force [-]", muscleLabels, "", colors_generic)
plot_mtu_range(gca, FMtildeSyncpass_personal(:,1:Nemgcol/2,:), "", "Passive Muscle Force [-]", muscleLabels, "", colors_personal)
% plot_mtu_range(gca, lMtilde_tracking(:,1:Nemgcol/2,:), "test", "test", muscleLabels, "", colors_tracking)

legend([repmat("", 1, Nemgcol/2*6-1), "generic", repmat("", 1, Nemgcol/2*6-1), "personal"], "Box", "off", "Location", "northoutside", "Orientation", "horizontal")

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
set(0,"DefaultFigureColor","w")                                         % white background
set(0,"defaulttextinterpreter","tex")                                   % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
set(gca,"Units","centimeters")                                          % cm units for position
set(gca,"Position",[1.5 1 fig_width*2-2.2 fig_height-2])              % axes position (x, y, w, h)

%% Create Figure (Passive Muscle Force)
fig = figure;
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height])                          % IEEE 1-column: 8.89cm
plot_mtu_range_minmax(gca, FMtildeSyncpass_generic(:,1:Nemgcol/2,:), "", "Passive Muscle Force [-]", muscleLabels, "", color_generic, 4, 0.3)
plot_mtu_range_minmax(gca, FMtildeSyncpass_personal(:,1:Nemgcol/2,:), "", "Passive Muscle Force [-]", muscleLabels, "", color_personal, 4, -0.3)
% plot_mtu_range(gca, lMtilde_tracking(:,1:Nemgcol/2,:), "test", "test", muscleLabels, "", colors_tracking)

legend([repmat("", 1, Nemgcol/2-1), "generic", repmat("", 1, Nemgcol/2-1), "personal"], "Box", "off", "Location", "northoutside", "Orientation", "horizontal")

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
set(0,"DefaultFigureColor","w")                                         % white background
set(0,"defaulttextinterpreter","tex")                                   % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
set(gca,"Units","centimeters")                                          % cm units for position
set(gca,"Position",[1.5 1 fig_width*2-2.2 fig_height-2])              % axes position (x, y, w, h)