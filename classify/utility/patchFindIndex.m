function idx = patchFindIndex(curLabel, lv, p_Type, varargin)
    % find the indices for a certain label, and for certain channel
    % if needed.
    assert(length(varargin) < 2, 'No more than 1 inputs.');
    if (length(varargin) == 1)
        channelNumber = varargin{1};
    end

    idx = find(curLabel(:,1) == lv);
    if ~notDefined('channelNumber')
        idx = find(p_Type(idx) == channelNumber);
    end
end