% --------------------------------------------------------------------------
% processIKresults
%   combines the IK, GRF and sEMG data inside a structure
%
% Original author: Menthy Denayer
% Original date: 12/Oct/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 25/Oct/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Add Path
% general data processing
addpath("..\post_processing\vFinal\helperFunctions\") 

%% Define Variables
resampTime = 0:0.01:1;
Ndata = length(resampTime);
exportFigure = false;
resFileName = "MAT_normalizedIKData-gait2128-vOct2026.mat";

lowpassSettings.lowpassFreq = 6;                                            % default in OpenSim
lowpassSettings.lowpassFilterOrder = 2;                                     % default in OpenSim

%% Load Existing Data
% File containing EMG data already processed before
[prev_mat_file_name, prev_mat_file_loc] = uigetfile(".mat","Choose existing data .mat file to process");
procData = load(fullfile(prev_mat_file_loc,prev_mat_file_name));

%% Load Events File
% File containing heel strike events for both legs
[mat_file_name, mat_file_loc] = uigetfile(".mat","Choose events .mat file to process");
gaitEvents = load(fullfile(mat_file_loc,mat_file_name));

% Check empty events
expNames = string(fieldnames(gaitEvents.events));
for i = 1:length(expNames)
    if(isempty(gaitEvents.events.(expNames(i)).LHeelStrike))
        fprintf(['Empty gait events for: ' char(expNames(i)) '\n'])
    end
end

%% Load MOT Kinematics Data
% results of IK
ikDir = uigetdir("..\..\data\Inverse Kinematics","Choose directory with kinematics .mot files to process");
dirInfo = struct2table(dir(ikDir));
[~,~,kinFileExtensions] = fileparts(dirInfo.name);
ikFiles = string(dirInfo.name(ismember(kinFileExtensions, ".mot")));
isWalking = contains(ikFiles,"walking","IgnoreCase",true);
ikFiles = ikFiles(isWalking);
NkinFiles = length(ikFiles); 
SUBJID = split(ikFiles(1),"_"); SUBJID = double(strrep(SUBJID(1),"SUBJ",""));

%% Load MOT GRF Data
% results of IK
grfDir = uigetdir("..\..\data\Experimental Data","Choose directory with grf .mot files to process");
dirInfo = struct2table(dir(grfDir));
[~,~,grfFileExtensions] = fileparts(dirInfo.name);
grfFiles = string(dirInfo.name(ismember(grfFileExtensions, ".mot")));
NgrfFiles = length(grfFiles); 

%% Check Equal Number of GRF/Kinematics Files
assert(NgrfFiles == NkinFiles)

%% Find Kinematics Labels
% import first kinematics file to find IK labels
IKstruct = importdata(fullfile(ikDir,ikFiles(1)));
desKINColumns = string(IKstruct.colheaders);
NkinCol = length(desKINColumns);

%% Find GRF Labels
desGRFColumns = ["time", "ground_force_r_vx", "ground_force_r_vy", "ground_force_r_vz", "ground_force_l_vx", "ground_force_l_vy", "ground_force_l_vz"];
NgrfCol = length(desGRFColumns);

%% Align MOT Kinematics Data
% 0->100% of gait cycle
IKdataTot = NaN(Ndata, NkinCol-1, NkinFiles);                               % time data excluded

f = waitbar(0, 'Processing data...');
for fileIdx = 1:NkinFiles
    expName = split(ikFiles(fileIdx),"_markers_ik.mot"); 
    expName = expName(1);
    RHeelStrike = gaitEvents.events.(expName).RHeelStrike;
    LHeelStrike = gaitEvents.events.(expName).LHeelStrike;
    
    waitbar(fileIdx/NkinFiles, f, ['Processing file: ' num2str(fileIdx) '/' num2str(NkinFiles)])

    if(~isempty(RHeelStrike))
        % IK results
        try
            fprintf(['Processing kinematics file: ' char(replace(ikFiles(fileIdx),"_"," ")) ' (' num2str(fileIdx) '/' num2str(NkinFiles) ')\n'])
            IKdata = processData(fullfile(ikDir,ikFiles(fileIdx)), desKINColumns, LHeelStrike, RHeelStrike, resampTime, "_l", lowpassSettings);

            % assign data
            IKdataTot(:,:,fileIdx) = IKdata;
        catch
            fprintf('No IK files found to process.\n')
        end
        
    end
end
close(f)

%% Align MOT GRF Data
% 0->100% of gait cycle
GRFdataTot = NaN(Ndata, NgrfCol-1, NgrfFiles);                              % time data excluded

f = waitbar(0, 'Processing data...');
for fileIdx = 1:NgrfFiles
    expName = split(grfFiles(fileIdx),"_forces_COP.mot"); 
    expName = expName(1);
    RHeelStrike = gaitEvents.events.(expName).RHeelStrike;
    LHeelStrike = gaitEvents.events.(expName).LHeelStrike;

    waitbar(fileIdx/NkinFiles, f, ['Processing file: ' num2str(fileIdx) '/' num2str(NkinFiles)])

    if(~isempty(RHeelStrike))
        % GRF results
        try
            fprintf(['Processing grf file: ' char(replace(grfFiles(fileIdx),"_"," ")) ' (' num2str(fileIdx) '/' num2str(NgrfFiles) ')\n'])
            GRFdata = processData(fullfile(grfDir,grfFiles(fileIdx)), desGRFColumns, LHeelStrike, RHeelStrike, resampTime, "_l_", []);

            % assign data
            GRFdataTot(:,:,fileIdx) = GRFdata;
        catch
            fprintf('No GRF files found to process.\n')
        end

    end
end
close(f)

%% Split Data in Normal & Weighted Walking
% find normal/weighted indices
normalWalkingIdx = contains(ikFiles,"Normal");
weightedWalking1kgIdx = contains(ikFiles,"1kg");
weightedWalking2kgIdx = contains(ikFiles,"2kg");
weightedWalking3kgIdx = contains(ikFiles,"3kg");
weightedWalking4kgIdx = contains(ikFiles,"4kg");
weightedWalking5kgIdx = contains(ikFiles,"5kg");

% split kinematics data into seperate arrays
IKdataTotNormal = IKdataTot(:,:,normalWalkingIdx);
IKdataTotWeighted1kg = IKdataTot(:,:,weightedWalking1kgIdx);
IKdataTotWeighted2kg = IKdataTot(:,:,weightedWalking2kgIdx);
IKdataTotWeighted3kg = IKdataTot(:,:,weightedWalking3kgIdx);
IKdataTotWeighted4kg = IKdataTot(:,:,weightedWalking4kgIdx);
IKdataTotWeighted5kg = IKdataTot(:,:,weightedWalking5kgIdx);

% split GRF data into seperate arrays
GRFdataTotNormal = GRFdataTot(:,:,normalWalkingIdx);
GRFdataTotWeighted1kg = GRFdataTot(:,:,weightedWalking1kgIdx);
GRFdataTotWeighted2kg = GRFdataTot(:,:,weightedWalking2kgIdx);
GRFdataTotWeighted3kg = GRFdataTot(:,:,weightedWalking3kgIdx);
GRFdataTotWeighted4kg = GRFdataTot(:,:,weightedWalking4kgIdx);
GRFdataTotWeighted5kg = GRFdataTot(:,:,weightedWalking5kgIdx);

%% Compute Mean & STD
% mean & std kinematics 
meanKinNormalWalking = mean(IKdataTotNormal,3,"omitnan");
meanKinWeightedWalking1kg = mean(IKdataTotWeighted1kg,3,"omitnan");
meanKinWeightedWalking2kg = mean(IKdataTotWeighted2kg,3,"omitnan");
meanKinWeightedWalking3kg = mean(IKdataTotWeighted3kg,3,"omitnan");
meanKinWeightedWalking4kg = mean(IKdataTotWeighted4kg,3,"omitnan");
meanKinWeightedWalking5kg = mean(IKdataTotWeighted5kg,3,"omitnan");

stdKinNormalWalking = std(IKdataTotNormal,0,3,"omitnan");
stdKinWeightedWalking1kg = std(IKdataTotWeighted1kg,0,3,"omitnan");
stdKinWeightedWalking2kg = std(IKdataTotWeighted2kg,0,3,"omitnan");
stdKinWeightedWalking3kg = std(IKdataTotWeighted3kg,0,3,"omitnan");
stdKinWeightedWalking4kg = std(IKdataTotWeighted4kg,0,3,"omitnan");
stdKinWeightedWalking5kg = std(IKdataTotWeighted5kg,0,3,"omitnan");

% mean & std GRFs 
meanGRFNormalWalking = mean(GRFdataTotNormal,3,"omitnan");
meanGRFWeightedWalking1kg = mean(GRFdataTotWeighted1kg,3,"omitnan");
meanGRFWeightedWalking2kg = mean(GRFdataTotWeighted2kg,3,"omitnan");
meanGRFWeightedWalking3kg = mean(GRFdataTotWeighted3kg,3,"omitnan");
meanGRFWeightedWalking4kg = mean(GRFdataTotWeighted4kg,3,"omitnan");
meanGRFWeightedWalking5kg = mean(GRFdataTotWeighted5kg,3,"omitnan");

stdGRFNormalWalking = std(GRFdataTotNormal,0,3,"omitnan");
stdGRFWeightedWalking1kg = std(GRFdataTotWeighted1kg,0,3,"omitnan");
stdGRFWeightedWalking2kg = std(GRFdataTotWeighted2kg,0,3,"omitnan");
stdGRFWeightedWalking3kg = std(GRFdataTotWeighted3kg,0,3,"omitnan");
stdGRFWeightedWalking4kg = std(GRFdataTotWeighted4kg,0,3,"omitnan");
stdGRFWeightedWalking5kg = std(GRFdataTotWeighted5kg,0,3,"omitnan");

%% Create Figure
% Figure properties
colors = [repmat("blue",1,5) repmat("red",1,5)];
expName = split(ikFiles,"_markers_ik.mot"); 
expName = expName(:,1);
fileType = "png";

%% Kinematics Plot
% % time series figure
% for i = 1:NkinCol-1                           
% 
%     fig = figure;
%     hold on
%     grid on
%     for j = 1:size(IKdataTotNormal,3)
%         plot(resampTime, IKdataTotNormal(:,i,j), "blue")
%         plot(resampTime, IKdataTotWeighted1kg(:,i,j), "Color", [0,0,0])
%         plot(resampTime, IKdataTotWeighted2kg(:,i,j), "Color", [0.25,0,0])
%         plot(resampTime, IKdataTotWeighted3kg(:,i,j), "Color", [0.50,0,0])
%         plot(resampTime, IKdataTotWeighted4kg(:,i,j), "Color", [0.75,0,0])
%         plot(resampTime, IKdataTotWeighted5kg(:,i,j), "Color", [1,0,0])
%     end
% 
%     xlabel("Gait Cycle [%]")
%     ylabel("Joint Angle [°]")
%     legend(["" "Normal" "" "Weighted 1kg" "" "Weighted 2kg" "" "Weighted 3kg" "" "Weighted 4kg" "" "Weighted 5kg"], 'Location', 'best')
%     title(replace(desKINColumns(i+1),"_"," "))
%     hold off
% end

%% GRF Plot
% % time series figure
% for i = 1:NgrfCol-1                           
% 
%     fig = figure;
%     hold on
%     grid on
%     for j = 1:size(GRFdataTotNormal,3)
%         plot(resampTime, GRFdataTotNormal(:,i,j), "blue")
%         plot(resampTime, GRFdataTotWeighted1kg(:,i,j), "Color", [0,0,0])
%         plot(resampTime, GRFdataTotWeighted2kg(:,i,j), "Color", [0.25,0,0])
%         plot(resampTime, GRFdataTotWeighted3kg(:,i,j), "Color", [0.50,0,0])
%         plot(resampTime, GRFdataTotWeighted4kg(:,i,j), "Color", [0.75,0,0])
%         plot(resampTime, GRFdataTotWeighted5kg(:,i,j), "Color", [1,0,0])
%     end
% 
%     xlabel("Gait Cycle [%]")
%     ylabel("Force [N]")
%     legend(["" "Normal" "" "Weighted 1kg" "" "Weighted 2kg" "" "Weighted 3kg" "" "Weighted 4kg" "" "Weighted 5kg"], 'Location', 'best')
%     title(replace(desGRFColumns(i+1),"_"," "))
%     hold off
% end

%% Load Existing Data
% load existing EMG data
EMGdataTotNormal = procData.data.("SUBJ"+SUBJID).EMG.EMGdataNormal;
EMGdataTotWeighted1kg = procData.data.("SUBJ"+SUBJID).EMG.EMGdataWeighted1kg;
EMGdataTotWeighted2kg = procData.data.("SUBJ"+SUBJID).EMG.EMGdataWeighted2kg;
EMGdataTotWeighted3kg = procData.data.("SUBJ"+SUBJID).EMG.EMGdataWeighted3kg;
EMGdataTotWeighted4kg = procData.data.("SUBJ"+SUBJID).EMG.EMGdataWeighted4kg;
EMGdataTotWeighted5kg = procData.data.("SUBJ"+SUBJID).EMG.EMGdataWeighted5kg;

%% Save Data
% load previous data
data = load(resFileName);
data = data.data;

% % save headers
% data.headers.kinematics = desKINColumns(2:end);
% data.headers.GRF = desGRFColumns(2:end);
% data.headers.EMG = procData.data.headers.EMG;
% 
% % save kinematics
% data.("SUBJ" + SUBJID).kinematics.IkdataNormal = IKdataTotNormal;
% data.("SUBJ" + SUBJID).kinematics.IkdataWeighted1kg = IKdataTotWeighted1kg;
% data.("SUBJ" + SUBJID).kinematics.IkdataWeighted2kg = IKdataTotWeighted2kg;
% data.("SUBJ" + SUBJID).kinematics.IkdataWeighted3kg = IKdataTotWeighted3kg;
% data.("SUBJ" + SUBJID).kinematics.IkdataWeighted4kg = IKdataTotWeighted4kg;
% data.("SUBJ" + SUBJID).kinematics.IkdataWeighted5kg = IKdataTotWeighted5kg;
% 
% % save EMG
% data.("SUBJ" + SUBJID).EMG.EMGdataNormal = EMGdataTotNormal;
% data.("SUBJ" + SUBJID).EMG.EMGdataWeighted1kg = EMGdataTotWeighted1kg;
% data.("SUBJ" + SUBJID).EMG.EMGdataWeighted2kg = EMGdataTotWeighted2kg;
% data.("SUBJ" + SUBJID).EMG.EMGdataWeighted3kg = EMGdataTotWeighted3kg;
% data.("SUBJ" + SUBJID).EMG.EMGdataWeighted4kg = EMGdataTotWeighted4kg;
% data.("SUBJ" + SUBJID).EMG.EMGdataWeighted5kg = EMGdataTotWeighted5kg;
% 
% % save GRF
% data.("SUBJ" + SUBJID).GRF.GRFdataNormal = GRFdataTotNormal;
% data.("SUBJ" + SUBJID).GRF.GRFdataWeighted1kg = GRFdataTotWeighted1kg;
% data.("SUBJ" + SUBJID).GRF.GRFdataWeighted2kg = GRFdataTotWeighted2kg;
% data.("SUBJ" + SUBJID).GRF.GRFdataWeighted3kg = GRFdataTotWeighted3kg;
% data.("SUBJ" + SUBJID).GRF.GRFdataWeighted4kg = GRFdataTotWeighted4kg;
% data.("SUBJ" + SUBJID).GRF.GRFdataWeighted5kg = GRFdataTotWeighted5kg;

% save(resFileName,"data")

%% Check Data
sum(rmse(IKdataTotNormal, data.("SUBJ" + SUBJID).kinematics.IkdataNormal),"all")
sum(rmse(IKdataTotWeighted1kg, data.("SUBJ" + SUBJID).kinematics.IkdataWeighted1kg),"all")
sum(rmse(IKdataTotWeighted2kg, data.("SUBJ" + SUBJID).kinematics.IkdataWeighted2kg),"all")
sum(rmse(IKdataTotWeighted3kg, data.("SUBJ" + SUBJID).kinematics.IkdataWeighted3kg),"all")
sum(rmse(IKdataTotWeighted4kg, data.("SUBJ" + SUBJID).kinematics.IkdataWeighted4kg),"all")
sum(rmse(IKdataTotWeighted5kg, data.("SUBJ" + SUBJID).kinematics.IkdataWeighted5kg),"all")

sum(rmse(EMGdataTotNormal, data.("SUBJ" + SUBJID).EMG.EMGdataNormal),"all","omitnan")
sum(rmse(EMGdataTotWeighted1kg, data.("SUBJ" + SUBJID).EMG.EMGdataWeighted1kg),"all","omitnan")
sum(rmse(EMGdataTotWeighted2kg, data.("SUBJ" + SUBJID).EMG.EMGdataWeighted2kg),"all","omitnan")
sum(rmse(EMGdataTotWeighted3kg, data.("SUBJ" + SUBJID).EMG.EMGdataWeighted3kg),"all","omitnan")
sum(rmse(EMGdataTotWeighted4kg, data.("SUBJ" + SUBJID).EMG.EMGdataWeighted4kg),"all","omitnan")
sum(rmse(EMGdataTotWeighted5kg, data.("SUBJ" + SUBJID).EMG.EMGdataWeighted5kg),"all","omitnan")

sum(rmse(GRFdataTotNormal, data.("SUBJ" + SUBJID).GRF.GRFdataNormal),"all")
sum(rmse(GRFdataTotWeighted1kg, data.("SUBJ" + SUBJID).GRF.GRFdataWeighted1kg),"all")
sum(rmse(GRFdataTotWeighted2kg, data.("SUBJ" + SUBJID).GRF.GRFdataWeighted2kg),"all")
sum(rmse(GRFdataTotWeighted3kg, data.("SUBJ" + SUBJID).GRF.GRFdataWeighted3kg),"all")
sum(rmse(GRFdataTotWeighted4kg, data.("SUBJ" + SUBJID).GRF.GRFdataWeighted4kg),"all")
sum(rmse(GRFdataTotWeighted5kg, data.("SUBJ" + SUBJID).GRF.GRFdataWeighted5kg),"all")


% for i = 1:size(IKdataTotNormal,2)
%     figure 
%     hold on
%     plot(squeeze(data.SUBJ11.kinematics.IkdataNormal(:,i,:)),"black")
%     plot(squeeze(IKdataTotNormal(:,i,:)),"red--")
% end

%% Functions
function plot_mean_std(time, mean, std, color)

% Compute 68 % interval bounds
lower_bound = mean - std;
upper_bound = mean + std;
time_shaded = [time fliplr(time)];

shaded = [lower_bound' fliplr(upper_bound')];                               % Deviation shaded area y-values
fill(time_shaded,shaded,"black","FaceAlpha",0.1,'EdgeColor','none')         % Fill shaded area between mean +/- sigma
plot(time, mean,"LineWidth",1,"Color",color)

end


function idx = findTimeIdx(timeVector, timePoint)
    [dist,idx] = min(abs(timeVector-timePoint));
    if(dist > 0.5)
        warning(['Time distance is larger than 0.5 (' num2str(dist) ')!'])
        idx = 1;
    end
end

function procData = processData(fileName, desCol, LHeelStrike, RHeelStrike, resampTime, delim, lowpassSettings)
    % import data
    Datastruct = importdata(fileName);
    Rawdata = Datastruct.data;
    Datacolumns = Datastruct.colheaders;
    [~,colIdx] = ismember(desCol, Datacolumns); colIdx = colIdx(colIdx>0);
    Rawdata = Rawdata(:,colIdx);
    Time = Rawdata(:,1);

    % split left/right
    isLeft = contains(desCol,delim,"IgnoreCase",true) & ~contains(desCol,"pelvis","IgnoreCase",true);
    isRight = ~isLeft; isRight(1) = 0;                                       % ignore time

    % create empty matrix to store processed data
    Ncol = size(Rawdata,2);
    Nrow = length(resampTime);
    procData = NaN(Nrow, Ncol);

    % filter data
    if(~isempty(lowpassSettings))
        FS = 1/(Time(2) - Time(1));
        FilteredData = Rawdata;
        FilteredData(:,2:end) = lowpassFilterWrapper(Rawdata(:,2:end), FS, lowpassSettings);
    else
        FilteredData = Rawdata;
    end

    % find heel strike times
    startTimeR = RHeelStrike(1);
    endTimeR = RHeelStrike(2);
    startTimeL = LHeelStrike(1);
    endTimeL = LHeelStrike(2);

    % find indices
    startIdxR = findTimeIdx(Time, startTimeR);
    endIdxR = findTimeIdx(Time, endTimeR);
    startIdxL = findTimeIdx(Time, startTimeL);
    endIdxL = findTimeIdx(Time, endTimeL);

    % get left/right data
    RightTime = Time(startIdxR:endIdxR); RightDuration = (RightTime(end) - RightTime(1));
    newRightTime = (RightTime - RightTime(1))/RightDuration;

    LeftTime = Time(startIdxL:endIdxL); LeftDuration = (LeftTime(end) - LeftTime(1));
    newLeftTime = (LeftTime - LeftTime(1))/LeftDuration;

    RightData = FilteredData(startIdxR:endIdxR,isRight);
    LeftData = FilteredData(startIdxL:endIdxL,isLeft);

    % resample data
    procData(:,isRight) = interp1(newRightTime, RightData, resampTime);
    procData(:,isLeft) = interp1(newLeftTime, LeftData, resampTime);

    % Fix Plevis Heading
    isPelvisTx = contains(desCol,"pelvis_tx");
    if(any(isPelvisTx))
        shiftTx = procData(1,isPelvisTx);
        procData(:,isPelvisTx) = procData(:,isPelvisTx)-shiftTx;
    end

    isPelvisTz = contains(desCol,"pelvis_tz");
    if(any(isPelvisTz))
        shiftTz = procData(1,isPelvisTz);
        procData(:,isPelvisTz) = procData(:,isPelvisTz)-shiftTz;
    end
      
    procData = procData(:,2:end);

end

function filteredData = lowpassFilterWrapper(data, Fs, settings)
Ntrials = size(data,3);
filteredData = NaN(size(data));

for i = 1:Ntrials
    filteredData(:,:,i) = lowpassFilter(data(:,:,i), Fs, settings);
end

% debug
% for i = 1:size(data,2)
%     figure
%     hold on
%     plot(data(:,i),"black")
%     plot(filteredData(:,i),"red--")
%     hold off
% end

end