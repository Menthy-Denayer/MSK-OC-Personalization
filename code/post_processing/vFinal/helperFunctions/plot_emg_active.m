function legendTxt = plot_emg_active(time, EMGdata, threshold, color, y1, y2)
%% plot_emg_active 
% Function to generate a gradient of colors 
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% time                          | Ndata x 1 Double Array                    | Time vector
% EMGdata                       | Ndata x 1 Double Array                    | EMG data (0-1)
% threshold                     | Double                                    | Threshold above which EMG is considered active (0-1)
% color                         | 3 x 1 Double Array                        | Color for active bars
% y1                            | Double                                    | Height where to start the bar
% y2                            | Double                                    | Height where to stop the bar
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% legendTxt                     | 1 x Nbars String Array                    | List of empty strings for legend formatting
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026

%% Compute Muscle Active Regions
isActive = EMGdata > threshold;

% Find onsets and offsets
d = diff([0; isActive; 0]);
onsets  = find(d == 1);
offsets = find(d == -1) - 1;

%% Draw shaded rectangles
Nbars = length(onsets);
for i = 1:Nbars
    fill([time(onsets(i)) time(offsets(i)) time(offsets(i)) time(onsets(i))], ...
     [y1 y1 y2 y2], ...
     color, ...
     'EdgeColor','none', ...
     'FaceAlpha',0.8);
end

if(Nbars == 0)
    legendTxt = [];
else
    legendTxt = ["Experimental", repmat("",1,Nbars-1)];
end
end