% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Script to configure assessment of your trained Bonsai brain. Assessment can be
% run in 3 steps:
%   1. run this script to configure an assessment session and set required variables
%   2. open the model and click "Run"
%   3. begin assessmnet in the web, selecting the "Simulink Cartpole" simulator.

initializeMoab;

% see the visualization
set_param(moab_mdl, 'FastRestart', 'on');

% load model
open_system(moab_mdl);

% configure assessment
config = bonsaiConfig;
BonsaiConfigureAssessment(config, moab_mdl, @episodeStartCallback);

% callback for provided episode configuration
function episodeStartCallback(mdl, episodeConfig)

    %assessment differs from training -- we assume the model is already
    %open so we use assignin() instead of SimulationInput 

    tilt_x0 = episodeConfig.initial_pitch;
    tilt_y0 = episodeConfig.initial_roll;
    
    assignin('base', 'tilt_x0',tilt_x0);
    assignin('base', 'tilt_y0',tilt_y0);
    assignin('base', 'ball_x0',episodeConfig.initial_x);
    assignin('base', 'ball_y0',episodeConfig.initial_y);
    
    assignin('base', 'ball_vel_x0',episodeConfig.initial_vel_x);
    assignin('base', 'ball_vel_y0',episodeConfig.initial_vel_y);
    
    h = evalin('base','DEFAULT_PLATE_HEIGHT+z_offset');
    [a1,a2,a3] = runMixer(h, tilt_x0, tilt_y0);
    
    assignin('base', 'arm1_alpha0',a1);
    assignin('base', 'arm2_alpha0',a2);
    assignin('base', 'arm3_alpha0',a3);

    %tutorial 2
    if isfield(episodeConfig, 'ball_radius') == 1
        disp('assessing tutorial 2');
        
        ball_radius = episodeConfig.ball_radius;
        ball_shell = episodeConfig.ball_shell;
   
        % Recalculate variables affected by ball parameter changes
        ball_mass = evalin('base','DEFAULT_BALL_MASS');
        ball_cor = evalin('base','DEFAULT_BALL_COR');
        ball_z0 = evalin('base','PLATE_ORIGIN_TO_SURFACE_OFFSET') + ball_radius;
        ball_moi  = calcMOI(ball_radius,ball_shell,ball_mass);
        [ball_stiffness, ball_damping, ball_transitionwidth] = cor2SpringDamperParams(ball_cor,ball_mass);
        
        assignin('base', 'ball_radius',ball_radius);
        assignin('base', 'ball_mass',ball_mass);
        assignin('base', 'ball_shell',ball_shell);
        assignin('base', 'ball_z0',ball_z0);

        assignin('base', 'ball_stiffness',ball_stiffness);
        assignin('base', 'ball_damping',ball_damping);
        assignin('base', 'ball_transitionwidth',ball_transitionwidth);
        assignin('base', 'ball_moi',ball_moi);    
    end
   
    %tutorial 3
    if isfield(episodeConfig, 'obstacle_radius') == 1
        disp('assessing tutorial 3');
        
        ob_radius = episodeConfig.obstacle_radius;
       
        assignin('base', 'obstacle_radius',ob_radius);
        assignin('base', 'obstacle_pos_x0',episodeConfig.obstacle_x);
        assignin('base', 'obstacle_pos_y0',episodeConfig.obstacle_y);
    end
end
