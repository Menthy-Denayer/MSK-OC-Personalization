clear all
clc
close all

%% Load Libraries
addpath("C:\Users\medenaye\Documents\programs\GitHub\OpenSim-Processing\data-processing\utilities")
addpath(pwd + "\helperFunctions")

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = false;

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];   
NSUBJ = length(SUBJID);
Nmuscles = 14;
Nparam = Nmuscles*2;

personalKeyWords = "worker";
resultsSubFolder = repmat("trackKIN-compliantTendon-3D",1,NSUBJ);
resultsSubFolder = resultsSubFolder + "/" + ["SUBJ04mtu3D_02421031", "SUBJ06mtu3D_02452315", "SUBJ07mtu3D_02462103", "SUBJ09mtu3D_02472054", "SUBJ10mtu3D_02491301", "SUBJ11mtu3D_02501441"];
resampTime = 0:0.01:1;
figFileType = ".pdf";

muscleNames = ["ercspn", "intobl", "extobl", "abd", "add", "hamstring", "bifemsh", "glut_max", "iliopsoas", "rect_fem", "vasti", "gastroc", "soleus", "tib_ant"];
% FiberLengthLabels = muscleNames + " lMopt";
% TendonLengthLabels = muscleNames + " lTslack";

colors = [[255,189,144]/255; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255; [0.5, 0.5, 0.5]; [0,85,255]/255];

%% Load Results
ResultsOneDriveDIR = "C:\Users\medenaye\OneDrive - Vrije Universiteit Brussel\PhD-Main\[01] main\WP1\T1.3\[01] results\PredSim";
resultsDIR = uigetdir(ResultsOneDriveDIR,"Choose generic solution directory");

%% Choose Desired Tracking Folders
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);
Nfolders = length(ResultsFolders);

%% Load Results
initialGuess = NaN(Nparam, NSUBJ);
bestGuess = NaN(Nparam, NSUBJ);
lowerBounds = NaN(Nparam, NSUBJ);
upperBounds = NaN(Nparam, NSUBJ);
worstGuess = NaN(Nparam, NSUBJ);

for subj = 1:Nfolders
    currentDIR = resultsDIR+"/"+ResultsFolders(subj);
    if(~isempty(resultsSubFolder))
        currentDIR = currentDIR + "/" + resultsSubFolder(subj);
    end
    dirInfo = dir(currentDIR);
    Files = string({dirInfo.name});
    CMAESdataFile = Files(contains(Files,"variablescmaes") & endsWith(Files,".mat"));
    WorkerParamdataFile = Files(contains(Files,"workerparam") & endsWith(Files,".mat"));

    if(isfile(fullfile(currentDIR,CMAESdataFile)))
        cmaes_data = load(fullfile(currentDIR,CMAESdataFile));

        initialGuess(:,subj) = cmaes_data.input.xstart(1:Nparam);
        bestGuess(:,subj) = cmaes_data.out.solutions.bestever.x(1:Nparam);
        
        lowerBounds(:,subj) = cmaes_data.lbounds(1:Nparam);
        upperBounds(:,subj) = cmaes_data.ubounds(1:Nparam);
    end

    if(isfile(fullfile(currentDIR,WorkerParamdataFile)))
        % worst results
        worker_data = load(fullfile(currentDIR,WorkerParamdataFile));
        [~,worstIdx] = max(worker_data.data.fhist,[],'all');
        worstGuess(:,subj) = worker_data.data.xhist(1:Nparam,worstIdx);
    end
end


%% Load CMA-ES File
% [cmaes_fileName, cmaes_fileDIR] = uigetfile(".mat", "Choose CMA-ES optimization results file");
% cmaes_data = load(fullfile(cmaes_fileDIR,cmaes_fileName));

%% Load Worker File
% [worker_fileName, worker_fileDIR] = uigetfile(".mat", "Choose worker optimization results file");
% worker_data = load(fullfile(worker_fileDIR,worker_fileName));

%% Load Data
% optimal fiber lengths
lMinit = initialGuess(1:Nmuscles,:);
lMopt = bestGuess(1:Nmuscles,:);

% bounds
lMlow = min(lowerBounds(1:Nmuscles,:),[],2);
lMupp = max(upperBounds(1:Nmuscles,:),[],2);

% parameter change
deltalM = (lMopt - lMinit)./lMinit*100;

% tendon slack lengths
lTinit = initialGuess(Nmuscles+1:2*Nmuscles,:);
lTopt = bestGuess(Nmuscles+1:2*Nmuscles,:);

% bounds
lTlow = min(lowerBounds(Nmuscles+1:2*Nmuscles,:),[],2);
lTupp = max(upperBounds(Nmuscles+1:2*Nmuscles,:),[],2);

% parameter change
deltalT = (lTopt - lTinit)./lTinit*100;

% worst results
lMworst = worstGuess(1:Nmuscles,:);
lTworst = worstGuess(Nmuscles+1:2*Nmuscles,:);

%% Plot Settings
% desiderd_muscles = ["hamstring", "bifemsh", "glut_max", "iliopsoas", "rect_fem", "vasti", "gastroc", "soleus", "tib_ant"];
% desiderd_muscles = ["vasti","gastroc", "soleus"];
desiderd_muscles = muscleNames;

isDesiredMuscle = contains(muscleNames,desiderd_muscles);
NdesiredMuscles = length(desiderd_muscles);
rangeWidth = 0.4;
color = ["green", "green", "yellow", "green", "yellow", "yellow", "red"];

legendtxt = strings(1,NdesiredMuscles);
legendtxt = [legendtxt "S" + SUBJID];

%% Plot Optimal Fiber Length (Absolute)
fig = figure;
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/2])                          % IEEE 1-column: 8.89cm
hold on

for i = 1:NdesiredMuscles
    fill([i-rangeWidth i-rangeWidth i+rangeWidth  i+rangeWidth],[lMlow(i) lMupp(i) lMupp(i) lMlow(i)],[0.9, 0.9, 0.9],"FaceAlpha",0.5,'EdgeColor','none')
end

b = bar(1:NdesiredMuscles,lMopt(isDesiredMuscle,:)',"grouped");

for i = 1:NSUBJ
    b(i).FaceColor = 'flat';
    b(i).CData = colors(i,:);
end

for i = 1:Nmuscles
    plot([i-rangeWidth, i+rangeWidth],[lMlow(i), lMlow(i)],"k--")
    plot([i-rangeWidth, i+rangeWidth],[lMupp(i), lMupp(i)],"k--")
end

ylabel("Optimal Fibre Length [m]", "FontWeight", "bold")
ylim([0, 0.22])
xticks(1:NdesiredMuscles)
% xticklabels(strrep(desiderd_muscles,"_"," "))
xticklabels(repmat("", NdesiredMuscles, 1))
ytickformat('%.2f')
% set(gca, "xticklabels", "FontSize", 8)

legend([repmat("", 1, Nmuscles) "S" + SUBJID],"Location","northoutside", "Orientation", "horizontal", "Box", "off")

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
set(0,"DefaultFigureColor","w")                                         % white background
set(0,"defaulttextinterpreter","tex")                                   % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
set(gca,"Units","centimeters")                                          % cm units for position
set(gca,"Position",[1 0.2 fig_width*2-1.2 fig_height/2-1.2])              % axes position (x, y, w, h)
hold off

if(export)
    figName = "personal_gait1422_LMopt" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Tendon Slack Length (Absolute)
fig = figure;
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/2])                          % IEEE 1-column: 8.89cm
hold on

for i = 1:NdesiredMuscles
    fill([i-rangeWidth i-rangeWidth i+rangeWidth  i+rangeWidth],[lTlow(i) lTupp(i) lTupp(i) lTlow(i)],[0.9, 0.9, 0.9],"FaceAlpha",0.5,'EdgeColor','none')
end

b = bar(1:NdesiredMuscles,lTopt(isDesiredMuscle,:)',"grouped");

for i = 1:NSUBJ
    b(i).FaceColor = 'flat';
    b(i).CData = colors(i,:);
end

for i = 1:Nmuscles
    plot([i-rangeWidth, i+rangeWidth],[lTlow(i), lTlow(i)],"k--")
    plot([i-rangeWidth, i+rangeWidth],[lTupp(i), lTupp(i)],"k--")
end

ylabel("Tendon Slack Length [m]", "FontWeight", "bold")
ylim([0, 0.45])
xticks(1:NdesiredMuscles)
xticklabels(strrep(desiderd_muscles,"_"," "))
ytickformat('%.2f')
% legend([repmat("", 1, Nmuscles) "S" + SUBJID],"Location","northoutside", "Orientation", "horizontal", "Box", "off")

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
set(0,"DefaultFigureColor","w")                                         % white background
set(0,"defaulttextinterpreter","tex")                                   % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
set(gca,"Units","centimeters")                                          % cm units for position
set(gca,"Position",[1 1 fig_width*2-1.2 fig_height/2-1.2])              % axes position (x, y, w, h)
hold off

if(export)
    figName = "personal_gait1422_LTopt" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Optimal Fiber Length (Change)
fig = figure;
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
hold on
grid on

for i = 1:NdesiredMuscles
    fill([i-rangeWidth i-rangeWidth i+rangeWidth  i+rangeWidth],[-25 25 25 -25],[0.9, 0.9, 0.9],"FaceAlpha",0.5,'EdgeColor','none')
end

b = bar(1:NdesiredMuscles,deltalM(isDesiredMuscle,:),"grouped");

Y = deltalM(isDesiredMuscle,:);
for i = 1:NSUBJ
    cdata = repmat([0 1 0], NdesiredMuscles, 1);
    cdata(Y(:,i) < 0, :) = repmat([1 0 0], sum(Y(:,i)<0), 1);

    b(i).FaceColor = 'flat';
    b(i).CData = cdata;
end

% for i = 1:Nmuscles
%     plot([i-0.3, i+0.3],[lMlow(i), lMlow(i)],"k--")
%     plot([i-0.3, i+0.3],[lMupp(i), lMupp(i)],"k--")
% end

ylabel("Change [%]")
ylim([-20, 20])
xticks(1:NdesiredMuscles)
xticklabels(strrep(desiderd_muscles,"_"," "))
legend(legendtxt,"Location","bestoutside")
title("Optimal Fiber Lengths")

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
set(0,"DefaultFigureColor","w")                                         % white background
set(0,"defaulttextinterpreter","tex")                                   % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
set(gca,"Units","centimeters")                                          % cm units for position
set(gca,"Position",[0.8 1 fig_width-3.5 fig_height-1.3])              % axes position (x, y, w, h)
hold off

if(export)
    figName = "personal_gait1422_deltaMoptL" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Tendon Slack Length Figure (Change)
fig = figure;
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
hold on
grid on
% for i = 1:Nmuscles
%     fill([i-rangeWidth, i+rangeWidth, i+rangeWidth, i-rangeWidth],[lTlow(i), lTlow(i), lTupp(i), lTupp(i)],"green","FaceAlpha",0.3,"EdgeColor","none")
% end

for i = 1:NdesiredMuscles
    fill([i-rangeWidth i-rangeWidth i+rangeWidth  i+rangeWidth],[-25 25 25 -25],[0.9, 0.9, 0.9],"FaceAlpha",0.5,'EdgeColor','none')
end

b = bar(1:NdesiredMuscles,deltalT(isDesiredMuscle,:),"grouped");

Y = deltalT(isDesiredMuscle,:);
for i = 1:NSUBJ
    cdata = repmat([0 1 0], NdesiredMuscles, 1);
    cdata(Y(:,i) < 0, :) = repmat([1 0 0], sum(Y(:,i)<0), 1);

    b(i).FaceColor = 'flat';
    b(i).CData = cdata;
end

% for i = 1:Nmuscles
%     plot([i-0.3, i+0.3],[lTlow(i), lTlow(i)],"k--")
%     plot([i-0.3, i+0.3],[lTupp(i), lTupp(i)],"k--")
% end

ylabel("Change [%]")
ylim([-20, 20])
xticks(1:NdesiredMuscles)
xticklabels(strrep(desiderd_muscles,"_"," "))
legend(legendtxt,"Location","bestoutside")
title("Tendon Slack Lengths")

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
set(0,"DefaultFigureColor","w")                                         % white background
set(0,"defaulttextinterpreter","tex")                                   % tex style font
set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
set(gca,"Units","centimeters")                                          % cm units for position
set(gca,"Position",[0.8 1 fig_width-3.5 fig_height-1.3])              % axes position (x, y, w, h)

if(export)
    figName = "personal_gait1422_deltaTslackL" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end
hold off