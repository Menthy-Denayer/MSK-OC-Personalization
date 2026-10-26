% --------------------------------------------------------------------------
% plotPersonalizationSpeedSweep
%   Plot the results of the speed sweep simulations.
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

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];   
NSUBJ = length(SUBJID);
desSpeeds = 0.8:0.1:1.6;
personalKeyWords = "worker";
resultsSubFolder = repmat("trackKIN-compliantTendon-3D",1,NSUBJ);
resultsSubFolder = resultsSubFolder + "/" + ["SUBJ04mtu3D_02421031", "SUBJ06mtu3D_02452315", "SUBJ07mtu3D_02462103", "SUBJ09mtu3D_02472054", "SUBJ10mtu3D_02491301", "SUBJ11mtu3D_02501441"];
resultsSubFolder = resultsSubFolder + "/speedIterations";
trackIGsubFolder = resultsSubFolder + "/trackIG";
expIGsubFolder = resultsSubFolder + "/expIG";
resampTime = 0:0.01:1;

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = false;
figFileType = ".pdf";
linewidth = 1.5;

%% General Variablesc
Ndata = length(resampTime);
Nkincol = 19;
Ngrfcol = 6;
Nemgcol = 28;
Nworkers = 15;
Nspeeds = length(desSpeeds);
emg_col_exp = ["bifemsh_r","hamstrings_r","rect_fem_r","vasti_r","","","gastroc_r","soleus_r","bifemsh_l","hamstrings_l","rect_fem_l","vasti_l","","","gastroc_l","soleus_l"];

%% Load Results
ResultsOneDriveDIR = "C:\Users\medenaye\Documents\programs\GitHub\MSK-OC-Personalization\results";
resultsDIR = uigetdir(ResultsOneDriveDIR,"Choose generic solution directory");

%% Choose Desired Tracking Folders
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);

%% Load Results
% tracking IG
[PersonalKinDataTrackIG, PersonalGrfDataTrackIG, PersonalKitDataTrackIG, PersonalEmgDataTrackIG, PersonalVelDataTrackIG, ...
    ~, PersonalCostDataTrackIG, ~, kinColHeaders, GRFColHeaders, EMGColHeaders] = ...
    average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR,...
    ResultsFolders, trackIGsubFolder, personalKeyWords, Nworkers);

% experimental IG
[PersonalKinDataExpIG, PersonalGrfDataExpIG, PersonalKitDataExpIG, PersonalEmgDataExpIG, PersonalVelDataExpIG, ...
    ~,PersonalCostDataExpIG, ~, ~, ~, ~] = ...
    average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR,...
    ResultsFolders, expIGsubFolder, personalKeyWords, Nworkers);

%% Make Sure Speeds Match
[PersonalKinDataTrackIGfixSpeed, PersonalGrfDataTrackIGfixSpeed, PersonalKitDataTrackIGfixSpeed, PersonalEmgDataTrackIGfixSpeed, PersonalCostDataTrackIGfixSpeed] = ...
    match_correct_speeds(PersonalVelDataTrackIG, PersonalKinDataTrackIG, PersonalGrfDataTrackIG, PersonalKitDataTrackIG, PersonalEmgDataTrackIG, PersonalCostDataTrackIG, desSpeeds);

[PersonalKinDataExpIGfixSpeed, PersonalGrfDataExpIGfixSpeed, PersonalKitDataExpIGfixSpeed, PersonalEmgDataExpIGfixSpeed, PersonalCostDataExpIGfixSpeed] = ...
    match_correct_speeds(PersonalVelDataExpIG, PersonalKinDataExpIG, PersonalGrfDataExpIG, PersonalKitDataExpIG, PersonalEmgDataExpIG, PersonalCostDataExpIG, desSpeeds);

%% Choose Lowest Cost Solution
PersonalCostDataExpIGfixSpeed(isnan(PersonalCostDataExpIGfixSpeed)) = 1e7;
PersonalCostDataTrackIGfixSpeed(isnan(PersonalCostDataTrackIGfixSpeed)) = 1e7;

isExpIGlower = PersonalCostDataExpIGfixSpeed < PersonalCostDataTrackIGfixSpeed;

PersonalKinData = PersonalKinDataTrackIGfixSpeed;
PersonalGrfData = PersonalGrfDataTrackIGfixSpeed;
PersonalKitData = PersonalKitDataTrackIGfixSpeed;
PersonalEmgData = PersonalEmgDataTrackIGfixSpeed;

for i = 1:NSUBJ
    for j = 1:Nspeeds
        if(isExpIGlower(i,j))
            PersonalKinData(:,:,i,j) = PersonalKinDataExpIGfixSpeed(:,:,i,j);
            PersonalGrfData(:,:,i,j) = PersonalGrfDataExpIGfixSpeed(:,:,i,j);
            PersonalKitData(:,:,i,j) = PersonalKitDataExpIGfixSpeed(:,:,i,j);
            PersonalEmgData(:,:,i,j) = PersonalEmgDataExpIGfixSpeed(:,:,i,j);
        end
    end
end

%% Assign EMG Columns
EMGColHeadersLim = EMGColHeaders;                                           % simulation data only for muscle with experimental data
PersonalEmgDataLim = PersonalEmgData;

%% Average Results
PersonalKinDataAvg = mean(PersonalKinData,3,"omitnan");
PersonalKinDataSTD = std(PersonalKinData,0,3,"omitnan");
PersonalGRFDataAvg = mean(PersonalGrfData,3,"omitnan");
PersonalGRFDataSTD = std(PersonalGrfData,0,3,"omitnan");
PersonalKitDataAvg = mean(PersonalKitData,3,"omitnan");
PersonalKitDataSTD = std(PersonalKitData,0,3,"omitnan");
PersonalEmgDataAvg = mean(PersonalEmgData,3,"omitnan");
PersonalEmgDataSTD = std(PersonalEmgData,0,3,"omitnan");

%% Define Labels
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
kinLabels = repmat("[°]",Nkincol,1); kinLabels(isTrans) = "[m]";
grfLabels = repmat("Force [N]", Ngrfcol, 1);
kitLabels = repmat("Joint Moment [Nm]", Nkincol, 1); kitLabels(isTrans) = "Joint Force [N]";
emgLabels = repmat("Muscle Activation [-]", Nemgcol, 1);

jointNames = extractBefore(kinColHeaders,"_"); jointNames = strcat(upper(extractBefore(jointNames,2)), extractAfter(jointNames,1));
kitLabels = jointNames + " " + kitLabels;

muscleNames = extractBefore(EMGColHeaders,"_"); muscleNames = strcat(upper(extractBefore(muscleNames,2)), extractAfter(muscleNames,1));
emgLabels = muscleNames' + " " + emgLabels;
emgLabelsLim = emgLabels;

%% Extract Sagittal Plane Data
isSagittalPlaneKinematics = contains(kinColHeaders,"knee_angle") | contains(kinColHeaders,"hip_flexion") | contains(kinColHeaders,"ankle_angle");
sagittalPlaneCols = 1:Nkincol; sagittalPlaneCols = sagittalPlaneCols(isSagittalPlaneKinematics);

%% Add Labels Directions
kinLabelsExt = strings(Nkincol,2); kinLabelsExt(:,1) = kinLabels;

% ankle
isAnkle = contains(kinColHeaders,"ankle_angle");
kinLabelsExt(isAnkle,:) = [kinLabelsExt(isAnkle,1), repmat("(-) plantarflexion / dorsiflexion (+)",2,1)]; 

% knee
isKnee = contains(kinColHeaders,"knee_angle");
kinLabelsExt(isKnee,:) = [kinLabelsExt(isKnee,1), repmat("(-) flexion / extension (+)",2,1)]; 

% hip
isHip = contains(kinColHeaders,"hip_flexion");
kinLabelsExt(isHip,:) = [kinLabelsExt(isHip,1), repmat("(-) extension / flexion (+)",2,1)]; 

%% Plot Kinematics Results
legendtxt = strings(Nspeeds*2,1);
legendtxt(2:2:end) = string(desSpeeds) + " m/s";
color = makeGroupColors(24/360,Nspeeds,1,0.3,0.95)';

t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.15 0.75 0.75];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.5])                        % IEEE 1-column: 8.89cm

for i = sagittalPlaneCols(1:3)
    nexttile
    hold on
    XaxisLine = plot([0 1],[0 0],"Color","black","LineWidth",0.5);
    for j = 1:Nspeeds
        plot_mean_std(resampTime,PersonalKinDataAvg(:,i,:,j),PersonalKinDataSTD(:,i,:,j),color(:,j)', linewidth,"-")
    end

    if(isHip(i))
        % draw arrows
        draw_arrow(0.2, 0.2, 28, 35, 2, 0.02, "black")
        draw_arrow(0.65, 0.65, -8, -15, 2, 0.02, "black")
        
    elseif(isKnee(i))
        % draw arrows
        draw_arrow(0.3, 0.3, -15, -25, 2, 0.02, "black")
        draw_arrow(0.55, 0.55, -60, -68, 2, 0.02, "black")

    elseif(isAnkle(i))
        % draw arrows
        draw_arrow(0.6, 0.6, 13, 9, 0.7, 0.02, "black")
        draw_arrow(0.5, 0.5, -5, -8, 0.7, 0.02, "black")
    end

    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(kinLabelsExt(i,:),"FontWeight","bold")
    title(jointNames(i) + " Joint Angle")

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
    axis tight
end

lg = legend([""; legendtxt],"Location","bestoutside");
lg.Layout.Tile = 'East';
lg.Box = "off";
set(findall(t,'-property','FontSize'),'FontSize',8)                   % font size

if(export)
    figName = "personal_gait2128_kin_speedSweep" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Kinematics (seperate)
kin_color = makeGroupColors(24/360,Nspeeds,1,0.3,0.95)';
kin_legendtxt = string(desSpeeds) + " m/s";

for j = 1:NSUBJ
    fig = figure;
    t = tiledlayout(figure(j), 2, 3);  
    for i = sagittalPlaneCols
        nexttile
        grid on
        hold on
        for k = 1:Nspeeds
            plot(resampTime,PersonalKinData(:,i,j,k),"Color",kin_color(:,k)',"LineWidth", 1)
        end
        xlabel("Gait Cycle [-]")
        ylabel(kinLabels(i))
    end
    legend(kin_legendtxt,"Location","best")
    title(t,"SUBJECT " + num2str(SUBJID(j)))

    % figure settings
    set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
end

%% Plot Ground Reaction Forces
for i = 1:Ngrfcol
    fig = figure;
    set(gcf,"Units","centimeters")                                          % cm units for position
    set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    grid on
    hold on
    for j = 1:Nspeeds
        plot_mean_std(resampTime,PersonalGRFDataAvg(:,i,:,j),PersonalGRFDataSTD(:,i,:,j),color(:,j)', 1, "-")
    end
    legend(legendtxt,"Location","bestoutside")
    xlabel("Gait Cycle [-]")
    ylabel(grfLabels(i))
    title(GRFColHeaders(i))
    
    % figure settings
    set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
    set(gca,"Units","centimeters")                                          % cm units for position
    set(gca,"Position",[1.2 0.8 fig_width-4.5 fig_height-1.5])              % axes position (x, y, w, h)
    hold off
    axis tight

    if(export)
        figName = "personal_gait1422_grf_speedSweep_" + GRFColHeaders(i) + figFileType;
        exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    end
end

%% Plot Joint Moments
isAnkle = contains(kinColHeaders,"ankle");
fixSign = ones(Nkincol,1);
fixSign(isAnkle) = -1;

for i = sagittalPlaneCols
    fig = figure;
    set(gcf,"Units","centimeters")                                          % cm units for position
    set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    grid on
    hold on
    for j = 1:Nspeeds
        plot_mean_std(resampTime,PersonalKitDataAvg(:,i,:,j)*fixSign(i),PersonalKitDataSTD(:,i,:,j),color(:,j)', 1, "-")
    end
    legend(legendtxt,"Location","bestoutside")
    xlabel("Gait Cycle [-]")
    ylabel(kitLabels(i))
    title(strrep(kinColHeaders(i),"_"," ") + " Joint Moment")

    % figure settings
    set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
    set(gca,"Units","centimeters")                                          % cm units for position
    set(gca,"Position",[1.2 0.8 fig_width-4.5 fig_height-1.5])              % axes position (x, y, w, h)
    hold off
    axis tight

    if(export)
        figName = "personal_gait1422_kit_speedSweep_" + kinColHeaders(i) + "_moment"  + figFileType;
        exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    end
end

%% Plot Muscle Activations
NemgcolLim = length(EMGColHeadersLim);
for i = 1:NemgcolLim/2
    fig = figure;
    set(gcf,"Units","centimeters")                                          % cm units for position
    set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    grid on
    hold on
    for j = 1:Nspeeds
        plot_mean_std(resampTime,PersonalEmgDataAvg(:,i,:,j),PersonalEmgDataSTD(:,i,:,j),color(:,j)', 1, "-")
    end
    legend(legendtxt,"Location","bestoutside")
    xlabel("Gait Cycle [-]")
    ylabel(emgLabels(i))
    title(strrep(EMGColHeadersLim(i),"_"," "))

    % figure settings
    set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
    set(gca,"Units","centimeters")                                          % cm units for position
    set(gca,"Position",[1.2 0.8 fig_width-4.5 fig_height-1.5])              % axes position (x, y, w, h)
    hold off
    axis tight

    if(export)
        figName = "personal_gait1422_emg_speedSweep_" + EMGColHeadersLim(i) + "_moment"  + figFileType;
        exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    end
end

function [kinDataFixSpeed, grfDataFixSpeed, kitDataFixSpeed, emgDataFixSpeed, costDataFixSpeed] = match_correct_speeds(velData, kinData, grfData, kitData, emgData, costData, desSpeeds)

% define variables
Nspeeds = length(desSpeeds);
Ndata = size(kinData,1);
Nkincol = size(kinData,2);
NSUBJ = size(kinData,3);
Ngrfcol = size(grfData,2);
Nemgcol = size(emgData,2);

% create new matrices
kinDataFixSpeed = NaN(Ndata, Nkincol, NSUBJ, Nspeeds);
grfDataFixSpeed = NaN(Ndata, Ngrfcol, NSUBJ, Nspeeds);
kitDataFixSpeed = NaN(Ndata, Nkincol, NSUBJ, Nspeeds);
emgDataFixSpeed = NaN(Ndata, Nemgcol, NSUBJ, Nspeeds);
costDataFixSpeed = NaN(NSUBJ, Nspeeds);

for i = 1:NSUBJ
    [isSpeed,correctIdx] = ismember(round(velData(i,:),1), round(desSpeeds,1));
    kinDataFixSpeed(:,:,i,correctIdx(correctIdx>0)) = kinData(:,:,i,isSpeed);
    grfDataFixSpeed(:,:,i,correctIdx(correctIdx>0)) = grfData(:,:,i,isSpeed);
    kitDataFixSpeed(:,:,i,correctIdx(correctIdx>0)) = kitData(:,:,i,isSpeed);
    emgDataFixSpeed(:,:,i,correctIdx(correctIdx>0)) = emgData(:,:,i,isSpeed);
    costDataFixSpeed(i,correctIdx(correctIdx>0)) = costData(i,isSpeed);
end

end