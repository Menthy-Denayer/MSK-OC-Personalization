clear all
clc
close all

%% Load Libraries
addpath("C:\Users\medenaye\Documents\programs\GitHub\OpenSim-Processing\data-processing\utilities")

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];   
NSUBJ = length(SUBJID);
optFileName = "workerparam.mat";
resultsSubFolder = repmat("trackKIN-compliantTendon-3D",1,NSUBJ);
resultsSubFolder = resultsSubFolder + "/" + ["SUBJ04mtu3D_02421031", "SUBJ06mtu3D_02452315", "SUBJ07mtu3D_02462103", "SUBJ09mtu3D_02472054", "SUBJ10mtu3D_02491301", "SUBJ11mtu3D_02501441"];

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = false;
figFileType = ".pdf";
linewidth = 1.5;

% colors = ["black"; "red"; "blue"; "magenta"];
% colors = [[0,39,182]/255; [182,142,0]/255; [0,130,182]/255; [182,0,39]/255];
colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

%% General Variables
Niter = 202;
Nworkers = 10;

%% Load Generic Results
ResultsOneDriveDIR = "C:\Users\medenaye\OneDrive - Vrije Universiteit Brussel\PhD-Main\[01] main\WP1\T1.3\[01] results\PredSim";
resultsDIR = uigetdir(ResultsOneDriveDIR,"Choose generic solution directory");

%% Choose Desired Tracking Folders
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);

%% Load Results
fitnessData = NaN(Niter, Nworkers, NSUBJ);
bestFitnessData = NaN(1,NSUBJ);
genericFitnessData = NaN(1,NSUBJ);

for i = 1:NSUBJ
    fileName = fullfile(resultsDIR,ResultsFolders(i),resultsSubFolder(i),optFileName);
    data = load(fileName);
    fitnessData(:,:,i) = squeeze(data.data.fhist)';
    genericFitnessData(i) = data.data.fhist(1,1,1);
    bestFitnessData(i) = data.data.besteverF;
end

%% Compute Mean & STD
meanFitnessData = mean(fitnessData,2,"omitnan");
stdFitnessData = std(fitnessData,0,2,"omitnan");

minFitnessData = min(fitnessData,[],2,"omitnan");
maxFitnessData = max(fitnessData,[],2,"omitnan");

%% Compute Mean Reduction
deltaFitness = (bestFitnessData-genericFitnessData)./genericFitnessData*100;
mean(deltaFitness);
std(deltaFitness);

%% Plot Fitness - Iterations

% Create figure
fig = figure;
t = tiledlayout(2,3,"TileSpacing","tight");
t.InnerPosition = [0.05 0.08 0.93 0.85];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height])                                             % IEEE 1-column: 8.89cm
for i = 1:NSUBJ
    nexttile
    hold on
    plot_mean_std(1:Niter, meanFitnessData(:,:,i), stdFitnessData(:,:,i), "black", 1, "-")
    % plot(1:Niter, minFitnessData(:,:,i), "k--")
    % plot(1:Niter, maxFitnessData(:,:,i), "k--")
    % yline(genericFitnessData(i))
    % yline(bestFitnessData(i))
    xlim([0 Niter])
    ylim([60 300])
    if(i > 3)
        xlabel("Iteration [-]", "FontWeight", "bold")
    end

    if(i == 1 || i == 4)
        ylabel("Fitness [-]", "FontWeight", "bold")
    end
    title("Subject " + SUBJID(i))
    hold off
end

set(findall(fig,'-property','FontSize'),'FontSize',8)              % font size
set(0,"DefaultFigureColor","w")                                     % white background
set(0,"defaulttextinterpreter","tex")                               % tex style font
set(0,"DefaultAxesFontName","Helvetica")                            % times new roman font
set(gca,"Units","centimeters")                                      % cm units for position

if(export)
    figName = "personalization_convergence.pdf";
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end