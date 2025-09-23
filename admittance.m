function Y = admittance(nfrom, nto, r, x, b)
% ADMITTANCE Calculate the admittance matrix for an AC network
    nbus = max([nfrom; nto]);
    Y = zeros(nbus, nbus) + 1i*zeros(nbus, nbus);
    
    for k = 1:length(nfrom)
        z = r(k) + 1i*x(k);
        y_series = 1/z;
        
        i = nfrom(k);
        j = nto(k);
        
        Y(i,j) = Y(i,j) - y_series;
        Y(j,i) = Y(j,i) - y_series;
        Y(i,i) = Y(i,i) + y_series;
        Y(j,j) = Y(j,j) + y_series;
        
        y_shunt = 1i*b(k)/2;
        Y(i,i) = Y(i,i) + y_shunt;
        Y(j,j) = Y(j,j) + y_shunt;
    end
end
