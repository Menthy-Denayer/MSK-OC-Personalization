clear all
clc
close all

% opts = cmaes('defaults');
% % opts.SaveVariables = 'on';
% [xmin, fmin] = cmaes('testobjective', randn(10,1), 0.5, opts);

data1 = importdata("C:\Users\menth\OneDrive - Vrije Universiteit Brussel\PhD-Main\[01] main\WP1\T1.3\[03] data\SUBJ11\SUBJ11_gait1422_vTrackCost3e7-1GC.mot");
data2 = importdata("C:\Users\menth\OneDrive - Vrije Universiteit Brussel\PhD-Main\[01] main\WP1\T1.3\[03] data\SUBJ07\SUBJ07_gait1422_vTrack5e7Cost-1GC.mot");
data3 = importdata("C:\Users\menth\OneDrive - Vrije Universiteit Brussel\PhD-Main\[01] main\WP1\T1.3\[03] data\SUBJ04\SUBJ04_gait1422-kinTracking-PredSim-1GC.mot");

Ndata = size(data1.data,2);
time1 = data1.data(:,1);
time2 = data2.data(:,1);
time3 = data3.data(:,1);

for i = 1:19

    figure
    hold on
    plot(time1,data1.data(:,i+1),"red")
    plot(time2,data2.data(:,i+1),"blue")
    plot(time3,data3.data(:,i+1),"magenta")
    title(strrep(string(data1.colheaders(i+1)),"_"," "))
    legend(["SUBJ11","SUBJ07","SUBJ04"])
    hold off

end


