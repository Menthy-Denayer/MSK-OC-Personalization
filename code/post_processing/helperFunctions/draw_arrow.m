function draw_arrow(x1, x2, y1, y2, alpha, beta, color)
% Draws custom arrow for plotting

% Draw shaft
plot([x1 x2],[y1 y2],'Color', color,'LineWidth',0.8)

% ---- Filled arrowhead ----
% alpha = 0.03;   % arrowhead length (tune this)
% beta  = 0.02;   % arrowhead width  (tune this)

% Direction vector
v = [x2-x1, y2-y1];
v = v / norm(v);                  % normalize
n = [-v(2), v(1)];                % perpendicular

% Arrowhead base
p1 = [x2 y2];
p2 = p1 - alpha*v + beta*n;
p3 = p1 - alpha*v - beta*n;

patch([p1(1) p2(1) p3(1)], ...
      [p1(2) p2(2) p3(2)], ...
      color, 'EdgeColor','none');

end