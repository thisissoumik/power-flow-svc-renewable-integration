# Power Flow Analysis with Static VAR Compensator (SVC) and Renewable Energy Integration

A comprehensive power system analysis project implementing Newton-Raphson load flow algorithm with Static VAR Compensator (SVC) and renewable energy source modeling for IEEE 5-bus test system.

## 📋 Project Overview

This project investigates:
- **Power flow control** with FACTS devices (SVC) in transmission systems
- **Variable susceptance modeling** of SVC integrated into Newton-Raphson algorithm
- **Renewable energy modeling** using probability distribution functions
  - Solar farms modeled with Beta distribution
  - Wind farms modeled with Weibull distribution
- **System performance analysis** including voltage stability, power loss, and reactive power compensation

## 👥 Contributors

### Course Information
- **Course**: EEE 306 - Power System I Laboratory (2024)
- **Institution**: Bangladesh University of Engineering and Technology (BUET)
- **Department**: Electrical and Electronic Engineering
- **Section**: A1, Group: 06

### Team Members
- **Soumik Saha** (2006011) - SVC Implementation & Analysis
- **Sayba Kamal Orni** (2006009) - SVC Implementation & Analysis
- **Nittya Ananda Biswas** (2006025) - Renewable Energy Modeling
- **Md. Khalid Hossain** (2006012)
- **Adith Saha Dipro** (2006018)

### Course Instructors
- Iftekharul Islam Emon, Lecturer
- Md. Obaidur Rahman, Part-Time Lecturer

## 🔬 Technical Approach

### Static VAR Compensator (SVC)
- Variable susceptance model implementation
- Voltage regulation at target bus (1.00 pu)
- Reactive power injection control
- Integration with Newton-Raphson power flow algorithm
- Two placement strategies analyzed:
  - Direct bus connection (Bus 3)
  - Line midpoint connection (Bus 3-4 midpoint)

### Renewable Energy Sources

#### Solar Farm Modeling
- **Location**: Netrokona, Bangladesh (24.8821° N, 90.7231° E)
- **Capacity**: 30 MW
- **Method**: Beta probability distribution function
- **Parameters**: Based on historical irradiance data
- **Analysis**: Seasonal variations and hourly power output

#### Wind Farm Modeling
- **Location**: Cox's Bazar, Bangladesh (21.4272° N, 92.0061° E)
- **Capacity**: 15 MW
- **Method**: Weibull probability distribution function
- **Parameters**: Shape and scale factors from wind speed data
- **Analysis**: Wind speed probability and power generation

## 📂 Project Structure

```
power-flow-svc-renewable-integration/
├── src/
│   ├── svc_analysis/
│   │   ├── Load_flow_With_SVC.m              # SVC at Bus 3
│   │   ├── svc_between_2_bus_mline.m          # SVC at line midpoint
│   │   └── load_flow_with_svc_unbounded.m     # Alternative SVC implementation
│   └── renewable_modeling/
│       ├── Beta_Distribution.ipynb             # Solar farm modeling
│       ├── Beta_Distribution_2.ipynb           # Enhanced solar analysis
│       └── Weibull_Distribution.ipynb          # Wind farm modeling
├── data/
│   ├── pvdata.csv                              # Solar irradiance data
│   ├── pvdata2.csv                             # Extended solar data
│   └── windspeed.csv                           # Wind speed measurements
├── results/
│   ├── res_svc_all_case.txt                    # All test cases results
│   ├── res_svc_midpoint.txt                    # Midpoint SVC results
│   ├── svc_all_midpoint.txt                    # Comprehensive midpoint analysis
│   └── svc_each_5_case.txt                     # Individual case results
├── docs/
│   └── UPDATED_power_paper.pdf                 # Complete project report
└── README.md
```

## 🚀 Getting Started

### Prerequisites

**MATLAB Requirements:**
- MATLAB R2018b or later
- No additional toolboxes required

**Python Requirements:**
```bash
pip install numpy pandas matplotlib scipy jupyter
```

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/power-flow-svc-renewable-integration.git
cd power-flow-svc-renewable-integration
```

### Running the Code

#### SVC Load Flow Analysis

```matlab
% In MATLAB, navigate to src/svc_analysis/

% Run SVC at Bus 3
Load_flow_With_SVC

% Run SVC at line midpoint
svc_between_2_bus_mline

% Run alternative implementation
load_flow_with_svc_unbounded
```

#### Renewable Energy Modeling

```bash
# Start Jupyter Notebook
jupyter notebook

# Open and run:
# - src/renewable_modeling/Beta_Distribution.ipynb
# - src/renewable_modeling/Weibull_Distribution.ipynb
```

## 📊 Key Results

### SVC Performance
- **Voltage Improvement**: Maintained target voltage of 1.00 pu at regulated bus
- **Power Loss Reduction**: Achieved through optimal reactive power compensation
- **Reactive Power Control**: Dynamic adjustment based on system loading
- **Stability Enhancement**: Improved voltage profile across all buses

### Renewable Integration Impact
- **Solar Farm**: Modeled seasonal and hourly variations in power output
- **Wind Farm**: Characterized probability distribution of wind power generation
- **System Analysis**: Evaluated impact on power flow with and without SVC

## 🔍 Test System

**IEEE 5-Bus System Specifications:**
- Base Power: 100 MVA
- Voltage Levels: Slack bus at 1.06 pu
- Total Load: 165 MW / 40 MVAr
- Generator at Bus 2: 40 MW / 30 MVAr
- Seven transmission lines with detailed impedance data

## 📈 Analysis Performed

1. **Base Case Load Flow**: Standard Newton-Raphson analysis
2. **SVC Integration**: Variable susceptance model at Bus 3
3. **Midpoint SVC**: Enhanced control with line-mounted SVC
4. **Renewable Addition**: Solar and wind farms at Buses 4 & 5
5. **Combined System**: Renewables with SVC coordination
6. **Comparative Analysis**: Voltage profiles, losses, and power flows

## 📄 Documentation

Complete technical documentation available in:
- `docs/UPDATED_power_paper.pdf` - Full project report (98 pages)
- Includes methodology, mathematical formulations, results, and analysis

## 🔧 Code Features

- **Well-commented implementations** for easy understanding
- **Modular design** for easy modification and extension
- **Comprehensive output** including:
  - Bus voltages and angles
  - Line currents and power flows
  - Power losses
  - SVC reactive power injection
  - System totals and comparisons

## 📝 Citation

If you use this work, please cite:

```bibtex
@techreport{saha2024powerflow,
  title={Power Flow Analysis Incorporating Static VAR Compensator (SVC) in Newton Raphson Algorithm and Modelling of Renewable Energy Sources},
  author={Saha, Soumik and Orni, Sayba Kamal and Biswas, Nittya Ananda and Hossain, Md. Khalid and Dipro, Adith Saha},
  institution={Bangladesh University of Engineering and Technology},
  year={2024},
  type={EEE 306 Final Project Report}
}
```

## 🤝 Contributing

This is an academic project. For questions or collaboration:
- Soumik Saha: [GitHub Profile]
- Contact through BUET EEE Department

## 📜 License

This project is submitted as part of academic coursework at BUET. 

**Academic Integrity Statement**: This work is original and completed in accordance with BUET's academic honesty policies.

## 🙏 Acknowledgments

- Course instructors for guidance and support
- BUET EEE Department for facilities and resources
- Historical weather data sources for renewable modeling
- IEEE for standardized test system specifications

## 📞 Contact

For technical questions or collaborations:
- **Primary Contact**: Soumik Saha
- **Institution**: Bangladesh University of Engineering and Technology
- **Department**: Electrical and Electronic Engineering

---

**Note**: This project demonstrates the integration of FACTS devices and renewable energy sources in power system analysis, serving as a foundation for advanced power systems research and applications.
