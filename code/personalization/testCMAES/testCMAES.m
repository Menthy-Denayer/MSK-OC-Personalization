clear all
clc
close all

addpath("..\")
addpath("..\lapack\")

%% Choose CMA-ES Settings
sigma0 = 0.5;                                                                % percentage of change allowed from generic values

% Options
opts = cmaes('defaults');
% opts.EvalParallel = 'on';
% opts.MaxFunEvals = 2000;
opts.PopSize = 10;                                                           % matched to number of workers for parallelization
opts.Restarts = 0;
% opts.LBounds = -500;                                                 % lower bounds
% opts.UBounds = 500;                                                 % upper bounds
opts.Resume = 0;                                                            % resume from best 
opts.SaveVariables = 'on';
% opts.SaveFilename = fullfile(cmaesResultsDir, 'variablescmaes.mat');
% opts.LogFilenamePrefix = fullfile(cmaesResultsDir,'outcmaes');

%% Run CMA-ES
initialGuess = zeros(28,1);
opts.Seed = [362436069;209941];

[xmin, fmin] = cmaes('frosenbrock', initialGuess, sigma0, opts);
