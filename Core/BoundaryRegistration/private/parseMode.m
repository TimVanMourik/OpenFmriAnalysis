function modeSetting = parseMode(mode)
%PARSEMODE parses the mode
%Parses the mode. Gives a 1 X 9 row vector that consist of ones where the
%contrast needs to be optimised and a zero when the variable does not
%change.
%There are 2^9 possible modes, so a parser of the mode is needed instead
%instead of writing out all possible combinations
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

stringLength = size(mode, 2);
%If the mode is an empty string
if stringLength == 0
    error('TVM:optimalTransformation:InvalidMode', 'The mode is invalid: it is an empty string')
end
%Modes larger than 12 are invalid: rxrysxsytxty is the longest possible. 
if stringLength > 12
    error('TVM:optimalTransformation:InvalidMode', 'The mode is invalid: it contains to many letters')
end

%This parses the mode into actual settings
modeSetting = false(1, 9);
readIndex = 1;
%If the mode starts with an r...
if mode(readIndex) == 'r'
    readIndex = readIndex + 1;
    %...and contains more letters...
    if stringLength >= readIndex
        %...that is not a t or s...
        if ~(mode(readIndex) == 't' || mode(readIndex) == 's')
            %...then only some rotation are applied.
            %If the next letter is an x
            if mode(readIndex) == 'x'
                modeSetting(1) = true;
                readIndex = readIndex + 1;
                %If the mode contains more letters...
                if stringLength >= readIndex
                    %...Of which the first one is an r...
                    if mode(readIndex) == 'r'
                        readIndex = readIndex + 1;
                        if stringLength >= readIndex
                            %...and the next is a y
                            if mode(readIndex) == 'y'
                                readIndex = readIndex + 1;
                                modeSetting(2) = true;
                            %...and the next is a z
                            elseif mode(readIndex) == 'z'
                                readIndex = readIndex + 1;
                                modeSetting(3) = true;
                            else
                                error('TVM:optimalTransformation:InvalidMode', 'The mode is invalid: it contains an illegal sequence')
                            end
                        else
                            %string has been parsed, method interrupted
                            return
                        end
                    end
                else
                    %string has been parsed, method interrupted
                    return
                end
            %...otherwise if the next is a y
            elseif mode(readIndex) == 'y'
                modeSetting(2) = true;
                readIndex = readIndex + 1;
                %If the mode contains more letters...
                if stringLength >= readIndex
                    %...Of which the first one is an r...
                    if mode(readIndex) == 'r'
                        readIndex = readIndex + 1;
                        if stringLength >= readIndex
                            %...and the next is a z
                            if mode(readIndex) == 'z'
                                readIndex = readIndex + 1;
                                modeSetting(3) = true;
                            end
                        else
                            %string has been parsed, method interrupted
                            return
                        end
                    end
                else
                    %string has been parsed, method interrupted
                    return
                end
            %...otherwise if the next is a z
            elseif mode(readIndex) == 'z'
                modeSetting(3) = trueu;
            end       
        %else, all rotations are set to 1
        else
            modeSetting(1) = true;
            modeSetting(2) = true;
            modeSetting(3) = true;  
        end
    else
        modeSetting(1) = true;
        modeSetting(2) = true;
        modeSetting(3) = true;
    end
end
%If there are more chars in the the string, go on with translation
if stringLength < readIndex
    %string has been parsed, method interrupted
    return
end
if mode(readIndex) == 's'
    readIndex = readIndex + 1;
    %...and contains more letters...
    if stringLength >= readIndex
        %...that is not a t...
        if mode(readIndex) ~= 't'
            %...then only some rotation are applied.
            %If the next letter is an x
            if mode(readIndex) == 'x'
                modeSetting(4) = true;
                readIndex = readIndex + 1;
                %If the mode contains more letters...
                if stringLength >= readIndex
                    %...of which the first one is an s...
                    if mode(readIndex) == 's'
                        readIndex = readIndex + 1;
                        if stringLength >= readIndex
                            %...and the next is a y
                            if mode(readIndex) == 'y'
                                readIndex = readIndex + 1;
                                modeSetting(5) = true;
                            %...and the next is a z
                            elseif mode(readIndex) == 'z'
                                readIndex = readIndex + 1;
                                modeSetting(6) = true;
                            else
                                error('TVM:optimalTransformation:InvalidMode', 'The mode is invalid: it contains an illegal sequence')
                            end
                        else
                            %string has been parsed, method interrupted
                            return
                        end
                    end
                else
                    %string has been parsed, method interrupted
                    return
                end
            %...otherwise if the next is a y
            elseif mode(readIndex) == 'y'
                modeSetting(5) = true;
                readIndex = readIndex + 1;
                %If the mode contains more letters...
                if stringLength >= readIndex
                    %...Of which the first one is an s...
                    if mode(readIndex) == 's'
                        readIndex = readIndex + 1;
                        if stringLength >= readIndex
                            %...and the next is a z
                            if mode(readIndex) == 'z'
                                readIndex = readIndex + 1;
                                modeSetting(6) = true;
                            end
                        else
                            %string has been parsed, method interrupted
                            return
                        end
                    end
                else
                    %string has been parsed, method interrupted
                    return
                end
            %...otherwise if the next is a z
            elseif mode(readIndex) == 'z'
                modeSetting(6) = true;
            end
        %else, all rotations are set to 1
        else
            %readIndex = readIndex + 1;
            modeSetting(4) = true;
            modeSetting(5) = true;
            modeSetting(6) = true;  
        end
    else
        %readIndex = readIndex + 1;
        modeSetting(4) = true;
        modeSetting(5) = true;
        modeSetting(6) = true; 
    end
end
%If there are more chars in the the string, go on with translation
if stringLength < readIndex
    %string has been parsed, method interrupted
    return
end
if mode(readIndex) == 't'
    readIndex = readIndex + 1;
    %...and contains more letters...
    if stringLength >= readIndex
        %...then only some rotation are applied.
        %If the next letter is an x
        if mode(readIndex) == 'x'
            modeSetting(7) = true;
            readIndex = readIndex + 1;
            %If the mode contains more letters...
            if stringLength >= readIndex
                %...of which the first one is an t...
                if mode(readIndex) == 't'
                    readIndex = readIndex + 1;
                    if stringLength >= readIndex
                        %...and the next is a y
                        if mode(readIndex) == 'y'
                            modeSetting(8) = true;
                        %...and the next is a z
                        elseif mode(readIndex) == 'z'
                            modeSetting(9) = true;
                        else
                            error('TVM:optimalTransformation:InvalidMode', 'The mode is invalid: it contains an illegal sequence')
                        end
                    else
                        %string has been parsed, method interrupted
                        return
                    end
                end
            else
                %string has been parsed, method interrupted
                return
            end
        %...otherwise if the next is a y
        elseif mode(readIndex) == 'y'
            modeSetting(8) = true;
            readIndex = readIndex + 1;
            %If the mode contains more letters...
            if stringLength >= readIndex
                %...Of which the first one is an s...
                if mode(readIndex) == 't'
                    readIndex = readIndex + 1;
                    if stringLength >= readIndex
                        %...and the next is a z
                        if mode(readIndex) == 'z'
                            modeSetting(9) = true;
                        end
                    else
                        %string has been parsed, method interrupted
                        return
                    end
                end
            else
                %string has been parsed, method interrupted
                return
            end
        %...otherwise if the next is a z
        elseif mode(readIndex) == 'z'
            modeSetting(9) = true;
        %else, all rotations are set to 1
        else
            modeSetting(7) = true;
            modeSetting(8) = true;
            modeSetting(9) = true;  
        end
    else
        modeSetting(7) = true;
        modeSetting(8) = true;
        modeSetting(9) = true;  
    end
end

end %end function