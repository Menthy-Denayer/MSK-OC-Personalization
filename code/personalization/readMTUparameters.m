function [lMopt, lTslack, Fmax] = readMTUparameters(model)
%% readMTUparameters 
% - Reads the optimal fibre length, tendon slack length and maximal 
%   isometric force from a model file
% - assumes left/right have the same properties
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% model                         | OpenSim Model                         | OpenSim model to read parameters from
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% lMopt                         | Nmuscles/2 x 1 Double Array           | List of optimal fibre lengths
% lTslack                       | Nmuscles/2 x 1 Double Array           | List of tendon slack lengths
% Fmax                          | Nmuscles/2 x 1 Double Array           | List of maximal isometric forces
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 29/November/2025

% Last Update: Menthy Denayer
% Date: 24/June/2026

%% Import Libraries
import org.opensim.modeling.*

%% Initialize Model Info
Muscles = model.getMuscles();
Nmuscles = Muscles.getSize();

%% Initialize Outputs
lMopt = zeros(Nmuscles/2,1);
lTslack = zeros(Nmuscles/2,1);
Fmax = zeros(Nmuscles/2,1);

%% Read Muscle Parameters

for muscleIdx = 1:Nmuscles/2
    currMuscle = Muscles.get(muscleIdx-1);
    lMopt(muscleIdx) = currMuscle.getOptimalFiberLength();
    lTslack(muscleIdx) = currMuscle.getTendonSlackLength();
    Fmax(muscleIdx) = currMuscle.getMaxIsometricForce();
end 

end