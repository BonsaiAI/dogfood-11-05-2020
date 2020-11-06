disp('structCartpoleTrain');

mdl = 'struct_cartpole_discrete';
load_system(mdl)
set_param(mdl, 'FastRestart', 'on');

% load buses
load('cartpoleBuses.mat')


config = structCartpoleConfig
BonsaiRunTraining(config, mdl, @episodeStartCallback);

disp('end structCartpoleTrain');

function episodeStartCallback(mdl, episodeConfig)
    disp('epStart Callback')
    in = Simulink.SimulationInput(mdl);
    in = in.setVariable('initialPos', episodeConfig.pos);
    sim(in);
end