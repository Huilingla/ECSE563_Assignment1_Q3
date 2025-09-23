function [If, Vf] = fault(Y, Init, idfault, Zf)
% FAULT Calculate fault currents and node voltages during balanced three-phase faults
% Using Matrix Inversion Lemma approach from the slides
%
% Inputs:
%   Y       - admittance matrix of the healthy network
%   Init    - vector of pre-fault internal currents
%   idfault - index of the faulted node
%   Zf      - impedance of the fault
%
% Outputs:
%   If      - fault current at idfault
%   Vf      - vector of network node voltages during the fault

    % Number of buses
    nbus = size(Y, 1);
    
    % Pre-fault open-circuit voltages (slide 6)
    Voc = linsolve(Y, Init);
    
    if isinf(Zf)  % No fault case
        Vf = Voc;
        If = 0;
        return;
    end
    
    % Calculate Thévenin equivalent parameters (slides 14-15)
    % Zeq = Zii (input impedance at faulted node)
    ei = zeros(nbus, 1);
    ei(idfault) = 1;
    
    % Solve for Zii: Y * v = ei to get the ith column of Z
    v_col = linsolve(Y, ei);
    Zeq = v_col(idfault);  % Zii = e_i^T * Y^-1 * e_i
    
    % Eeq = Voc at faulted node (slide 15)
    Eeq = Voc(idfault);
    
    % Calculate fault current using Thévenin equivalent (slide 16)
    if Zf == 0  % Bolted fault
        If = Eeq / Zeq;
    else
        If = Eeq / (Zeq + Zf);
    end
    
    % Calculate fault voltages using Matrix Inversion Lemma (slides 20-22)
    % Vf = Voc - Y^-1 * ei * If  (from slide 22)
    Vf = Voc - v_col * If;
    
    % Alternative MIL formulation from slide 21:
    % Vf = Voc - (v_col * v_col' * Init) / (Zeq + Zf);
    % But the first method is more numerically stable
end
