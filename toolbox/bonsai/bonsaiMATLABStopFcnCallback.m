% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% StopFcn that is added to the bonsai block at runtime. It will terminate
% the session when necessary upon exiting the block.

% terminate session if we are in an assessment session
session = bonsai.Session.getInstance();
if session.isTrainingSession
    % session will be terminated by BonsaiRunTraining
else
    session.terminateSession();
end