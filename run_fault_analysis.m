% Main script to run fault analysis
clear; clc;

fprintf('IEEE 9-Bus System Fault Analysis\n');
fprintf('================================\n\n');

% Load test system data
ieee9_A1;

% Calculate admittance matrix
Y = admittance(nfrom, nto, r, x, b);

% Pre-fault voltages
V_prefault = linsolve(Y, Iint);

fprintf('Pre-fault Voltages:\n');
fprintf('Bus\tMagnitude (pu)\tAngle (deg)\n');
for k = 1:length(V_prefault)
    fprintf('%d\t%.4f\t\t%.2f\n', k, abs(V_prefault(k)), angle(V_prefault(k))*180/pi);
end

% Analyze bolted faults at each node
fprintf('\nBolted Fault Analysis (Zf = 0):\n');
fprintf('Fault Bus\tFault Current (pu)\tFault Bus Voltage (pu)\n');

for fault_bus = 1:9
    [If, Vf] = fault(Y, Iint, fault_bus, 0);
    fprintf('%d\t\t%.4f\t\t\t%.4f\n', fault_bus, abs(If), abs(Vf(fault_bus)));
end

fprintf('\nAnalysis complete!\n');
