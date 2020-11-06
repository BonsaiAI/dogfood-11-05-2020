% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

%%% NOTES %%%
%{
The general flow of Bonsai is:

1. Session register
2. Episode start
3. Receive callback with initialization parameters 
4. Send episode step information using the State inputs
5. Receive an Action from Bonsai
6. The Bonsai Action is an input to a subsystem
7. Steps 5 and 6 are repeated until an episode End event or an error occurs
8. Upon an episode End event, the model will close and the Bonsai toolbox will create 
   a new Episode. Steps 2-8 will repeat.

When Bonsai initiates a training session, a callback is fired and handled in episodeStartCallback. 
This method configures the model environment and sets parameters to what a particular model 
requires. The model should also be started in this callback. Some users may choose to pass just th
e *mdl* to *sim()* while others have more dynamic SimulationInput requirements.
%}

%initializes variables, paths, etc.
initializeMoab;

% for performance
set_param(moab_mdl, 'FastRestart', 'on');

% run training
config = bonsaiConfig;
BonsaiRunTraining(config, moab_mdl, @episodeStartCallback);

% callback for setting the model's initial episode configuration
function episodeStartCallback(mdl, episodeConfig)
    
%{

- Each time you start a new training Episode in Bonsai, the Bonsai brain will send initial 
  start up parameters that can be used to initialize the model to set it to various states
- The Moab model is used in multiple tutorials. However, each tutorial has a slightly different 
  set of parameters. All tutorials use the first set of variables (tilt_x0. tilt_y0, etc). 
- The *isfield* function determines whether a configuration parameter is included and then 
  set the parameter values accordingly. 

 %} 

    in = Simulink.SimulationInput(mdl);
    
    tilt_x0 = episodeConfig.initial_pitch;
    tilt_y0 = episodeConfig.initial_roll;
    
    in = in.setVariable('tilt_x0',tilt_x0);
    in = in.setVariable('tilt_y0',tilt_y0);
    in = in.setVariable('ball_x0',episodeConfig.initial_x);
    in = in.setVariable('ball_y0',episodeConfig.initial_y);
    
    in = in.setVariable('ball_vel_x0',episodeConfig.initial_vel_x);
    in = in.setVariable('ball_vel_y0',episodeConfig.initial_vel_y);
    
    h = evalin('base','DEFAULT_PLATE_HEIGHT+z_offset');
    [a1,a2,a3] = runMixer(h, tilt_x0, tilt_y0);
    
    in = in.setVariable('arm1_alpha0',a1);
    in = in.setVariable('arm2_alpha0',a2);
    in = in.setVariable('arm3_alpha0',a3);

    %tutorial 2
    if isfield(episodeConfig, 'ball_radius') == 1
        disp('training tutorial 2');
        
        
        ball_radius = episodeConfig.ball_radius;
        ball_shell = episodeConfig.ball_shell;
   
        % Recalculate variables affected by ball parameter changes
        ball_mass = evalin('base','DEFAULT_BALL_MASS');
        ball_cor = evalin('base','DEFAULT_BALL_COR');
        ball_z0 = evalin('base','PLATE_ORIGIN_TO_SURFACE_OFFSET') + ball_radius;
        ball_moi  = calcMOI(ball_radius,ball_shell,ball_mass);
        [ball_stiffness, ball_damping, ball_transitionwidth] = cor2SpringDamperParams(ball_cor,ball_mass);
        
        in = in.setVariable('ball_radius',ball_radius);
        in = in.setVariable('ball_mass',ball_mass);
        in = in.setVariable('ball_shell',ball_shell);
        in = in.setVariable('ball_z0',ball_z0);

        in = in.setVariable('ball_stiffness',ball_stiffness);
        in = in.setVariable('ball_damping',ball_damping);
        in = in.setVariable('ball_transitionwidth',ball_transitionwidth);
        in = in.setVariable('ball_moi',ball_moi);    
    end
   
    %tutorial 3
    if isfield(episodeConfig, 'obstacle_radius') == 1
        disp('training tutorial 3');
        
        ob_radius = episodeConfig.obstacle_radius;
       
        %assignin('base','obstacle_radius',ob_radius);
        in = in.setVariable('obstacle_radius',ob_radius);
        in = in.setVariable('obstacle_pos_x0',episodeConfig.obstacle_x);
        in = in.setVariable('obstacle_pos_y0',episodeConfig.obstacle_y);
        
    end
    
    %start the model
    sim(in);
end
