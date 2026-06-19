function adaptMTUparameters(coeffs0, params, modelFile)
%% adaptMTUparameters 
% - Changes the MTU parameters to the desired ones
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% coeffs0                       | Nmuscles x 1 Double Array     | Desired MTU parameters (first Nmuscles/2 lMopt, next lTslack) 
% params                        | struct                        | Structure with settings
%   modelPath                   | string                        | Input model path
%   rescaleF                    | boolean                       | Whether to rescale Fmax based on the new muscle parameters
%   FmaxGen                     | Nmuscles/2 x 1 Double Array   | Maximal isometric force in the generic model
%   adaptedModelPath            | string                        | Path to the output model
% modelFile                     | string                        | Name of the output model path
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% adaptedModel                  | OpenSim Model                 | Adapted model saved at modelFile
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 05/December/2025

% Last Update: Menthy Denayer
% Date: 05/December/2025 


%% Import Libraries
import org.opensim.modeling.*

%% Load Model
adaptedModel = Model(params.modelPath);

%% Initialize Model Info
Muscles = adaptedModel.getMuscles();
Nmuscles = Muscles.getSize();

%% Initialize Parameters
lMopt = coeffs0(1:Nmuscles/2);
lTslack = coeffs0(Nmuscles/2+1:Nmuscles);

% lMopt_org = params.initialCoefficients(1:Nmuscles/2);
% lTslack_org = params.initialCoefficients(Nmuscles/2+1:Nmuscles);

if(params.rescaleF)
    FmaxScale = params.initialCoefficients(1:Nmuscles/2)./lMopt;            % scale Fmax to keep PCSA constant, with lMold/lMnew
    FmaxGen = params.FmaxGen;
end

%% Read Muscle Parameters
for muscleIdx = 1:Nmuscles/2
    currMuscleR = Muscles.get(muscleIdx-1);
    currMuscleR.setOptimalFiberLength(lMopt(muscleIdx));
    currMuscleR.setTendonSlackLength(lTslack(muscleIdx));

    currMuscleL = Muscles.get(muscleIdx-1+Nmuscles/2);
    currMuscleL.setOptimalFiberLength(lMopt(muscleIdx));
    currMuscleL.setTendonSlackLength(lTslack(muscleIdx));

    if(params.rescaleF)
        currMuscleR.setMaxIsometricForce(FmaxScale(muscleIdx)*FmaxGen(muscleIdx));
        currMuscleL.setMaxIsometricForce(FmaxScale(muscleIdx)*FmaxGen(muscleIdx));
    end
end

adaptedModel.finalizeConnections();

try
    adaptedModel.initSystem();
    adaptedModel.print(modelFile);
    fprintf('Written model %s at %s\n', modelFile, datetime('now','format','HH:mm:ss'))
%     fprintf('Model parameters are %0.2f', coeffs0);
catch ME
    disp("ERROR writing model:");
    disp(params.adaptedModelPath);
    disp(getReport(ME));
end

end