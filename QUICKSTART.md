# Quick Start Guide

Get up and running with the Power Flow Analysis project in minutes!

## 🚀 Fast Track Installation

### For MATLAB Users (SVC Analysis)

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/power-flow-svc-renewable-integration.git
   cd power-flow-svc-renewable-integration
   ```

2. **Open MATLAB and run**
   ```matlab
   cd('src/svc_analysis')
   Load_flow_With_SVC  % Run SVC at Bus 3
   ```

That's it! You should see convergence results and power flow analysis.

### For Python Users (Renewable Modeling)

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/power-flow-svc-renewable-integration.git
   cd power-flow-svc-renewable-integration
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Launch Jupyter**
   ```bash
   cd src/renewable_modeling
   jupyter notebook
   ```

4. **Open and run any notebook**
   - `Beta_Distribution.ipynb` for solar analysis
   - `Weibull_Distribution.ipynb` for wind analysis

## 📊 Quick Test Runs

### Test 1: Basic SVC Load Flow
```matlab
% In MATLAB
cd('src/svc_analysis')
Load_flow_With_SVC
```
**Expected**: Converges in ~5-10 iterations, shows voltage profile

### Test 2: Midpoint SVC
```matlab
% In MATLAB
svc_between_2_bus_mline
```
**Expected**: 6-bus system results, improved voltage profile

### Test 3: Solar Modeling
Open `Beta_Distribution.ipynb` and run all cells
**Expected**: Solar irradiance PDFs and power generation plots

### Test 4: Wind Modeling
Open `Weibull_Distribution.ipynb` and run all cells
**Expected**: Wind speed distribution and power curves

## 📁 Project Structure at a Glance

```
power-flow-svc-renewable-integration/
├── src/
│   ├── svc_analysis/          ← MATLAB codes here
│   └── renewable_modeling/    ← Python notebooks here
├── data/                      ← CSV data files
├── results/                   ← Pre-computed results
├── docs/                      ← Full project report (PDF)
└── README.md                  ← Start here for details
```

## 💡 Common First-Time Issues

### Issue: "File not found" in MATLAB
**Fix**: Make sure you're in the right directory
```matlab
pwd  % Check where you are
cd('path/to/src/svc_analysis')  % Navigate to code
```

### Issue: Python packages not found
**Fix**: Install requirements
```bash
pip install -r requirements.txt
```

### Issue: Data files not loading
**Fix**: Check your working directory and data paths
- MATLAB: Data is embedded in code (no external files needed)
- Python: Ensure CSV files are in `data/` directory

## 🎯 What to Explore First

### If you're interested in Power Systems:
1. Read `README.md` for project overview
2. Run `Load_flow_With_SVC.m` to see SVC in action
3. Compare results with and without SVC
4. Check `docs/UPDATED_power_paper.pdf` for theory

### If you're interested in Renewable Energy:
1. Start with `Beta_Distribution.ipynb`
2. Explore seasonal variations in solar output
3. Try `Weibull_Distribution.ipynb` for wind analysis
4. Modify parameters to see different scenarios

### If you're interested in the Math/Algorithms:
1. Read the commented code in `Load_flow_With_SVC.m`
2. Understand Newton-Raphson implementation
3. Study the Jacobian matrix formation for SVC
4. Compare with standard load flow

## 📖 Next Steps

After running the quick tests:

1. **Read the full documentation**
   - `README.md` - Project overview
   - `USAGE.md` - Detailed usage instructions
   - `AUTHORS.md` - Team and contributions

2. **Explore the results**
   - Compare SVC vs no-SVC cases
   - Analyze voltage profiles
   - Study power loss reduction
   - Examine renewable integration effects

3. **Customize and extend**
   - Modify load values
   - Change SVC location
   - Adjust renewable capacity
   - Test different scenarios

## 🆘 Need Help?

- **Documentation**: Check `USAGE.md` for detailed instructions
- **Code comments**: All MATLAB files are extensively commented
- **Contact**: See `AUTHORS.md` for contributor information
- **Issues**: Report problems or ask questions via GitHub issues

## ✅ System Check

Before you start, verify:
- [ ] MATLAB R2018b or later (for SVC analysis)
- [ ] Python 3.7+ (for renewable modeling)
- [ ] Required Python packages installed
- [ ] At least 4 GB RAM available
- [ ] ~1 GB free disk space

## 🎓 Learning Path

**Beginner**: 
1. Run examples as-is
2. Read code comments
3. Compare results
4. Modify simple parameters

**Intermediate**: 
1. Understand the algorithms
2. Modify system configuration
3. Add new test cases
4. Analyze different scenarios

**Advanced**: 
1. Extend to larger systems
2. Implement new FACTS devices
3. Add dynamic analysis
4. Integrate with other tools

---

**Ready to start?** Jump to the relevant section above and run your first simulation!

For comprehensive documentation, see `README.md` and `USAGE.md`.
