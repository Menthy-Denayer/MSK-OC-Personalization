function colors = makeGroupColors(hue, n, S, Vmin, Vmax)
%% makeGroupColors 
% Function to generate a gradient of colors 
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% hue                           | Double                                    | Hue value
% n                             | Double                                    | Number of colors to generate
% S                             | Double                                    | Saturation value
% Vmin                          | Double                                    | Min value
% Vmax                          | Double                                    | Max value
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% colors                        | n x 3 Double Array                        | Color matrix
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026

%% Create Colors
V = linspace(Vmin, Vmax, n);        % light → dark
colors = hsv2rgb([ ...
    hue*ones(n,1), ...
    S*ones(n,1), ...
    V' ]);

end