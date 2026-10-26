function newModelFile = shiftMarker(modelFile, modelFolder, markerNames, offsetVector)
%% average_results 
% Function to read the desired data for the desired subjects
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% modelFile                                         | string                | OpenSim model file name
% modelFolder                                       | string                | OpenSim model directory
% markerNames                                       | string array 1xN      | Names of OpenSim
% markers to shift offsetVector                     | double array 3xN      | Offset vectors for each marker columns
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% newModelFile                                      | string                | Name of the modified OpenSim model
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 07/Oct/2026

% Last Update: Menthy Denayer
% Date: 25/Oct/2026


%% Import Libraries
import org.opensim.modeling.*

%% Load Model
model = Model(fullfile(modelFolder, modelFile));
newModel = model.clone();

%% Find Marker  
markers = newModel.getMarkerSet();
Nmarkers = length(markerNames);

for markerIDX = 1:Nmarkers
    marker = markers.get(markerNames(markerIDX));
    localPos = marker.get_location().getAsMat();
    newPos = localPos + offsetVector(markerIDX,:)';
    marker.set_location(Vec3(newPos(1), newPos(2), newPos(3)));
end

%% Recompute Pelvis Markers
% retrieve markers & positions
RPSImarker = markers.get("RPSI");
RPSIpos = RPSImarker.get_location().getAsMat();
LPSImarker = markers.get("LPSI");
LPSIpos = LPSImarker.get_location().getAsMat();
RASImarker = markers.get("RASI");
RASIpos = RASImarker.get_location().getAsMat();
LASImarker = markers.get("LASI");
LASIpos = LASImarker.get_location().getAsMat();
midPSImarker = markers.get("midPSI");
midASImarker = markers.get("midASI");
midPelvisMarker = markers.get("midPelvis");

% compute new positions
midASIpos = (RASIpos+LASIpos)/2;
midPSIpos = (RPSIpos+LPSIpos)/2;
midPelvisPos = (midPSIpos+midASIpos)/2;

% update positions
midASImarker.set_location(Vec3(midASIpos(1), midASIpos(2), midASIpos(3)));
midPSImarker.set_location(Vec3(midPSIpos(1), midPSIpos(2), midPSIpos(3)));
midPelvisMarker.set_location(Vec3(midPelvisPos(1), midPelvisPos(2), midPelvisPos(3)));

%% Recompute Foot Markers
% retrieve markers & positions
RHEEmarker = markers.get("RHEE");
RHEEpos = RHEEmarker.get_location().getAsMat();
LHEEmarker = markers.get("LHEE");
LHEEpos = LHEEmarker.get_location().getAsMat();
RAJCmarker = markers.get("RAJC");
RAJCpos = RAJCmarker.get_location().getAsMat();
LAJCmarker = markers.get("LAJC");
LAJCpos = LAJCmarker.get_location().getAsMat();
RMT5marker = markers.get("RMT5");
RMT5pos = RMT5marker.get_location().getAsMat();
LMT5marker = markers.get("LMT5");
LMT5pos = LMT5marker.get_location().getAsMat();
RTOEmarker = markers.get("RTOE");
RTOEpos = RTOEmarker.get_location().getAsMat();
LTOEmarker = markers.get("LTOE");
LTOEpos = LTOEmarker.get_location().getAsMat();

RHEEprojMarker = markers.get("RHEEproj");
RHEEprojPos = RHEEprojMarker.get_location().getAsMat();
RAJCprojMarker = markers.get("RAJCproj");
RAJCprojPos = RAJCprojMarker.get_location().getAsMat();
RMT5projMarker = markers.get("RMT5proj");
RMT5projPos = RMT5projMarker.get_location().getAsMat();
RTOEprojMarker = markers.get("RTOEproj");
RTOEprojPos = RTOEprojMarker.get_location().getAsMat();
RTOEmidMarker = markers.get("RTOEmid");
RTOEmidPos = RTOEmidMarker.get_location().getAsMat();
LHEEprojMarker = markers.get("LHEEproj");
LHEEprojPos = LHEEprojMarker.get_location().getAsMat();
LAJCprojMarker = markers.get("LAJCproj");
LAJCprojPos = LAJCprojMarker.get_location().getAsMat();
LMT5projMarker = markers.get("LMT5proj");
LMT5projPos = LMT5projMarker.get_location().getAsMat();
LTOEprojMarker = markers.get("LTOEproj");
LTOEprojPos = LTOEprojMarker.get_location().getAsMat();
LTOEmidMarker = markers.get("LTOEmid");
LTOEmidPos = LTOEmidMarker.get_location().getAsMat();

% compute new positions
RTOEmidPosNew = (RTOEpos + RMT5pos)/2;
LTOEmidPosNew = (LTOEpos + LMT5pos)/2;

% update positions
RHEEprojMarker.set_location(Vec3(RHEEpos(1), RHEEprojPos(2), RHEEpos(3)));
RAJCprojMarker.set_location(Vec3(RAJCpos(1), RAJCprojPos(2), RAJCpos(3)));
RMT5projMarker.set_location(Vec3(RMT5pos(1), RMT5projPos(2), RMT5pos(3)));
RTOEprojMarker.set_location(Vec3(RTOEpos(1), RTOEprojPos(2), RTOEpos(3)));
RTOEmidMarker.set_location(Vec3(RTOEmidPosNew(1), RTOEmidPos(2), RTOEmidPosNew(3)));
LHEEprojMarker.set_location(Vec3(LHEEpos(1), LHEEprojPos(2), LHEEpos(3)));
LAJCprojMarker.set_location(Vec3(LAJCpos(1), LAJCprojPos(2), LAJCpos(3)));
LMT5projMarker.set_location(Vec3(LMT5pos(1), LMT5projPos(2), LMT5pos(3)));
LTOEprojMarker.set_location(Vec3(LTOEpos(1), LTOEprojPos(2), LTOEpos(3)));
LTOEmidMarker.set_location(Vec3(LTOEmidPosNew(1), LTOEmidPos(2), LTOEmidPosNew(3)));

%% Save Model
newModel.finalizeConnections();
newModelFile = strrep(modelFile,".osim","_shiftedMarkers.osim");
newModel.print(newModelFile);