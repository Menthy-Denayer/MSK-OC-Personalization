clear all
clc
close all

%% Import Data Files
resDIR = uigetdir("","Choose point kinematics results directory");

%% Load Data
dirInfo = dir(resDIR);
dirNames = string({dirInfo.name});
files = dirNames(~[dirInfo.isdir]);
Nfiles = length(files);
Ndata = 100;
allDATA = NaN(Ndata,3,Nfiles);

for fileID = 1:Nfiles
    currDATA = importdata(fullfile(resDIR,files(fileID)));
    allDATA(:,:,fileID) = currDATA.data(:,2:end);
end

%% Split Left/Right
rDATA = allDATA(:,:,1:2:end);
lDATA = allDATA(:,:,2:2:end);

%% Compute Distance
distance = NaN(Ndata, Nfiles/2);

for i = 1:Nfiles/2
    distance(:,i) = vecnorm(rDATA(:,[1,3],i)-lDATA(:,[1,3],i),2,2);
end

%% Plot Distance

names = ["calcn", "tibia", "toes"];
bounds = [[0.09, 2]; [0.11, 2]; [0.1 2]];

for i = 1:Nfiles/2
    figure
    hold on
    grid on
    plot(distance(:,i),"k")
    yline(bounds(i,1),"r--")
    yline(bounds(i,2),"r--")
    title(names(i))
    hold off
end


