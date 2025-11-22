# Usage Guide

This guide provides detailed instructions for running the power flow analysis and renewable energy modeling simulations.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [SVC Load Flow Analysis](#svc-load-flow-analysis)
3. [Renewable Energy Modeling](#renewable-energy-modeling)
4. [Understanding the Results](#understanding-the-results)
5. [Customization](#customization)
6. [Troubleshooting](#troubleshooting)

## System Requirements

### For MATLAB Simulations (SVC Analysis)
- **MATLAB Version**: R2018b or later recommended
- **Toolboxes**: No additional toolboxes required
- **RAM**: Minimum 4 GB
- **Disk Space**: ~100 MB for code and results

### For Python Simulations (Renewable Modeling)
- **Python Version**: 3.7 or later
- **Required Packages**:
  ```bash
  pip install numpy pandas matplotlib scipy jupyter
  ```
- **RAM**: Minimum 4 GB
- **Disk Space**: ~500 MB (including data files)

## SVC Load Flow Analysis

### 1. SVC at Bus 3

This simulation places an SVC directly at Bus 3 of the IEEE 5-bus system.

#### Running the Simulation

```matlab
% Open MATLAB and navigate to the project directory
cd('path/to/power-flow-svc-renewable-integration/src/svc_analysis')

% Run the main script
Load_flow_With_SVC
```

#### What It Does
- Performs Newton-Raphson load flow with SVC at Bus 3
- Regulates voltage at Bus 3 to 1.00 pu
- Calculates optimal SVC susceptance
- Outputs bus voltages, line flows, and power losses

#### Expected Output
```
Converged in X iterations. Max mismatch = X.XXe-XX

=== BUS VOLTAGES ===
Bus 1: |V| = 1.06000  angle =  +0.0000 deg
Bus 2: |V| = X.XXXXX  angle = +XX.XXXX deg
...

=== SVC PERFORMANCE ===
SVC: B = +X.XXXXX pu   =>   Q_svc = +XX.XXX MVAr

=== LINE FLOWS AND LOSSES ===
From To  I_mag(pu)  I_ang(deg)  P_loss(MW)  Q_loss(MVAr)
...
```

### 2. SVC at Line Midpoint

This simulation places an SVC at the midpoint of transmission line 3-4.

#### Running the Simulation

```matlab
% In MATLAB, same directory as above
svc_between_2_bus_mline
```

#### What It Does
- Creates a 6-bus system by splitting line 3-4
- Places SVC at new Bus 6 (midpoint)
- Provides enhanced voltage control along the line
- Analyzes modified system performance

#### Key Differences
- System expanded to 6 buses
- Line 3-4 split into two half-π sections
- More uniform voltage profile along critical lines

### 3. Alternative SVC Implementation

This provides an unbounded SVC implementation for comparison.

```matlab
load_flow_with_svc_unbounded
```

## Renewable Energy Modeling

### Setting Up Jupyter

```bash
# Navigate to renewable modeling directory
cd power-flow-svc-renewable-integration/src/renewable_modeling

# Start Jupyter Notebook
jupyter notebook
```

### 1. Solar Farm Modeling (Beta Distribution)

**Notebook**: `Beta_Distribution.ipynb` or `Beta_Distribution_2.ipynb`

#### Purpose
Models a 30 MW solar farm in Netrokona, Bangladesh using Beta probability distribution.

#### Key Parameters
- **Location**: 24.8821° N, 90.7231° E
- **Capacity**: 30 MW
- **Data**: Historical irradiance data from `pvdata.csv` and `pvdata2.csv`
- **Method**: Beta distribution fitting

#### Running the Analysis

1. Open the notebook in Jupyter
2. Ensure data files are in the `data/` directory
3. Run all cells sequentially (Cell → Run All)

#### Output
- Probability density functions for different seasons
- Hourly power generation profiles
- Seasonal variation analysis
- Statistical parameters (α, β) for Beta distribution

### 2. Wind Farm Modeling (Weibull Distribution)

**Notebook**: `Weibull_Distribution.ipynb`

#### Purpose
Models a 15 MW wind farm in Cox's Bazar, Bangladesh using Weibull probability distribution.

#### Key Parameters
- **Location**: 21.4272° N, 92.0061° E
- **Capacity**: 15 MW
- **Data**: Wind speed measurements from `windspeed.csv`
- **Method**: Weibull distribution fitting

#### Running the Analysis

1. Open the notebook in Jupyter
2. Ensure `windspeed.csv` is in the `data/` directory
3. Run all cells sequentially

#### Output
- Wind speed probability distributions
- Power generation curves
- Shape (k) and scale (c) parameters
- Expected power output calculations

## Understanding the Results

### SVC Analysis Results

#### Bus Voltages
- **|V|**: Voltage magnitude in per unit (pu)
- **angle**: Voltage angle in degrees
- Target: All voltages should be within 0.95-1.05 pu

#### SVC Performance
- **B**: Susceptance in per unit
  - Positive B: Inductive (absorbs reactive power)
  - Negative B: Capacitive (supplies reactive power)
- **Q_svc**: Reactive power injection in MVAr

#### Line Flows
- **I_mag**: Current magnitude in per unit
- **I_ang**: Current angle in degrees
- **P_loss**: Active power loss in MW
- **Q_loss**: Reactive power loss in MVAr

### Renewable Energy Results

#### Solar Farm
- **PDF plots**: Show probability of different irradiance levels
- **Hourly profiles**: Expected power generation throughout the day
- **Seasonal variations**: Changes in output across different seasons

#### Wind Farm
- **Weibull PDF**: Probability distribution of wind speeds
- **Power curve**: Relationship between wind speed and power output
- **Expected energy**: Average power generation

## Customization

### Modifying System Parameters

#### Change Load Values
In the MATLAB files, locate:
```matlab
Pd = [0  20 45 40 60]/Sbase;  % Active power load [MW]
Qd = [0  10 15  5 10]/Sbase;  % Reactive power load [MVAr]
```

#### Change SVC Location
```matlab
svc_bus = 3;  % Change to desired bus number (2-5)
```

#### Adjust SVC Limits
```matlab
Bmin = -1.0;  % Minimum susceptance [pu]
Bmax = +1.0;  % Maximum susceptance [pu]
```

#### Change Target Voltage
```matlab
Vref_svc = 1.00;  % Target voltage at SVC bus [pu]
```

### Modifying Renewable Parameters

#### Solar Farm Capacity
In the notebooks, locate:
```python
rated_capacity = 30  # MW
```

#### Wind Farm Characteristics
```python
rated_power = 15  # MW
cut_in_speed = 3  # m/s
rated_speed = 12  # m/s
cut_out_speed = 25  # m/s
```

## Troubleshooting

### Common MATLAB Issues

#### "Function not found" Error
**Solution**: Ensure you're in the correct directory
```matlab
pwd  % Check current directory
cd('path/to/src/svc_analysis')
```

#### Convergence Issues
**Symptoms**: 
- "Max iterations reached"
- Large final mismatch

**Solutions**:
1. Check load/generation data for errors
2. Reduce damping factors (alphaV, alphaB)
3. Increase max_iter
4. Verify Y-bus matrix formation

#### Unexpected Results
- Verify base power (Sbase = 100 MVA)
- Check line impedance data
- Ensure proper per-unit conversion

### Common Python Issues

#### Package Import Errors
```bash
# Reinstall required packages
pip install --upgrade numpy pandas matplotlib scipy
```

#### Data File Not Found
- Verify data files are in `data/` directory
- Check file paths in notebook cells
- Ensure correct working directory

#### Plot Not Displaying
```python
# Add this at the beginning of notebook
%matplotlib inline
```

## Performance Optimization

### MATLAB
- Use sparse matrices for large systems (not needed for 5-bus)
- Adjust tolerance for faster convergence (if acceptable)
- Vectorize operations where possible

### Python
- Use NumPy operations instead of loops
- Consider parallel processing for large datasets
- Cache intermediate results

## Output Files

### Generated by MATLAB
- Console output with voltage profiles and line flows
- Can redirect output to file:
  ```matlab
  diary results_output.txt
  % Run simulation
  diary off
  ```

### Generated by Python
- Figures saved using:
  ```python
  plt.savefig('output_figure.png', dpi=300)
  ```

## Further Analysis

### Comparative Studies
1. Run base case (no SVC)
2. Run with SVC at Bus 3
3. Run with SVC at midpoint
4. Compare voltage profiles and losses

### Sensitivity Analysis
- Vary load levels
- Change SVC capacity limits
- Test different renewable penetration levels

### Integration Studies
- Combine SVC with renewable sources
- Analyze system stability
- Study transient behavior (requires additional code)

## Support

For technical questions or issues:
- Check the main README.md
- Review code comments in source files
- Contact project contributors (see AUTHORS.md)

## References

1. IEEE 5-Bus Test System Documentation
2. Newton-Raphson Load Flow Algorithm
3. SVC Modeling in Power Systems
4. Renewable Energy Statistical Methods

---
*For more detailed technical information, refer to `docs/UPDATED_power_paper.pdf`*
