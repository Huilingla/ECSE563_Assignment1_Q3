% RUN_FAULT_ANALYSIS Validate fault analysis for IEEE 9-bus system
clear all; close all; clc;

% Load the IEEE 9-bus system data
ieee9_A1;

fprintf('=== THREE-PHASE FAULT ANALYSIS - IEEE 9-BUS SYSTEM ===\n\n');

% Calculate admittance matrix
Y = admittance(nfrom, nto, r, x, b);
N = size(Y, 1);

fprintf('System has %d nodes\n\n', N);

% Test 1: Bolted faults (Zf = 0) at each node
fprintf('TEST 1: BOLTED FAULTS (Zf = 0) AT EACH NODE\n');
fprintf('===========================================\n\n');

Zf_bolted = 0;  % Bolted fault

for fault_node = 1:N
    fprintf('\n*** FAULT AT NODE %d ***\n', fault_node);
    fprintf('------------------------\n');
    
    [If, Vf] = fault(Y, Iint, fault_node, Zf_bolted);
    
    % Display voltage magnitudes at all nodes
    fprintf('\nVoltage magnitudes during fault:\n');
    fprintf('Node   Voltage (p.u.)   Angle (deg)\n');
    fprintf('----   ---------------   ----------\n');
    
    for i = 1:N
        V_mag = abs(Vf(i));
        V_angle = angle(Vf(i)) * 180/pi;
        if i == fault_node
            fprintf('%2d*    %8.4f         %8.2f  (FAULTED)\n', i, V_mag, V_angle);
        else
            fprintf('%2d     %8.4f         %8.2f\n', i, V_mag, V_angle);
        end
    end
    
    % Calculate voltage dips
    V_prefault = linsolve(Y, Iint);
    voltage_dips = abs(V_prefault) - abs(Vf);
    
    fprintf('Maximum voltage dip: %.4f p.u. at node %d\n', ...
            max(voltage_dips), find(voltage_dips == max(voltage_dips), 1));
    
    fprintf('\n%s\n', repmat('-', 60));
end

% Test 2: Faults with different impedance values
fprintf('\n\nTEST 2: FAULTS WITH DIFFERENT IMPEDANCE VALUES\n');
fprintf('============================================\n\n');

fault_node = 5;  % Choose a representative node
Zf_values = [0, 0.01+0.1j, 0.1+0.5j];  % Different fault impedances

fprintf('Fault analysis at node %d with different Zf values:\n', fault_node);
fprintf('Zf (p.u.)         |If| (p.u.)    |Vf(%d)| (p.u.)\n', fault_node);
fprintf('----------------   -----------    --------------\n');

for i = 1:length(Zf_values)
    Zf = Zf_values(i);
    [If, Vf] = fault(Y, Iint, fault_node, Zf);
    
    fprintf('%.3f + j%.3f   %8.4f        %8.4f\n', ...
            real(Zf), imag(Zf), abs(If), abs(Vf(fault_node)));
end

% Test 3: Comprehensive analysis
fprintf('\n\nTEST 3: COMPREHENSIVE FAULT ANALYSIS\n');
fprintf('===================================\n\n');

% Calculate impedance matrix for reference
Z = zeros(N, N);
I_matrix = eye(N);
for col = 1:N
    e_col = I_matrix(:, col);
    z_col = linsolve(Y, e_col);
    Z(:, col) = z_col;
end

fprintf('Self-impedances (Zii) for fault current estimation:\n');
fprintf('Node   Zii (p.u.)          |Zii| (p.u.)\n');
fprintf('----   ------------------   -----------\n');

for i = 1:N
    fprintf('%2d     %.4f + j%.4f   %8.4f\n', ...
            i, real(Z(i,i)), imag(Z(i,i)), abs(Z(i,i)));
end

% Calculate theoretical maximum fault currents (bolted faults)
fprintf('\nTheoretical maximum fault currents (Zf = 0):\n');
fprintf('Node   |Eeq| (p.u.)   |Zeq| (p.u.)   |If_max| (p.u.)\n');
fprintf('----   ------------   ------------   --------------\n');

V_prefault = linsolve(Y, Iint);
for i = 1:N
    Eeq = V_prefault(i);
    Zeq = Z(i,i);
    If_max = abs(Eeq) / abs(Zeq);  % Approximate magnitude
    
    fprintf('%2d     %8.4f      %8.4f       %8.4f\n', ...
            i, abs(Eeq), abs(Zeq), If_max);
end

% Create summary plot of fault currents
fault_currents = zeros(N, 1);
for i = 1:N
    [If, ~] = fault(Y, Iint, i, 0);
    fault_currents(i) = abs(If);
end

figure;
bar(1:N, fault_currents);
xlabel('Faulted Node');
ylabel('Fault Current Magnitude (p.u.)');
title('Three-Phase Bolted Fault Currents - IEEE 9-Bus System');
grid on;

% Save results
fprintf('\nSaving results to fault_analysis_results.mat\n');
save('fault_analysis_results.mat', 'Y', 'Iint', 'Z', 'fault_currents');

fprintf('\n=== FAULT ANALYSIS COMPLETE ===\n');
