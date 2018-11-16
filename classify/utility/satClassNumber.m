function [classNum, nc] = satClassNumber(cfa, satClassOption, varargin)
% Calculate the number of the classes containing saturated pixels.
% Inputs:
%   - cfa: the color filter array
%   - satClassOption: the approach to determine number of the classes for
%                     saturated pixels. It could be:
%                     a)'individual': create class for each individual 
%                                     pixel within patch
%                     b) 'compress' : create class for pixels having same
%                                     color filter
% Outputs:
%   - classNum: number of the classes for the saturated pixels.
% ZL, Brian, VISTA Lab, 2018

switch satClassOption
    case 'individual'
        nc = numel(cfa);
        
    case 'compress'
        nCF = unique(cfa);
        pHist = sum(hist(cfa, nCF), 2);
        rCF = pHist / min(pHist);
        nc = sum(rCF); % NOTE: this may need to be changed
end

classNum = power(2, nc) - 1;

end