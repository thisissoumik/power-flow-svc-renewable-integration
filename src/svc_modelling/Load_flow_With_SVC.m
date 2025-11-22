%% Newton-Raphson Load Flow with SVC at Bus 3
% =========================================================================
% Project: Power Flow Analysis with Static VAR Compensator Integration
% Course: EEE 306 - Power System I Laboratory (2024)
% Institution: Bangladesh University of Engineering and Technology (BUET)
% 
% Authors: Soumik Saha (2006011), Sayba Kamal Orni (2006009)
% Date: 2024
% 
% Description:
%   Implements Newton-Raphson power flow algorithm with a Static VAR 
%   Compensator (SVC) connected at Bus 3 using variable susceptance model.
%   The SVC regulates voltage at Bus 3 to a target value while dynamically
%   adjusting its reactive power injection.
%
% System: IEEE 5-Bus Test System
%   - Base Power: 100 MVA
%   - Slack Bus: Bus 1 at 1.06 pu
%   - SVC Location: Bus 3
%   - Target Voltage: 1.00 pu at Bus 3
% =========================================================================

clc; clear; close all;

%% ========================================================================
% SYSTEM DATA - TRANSMISSION LINE PARAMETERS
% =========================================================================
% Line admittances (series) and shunt susceptances for IEEE 5-bus system
% Format: y_ij = 1/Z_ij where Z_ij = R_ij + jX_ij
% B_ij represents half of the total line charging susceptance

% Line 1-2: Impedance = 0.02 + j0.06 pu
y12 = 1/(0.02 + 0.06i);   
B12 = 0.03i;  % Line charging susceptance (both ends)

% Line 1-3: Impedance = 0.08 + j0.24 pu
y13 = 1/(0.08 + 0.24i);   
B13 = 0.025i;

% Line 2-3: Impedance = 0.06 + j0.25 pu
y23 = 1/(0.06 + 0.25i);   
B23 = 0.020i;

% Line 2-4: Impedance = 0.06 + j0.18 pu
y24 = 1/(0.06 + 0.18i);   
B24 = 0.020i;

% Line 2-5: Impedance = 0.04 + j0.12 pu
y25 = 1/(0.04 + 0.12i);   
B25 = 0.015i;

% Line 3-4: Impedance = 0.01 + j0.03 pu
y34 = 1/(0.01 + 0.03i);   
B34 = 0.010i;

% Line 4-5: Impedance = 0.08 + j0.24 pu
y45 = 1/(0.08 + 0.24i);   
B45 = 0.025i;

%% ========================================================================
% BUS ADMITTANCE MATRIX (Y-BUS) FORMATION
% =========================================================================
% Construct the 5x5 admittance matrix including line admittances and 
% shunt susceptances. Diagonal elements are sum of all admittances 
% connected to that bus. Off-diagonal elements are negative of line 
% admittances between buses.

Y_base = [ (y12+y13+B12+B13)                     -y12                     -y13                   0                      0
           -y12               (y12+y23+y24+y25+B12+B23+B24+B25)           -y23                 -y24                  -y25
           -y13                                 -y23        (y13+y23+y34+B13+B23+B34)         -y34                   0
            0                                   -y24                               -y34   (y34+y45+y24+B34+B45+B24) -y45
            0                                   -y25                                0                   -y45   (y25+y45+B25+B45) ];

%% ========================================================================
% SVC PARAMETERS AND SYSTEM BASE VALUES
% =========================================================================
Sbase     = 100;                % System base power [MVA]
svc_bus   = 3;                  % SVC connected at Bus 3
Vref_svc  = 1.00;               % Target voltage magnitude at SVC bus [pu]
B_svc     = 0.0;                % Initial SVC susceptance [pu]
Bmin      = -1.0;               % Minimum susceptance (capacitive) [pu]
Bmax      = +1.0;               % Maximum susceptance (inductive) [pu]
svc_regulating = true;          % Enable SVC voltage regulation

%% ========================================================================
% INITIAL CONDITIONS - FLAT START
% =========================================================================
% Start with all bus voltages at 1.0 pu (except slack bus at 1.06 pu)
% and all voltage angles at zero

V_abs   = [1.06, 1.00, Vref_svc, 1.00, 1.00];  % Voltage magnitudes [pu]
V_ang   = zeros(1,5);                          % Voltage angles [rad]

%% ========================================================================
% SCHEDULED GENERATION AND LOAD DATA
% =========================================================================
% Active and reactive power for each bus (per unit on 100 MVA base)
% Note: Bus 2 is treated as PQ bus (both P and Q specified)

% Load demand at each bus [pu]
Pd = [0  20 45 40 60]/Sbase;  % Active power load [pu]
Qd = [0  10 15  5 10]/Sbase;  % Reactive power load [pu]

% Generation at each bus [pu]
Pg = [0  40  0  0  0]/Sbase;  % Active power generation [pu]
Qg = [0  30  0  0  0]/Sbase;  % Reactive power generation [pu]
                               % (Bus 2 has fixed Q - treated as PQ bus)

% Net scheduled power (generation - load)
Psch = Pg - Pd;  % Net active power injection [pu]
Qsch = Qg - Qd;  % Net reactive power injection [pu]

%% ========================================================================
% NEWTON-RAPHSON ITERATION SETUP
% =========================================================================
tol = 1e-6;       % Convergence tolerance for power mismatch
max_iter = 50;    % Maximum number of iterations
iter = 0;         % Iteration counter
err = 1;          % Initial error (set high to enter loop)

% Define unknown state variables
ang_idx = 2:5;    % Buses with unknown angles (all except slack)
pq_set  = 2:5;    % PQ buses (all non-slack buses in this case)

% Damping and step limiting parameters for better convergence
alphaV = 0.6;     % Damping factor for voltage magnitude updates
capV = 0.10;      % Maximum voltage magnitude change per iteration [pu]
alphaB = 0.6;     % Damping factor for susceptance updates
capB = 0.50;      % Maximum susceptance change per iteration [pu]

%% ========================================================================
% MAIN NEWTON-RAPHSON ITERATION LOOP
% =========================================================================
while err > tol && iter < max_iter
    iter = iter + 1;
    
    % ---------------------------------------------------------------------
    % Update Y-bus with current SVC susceptance
    % ---------------------------------------------------------------------
    % SVC is modeled as a shunt susceptance at Bus 3
    Y = Y_base;
    Y(svc_bus, svc_bus) = Y(svc_bus, svc_bus) + 1i*B_svc;
    
    % ---------------------------------------------------------------------
    % Enforce voltage regulation at SVC bus
    % ---------------------------------------------------------------------
    if svc_regulating
        V_abs(svc_bus) = Vref_svc;  % Hold |V3| at target value
    end
    
    % ---------------------------------------------------------------------
    % Calculate power injections at all buses
    % ---------------------------------------------------------------------
    % Using: P_i = Σ |V_i||V_k||Y_ik|cos(θ_ik + δ_k - δ_i)
    %        Q_i = -Σ |V_i||V_k||Y_ik|sin(θ_ik + δ_k - δ_i)
    N = 5;
    Pcalc = zeros(1,N); 
    Qcalc = zeros(1,N);
    
    for i = 1:N
        for k = 1:N
            Vi = V_abs(i); 
            Vk = V_abs(k);
            Yik = Y(i,k); 
            th = angle(Yik) + V_ang(k) - V_ang(i);
            Pcalc(i) = Pcalc(i) + Vi*Vk*abs(Yik)*cos(th);
            Qcalc(i) = Qcalc(i) - Vi*Vk*abs(Yik)*sin(th);
        end
    end
    
    % ---------------------------------------------------------------------
    % Calculate power mismatches
    % ---------------------------------------------------------------------
    dP = Psch - Pcalc;           % Active power mismatch [pu]
    dQ = Qsch - Qcalc;           % Reactive power mismatch [pu]
    
    misP = dP(ang_idx);          % ΔP for buses 2,3,4,5
    misQ = dQ(pq_set);           % ΔQ for buses 2,3,4,5
    M = [misP, misQ]';           % Combined mismatch vector (8×1)
    
    % Check for convergence
    err = max(abs(M)); 
    if err <= tol
        break;
    end
    
    % ---------------------------------------------------------------------
    % Form Jacobian Matrix Components
    % ---------------------------------------------------------------------
    % Standard Newton-Raphson has 4 sub-matrices:
    % J = [J11  J12]  where J11 = ∂P/∂δ,  J12 = ∂P/∂|V|
    %     [J21  J22]        J21 = ∂Q/∂δ,  J22 = ∂Q/∂|V|
    %
    % With SVC: Replace the |V3| column in J12 and J22 with ∂P/∂B and ∂Q/∂B
    
    na = numel(ang_idx);               % Number of angle unknowns = 4
    mag_unknowns = pq_set;             % Initially all PQ buses
    addB = 0;                          % Flag for additional B column
    
    if svc_regulating
        % Remove SVC bus from voltage magnitude unknowns
        % Add susceptance B as an unknown instead
        mag_unknowns = setdiff(mag_unknowns, svc_bus);
        addB = 1;
    end
    nm = numel(mag_unknowns);          % Number of voltage magnitude unknowns
    
    % Initialize Jacobian sub-matrices
    J11 = zeros(na, na);                    % ∂P/∂δ
    J12 = zeros(na, nm+addB);               % ∂P/∂|V| (or ∂P/∂B)
    J21 = zeros(numel(pq_set), na);         % ∂Q/∂δ
    J22 = zeros(numel(pq_set), nm+addB);    % ∂Q/∂|V| (or ∂Q/∂B)
    
    % ---------------------------------------------------------------------
    % Fill J11: ∂P/∂δ (all angle derivatives)
    % ---------------------------------------------------------------------
    for r = 1:na
        i = ang_idx(r);
        for c = 1:na
            k = ang_idx(c);
            if i == k
                % Diagonal element: ∂P_i/∂δ_i = -Q_i - |V_i|²|Y_ii|sin(θ_ii)
                J11(r,c) = -Qcalc(i) - V_abs(i)^2*abs(Y(i,i))*sin(angle(Y(i,i)));
            else
                % Off-diagonal: ∂P_i/∂δ_k = -|V_i||V_k||Y_ik|sin(θ_ik + δ_k - δ_i)
                thik = angle(Y(i,k)) + V_ang(k) - V_ang(i);
                J11(r,c) = -V_abs(i)*V_abs(k)*abs(Y(i,k))*sin(thik);
            end
        end
        
        % -----------------------------------------------------------------
        % Fill J12: ∂P/∂|V| for voltage magnitude unknowns
        % -----------------------------------------------------------------
        for c = 1:nm
            k = mag_unknowns(c);
            if i == k
                % Diagonal: ∂P_i/∂|V_i| = P_i + |V_i|²|Y_ii|cos(θ_ii)
                J12(r,c) = Pcalc(i) + V_abs(i)^2*abs(Y(i,i))*cos(angle(Y(i,i)));
            else
                % Off-diagonal: ∂P_i/∂|V_k| = |V_i||V_k||Y_ik|cos(θ_ik + δ_k - δ_i)
                thik = angle(Y(i,k)) + V_ang(k) - V_ang(i);
                J12(r,c) = V_abs(i)*V_abs(k)*abs(Y(i,k))*cos(thik);
            end
        end
    end
    
    % ∂P/∂B column is zero (active power doesn't depend on SVC susceptance)
    if addB
        J12(:, nm+1) = 0;
    end
    
    % ---------------------------------------------------------------------
    % Fill J21: ∂Q/∂δ
    % ---------------------------------------------------------------------
    for r = 1:numel(pq_set)
        i = pq_set(r);
        for c = 1:na
            k = ang_idx(c);
            if i == k
                % Diagonal: ∂Q_i/∂δ_i = P_i - |V_i|²|Y_ii|cos(θ_ii)
                J21(r,c) = Pcalc(i) - V_abs(i)^2*abs(Y(i,i))*cos(angle(Y(i,i)));
            else
                % Off-diagonal: ∂Q_i/∂δ_k = -|V_i||V_k||Y_ik|cos(θ_ik + δ_k - δ_i)
                thik = angle(Y(i,k)) + V_ang(k) - V_ang(i);
                J21(r,c) = -V_abs(i)*V_abs(k)*abs(Y(i,k))*cos(thik);
            end
        end
        
        % -----------------------------------------------------------------
        % Fill J22: ∂Q/∂|V|
        % -----------------------------------------------------------------
        for c = 1:nm
            k = mag_unknowns(c);
            if i == k
                % Diagonal: ∂Q_i/∂|V_i| = Q_i - |V_i|²|Y_ii|sin(θ_ii)
                J22(r,c) = Qcalc(i) - V_abs(i)^2*abs(Y(i,i))*sin(angle(Y(i,i)));
            else
                % Off-diagonal: ∂Q_i/∂|V_k| = -|V_i||V_k||Y_ik|sin(θ_ik + δ_k - δ_i)
                thik = angle(Y(i,k)) + V_ang(k) - V_ang(i);
                J22(r,c) = -V_abs(i)*V_abs(k)*abs(Y(i,k))*sin(thik);
            end
        end
    end
    
    % ---------------------------------------------------------------------
    % Fill ∂Q/∂B column for SVC
    % ---------------------------------------------------------------------
    % For SVC: Q = -|V|²B, therefore ∂Q/∂B = -|V|²
    % Only the SVC bus row has non-zero entry
    if addB
        J22(:, nm+1) = 0;
        row_svc = find(pq_set == svc_bus);  % Find SVC bus row in J22
        J22(row_svc, nm+1) = -V_abs(svc_bus)^2;
    end
    
    % ---------------------------------------------------------------------
    % Solve linear system: J·Δx = M
    % ---------------------------------------------------------------------
    J = [J11 J12; J21 J22];  % Complete Jacobian matrix
    dx = J \ M;              % Solve for corrections
    
    % Extract angle and other corrections
    dDel  = dx(1:na).';      % Angle corrections [rad]
    dRest = dx(na+1:end).';  % Voltage magnitude and/or susceptance corrections
    
    % ---------------------------------------------------------------------
    % Update voltage angles (no damping or limiting)
    % ---------------------------------------------------------------------
    V_ang(ang_idx) = V_ang(ang_idx) + dDel;
    
    % ---------------------------------------------------------------------
    % Update voltage magnitudes (with damping and step limiting)
    % ---------------------------------------------------------------------
    if nm > 0
        dV = dRest(1:nm);
        dV = max(min(dV, capV), -capV);      % Limit step size to ±capV
        V_abs(mag_unknowns) = V_abs(mag_unknowns) + alphaV * dV;
    end
    
    % ---------------------------------------------------------------------
    % Update SVC susceptance (with damping and limits)
    % ---------------------------------------------------------------------
    if addB
        dB = dRest(end);
        dB = max(min(dB, capB), -capB);      % Limit step size to ±capB
        B_svc = B_svc + alphaB * dB;         % Apply damped correction
        
        % Enforce physical limits on SVC susceptance
        B_svc = min(max(B_svc, Bmin), Bmax);
    end
    
    % ---------------------------------------------------------------------
    % Re-enforce voltage regulation at SVC bus
    % ---------------------------------------------------------------------
    if svc_regulating
        V_abs(svc_bus) = Vref_svc;
    end
end

%% ========================================================================
% POST-CONVERGENCE ANALYSIS AND OUTPUT
% =========================================================================

V_deg = V_ang * 180/pi;  % Convert angles to degrees

% Display convergence information
fprintf('Converged in %d iterations. Max mismatch = %.3e\n', iter, err);
fprintf('\n=== BUS VOLTAGES ===\n');
for b = 1:5
    fprintf('Bus %d: |V| = %.5f  angle = %+8.4f deg\n', b, V_abs(b), V_deg(b));
end

% Calculate and display SVC reactive power injection
Qsvc_MVAr = -(V_abs(svc_bus)^2) * B_svc * Sbase;  % Q = -|V|²B [MVAr]
fprintf('\n=== SVC PERFORMANCE ===\n');
fprintf('SVC: B = %+8.5f pu   =>   Q_svc = %+8.3f MVAr\n', B_svc, Qsvc_MVAr);

%% ========================================================================
% LINE FLOW CALCULATIONS
% =========================================================================
% Calculate current magnitude/angle and power losses for each line

lines = [1 2; 1 3; 2 3; 2 4; 2 5; 3 4; 4 5];  % Line connections
Zs    = [0.02+0.06i; 0.08+0.24i; 0.06+0.25i; 0.06+0.18i; ...
         0.04+0.12i; 0.01+0.03i; 0.08+0.24i];             % Line impedances

fprintf('\n=== LINE FLOWS AND LOSSES ===\n');
fprintf('From To\t I_mag(pu)\t I_ang(deg)\t P_loss(MW)\t Q_loss(MVAr)\n');

for e = 1:size(lines,1)
    i = lines(e,1); 
    k = lines(e,2);
    
    % Calculate current and losses for this line
    out = current_and_lineloss(V_abs(i), V_deg(i), V_abs(k), V_deg(k), Zs(e), Sbase);
    
    fprintf('%d    %d\t %.5f\t  %8.4f\t   %9.5f\t   %9.5f\n', ...
            i, k, out(1), out(2), out(3), out(4));
end

%% ========================================================================
% HELPER FUNCTION: CURRENT AND LINE LOSS CALCULATION
% =========================================================================
% Calculates line current and power losses for a transmission line
%
% Inputs:
%   Vm_i, ang_i_deg : Sending end voltage magnitude [pu] and angle [deg]
%   Vm_j, ang_j_deg : Receiving end voltage magnitude [pu] and angle [deg]
%   Z               : Line series impedance [pu]
%   Sbase           : System base power [MVA]
%
% Outputs:
%   r(1) : Current magnitude [pu]
%   r(2) : Current angle [deg]
%   r(3) : Active power loss [MW]
%   r(4) : Reactive power loss [MVAr]

function r = current_and_lineloss(Vm_i, ang_i_deg, Vm_j, ang_j_deg, Z, Sbase)
    % Convert voltage phasors to complex form
    Vi = Vm_i * exp(1i*deg2rad(ang_i_deg));
    Vj = Vm_j * exp(1i*deg2rad(ang_j_deg));
    
    % Calculate line current using Ohm's law: I = (V_i - V_j) / Z
    Iij = (Vi - Vj) / Z;
    
    % Extract magnitude and angle
    Iabs = abs(Iij);
    Iang = rad2deg(angle(Iij));
    
    % Calculate power loss: S_loss = I² × Z
    S_loss_pu = (Iabs^2) * Z;
    Ploss_MW   = Sbase * real(S_loss_pu);   % Active power loss [MW]
    Qloss_MVAr = Sbase * imag(S_loss_pu);   % Reactive power loss [MVAr]
    
    % Return all calculated values
    r = [Iabs, Iang, Ploss_MW, Qloss_MVAr];
end

%% ========================================================================
% END OF PROGRAM
% =========================================================================
% 
% Key Features Implemented:
%   1. Variable susceptance model for SVC
%   2. Voltage regulation at target bus
%   3. Dynamic reactive power control
%   4. Newton-Raphson with modified Jacobian for SVC
%   5. Damping and step limiting for robust convergence
%   6. Comprehensive line flow analysis
%
% For questions or modifications, contact:
%   Soumik Saha (2006011) - soumik.saha@example.com
%   Sayba Kamal Orni (2006009) - sayba.orni@example.com
% =========================================================================
