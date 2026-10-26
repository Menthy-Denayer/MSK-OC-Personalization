function draw_arrow(x1, x2, y1, y2, alpha, beta, color)
%% draw_arrow 
% Draws custom arrow for plotting
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% x1                        | Double                                        | x-coordinate start
% x2                        | Double                                        | x-coordinate end
% y1                        | Double                                        | y-coordinate start
% y2                        | Double                                        | y-coordinate end
% alpha                     | Double                                        | arrowhead length
% beta                      | Double                                        | arrowhead width
% color                     | 3 x 1 Double Array                            | arrow color
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

%% Draw Shaft
plot([x1 x2],[y1 y2],'Color', color,'LineWidth',0.8)

%% Filled Arrowhead 
% alpha = 0.03;   % arrowhead length (default)
% beta  = 0.02;   % arrowhead width  (default)

%2% Direction vector
v = [x2-x1, y2-y1];
v = v / norm(v);                  % normalize
n = [-v(2), v(1)];                % perpendicular

%% Arrowhead base
p1 = [x2 y2];
p2 = p1 - alpha*v + beta*n;
p3 = p1 - alpha*v - beta*n;

patch([p1(1) p2(1) p3(1)], ...
      [p1(2) p2(2) p3(2)], ...
      color, 'EdgeColor','none');

end