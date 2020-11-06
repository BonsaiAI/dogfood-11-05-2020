% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% The main function of the bonsai matlab function block.
%
% At runtime the REPLACE_WITH_INITIALIZED_ACTION_VAR text is overwritten with the correct
% initialized variable. The reason for this is that the matlab compiler
% does not let us use external code to initialize the output variables.
% However the correct dimensions of the output variable are contained in
% the external code.
%
% When using buses REPLACE_WITH_INITIALIZED_ACTION_VAR is replaced with an empty string.
% When using a flat vector, REPLACE_WITH_INITIALIZED_ACTION_VAR is replaced with action = zeros(1, N)
% where N is the length of the vector.

function [action, reset]= fcn(state, halted)
    coder.extrinsic('bonsaiMATLABFcnWrapper')
    
    REPLACE_WITH_INITIALIZED_ACTION_VAR
    reset = false;
    [action, reset] = bonsaiMATLABFcnWrapper(state, halted);
end