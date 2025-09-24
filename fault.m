function [If, Vf] = fault(Y, Iint, idfault, Zf)
% FAULT Calculate fault currents and node voltages during balanced three-phase faults.
%
%   [IF, VF] = FAULT(Y, IINT, IDFAULT, ZF) computes the fault current and
%   node voltages during a balanced three-phase fault using Thevenin equivalent.
%
%   Inputs:
%     Y       - NxN admittance matrix of the healthy network
%     Iint    - Nx1 vector of pre-fault internal current injections
%     idfault - Scalar index of the faulted node
%     Zf      - Impedance of the fault (scalar)
%
%   Outputs:
%     If      - Fault current at the faulted node (complex)
%     Vf      - Nx1 vector of node voltages during the fault
%
%   Method:
%     1. Find Thevenin equivalent at faulted node
%     2. Calculate fault current using Thevenin equivalent circuit
%     3. Compute node voltages during fault conditions

    fprintf('=== THREE-PHASE FAULT ANALYSIS ===\n\n');
    fprintf('Fault at node %d with Zf = %.4f + j%.4f p.u.\n', ...
            idfault, real(Zf), imag(Zf));
    
    % Step 0: Validate inputs
    N = size(Y, 1);
    if length(Iint) ~= N
        error('Iint must have the same dimension as Y');
    end
    if idfault < 1 || idfault > N
        error('idfault must be between 1 and %d', N);
    end
    
    % Step 1: Calculate Thevenin equivalent using impedance matrix
    fprintf('\nStep 1: Calculating Thevenin equivalent at node %d\n', idfault);
    fprintf('---------------------------------------------------\n');
    
    % Calculate impedance matrix Z = Y^(-1) using linsolve
    Z = zeros(N, N);
    I_matrix = eye(N);
    for col = 1:N
        e_col = I_matrix(:, col);
        z_col = linsolve(Y, e_col);
        Z(:, col) = z_col;
    end
    
    % Thevenin voltage (pre-fault voltage at faulted node)
    V_prefault = linsolve(Y, Iint);
    Eeq = V_prefault(idfault);
    fprintf('Thevenin voltage Eeq at node %d: %.4f + j%.4f p.u. (|Eeq| = %.4f p.u.)\n', ...
            idfault, real(Eeq), imag(Eeq), abs(Eeq));
    
    % Thevenin impedance (diagonal element of Z matrix)
    Zeq = Z(idfault, idfault);
    fprintf('Thevenin impedance Zeq at node %d: %.4f + j%.4f p.u. (|Zeq| = %.4f p.u.)\n', ...
            idfault, real(Zeq), imag(Zeq), abs(Zeq));
    
    % Step 2: Calculate fault current
    fprintf('\nStep 2: Calculating fault current\n');
    fprintf('---------------------------------\n');
    
    % Fault admittance (inverse of fault impedance)
    if Zf == 0
        yf = inf;  % Bolted fault
    else
        yf = 1 / Zf;
    end
    
    % Fault current using Thevenin equivalent: If = Eeq / (Zeq + Zf)
    If = Eeq / (Zeq + Zf);
    fprintf('Fault current If: %.4f + j%.4f p.u. (|If| = %.4f p.u.)\n', ...
            real(If), imag(If), abs(If));
    
    % Step 3: Calculate node voltages during fault
    fprintf('\nStep 3: Calculating node voltages during fault\n');
    fprintf('---------------------------------------------\n');
    
    % External current injection vector: Iext = -If at faulted node, 0 elsewhere
    Iext = zeros(N, 1);
    Iext(idfault) = -If;
    
    % Total current during fault: Ifault = Iint + Iext
    Ifault = Iint + Iext;
    
    % Node voltages during fault: Vf = Z * Ifault
    Vf = Z * Ifault;
    
    fprintf('Node voltages during fault calculated successfully\n');
    
    % Display results
    fprintf('\nRESULTS SUMMARY:\n');
    fprintf('================\n');
    fprintf('Faulted node: %d\n', idfault);
    fprintf('Fault impedance Zf: %.4f + j%.4f p.u.\n', real(Zf), imag(Zf));
    fprintf('Fault current |If|: %.4f p.u.\n', abs(If));
    fprintf('Voltage at faulted node |Vf(%d)|: %.4f p.u.\n', idfault, abs(Vf(idfault)));
end
