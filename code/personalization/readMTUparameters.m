function [lMopt, lTslack, Fmax] = readMTUparameters(model)

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