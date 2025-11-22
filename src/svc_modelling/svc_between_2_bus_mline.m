%% Newton-Raphson Load Flow with SVC at Line Midpoint (Bus 6)
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
%   Compensator (SVC) placed at the midpoint of transmission line 3-4.
%   The original 5-bus system is expanded to 6 buses by splitting line 3-4
%   into two half-sections, creating a new bus 6 at the midpoint where the
%   SVC is connected.
%
% System Configuration:
%   - Original: IEEE 5-Bus System
%   - Modified: 6-Bus System (Bus 6 = midpoint of line 3-4)
%   - Base Power: 100 MVA
%   - Slack Bus: Bus 1 at 1.06 pu
%   - SVC Location: Bus 6 (midpoint)
%   - Target Voltage: 1.00 pu at Bus 6
% =========================================================================

clc; clear; close all;

%% ========================================================================
% SYSTEM DATA - ORIGINAL 5-BUS LINE PARAMETERS
% =========================================================================
% Transmission line admittances and shunt susceptances
% These define the original 5-bus system before modification

y12 = 1/(0.02 + 0.06i);   B12 = 0.03i;
y13 = 1/(0.08 + 0.24i);   B13 = 0.025i;
y23 = 1/(0.06 + 0.25i);   B23 = 0.020i;
y24 = 1/(0.06 + 0.18i);   B24 = 0.020i;
y25 = 1/(0.04 + 0.12i);   B25 = 0.015i;
y34 = 1/(0.01 + 0.03i);   B34 = 0.010i;  % Line to be split
y45 = 1/(0.08 + 0.24i);   B45 = 0.025i;

%% ========================================================================
% ORIGINAL 5-BUS Y-MATRIX
% =========================================================================
% Form the original admittance matrix before line splitting
Y5 = [ (y12+y13+B12+B13)                     -y12                     -y13                   0                      0
       -y12               (y12+y23+y24+y25+B12+B23+B24+B25)           -y23                 -y24                  -y25
       -y13                                 -y23        (y13+y23+y34+B13+B23+B34)         -y34                   0
        0                                   -y24                               -y34   (y34+y45+y24+B34+B45+B24) -y45
        0                                   -y25                                0                   -y45   (y25+y45+B25+B45) ];

%% ========================================================================
% 6-BUS Y-MATRIX CONSTRUCTION WITH MIDPOINT BUS
% =========================================================================
% Strategy:
%   1. Start with 5-bus Y-matrix expanded to 6x6
%   2. Remove original 3-4 connection completely
%   3. Split line 3-4 into two half-π sections
%   4. Add half-line 3-6 with its parameters
%   5. Add half-line 6-4 with its parameters

% Initialize 6x6 matrix with original 5x5 data
Y = zeros(6,6);
Y(1:5,1:5) = Y5;

% Remove the original 3-4 branch completely (series + shunt elements)
Y(3,3) = Y(3,3) - y34 - B34;  % Remove y34 and B34 from Bus 3
Y(4,4) = Y(4,4) - y34 - B34;  % Remove y34 and B34 from Bus 4
Y(3,4) = 0;                   % Clear coupling term
Y(4,3) = 0;

% Calculate parameters for each half of the split line
z34     = 0.01 + 0.03i;       % Original line impedance
z_half  = z34/2;              % Half-line impedance
y_half  = 1/z_half;           % Half-line admittance = 2×y34
B_half  = B34/2;              % Half of line charging (per end)

% ---------------------------------------------------------------------
% Add Line Section 3-6 (first half)
% ---------------------------------------------------------------------
Y(3,3) = Y(3,3) + y_half + B_half;   % Add to Bus 3 diagonal
Y(6,6) = Y(6,6) + y_half + B_half;   % Add to Bus 6 diagonal
Y(3,6) = Y(3,6) - y_half;            % Coupling 3-6
Y(6,3) = Y(6,3) - y_half;            % Coupling 6-3

% ---------------------------------------------------------------------
% Add Line Section 6-4 (second half)
% ---------------------------------------------------------------------
Y(4,4) = Y(4,4) + y_half + B_half;   % Add to Bus 4 diagonal
Y(6,6) = Y(6,6) + y_half + B_half;   % Add to Bus 6 diagonal
Y(4,6) = Y(4,6) - y_half;            % Coupling 4-6
Y(6,4) = Y(6,4) - y_half;            % Coupling 6-4

N = 6;  % Total number of buses after modification

%% ========================================================================
% SVC PARAMETERS AND SYSTEM CONFIGURATION
% =========================================================================
Sbase     = 100;              % System base power [MVA]
slack     = 1;                % Slack bus number
svc_bus   = 6;                % SVC connected at the midpoint bus
Vref_svc  = 1.00;             % Target voltage magnitude at SVC bus [pu]
B_svc     = 0.00;             % Initial SVC susceptance [pu]
Bmin      = -1.00;            % Minimum susceptance (capacitive) [pu]
Bmax      = +1.00;            % Maximum susceptance (inductive) [pu]

%% ========================================================================
% SCHEDULED GENERATION AND LOAD DATA (EXTENDED TO 6 BUSES)
% =========================================================================
% Original 5-bus data extended with Bus 6 having zero load/generation
% (Bus 6 is a pure transmission node with only SVC)

Pd = [0 20 45 40 60]/Sbase;     % Original load [pu]
Pd = [Pd 0];                    % No load at Bus 6

Qd = [0 10 15  5 10]/Sbase;     % Original reactive load [pu]
Qd = [Qd 0];                    % No reactive load at Bus 6

Pg = [0 40  0  0  0]/Sbase;     % Original generation [pu]
Pg = [Pg 0];                    % No generation at Bus 6

Qg = [0 30  0  0  0]/Sbase;     % Original reactive generation [pu]
Qg = [Qg 0];                    % No reactive generation at Bus 6

% Net scheduled injections
Psch = Pg - Pd;
Qsch = Qg - Qd;

%% ========================================================================
% INITIAL CONDITIONS - FLAT START
% =========================================================================
Vmag = ones(1,N);              % Initialize all voltages to 1.0 pu
Vmag(1) = 1.06;                % Slack bus voltage
Vmag(2:5) = 1.00;              % Original PQ buses
Vmag(6) = Vref_svc;            % SVC bus target voltage
Vang = zeros(1,N);             % All angles start at zero

%% ========================================================================
% NEWTON-RAPHSON ITERATION SETUP
% =========================================================================
tol = 1e-6;       % Convergence tolerance
max_iter = 50;    % Maximum iterations
iter = 0;         % Iteration counter
err = 1;          % Initial error

ang_idx = 2:N;    % Unknown angles (all buses except slack)
PQ = N-1;         % Number of PQ buses (= number of non-slack buses)

%% ========================================================================
% MAIN NEWTON-RAPHSON ITERATION LOOP
% =========================================================================
while err > tol && iter < max_iter
    iter = iter + 1;
    
    % ---------------------------------------------------------------------
    % Update Y-bus with current SVC susceptance
    % ---------------------------------------------------------------------
    Yit = Y;
    Yit(svc_bus,svc_bus) = Yit(svc_bus,svc_bus) + 1i*B_svc;
    
    % ---------------------------------------------------------------------
    % Enforce voltage regulation at SVC bus
    % ---------------------------------------------------------------------
    Vmag(svc_bus) = Vref_svc;  % Hold |V6| at target value
    
    % ---------------------------------------------------------------------
    % Calculate power injections at all buses
    % ---------------------------------------------------------------------
    Pcalc = zeros(1,N); 
    Qcalc = zeros(1,N);
    
    for i = 1:N
        for k = 1:N
            % Angle difference including Y-matrix element phase
            th = angle(Yit(i,k)) + Vang(k) - Vang(i);
            
            % Active and reactive power injections
            Pcalc(i) = Pcalc(i) + Vmag(i)*Vmag(k)*abs(Yit(i,k))*cos(th);
            Qcalc(i) = Qcalc(i) - Vmag(i)*Vmag(k)*abs(Yit(i,k))*sin(th);
        end
    end
    
    % ---------------------------------------------------------------------
    % Calculate power mismatches for non-slack buses
    % ---------------------------------------------------------------------
    dP = Psch - Pcalc;
    dQ = Qsch - Qcalc;
    
    % Form combined mismatch vector [ΔP₂...ΔP₆, ΔQ₂...ΔQ₆]
    M  = [dP(ang_idx) dQ(ang_idx)]';
    
    % Check convergence
    err = max(abs(M));
    if err <= tol
        break;
    end
    
    % ---------------------------------------------------------------------
    % Form Jacobian Matrix (PQ×PQ blocks, but modified for SVC)
    % ---------------------------------------------------------------------
    % Standard blocks: J1=∂P/∂δ, J2=∂P/∂|V|, J3=∂Q/∂δ, J4=∂Q/∂|V|
    % For SVC: Replace |V6| column with ∂/∂B column
    
    J1 = zeros(PQ,PQ);  % ∂P/∂δ
    J2 = zeros(PQ,PQ);  % ∂P/∂|V| (with SVC: includes ∂P/∂B)
    J3 = zeros(PQ,PQ);  % ∂Q/∂δ
    J4 = zeros(PQ,PQ);  % ∂Q/∂|V| (with SVC: includes ∂Q/∂B)
    
    for i = 2:N
        for k = 2:N
            if i == k
                % Diagonal elements
                J1(i-1,k-1) = -Qcalc(i) - Vmag(i)^2*abs(Yit(i,i))*sin(angle(Yit(i,i)));
                J2(i-1,k-1) =  Pcalc(i) + Vmag(i)^2*abs(Yit(i,i))*cos(angle(Yit(i,i)));
                J3(i-1,k-1) =  Pcalc(i) - Vmag(i)^2*abs(Yit(i,i))*cos(angle(Yit(i,i)));
                J4(i-1,k-1) =  Qcalc(i) - Vmag(i)^2*abs(Yit(i,i))*sin(angle(Yit(i,i)));
            else
                % Off-diagonal elements
                th = angle(Yit(i,k)) + Vang(k) - Vang(i);
                J1(i-1,k-1) = -Vmag(i)*Vmag(k)*abs(Yit(i,k))*sin(th);
                J2(i-1,k-1) =  Vmag(i)*Vmag(k)*abs(Yit(i,k))*cos(th);
                J3(i-1,k-1) = -Vmag(i)*Vmag(k)*abs(Yit(i,k))*cos(th);
                J4(i-1,k-1) = -Vmag(i)*Vmag(k)*abs(Yit(i,k))*sin(th);
            end
        end
    end
    
    % ---------------------------------------------------------------------
    % Modify Jacobian for SVC: Replace |V6| column with ∂/∂B
    % ---------------------------------------------------------------------
    % ∂P/∂B = 0 (active power independent of SVC susceptance)
    J2(:, svc_bus-1) = 0;
    
    % ∂Q/∂B at SVC bus: Since Q = -|V|²B, then ∂Q/∂B = -|V|²
    J4(:, svc_bus-1) = 0;
    J4(svc_bus-1, svc_bus-1) = -Vmag(svc_bus)^2;
    
    % ---------------------------------------------------------------------
    % Solve Linear System and Update State Variables
    % ---------------------------------------------------------------------
    dx = ( [J1 J2; J3 J4] \ M ).';  % Solve for corrections
    
    % Update voltage angles
    Vang(ang_idx) = Vang(ang_idx) + dx(1:PQ);
    
    % Update voltage magnitudes (excluding SVC bus)
    dVm = dx(PQ+1:end);
    
    % Split corrections: before SVC bus, and after SVC bus
    if svc_bus > 2
        Vmag(2:svc_bus-1) = Vmag(2:svc_bus-1) + dVm(1:svc_bus-2);
    end
    if svc_bus < N
        Vmag(svc_bus+1:N) = Vmag(svc_bus+1:N) + dVm(svc_bus:end);
    end
    
    % Update SVC susceptance
    dB    = dVm(svc_bus-1);  % Correction for B_svc
    B_svc = max(min(B_svc + dB, Bmax), Bmin);  % Apply with limits
end

%% ========================================================================
% POST-CONVERGENCE ANALYSIS AND OUTPUT
% =========================================================================

% Final Y-matrix with converged SVC susceptance
Yfinal = Y;
Yfinal(svc_bus,svc_bus) = Yfinal(svc_bus,svc_bus) + 1i*B_svc;

% Convert angles to degrees
Vdeg = Vang*180/pi;

% Display convergence information
fprintf('Converged in %d iterations. Max mismatch = %.3e\n', iter, err);
fprintf('\n=== BUS VOLTAGES (6-BUS SYSTEM) ===\n');
for b = 1:N
    fprintf('Bus %d: |V| = %.5f  angle = %+8.4f deg\n', b, Vmag(b), Vdeg(b));
end

% Calculate and display SVC performance
Qsvc = -(Vmag(svc_bus)^2)*B_svc*Sbase;  % Reactive power injection [MVAr]
fprintf('\n=== SVC PERFORMANCE ===\n');
fprintf('SVC @ bus %d: B = %+8.5f pu   =>   Q_svc = %+8.3f MVAr\n\n', ...
        svc_bus, B_svc, Qsvc);

%% ========================================================================
% LINE FLOW CALCULATIONS FOR MODIFIED SYSTEM
% =========================================================================
% Note: Line 3-4 is now split into two half-lines: 3-6 and 6-4

lines = [1 2; 1 3; 2 3; 2 4; 2 5; 3 6; 6 4; 4 5];  % Line connections
Zs    = [0.02+0.06i; 0.08+0.24i; 0.06+0.25i; 0.06+0.18i; ...
         0.04+0.12i; z_half;     z_half;     0.08+0.24i];   % Impedances

fprintf('=== LINE FLOWS AND LOSSES ===\n');
fprintf('From To\t I_mag(pu)\t I_ang(deg)\t P_loss(MW)\t Q_loss(MVAr)\n');

lossPQ = zeros(size(lines,1),2);  % Store losses for totaling

for e = 1:size(lines,1)
    i = lines(e,1); 
    k = lines(e,2);
    
    % Calculate current and losses for each line
    [Iabs,Iang,Pl,Ql] = current_and_lineloss(Vmag(i),Vdeg(i),Vmag(k),Vdeg(k),Zs(e),Sbase);
    
    fprintf('%d    %d\t %.5f\t %10.4f\t %10.5f\t %10.5f\n', i,k,Iabs,Iang,Pl,Ql);
    lossPQ(e,:) = [Pl Ql];
end

fprintf('\nTotal line loss:  P = %.5f MW,   Q = %.5f MVAr\n\n', ...
        sum(lossPQ(:,1)), sum(lossPQ(:,2)));

%% ========================================================================
% SLACK BUS GENERATION
% =========================================================================
% Calculate actual generation at slack bus using converged voltages

Pg1 = Sbase * calc_injection_P(1, Vmag, Vang, Yfinal);
Qg1 = Sbase * calc_injection_Q(1, Vmag, Vang, Yfinal);

fprintf('=== SLACK BUS GENERATION ===\n');
fprintf('Slack injections:  P = %.4f MW,  Q = %.4f MVAr\n', Pg1, Qg1);

%% ========================================================================
% HELPER FUNCTIONS
% =========================================================================

function [Iabs,Iang,Ploss,Qloss] = current_and_lineloss(Vm_i,ang_i_deg,Vm_j,ang_j_deg,Z,Sbase)
    % Calculate line current and power losses
    %
    % Inputs:
    %   Vm_i, ang_i_deg : Sending end voltage magnitude [pu] and angle [deg]
    %   Vm_j, ang_j_deg : Receiving end voltage magnitude [pu] and angle [deg]
    %   Z               : Line series impedance [pu]
    %   Sbase           : System base power [MVA]
    %
    % Outputs:
    %   Iabs  : Current magnitude [pu]
    %   Iang  : Current angle [deg]
    %   Ploss : Active power loss [MW]
    %   Qloss : Reactive power loss [MVAr]
    
    Vi = Vm_i*exp(1i*deg2rad(ang_i_deg));
    Vj = Vm_j*exp(1i*deg2rad(ang_j_deg));
    I  = (Vi - Vj)/Z;              % Line current
    
    Iabs = abs(I);
    Iang = rad2deg(angle(I));
    
    S_loss_pu = (Iabs^2)*Z;        % S = I²Z
    Ploss = Sbase*real(S_loss_pu);
    Qloss = Sbase*imag(S_loss_pu);
end

function P = calc_injection_P(i,Vmag,Vang,Y)
    % Calculate active power injection at bus i
    %
    % Inputs:
    %   i    : Bus number
    %   Vmag : Vector of voltage magnitudes [pu]
    %   Vang : Vector of voltage angles [rad]
    %   Y    : Bus admittance matrix
    %
    % Output:
    %   P : Active power injection at bus i [pu]
    
    N = numel(Vmag);
    P = 0;
    for k = 1:N
        th = angle(Y(i,k)) + Vang(k) - Vang(i);
        P = P + Vmag(i)*Vmag(k)*abs(Y(i,k))*cos(th);
    end
end

function Q = calc_injection_Q(i,Vmag,Vang,Y)
    % Calculate reactive power injection at bus i
    %
    % Inputs:
    %   i    : Bus number
    %   Vmag : Vector of voltage magnitudes [pu]
    %   Vang : Vector of voltage angles [rad]
    %   Y    : Bus admittance matrix
    %
    % Output:
    %   Q : Reactive power injection at bus i [pu]
    
    N = numel(Vmag);
    Q = 0;
    for k = 1:N
        th = angle(Y(i,k)) + Vang(k) - Vang(i);
        Q = Q - Vmag(i)*Vmag(k)*abs(Y(i,k))*sin(th);
    end
end

%% ========================================================================
% END OF PROGRAM
% =========================================================================
%
% Key Innovations:
%   1. Line midpoint SVC placement strategy
%   2. Modified 6-bus system from original 5-bus
%   3. π-model representation of half-lines
%   4. Enhanced voltage control at critical transmission point
%   5. Detailed line-by-line power flow analysis
%
% Advantages of Midpoint Placement:
%   - Better voltage support along the line
%   - Reduced voltage sag at line center
%   - More uniform voltage profile
%   - Enhanced power transfer capability
%
% For questions or modifications, contact:
%   Soumik Saha (2006011) - soumik.saha@example.com
%   Sayba Kamal Orni (2006009) - sayba.orni@example.com
% =========================================================================
