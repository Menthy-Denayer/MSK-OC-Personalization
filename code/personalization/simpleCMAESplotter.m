function simpleCMAESplotter(varargin)

% load CMA-ES results
load("variablescmaes.mat",'fitness');
load("variablescmaes.mat",'out');

% create cost function evolution plot
fig = figure(1);
clf(fig)
hold on
grid on
plot(rot90(fitness.histbest),'k',"LineWidth",1)
plot(length(fitness.histbest),out.solutions.recentbest.f,'r*')
xlabel('Iteration')
ylabel('Objective Value')
hold off

% plot COT if given to function
if(nargin == 1)
    figure(2);
    hold on
    grid on
    plot(length(fitness.histbest),varargin{1},'k*',"LineWidth",1)
    xlabel('Iteration')
    ylabel('Bhargava 2004 Metabolic Cost')
    hold off
end

end