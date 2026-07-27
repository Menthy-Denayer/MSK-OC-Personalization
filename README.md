# Repository For Personalizing Predicitve MSK Simulations
This repository contains the processing code used for the paper on predictive MSK model personalization (see below). The repository is divided into different folders, containing the code, MSK models, experimental data etc. 

# Code
The "code" folder contains the code used for post-processing and personalization, built on top of the PredSim framework. The version of PredSim used for this work can be found at [https://github.com/Menthy-Denayer/PredSim/tree/hpc-edits](https://github.com/Menthy-Denayer/PredSim/releases/tag/personalization-v1.0.0).

The post-processing code should be ready to run on your own device, to recreate the figures inside the manuscript, and the reported metrics. The code will ask you to select the results directory ("results" folder) and the experimental data (inside the "data" folder).

The "subject_settings" folder contains the settings structure for each subject used during the simulations.

_Note: the code has been designed to run on a high-performance super computer (VUB-HPC). Minor tweaks to the slurm scripts and file directories might be required to run the code on your own device, or your institution's high-performance computing platform._

# Data
The "data" folder contains the data used for validation ("MAT_normalizedIKData-gait2334-vJul2026") and a summary of the metrics. The complete dataset can be found on FigShare (see below). Code used to process the raw data can be found at: [https://github.com/Menthy-Denayer/Data-Processing-Public.git](https://github.com/Menthy-Denayer/Data-Processing-Public.git).

# Musculoskeletal Models
The "models" folder contains all of the MSK models used to run the simulations.
- models containing 'mtu3D' are the generic models,
- models containing 'opt3D' are the personalized models,
- models containing 'Dhondt2024' are the extended models.

# Results
The "results" folder contains all of the simulation results. For each subject, we provide:
- the results for the extended model reported inside the manuscript (Dhondt2024_3seg),
- the results for the tracking simulation, used as a reference for the personalization framework (gait1422_MTPjoint_11433261),
- the results for personalization (trackKIN-compliantTendon-3D). The simulations denoted "rerun" represent the final simulations and are the ones reported inside the manuscript. You can also find the results of the weighted and speed simulations here.

# Citation
A paper describing the personalization framework is currenlty submitted in the Journal of the Royal Society Interface.

The dataset can be found at:

> Denayer, M. (Creator), Turcksin, T. (Researcher), De Pauw, K. (Supervisor), Verstraten, T. (Supervisor) (2026). A Full-body Motion Capture Dataset for > Bilateral Weighted Shank Walking. figshare Academic Research System. 10.6084/m9.figshare.30316372
