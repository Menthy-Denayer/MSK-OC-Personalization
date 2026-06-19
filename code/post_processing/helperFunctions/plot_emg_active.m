function legendTxt = plot_emg_active(time, EMGdata, threshold, color, y1, y2)

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