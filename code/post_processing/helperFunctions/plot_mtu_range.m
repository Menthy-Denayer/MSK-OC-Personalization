function plot_mtu_range(figaxes, data, titletxt, xtxt, ytxt, legendtxt, colors, height, width, deltay)

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
% colors = abs(rand(3,Nmethods));

%% Plot Figure
hold(figaxes, "on")
% grid(figaxes, "on")
for i = 1:Nmethods
    plot(figaxes, data(:,:,i), yval-height/2+space*i+deltay,"LineWidth",width, "color", colors(:,i))
end
yticks(figaxes, 1:2:Nmuscles*2)
yticklabels(figaxes, ytxt)
% legend(figaxes, legend_txt,"Location","bestoutside")
title(figaxes, titletxt)
xlabel(figaxes, xtxt, "FontWeight", "bold")
% ylabel(figaxes, ytxt(1:Nmuscles), "FontWeight", "bold")
hold(figaxes, "off")

end