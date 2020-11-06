% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Main entrypoint for training a Bonsai brain. After starting this script you
% must begin training your brain in the web, selecting the "Simulink Cartpole"
% simulator.

% load model and enable fast restart
mdl = 'cartpole_discrete';
load_system(mdl);
set_param(mdl, 'FastRestart', 'on');

% run training
config = bonsaiConfig;
BonsaiRunTraining(config, mdl, @episodeStartCallback);

% callback for running model with provided episode configuration
function episodeStartCallback(mdl, episodeConfig)
    in = Simulink.SimulationInput(mdl);
    in = in.setVariable('initialPos', episodeConfig.pos);
    sim(in);
end
