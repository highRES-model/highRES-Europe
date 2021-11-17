# highRES-Europe

### **What is highRES**?

Welcome to the repository for the European version of the high temporal and spatial resolution electricity system model (highRES-Europe). The model is used to plan least-cost electricity systems for Europe and specifically designed to analyse the effects of high shares of variable renewables and explore integration/flexibility options. It does this by comparing and trading off potential options to integrate renewables into the system including the extension of the transmission grid, interconnection with other countries, building flexible generation (e.g. gas power stations), renewable curtailment and energy storage.

highRES is written in GAMS and its objective is to minimise power system investment and operational costs to meet hourly demand, subject to a number of system constraints. The transmission grid is represented using a linear transport model. To realistically model variable renewable supply, the model uses spatially and temporally-detailed renewable generation time series that are based on weather data.

### **How to run the model**

This repository contains all GAMS code and necessary text files/GDX format input data for a 8760 hour model run. To execute the code:

1. GAMS must be installed and licensed. This version was tested/developed with GAMS version 27.2.0.
2. All files must be in the same directory and then open highres.gms, the main driving script for the model, in the GAMS IDE and hit run.
3. Full model outputs are written into the file "hR_dev.gdx" which is written into the same directory as the code/data and can be viewed using the GAMS IDE. Outputs include: the capacity of generation, storage and transmission by node, the hourly operation of these assets (including flows into and out of storage plus the storage level and total system costs.)
4. The GDX output file can be converted to SQLite using the command line utility gdx2sqlite which is distributed with GAMS. From the command line do "gdx2sqlite -i hR_dev.gdx -o hR_dev.db -fast". This SQLite database can then be easily read by Python using, e.g., Pandas.

### **Data**

This model uses the following data sources:

ERA5 for on and offshore wind capacity factors and runoff data (https://www.ecmwf.int/en/forecasts/datasets/reanalysis-datasets/era5)  
CMSAF-SARAH2 for solar PV capacity factors (https://wui.cmsaf.eu/safira/action/viewDoiDetails?acronym=SARAH_V002)  
Demand data is from ENTSO-E for the year 2013  
Cost and technical data is taken from UKTM (https://www.ucl.ac.uk/energy-models/models/uk-times) with data from the JRC report "Cost development of low carbon energy technologies: Scenario-based cost trajectories to 2050" (https://publications.jrc.ec.europa.eu/repository/handle/JRC109894) used to update some areas. 
