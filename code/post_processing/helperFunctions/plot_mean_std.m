% Plot mean +- 1 standard deviation
function plot_mean_std(time, mean, std, color, lineWidth, lineStyle)

    % Compute 68 % interval bounds
    lower_bound = mean - std;
    upper_bound = mean + std;
    time_shaded = [time fliplr(time)];
    
    shaded = [lower_bound' fliplr(upper_bound')];                               % Deviation shaded area y-values
    fill(time_shaded,shaded,color,"FaceAlpha",0.1,'EdgeColor','none')         % Fill shaded area between mean +/- sigma
    plot(time, mean,"LineWidth",lineWidth,"Color",color,"LineStyle",lineStyle)

end