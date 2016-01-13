function distance = tvm_partialVolumeArea(distance)
% The mode needs to be added as soon a different method is implementedy
% function distance = partialVolumeArea(distance, mode)
%
% The integral of a partial volume kernel from negative infinity to [input]
% Starting at zero, going to 1
%
% NB. distance is in voxels

method = 'cubic';
switch method
    %An approximation of a PVE kernel by means of a cubic function:
    %for      distance <= -1,   area = 0, 
    %for -1 < distance <= 0,    area = 0, 1 - 3 * x ^ 2 - 2 * x ^3
    %for  0 < distance <  1,    area = 0, 1 - 3 * x ^ 2 + 2 * x ^3
    %for      distance >= 1,    area = 0, 
    case 'cubic'
        %first scale it to a kernel from -1 to 1
        distance = distance * 2 / sqrt(3);
        
        %for memory friendliness, the same array is returned. This creates
        %the necessity to be careful with the order of the operations.
        zeroIndices = distance == 0;
        
        distance(distance >= 1) = 1;
        distance(distance <= -1) = 0;
        
        indices = distance > 0  & distance < 1;
        distance(indices) = 1 / 2 + distance(indices) - distance(indices) .^ 3 + distance(indices) .^ 4 / 2;
        
        indices = distance > -1 & distance < 0;
        distance(indices) = 1 / 2 + distance(indices) - distance(indices) .^ 3 - distance(indices) .^ 4 / 2;
        
        distance(zeroIndices) = 1 /2;
        
    case 'p20'
%         f = @(x, a)a(1) + a(2) * x .^ 2 + a(3) * x .^ 4 + a(4) * x .^ 6 + a(5) * x .^ 8 + a(6) * x .^ 10 + a(7) * x .^ 12 + a(8) * x .^ 14 + a(9) * x .^ 16 + a(10) * x .^ 18 + a(11) * x .^ 20;
        F = @(x, a)0.5 + a(1) * x + a(2) * x .^ 3 / 3 + a(3) * x .^ 5 / 5 + a(4) * x .^ 7 / 7 + a(5) * x .^ 9 / 9 + a(6) * x .^ 11 / 11 + a(7) * x .^ 13 / 13 + a(8) * x .^ 15 / 15 + a(9) * x .^ 17 / 17 + a(10) * x .^ 19 / 19 + a(11) * x .^ 21 / 21;
        coefficients = ...
            [0.5593585,	...% x^0
            -0.0373305,	...% x^2
            -2.2497690,	...% x^4
             9.2712318,	...% x^6
            -18.6792429,...% x^8
             20.2455425,...% x^10
            -12.7699239,...% x^12
             4.8372428,	...% x^14
            -1.0801467,	...% x^16
             0.1299689,	...% x^18
            -0.0064062];...% x^20
            
        indices = distance > -sqrt(3)  & distance < sqrt(3);
        distance(distance <= -sqrt(3)) = 0;
        distance(distance >=  sqrt(3)) = 1;
        distance(indices) = F(distance(indices), coefficients);
        
    %A proper PVE kernel has not yet been implemented, if an exact formula can be computed.
    case 'PVE'
end

end %end function