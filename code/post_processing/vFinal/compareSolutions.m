% --------------------------------------------------------------------------
% compareSolutions
%   Compare solutions of model calibration
%
% Original author: Menthy Denayer
% Original date: 16/Oct/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 25/Oct/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Add Paths
addpath("helperFunctions\")

%% Choose Calibration Directory
solDIR = uigetdir("..\..\..\results\","Choose solutions directory");

%% Get DIR Info
dirInfo = dir(solDIR);
subDIRs = string({dirInfo.name});
isDIR = [dirInfo.isdir]; isDIR(1:2) = 0;
subDIRs = subDIRs(isDIR);
NsubDIRs = length(subDIRs);
[~,subjFolder] = fileparts(fileparts(solDIR));

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = true;
figFileType = ".pdf";
linewidth = 1.5;

%% Define Variables
color = makeGroupColors(24/360,NsubDIRs,1,0.3,0.95)';
muscleNames = ["ercspn", "intobl", "extobl", "abd", "add", "hamstring", "bifemsh", "glut_max", "iliopsoas", "rect_fem", "vasti", "gastroc", "soleus", "tib_ant"];

%% Get Solution Info
xhist_all = NaN(28, 10, 202, NsubDIRs);
fhist_all = NaN(10, 202, NsubDIRs);
bestf = NaN(NsubDIRs,1);
for i = 1:NsubDIRs
    data = load(fullfile(solDIR, subDIRs(i), "workerparam.mat"));
    xhist_all(:,:,:,i) = data.data.xhist;
    fhist_all(:,:,i) = squeeze(data.data.fhist);
    bestf(i) = data.data.besteverF;
end

%% Find Best Result
resampTime = 0:0.01:1;
COTdata = NaN(NsubDIRs,1);
kinData = NaN(length(resampTime), 21, NsubDIRs);
grfData = NaN(length(resampTime), 6, NsubDIRs);
emgData = NaN(length(resampTime), 28, NsubDIRs);
grfColNames = ["GRFx Right", "GRFy Right", "GRFz Right", "GRFx Left", "GRFy Left", "GRFz Left"];
kinDim = repmat("°", 21, 1);
kinDim(4:6) = "m";

for i = 1:NsubDIRs
    bestDirInfo = dir(fullfile(solDIR, subDIRs(i), "best/"));
    bestFiles = string({bestDirInfo.name});
    isMAT = contains(bestFiles,".mat");
    matFiles = bestFiles(isMAT); matIterations = double(strrep(extractAfter(matFiles,"bestResult_"),".mat",""));
    [~,bestEverIdx] = max(matIterations);
    bestEverFile = fullfile(solDIR, subDIRs(i), "best/",matFiles(bestEverIdx));
    bestData = load(bestEverFile);
    COTdata(i) = bestData.R.metabolics.Bhargava2004.COT;
    kinData(:,:,i) = interp1(bestData.R.time.mesh_GC(1:end-1)/bestData.R.time.mesh_GC(end-1), bestData.R.kinematics.Qs, resampTime);
    grfData(:,:,i) =  interp1(bestData.R.time.mesh_GC(1:end-1)/bestData.R.time.mesh_GC(end-1), [bestData.R.ground_reaction.GRF_r bestData.R.ground_reaction.GRF_l], resampTime);
    emgData(:,:,i) = interp1(bestData.R.time.mesh_GC(1:end-1)/bestData.R.time.mesh_GC(end-1), bestData.R.muscles.a, resampTime);

    kinColNames = string(bestData.R.colheaders.coordinates);
    emgColNames = string(bestData.R.colheaders.muscles);
    bodyMass = bestData.model_info.mass;
end

% Compute Errors
isTrans = contains(kinColNames,"tx") | contains(kinColNames,"ty") | contains(kinColNames,"tz");
COTErr = rmse(COTdata(1), COTdata(2));
kinErr = rmse(kinData(:,:,1), kinData(:,:,2));
grfErr = rmse(grfData(:,:,1), grfData(:,:,2));
emgErr = rmse(emgData(:,:,1), emgData(:,:,2));

% Print Errors
for i = 1:size(kinErr,2)
    fprintf('RMSE for %s is %.2f %s\n', kinColNames(i), kinErr(i), kinDim(i))
end

for i = 1:size(grfErr,2)
    fprintf('RMSE for %s is %.2f N/kg\n', grfColNames(i), grfErr(i)/bodyMass)
end

for i = 1:size(emgErr,2)
    fprintf('RMSE for %s is %.2f\n', emgColNames(i), emgErr(i))
end

fprintf('RMSE for COT is %.2f J/(kg m)\n', COTErr)
fprintf('average RMSE for (rotational) kinematics is %.2f °\n', mean(kinErr(~isTrans)))
fprintf('average RMSE for GRFs is %.2f N/kg\n', mean(grfErr)/bodyMass)
fprintf('average RMSE for muscle activations is %.2f\n', mean(emgErr))

%% Plot Fitness Evolution
iterations = 1:202;

fig = figure;
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height/1.8])                              % IEEE 1-column: 8.89cm
hold on
for i = 1:size(fhist_all,3)
    plot_mean_std(iterations, mean(fhist_all(:,:,i),1,"omitnan")', std(fhist_all(:,:,i),0,1,"omitnan")', color(:,i)', 1.5, "-")
end
xlim([1 202])
ylim([0 300])
ylabel("Fitness [-]", "FontWeight", "bold")
xlabel("Iterations [-]", "FontWeight", "bold")
legend(["", "Seed 1", "", "Seed 2"], "Box", "off")
title(subjFolder)

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","SansSerif")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position
set(gca,"Position",[1 0.8 fig_width-1.2 fig_height/1.8-1.2])                % axes position (x, y, w, h)

if(export)
    figName = subjFolder + "_fitness_seed_sentivity.pdf";
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Kinematics
boundsSagg = [[-20 40]; % hip
    [-75 10];       % knee      
    [-20 20]];      % ankle

fig = figure;
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height*1.5])                              % IEEE 1-column: 8.89cm
t = tiledlayout(3, 1, "TileSpacing", "tight");
t.InnerPosition = [0.1 0.06 0.88 0.80];
cnt = 1;
for i = [7, 10, 11]
    nexttile
    hold on
    yline(0, "Color", "black", "LineWidth", 0.5)
    plot(resampTime, kinData(:,i,1), "Color", color(:,1), "LineWidth", 1.5)
    plot(resampTime, kinData(:,i,2), "Color", color(:,2), "LineWidth", 1.5)
    title("RMSE: " + round(kinErr(i),2) + "°", "LineWidth", 1.5)
    ylabel(strrep(strrep(kinColNames(i),"_r",""),"_"," ") + " [°]", "FontWeight", "bold")
    ylim(boundsSagg(cnt,:))
    if(i == 11)
        xlabel("Gait Cycle [-]", "FontWeight", "bold")
    end
    cnt = cnt + 1;
end
lg = legend(["","Seed 1", "Seed 2"], "Box", "off", "Orientation", "horizontal", "Location", "bestoutside");
lg.Layout.Tile = "North";
title(t, subjFolder, "FontSize", 8, "FontWeight", "bold")

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","SansSerif")                                    % times new roman font

if(export)
    figName = subjFolder + "_kinematics_seed_sentivity.pdf";
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Optimal Fibre Length Parameter Evolution
fig = figure;
t = tiledlayout(2,7,"TileSpacing","tight");
t.InnerPosition = [0.07 0.08 0.90 0.80];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height])                            % IEEE 1-column: 8.89cm
for i = 1:size(xhist_all,1)/2
    nexttile
    hold on
    for j = 1:size(xhist_all,4)
        scatter(repmat(1:202,10,1),squeeze(xhist_all(i,:,:,j)),1,color(:,j)',"filled")
    end
     title(strrep(muscleNames(i),"_"," "))

    if(ismember(i,[1,size(xhist_all,1)/2+1]))
        ylabel("Length [m]", "FontWeight", "bold")
    end

    if(i > size(xhist_all,1)/2+1)
        xlabel("Iteration [-]", "FontWeight", "bold")
    end
end
title(t, "Optimal Fibre Length", "FontSize", 8)
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position

%% Plot Tendon Slack Length Parameter Evolution
fig = figure;
t = tiledlayout(2,7,"TileSpacing","tight");
t.InnerPosition = [0.07 0.08 0.90 0.80];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height])                            % IEEE 1-column: 8.89cm
for i = size(xhist_all,1)/2+1:size(xhist_all,1)
    nexttile
    hold on
    for j = 1:size(xhist_all,4)
        scatter(repmat(1:202,10,1),squeeze(xhist_all(i,:,:,j)),1,color(:,j)',"filled")
    end
    title(strrep(muscleNames(i-size(xhist_all,1)/2),"_"," "))

    if(ismember(i,[size(xhist_all,1)/2+1,size(xhist_all,1)*3/4+1]))
        ylabel("Length [m]", "FontWeight", "bold")
    end

    if(i > size(xhist_all,1)/2+1)
        xlabel("Iteration [-]", "FontWeight", "bold")
    end
end
title(t, "Tendon Slack Length", "FontSize", 8)
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position