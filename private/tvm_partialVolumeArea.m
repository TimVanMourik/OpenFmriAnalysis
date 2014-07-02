function distance = partialVolumeArea(distance)
% The mode needs to be added as soon a different method is implementedy
% function distance = partialVolumeArea(distance, mode)
%
% The integral of a partial volume kernel from negative infinity to [input]
% Starting at zero, going to 1
%
mode = 'cubic';
switch mode
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
        
    %A proper PVE kernel has not yet been implemented.
    case 'PVE'
end

end %end function