disp('structCartpoleTrain2');

mdl = 'struct_cartpole_discrete2';
load_system(mdl)
set_param(mdl, 'FastRestart', 'on');

% load buses
load('cartpoleBuses.mat')


config = structCartpoleConfig2
BonsaiRunTraining(config, mdl, @episodeStartCallback);

disp('end structCartpoleTrain2');

function episodeStartCallback(mdl, episodeConfig)
    disp('epStart Callback')
    in = Simulink.SimulationInput(mdl);
    in = in.setVariable('initialPos', episodeConfig.pos);
    sim(in);
end