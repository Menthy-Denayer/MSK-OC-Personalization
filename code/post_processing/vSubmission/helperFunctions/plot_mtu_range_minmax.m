function plot_mtu_range_minmax(figaxes, data, titletxt, xtxt, ytxt, legendtxt, colors, width, deltay)
%% plot_mtu_range_minmax 
% Plot the maximum range of MTU states over the gait cycle
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% figaxes                       | Matlab Figure Handle                      | Handle of the figure to add to
% data                          | Ndata x Nmuscles x Nmethods Double Array  | Data to plot
% titletxt                      | String                                    | Title text
% xtxt                          | String                                    | Xaxis label
% ytxt                          | String                                    | Yaxis label
% legendtxt                     | String                                    | Legend txt (deprecated)
% colors                        | 3 x 1 Double Array                        | Color of the bars
% width                         | Double                                    | Thickness of the bars
% deltay                        | Double                                    | Distance between the centre of the bars
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

%% Parameters
Ndata = size(data,1);
Nmuscles = size(data,2);
Nmethods = size(data,3);

%% Find Min/Max For Each Muscle
min_val = min(min(data, [], 1), [], 3);
max_val = max(max(data, [], 1), [], 3);
plot_val = NaN(Ndata, Nmuscles);

for i = 1:Nmuscles
    plot_val(:,i) = linspace(min_val(i), max_val(i), Ndata);
end

%% Define y-values
% y values to plot MTU range with sufficient space
yval = 1:2:Nmuscles*2; yval = repmat(yval,Ndata,1);

%% Plot Parameters
% width = 8;
legend_txt = strings(Nmuscles*Nmethods,1);
legend_txt(1:Nmuscles:end) = legendtxt;

%% Plot Figure
hold(figaxes, "on")
plot(figaxes, plot_val, yval + deltay,"LineWidth", width, "color", colors)
yticks(figaxes, 1:2:Nmuscles*2)
yticklabels(figaxes, ytxt)
title(figaxes, titletxt)
xlabel(figaxes, xtxt, "FontWeight", "bold")
hold(figaxes, "off")

end