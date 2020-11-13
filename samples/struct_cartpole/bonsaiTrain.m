mdl = 'struct_cartpole_discrete';
load_system(mdl)
set_param(mdl, 'FastRestart', 'on');

% load buses
load('cartpoleBuses.mat')


config = bonsaiConfig
BonsaiRunTraining(config, mdl, @episodeStartCallback);

function episodeStartCallback(mdl, episodeConfig)
    disp('epStart Callback')
    in = Simulink.SimulationInput(mdl);
    in = in.setVariable('initialPos', episodeConfig);
    sim(in);
end