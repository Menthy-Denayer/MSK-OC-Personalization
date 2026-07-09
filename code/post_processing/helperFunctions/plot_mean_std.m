function plot_mean_std(time, mean, std, color, lineWidth, lineStyle)
%% plot_mean_std 
% Plot mean +- 1 standard deviation 
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% time                          | Ndata x 1 Double Array                    | Time vector
% mean                          | Ndata x 1 Double Array                    | Average data
% std                           | Ndata x 1 Double Array                    | Standard deviation data
% color                         | 3 x 1 Double Array                        | Color
% lineWidth                     | Double                                    | Line width
% lineStyle                     | String                                    | Matlab line style
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% 
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026

%% Compute 68 % interval bounds
lower_bound = mean - std;
upper_bound = mean + std;
time_shaded = [time fliplr(time)];

%% Create Plot
shaded = [lower_bound' fliplr(upper_bound')];                               % Deviation shaded area y-values
fill(time_shaded,shaded,color,"FaceAlpha",0.1,'EdgeColor','none')           % Fill shaded area between mean +/- sigma
plot(time, mean,"LineWidth",lineWidth,"Color",color,"LineStyle",lineStyle)

end