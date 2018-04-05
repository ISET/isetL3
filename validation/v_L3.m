function v_L3
%
% This the top level validation script.  We should make sure that when we
% add new functions or change things the basic code does the same thing.
% Like v_ISET.
%
% We should start writing these validation scripts using the
% UnitTestToolbox.
%
% This one is so high level that it is not yet informative. And it doesn't
% yet have assert() or other real checks.  It is just a reminder of how to
% start.
%
% BW Vistasoft Team, 2015

% Unit test
run(L3Test);

% We might implement more system level tests and they will go under here.

end