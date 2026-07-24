# Repository For Personalizing Predicitve MSK Simulations
- The "code" folder contains the code used for post-processing and personalization, built on top of the PredSim framework. The version of PredSim used for this work can be found at https://github.com/Menthy-Denayer/PredSim/tree/hpc-edits.
  - Note: the code has been designed to run on a high-performance super computer. Minor tweaks to the slurm scripts and file directories might be required to run the code on your own device, or your institution's high-performance computing platform.
- The "data" folder contains the data used for validation and a summary of the metrics.
- The "models" folder contains all of the MSK models used to run the simulations.
- The "results" folder contains all of the simulation results. For each subject, we provide:
  -  the results for the state-of-the-art, extended model reported inside the manuscript (Dhondt2024_3seg),
  -  the results for another extended model (Falisse2022), not reported inside the manuscript,
  -  the results for the tracking simulation, used as a reference for the personalization framework (gait1422_MTPjoint_11433261),
  -  the results for personalization (trackKIN-compliantTendon-3D). The simulations denoted "rerun" represent the final simulations and are the ones reported inside the manuscript.

# Citation
A paper describing the personalization framework is currenlty submitted in the Journal of the Royal Society Interface.
