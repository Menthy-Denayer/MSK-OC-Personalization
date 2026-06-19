function plot_mtu_range_minmax(figaxes, data, titletxt, xtxt, ytxt, legendtxt, colors, width, deltay)

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
% colors = abs(rand(3,Nmethods));

%% Plot Figure
hold(figaxes, "on")
plot(figaxes, plot_val, yval + deltay,"LineWidth", width, "color", colors)
yticks(figaxes, 1:2:Nmuscles*2)
yticklabels(figaxes, ytxt)
% legend(figaxes, legend_txt,"Location","bestoutside")
title(figaxes, titletxt)
xlabel(figaxes, xtxt, "FontWeight", "bold")
% ylabel(figaxes, ytxt(1:Nmuscles), "FontWeight", "bold")
hold(figaxes, "off")

end