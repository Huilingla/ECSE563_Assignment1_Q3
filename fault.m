function [If, Vf] = fault(Y, Init, idfault, Zf)
% FAULT Calculate fault currents and node voltages during balanced three-phase faults
    nbus = size(Y, 1);
    
    Yf = zeros(nbus, nbus);
    if Zf ~= 0
        Yf(idfault, idfault) = 1/Zf;
    end
    
    Y_mod = Y + Yf;
    Vf = linsolve(Y_mod, Init);
    
    if Zf == 0
        If = Init(idfault) - Y(idfault, :) * Vf;
    else
        If = Vf(idfault) / Zf;
    end
end
