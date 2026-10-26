function plot_mtu_range(figaxes, data, titletxt, xtxt, ytxt, legendtxt, colors, height, width, deltay)
%% plot_mtu_range 
% Plot the individual range of MTU states over the gait cycle 
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% figaxes                       | Matlab Figure Handle                      | Handle of the figure to add to
% data                          | Ndata x Nmuscles x Nmethods Double Array  | Data to plot
% titletxt                      | String                                    | Title text
% xtxt                          | String                                    | Xaxis label
% ytxt                          | String                                    | Yaxis label
% legendtxt                     | String                                    | Legend txt (deprecated)
% colors                        | 3 x 1 Double Array                        | Color of the bars
% height                        | Double                                    | Height of 1 group of bars
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

%% Define y-values
% y values to plot MTU range with sufficient space
yval = 1:2:Nmuscles*2; yval = repmat(yval,Ndata,1);

%% Plot Parameters

if isempty(height)
    height = 1.5;
end

if isempty(width)
    width = 10/Nmethods;
end

if isempty(deltay)
    deltay = 0;
end

space = height/(Nmethods+1);
legend_txt = strings(Nmuscles*Nmethods,1);
legend_txt(1:Nmuscles:end) = legendtxt;

%% Plot Figure
hold(figaxes, "on")
for i = 1:Nmethods
    plot(figaxes, data(:,:,i), yval-height/2+space*i+deltay,"LineWidth",width, "color", colors(:,i))
end
yticks(figaxes, 1:2:Nmuscles*2)
yticklabels(figaxes, ytxt)
title(figaxes, titletxt)
xlabel(figaxes, xtxt, "FontWeight", "bold")
hold(figaxes, "off")

end