% Enhanced Fault Analysis Validation for IEEE 9-bus test system
clear; clc;

% Load test system data
ieee9_A1;

% Calculate admittance matrix
Y = admittance(nfrom, nto, r, x, b);

fprintf('IEEE 9-Bus System - Corrected Fault Analysis\n');
fprintf('===========================================\n\n');

% Pre-fault voltages
Voc = linsolve(Y, Iint);

fprintf('Pre-fault Open-Circuit Voltages:\n');
fprintf('Bus\tMagnitude (pu)\tAngle (deg)\n');
for k = 1:length(Voc)
    fprintf('%d\t%.4f\t\t%.2f\n', k, abs(Voc(k)), angle(Voc(k))*180/pi);
end

% Analyze bolted faults (Zf = 0) at each node
Zf = 0;  % Bolted fault

fprintf('\n\nBolted Fault Analysis (Zf = 0) - Corrected Method:\n');
fprintf('==================================================\n');

fprintf('\nFault Bus\tFault Current (pu)\tFault Bus Voltage (pu)\tEeq\t\tZeq\n');

for fault_bus = 1:9
    [If, Vf] = fault(Y, Iint, fault_bus, Zf);
    
    % Calculate Thévenin parameters for verification
    ei = zeros(9, 1);
    ei(fault_bus) = 1;
    v_col = linsolve(Y, ei);
    Zeq = v_col(fault_bus);
    Eeq = Voc(fault_bus);
    
    fprintf('%d\t\t%.4f ∠ %.1f°\t\t%.6f\t\t%.4f\t%.4f\n', ...
            fault_bus, abs(If), angle(If)*180/pi, abs(Vf(fault_bus)), abs(Eeq), abs(Zeq));
end

% Detailed analysis for one fault case
fprintf('\n\nDetailed Analysis for Fault at Bus 5:\n');
fprintf('====================================\n');

fault_bus = 5;
[If, Vf] = fault(Y, Iint, fault_bus, 0);

fprintf('Fault Current: %.4f ∠ %.2f° pu\n', abs(If), angle(If)*180/pi);
fprintf('\nVoltage Profile during Fault:\n');
fprintf('Bus\tPre-fault V\tFault V\t\t%% Drop\n');
for k = 1:9
    Vpre = abs(Voc(k));
    Vfault = abs(Vf(k));
    drop_pct = ((Vpre - Vfault) / Vpre) * 100;
    fprintf('%d\t%.4f\t\t%.4f\t\t%.1f%%\n', k, Vpre, Vfault, drop_pct);
end

% Validation using the MIL formula from slide 21
fprintf('\nValidation using Matrix Inversion Lemma:\n');
ei = zeros(9, 1);
ei(fault_bus) = 1;
v_col = linsolve(Y, ei);
Zeq = v_col(fault_bus);
If_mil = Voc(fault_bus) / Zeq;
Vf_mil = Voc - v_col * If_mil;

fprintf('If (MIL method): %.4f ∠ %.2f° pu\n', abs(If_mil), angle(If_mil)*180/pi);
fprintf('Error in If: %.2e pu\n', abs(If - If_mil));
fprintf('Error in Vf: %.2e pu\n', norm(Vf - Vf_mil));
