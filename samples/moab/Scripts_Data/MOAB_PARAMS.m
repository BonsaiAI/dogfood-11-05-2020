% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

%% FROM moab_sim.py
DEFAULT_SIMULATION_RATE = 0.045; %s, 45ms --> previous: 0.020;   % s, 20ms
DEFAULT_GRAVITY = 9.81;          % m/s^2, Earth: there's no place like it.

DEFAULT_BALL_RADIUS = 0.02;      % m, Ping-Pong ball: 20mm
DEFAULT_BALL_SHELL = 0.0002;     % m, Ping-Pong ball: 0.2mm
DEFAULT_BALL_MASS = 0.0027;      % kg, Ping-Pong ball: 2.7g
DEFAULT_BALL_COR = 0.89;         % unitless, Ping-Pong Coefficient Of Restitution: 0.89
DEFAULT_FRICTION = 0.5;          % unitless, Ping-Pong on Acrylic

DEFAULT_PLATE_RADIUS = 0.225 / 2.0;      % m, Moab: 225mm dia
PLATE_ORIGIN_TO_SURFACE_OFFSET = 0.007471;  % offset from plate rot origin to plate surface

% plate limits
PLATE_HEIGHT_MAX = 0.040;                        % m, Moab: 40mm
DEFAULT_PLATE_HEIGHT = PLATE_HEIGHT_MAX / 2.0;
DEFAULT_PLATE_ANGLE_LIMIT = deg2rad(10.0 * 0.5);  % rad, 1/2 full range
DEFAULT_HEIGHT_Z_LIMIT = PLATE_HEIGHT_MAX / 2.0;  % m, +/- limit from center Z pos

% default ball Z position
DEFAULT_BALL_Z_POSITION = DEFAULT_PLATE_HEIGHT + PLATE_ORIGIN_TO_SURFACE_OFFSET + DEFAULT_BALL_RADIUS;

PLATE_MAX_Z_VELOCITY = 1.0;      % m/s
PLATE_Z_ACCEL = 10.0;            % m/s^2

% Moab measured velocity at 15deg in 3/60ths, or 300deg/s
DEFAULT_PLATE_MAX_ANGULAR_VELOCITY = (60.0 / 3.0) * deg2rad(15);  % rad/s

% Set acceleration to get the plate up to velocity in 1/100th of a sec
DEFAULT_PLATE_ANGULAR_ACCEL = (100.0 / 1.0) * DEFAULT_PLATE_MAX_ANGULAR_VELOCITY;   % rad/s^2

% Sensor Actuator Noises
DEFAULT_PLATE_NOISE = 0.0;     %radians
DEFAULT_BALL_NOISE = 0.0005;   % add a little noise on perceived ball location in meters
DEFAULT_VEL_NOISE = 0.0001;
noise_mean = 0;
noise_variance = 0.333;

% Set max iteration limit
MAX_ITER = Inf;

% Set obstacles
DEFAULT_OBSTACLE_RADIUS = 0;   % m, if radius is zero, obstacle is disabled
DEFAULT_OBSTACLE_X = 0.03;       % m, arbitrarily chosen
DEFAULT_OBSTACLE_Y = 0.03;       % m, arbitrarily chosen

TIME_DELTA = DEFAULT_SIMULATION_RATE;

%% -------- GLASS PLATE PARAMETERS --------

z_offset = 0.0328538;   % m, height from CAD model world frame to MOAB world frame (plate bottom at lowest height of plate, i.e. servo angle = 165 deg)

plate_radius    = DEFAULT_PLATE_RADIUS;     % m, radius of plate
plate_thickness = 0.003;                    % m, thicknes of plate
plate_mass = 0.1445;                        % m, mass of plate

plate_moi = 1/12 * plate_mass * (3*plate_radius^2 + plate_thickness^2);     % kgm^4, moment of inertia of plate

plate_pos_z0 = DEFAULT_PLATE_HEIGHT;        % m, initial height of glass plate center (bottom of glass plate to World frame)
plate_zmin   = 0.0;                         % m, minimum height of plate from world frame
plate_zmax   = PLATE_HEIGHT_MAX;            % m, maximum height of plate from world frame

tilt_x0      = deg2rad(0);   % rad, initial tilt of plate w.r.t. y axis (pitch)
tilt_y0      = deg2rad(0);   % rad, initial tilt of plate w.r.t. x axis (roll)
tilt_limit   = DEFAULT_PLATE_ANGLE_LIMIT;   % rad, max +/- tilt of plate w.r.t. x or y axis
tilt_acc     = DEFAULT_PLATE_ANGULAR_ACCEL;
tilt_max_vel = DEFAULT_PLATE_MAX_ANGULAR_VELOCITY;


%% -------- SERVO PARAMETERS --------
s = 0.1732;     % m, side length of equilateral traingle with magnets at the vertices (measured from Simscape model)
L = 0.055;      % m, arm length of links (measured from Simscape model)

[a1,a2,a3] = runMixer(plate_pos_z0+z_offset, tilt_x0, tilt_y0);
arm1_alpha0 = a1;     % rad, initial angle of arm1 servo
arm2_alpha0 = a2;     % rad, initial angle of arm2 servo
arm3_alpha0 = a3;     % rad, initial angle of arm3 servo

arm1_alphamin = deg2rad(90);   % rad
arm1_alphamax = deg2rad(165);  % rad
arm2_alphamin = deg2rad(90);   % rad
arm2_alphamax = deg2rad(165);  % rad
arm3_alphamin = deg2rad(90);   % rad
arm3_alphamax = deg2rad(165);  % rad

clear a1 a2 a3

%% -------- BALL PARAMETERS --------

% Target positon
target_pos_x = 0;
target_pos_y = 0;

%ball.z0 = DEFAULT_BALL_Z_POSITION; 

% Physical parameters
ball_radius = DEFAULT_BALL_RADIUS;   % m
ball_mass   = DEFAULT_BALL_MASS;     % kg
ball_shell  = DEFAULT_BALL_SHELL;    % m

% Calculate ball moment of inertia
ball_moi = calcMOI(ball_radius,ball_shell,ball_mass);

% Initial conditions. z is vertically updward
ball_x0  = 0;               % m, ball initial x distance from plate origin
ball_y0  = 0;               % m, ball initial y distance from plate origin
% Rx = [cos(tilt_x0) 0 sin(tilt_x0); 0 1 0; -sin(tilt_x0) 0 cos(tilt_x0)];
% Ry = [1 0 0; 0 cos(tilt_y0) -sin(tilt_y0); 0 sin(tilt_y0) cos(tilt_y0)];
% a = [0;0;plate_pos_z0];
% b = Rx*Ry*[ball_x0;ball_y0;ball_radius+PLATE_ORIGIN_TO_SURFACE_OFFSET];
% c = a+b;
% ball_pos_x0 = c(1);    % m, ball initial x distance from MOAB world frame
% ball_pos_y0 = c(2);    % m, ball initial y distance from MOAB world frame
% ball_pos_z0 = c(3);    % m, ball initial z distance from MOAB world frame
ball_z0 = ball_radius + PLATE_ORIGIN_TO_SURFACE_OFFSET;

ball_vel_x0 = 0;       % m/s, ball initial x speed
ball_vel_y0 = 0;       % m/s, ball initial y speed
ball_vel_z0 = 0;       % m/s, ball initial z speed

% Contact friction parameters
ball_staticfriction     = DEFAULT_FRICTION;
ball_dynamicfriction    = 0.3;     % Simscape Multibody default
ball_criticalvelocity   = 1e-3;    % Simscape Multibody default, m/s

% convert coefficient of restitution to spring-damper parameters
[ball_stiffness, ball_damping, ball_transitionwidth] = ...
    cor2SpringDamperParams(DEFAULT_BALL_COR,ball_mass);

clear r1 r2 I e dT a b c Rx Ry

%% -------- OBSTACLE PARAMETERS --------

obstacle_radius  = DEFAULT_OBSTACLE_RADIUS;
obstacle_pos_x0  = DEFAULT_OBSTACLE_X;
obstacle_pos_y0  = DEFAULT_OBSTACLE_Y;

%% -------- STEP FILE PARAMETERS --------

% Simscape(TM) Multibody(TM) version: 7.0

% This is a model data file derived from a Simscape Multibody Import XML file using the smimport function.
% The data in this file sets the block parameter values in an imported Simscape Multibody model.
% For more information on this file, see the smimport function help page in the Simscape Multibody documentation.
% You can modify numerical values, but avoid any other changes to this file.
% Do not add code to this file. Do not edit the physical units shown in comments.

%%%VariableName:smiData


%============= RigidTransform =============%

%Initialize the RigidTransform structure array by filling in null values.
smiData.RigidTransform(59).translation = [0.0 0.0 0.0];
smiData.RigidTransform(59).angle = 0.0;
smiData.RigidTransform(59).axis = [0.0 0.0 0.0];
smiData.RigidTransform(59).ID = '';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(1).translation = [2.8999999999999999 0 54.999999999999993];  % mm
smiData.RigidTransform(1).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(1).axis = [0.57735026918962573 0.57735026918962584 0.57735026918962573];
smiData.RigidTransform(1).ID = 'B[FC-HWA-00586 REV2-1:-:MG996R-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(2).translation = [41.798262127916601 69.505176274423604 48.074084368195642];  % mm
smiData.RigidTransform(2).angle = 3.1415926535897554;  % rad
smiData.RigidTransform(2).axis = [-1 3.3786133026394556e-30 -1.7934705801772013e-16];
smiData.RigidTransform(2).ID = 'F[FC-HWA-00586 REV2-1:-:MG996R-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(3).translation = [2.8999999999999999 0 55.000000000000014];  % mm
smiData.RigidTransform(3).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(3).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(3).ID = 'B[FC-HWA-00586 REV2-2:-:MG996R-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(4).translation = [41.798262127918676 69.505176274423604 48.074084368195628];  % mm
smiData.RigidTransform(4).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(4).axis = [1 1.9068096311256575e-33 4.8560910226733468e-17];
smiData.RigidTransform(4).ID = 'F[FC-HWA-00586 REV2-2:-:MG996R-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(5).translation = [2.8999999999999999 0 54.999999999999993];  % mm
smiData.RigidTransform(5).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(5).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(5).ID = 'B[FC-HWA-00586 REV2-3:-:MG996R-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(6).translation = [41.798262127917013 69.505176274423576 48.074094533532772];  % mm
smiData.RigidTransform(6).angle = 3.1415926535897909;  % rad
smiData.RigidTransform(6).axis = [1 -5.6104567444905711e-31 -4.4703079911610694e-16];
smiData.RigidTransform(6).ID = 'F[FC-HWA-00586 REV2-3:-:MG996R-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(7).translation = [0 0 -2.0750000000000215];  % mm
smiData.RigidTransform(7).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(7).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(7).ID = 'B[RING MAGNET 02.20-1:-:RING MAGNET 02.20-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(8).translation = [15.837218457296359 -7.1054273576010019e-15 174.35586144016128];  % mm
smiData.RigidTransform(8).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(8).axis = [0.57735026918962584 -0.57735026918962573 0.57735026918962573];
smiData.RigidTransform(8).ID = 'F[RING MAGNET 02.20-1:-:RING MAGNET 02.20-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(9).translation = [0 0 -2.0750000000000215];  % mm
smiData.RigidTransform(9).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(9).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(9).ID = 'B[RING MAGNET 02.20-1:-:RING MAGNET 02.20-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(10).translation = [-2.5374664832095846 7.9936057773011271e-14 173.34640002450615];  % mm
smiData.RigidTransform(10).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(10).axis = [0.57735026918962573 -0.57735026918962573 0.57735026918962584];
smiData.RigidTransform(10).ID = 'F[RING MAGNET 02.20-1:-:RING MAGNET 02.20-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(11).translation = [0 5.892859122126656 0];  % mm
smiData.RigidTransform(11).angle = 0;  % rad
smiData.RigidTransform(11).axis = [0 0 0];
smiData.RigidTransform(11).ID = 'B[RING MAGNET 02.20-1:-:FC-HWA-00591-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(12).translation = [-1.0380022546749466e-13 -1.5782836588679816e-13 -2.3288031590306667e-13];  % mm
smiData.RigidTransform(12).angle = 2.8133192243251059;  % rad
smiData.RigidTransform(12).axis = [-0.71847509284697986 0.64857904651907805 0.25127427519530793];
smiData.RigidTransform(12).ID = 'F[RING MAGNET 02.20-1:-:FC-HWA-00591-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(13).translation = [-86.602540378443592 20.796830864875162 50.000000000000426];  % mm
smiData.RigidTransform(13).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(13).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(13).ID = 'B[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(14).translation = [-6.4392935428259079e-15 -19.37472580451135 3.2529534621517087e-14];  % mm
smiData.RigidTransform(14).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(14).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(14).ID = 'F[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(15).translation = [0 5.892859122126656 0];  % mm
smiData.RigidTransform(15).angle = 0;  % rad
smiData.RigidTransform(15).axis = [0 0 0];
smiData.RigidTransform(15).ID = 'B[RING MAGNET 02.20-2:-:FC-HWA-00591-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(16).translation = [-1.7953591197843619e-13 -6.7347625040668408e-14 2.3903379649949505e-13];  % mm
smiData.RigidTransform(16).angle = 0;  % rad
smiData.RigidTransform(16).axis = [0 0 0];
smiData.RigidTransform(16).ID = 'F[RING MAGNET 02.20-2:-:FC-HWA-00591-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(17).translation = [86.602540378443607 20.796830864875133 50.000000000000412];  % mm
smiData.RigidTransform(17).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(17).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(17).ID = 'B[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(18).translation = [-2.886579864025407e-15 -19.374725804511371 4.1744385725905886e-14];  % mm
smiData.RigidTransform(18).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(18).axis = [-0.57735026918962584 -0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(18).ID = 'F[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(19).translation = [0 5.8928591221266702 0];  % mm
smiData.RigidTransform(19).angle = 0;  % rad
smiData.RigidTransform(19).axis = [0 0 0];
smiData.RigidTransform(19).ID = 'B[RING MAGNET 02.20-3:-:FC-HWA-00591-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(20).translation = [-1.6817661486075939e-13 2.3988474878995931e-13 3.8968828164342894e-14];  % mm
smiData.RigidTransform(20).angle = 0;  % rad
smiData.RigidTransform(20).axis = [0 0 0];
smiData.RigidTransform(20).ID = 'F[RING MAGNET 02.20-3:-:FC-HWA-00591-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(21).translation = [0 20.796830864875162 -100];  % mm
smiData.RigidTransform(21).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(21).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(21).ID = 'B[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(22).translation = [-5.5511151231257827e-15 -19.374725804511442 1.865174681370263e-14];  % mm
smiData.RigidTransform(22).angle = 2.0943951023931962;  % rad
smiData.RigidTransform(22).axis = [-0.57735026918962595 -0.57735026918962595 -0.5773502691896254];
smiData.RigidTransform(22).ID = 'F[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(23).translation = [0 0 0];  % mm
smiData.RigidTransform(23).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(23).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(23).ID = 'B[MASTER MODEL MOAB-1:-:FC-HWA-00550-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(24).translation = [0 0 0];  % mm
smiData.RigidTransform(24).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(24).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(24).ID = 'F[MASTER MODEL MOAB-1:-:FC-HWA-00550-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(25).translation = [0 0 0];  % mm
smiData.RigidTransform(25).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(25).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(25).ID = 'B[FC-HWA-00551-1:-:MASTER MODEL MOAB-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(26).translation = [0 0 0];  % mm
smiData.RigidTransform(26).angle = 1.6378338249998221;  % rad
smiData.RigidTransform(26).axis = [-0.25056280708573048 -0.25056280708573059 0.93511312653102996];
smiData.RigidTransform(26).ID = 'F[FC-HWA-00551-1:-:MASTER MODEL MOAB-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(27).translation = [0 0 0];  % mm
smiData.RigidTransform(27).angle = 1.8234765819369763;  % rad
smiData.RigidTransform(27).axis = [0.44721359549995882 0.44721359549995882 0.77459666924148241];
smiData.RigidTransform(27).ID = 'B[MASTER MODEL MOAB-1:-:FC-HWA-00555-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(28).translation = [0 0 0];  % mm
smiData.RigidTransform(28).angle = 1.8234765819369763;  % rad
smiData.RigidTransform(28).axis = [0.44721359549995882 0.44721359549995882 0.77459666924148241];
smiData.RigidTransform(28).ID = 'F[MASTER MODEL MOAB-1:-:FC-HWA-00555-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(29).translation = [0 0 0];  % mm
smiData.RigidTransform(29).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(29).axis = [-0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(29).ID = 'B[MASTER MODEL MOAB-1:-:FC-HWA-00591-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(30).translation = [-126.1811947218272 75.142947160164425 -1.4210854715202004e-14];  % mm
smiData.RigidTransform(30).angle = 3.1415926535897927;  % rad
smiData.RigidTransform(30).axis = [1 5.2093855864427869e-33 2.3594571776143373e-17];
smiData.RigidTransform(30).ID = 'F[MASTER MODEL MOAB-1:-:FC-HWA-00591-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(31).translation = [0 0 0];  % mm
smiData.RigidTransform(31).angle = 0.52359877559829682;  % rad
smiData.RigidTransform(31).axis = [0 1 0];
smiData.RigidTransform(31).ID = 'B[MASTER MODEL MOAB-1:-:FC-HWA-00591-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(32).translation = [-115.84531635972371 92.650077522611838 -1.0302869668521453e-12];  % mm
smiData.RigidTransform(32).angle = 3.1415926535897829;  % rad
smiData.RigidTransform(32).axis = [1 1.8932531226865247e-30 3.6327679357758251e-16];
smiData.RigidTransform(32).ID = 'F[MASTER MODEL MOAB-1:-:FC-HWA-00591-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(33).translation = [0 0 0];  % mm
smiData.RigidTransform(33).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(33).axis = [0.96592582628906865 0 0.25881904510251952];
smiData.RigidTransform(33).ID = 'B[MASTER MODEL MOAB-1:-:FC-HWA-00591-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(34).translation = [-23.502745591116337 133.63770216491804 1.1013412404281553e-12];  % mm
smiData.RigidTransform(34).angle = 3.1415926535897856;  % rad
smiData.RigidTransform(34).axis = [-1 1.5114860384011491e-31 -3.8869833646325887e-17];
smiData.RigidTransform(34).ID = 'F[MASTER MODEL MOAB-1:-:FC-HWA-00591-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(35).translation = [0 0 0];  % mm
smiData.RigidTransform(35).angle = 0;  % rad
smiData.RigidTransform(35).axis = [0 0 0];
smiData.RigidTransform(35).ID = 'B[MASTER MODEL MOAB-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(36).translation = [0 0 0];  % mm
smiData.RigidTransform(36).angle = 0;  % rad
smiData.RigidTransform(36).axis = [0 0 0];
smiData.RigidTransform(36).ID = 'F[MASTER MODEL MOAB-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(37).translation = [-5.1500000000000083 0 0];  % mm
smiData.RigidTransform(37).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(37).axis = [-0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(37).ID = 'B[FC-HWA-00590 REV2-2:-:FC-HWA-00586 REV2-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(38).translation = [2.1999999999999496 -1.8873791418627661e-14 3.7503333771837788e-13];  % mm
smiData.RigidTransform(38).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(38).axis = [-0.57735026918962584 -0.57735026918962573 0.57735026918962573];
smiData.RigidTransform(38).ID = 'F[FC-HWA-00590 REV2-2:-:FC-HWA-00586 REV2-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(39).translation = [-5.1500000000000004 0 0];  % mm
smiData.RigidTransform(39).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(39).axis = [-0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(39).ID = 'B[FC-HWA-00590 REV2-1:-:FC-HWA-00586 REV2-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(40).translation = [2.200000000000002 3.2884891611296511e-13 -1.6007662238806359e-12];  % mm
smiData.RigidTransform(40).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(40).axis = [-0.57735026918962573 -0.57735026918962595 0.57735026918962562];
smiData.RigidTransform(40).ID = 'F[FC-HWA-00590 REV2-1:-:FC-HWA-00586 REV2-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(41).translation = [-5.1500000000000021 0 0];  % mm
smiData.RigidTransform(41).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(41).axis = [-0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(41).ID = 'B[FC-HWA-00590 REV2-3:-:FC-HWA-00586 REV2-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(42).translation = [2.2000000000000197 1.9539925233402755e-14 2.3314683517128287e-14];  % mm
smiData.RigidTransform(42).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(42).axis = [-0.57735026918962584 -0.57735026918962584 0.57735026918962562];
smiData.RigidTransform(42).ID = 'F[FC-HWA-00590 REV2-3:-:FC-HWA-00586 REV2-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(43).translation = [0 0 0];  % mm
smiData.RigidTransform(43).angle = 0;  % rad
smiData.RigidTransform(43).axis = [0 0 0];
smiData.RigidTransform(43).ID = 'B[FC-HWA-00550-1:-:FC-HWA-00555-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(44).translation = [0 0 0];  % mm
smiData.RigidTransform(44).angle = 0;  % rad
smiData.RigidTransform(44).axis = [0 0 0];
smiData.RigidTransform(44).ID = 'F[FC-HWA-00550-1:-:FC-HWA-00555-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(45).translation = [0 0 0];  % mm
smiData.RigidTransform(45).angle = 0;  % rad
smiData.RigidTransform(45).axis = [0 0 0];
smiData.RigidTransform(45).ID = 'B[FC-HWA-00550-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(46).translation = [0 0 0];  % mm
smiData.RigidTransform(46).angle = 0;  % rad
smiData.RigidTransform(46).axis = [0 0 0];
smiData.RigidTransform(46).ID = 'F[FC-HWA-00550-1:-:]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(47).translation = [-0.75 0 -45.000000000000014];  % mm
smiData.RigidTransform(47).angle = 0;  % rad
smiData.RigidTransform(47).axis = [0 0 0];
smiData.RigidTransform(47).ID = 'B[FC-HWA-00590 REV2-1:-:FC-HWA-00591-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(48).translation = [-10.000000000000004 -3.5527136788005009e-15 -7.9936057773011271e-15];  % mm
smiData.RigidTransform(48).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(48).axis = [-0.57735026918962551 -0.57735026918962584 0.57735026918962595];
smiData.RigidTransform(48).ID = 'F[FC-HWA-00590 REV2-1:-:FC-HWA-00591-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(49).translation = [-0.75000000000000755 0 -45.000000000000007];  % mm
smiData.RigidTransform(49).angle = 0;  % rad
smiData.RigidTransform(49).axis = [0 0 0];
smiData.RigidTransform(49).ID = 'B[FC-HWA-00590 REV2-2:-:FC-HWA-00591-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(50).translation = [-10.000000000000002 -2.4868995751603507e-14 2.0872192862952943e-14];  % mm
smiData.RigidTransform(50).angle = 2.0943951023931962;  % rad
smiData.RigidTransform(50).axis = [-0.57735026918962562 -0.57735026918962595 0.57735026918962562];
smiData.RigidTransform(50).ID = 'F[FC-HWA-00590 REV2-2:-:FC-HWA-00591-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(51).translation = [-0.75000000000000067 0 -45.000000000000043];  % mm
smiData.RigidTransform(51).angle = 0;  % rad
smiData.RigidTransform(51).axis = [0 0 0];
smiData.RigidTransform(51).ID = 'B[FC-HWA-00590 REV2-3:-:FC-HWA-00591-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(52).translation = [-9.9999999999999787 -1.0658141036401503e-14 7.9936057773011271e-15];  % mm
smiData.RigidTransform(52).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(52).axis = [-0.5773502691896264 -0.57735026918962584 0.57735026918962506];
smiData.RigidTransform(52).ID = 'F[FC-HWA-00590 REV2-3:-:FC-HWA-00591-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(53).translation = [0 0 0];  % mm
smiData.RigidTransform(53).angle = 0;  % rad
smiData.RigidTransform(53).axis = [0 0 0];
smiData.RigidTransform(53).ID = 'RootGround[FC-HWA-00555-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(54).translation = [-4.2222498461790199 41.71126212791701 53.676496195316055];  % mm
smiData.RigidTransform(54).angle = 2.7734925708570866;  % rad
smiData.RigidTransform(54).axis = [0.69474659060686406 -0.69474659060686395 -0.18615678789739834];
smiData.RigidTransform(54).ID = 'RootGround[MG996R-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(55).translation = [5.0826694990250773e-06 -16.45000000000001 -0.42499999999974503];  % mm
smiData.RigidTransform(55).angle = 1.5707963267948968;  % rad
smiData.RigidTransform(55).axis = [0 1 0];
smiData.RigidTransform(55).ID = 'RootGround[FC-HWA-00582-1]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(56).translation = [48.596339297044103 41.71126212791701 -23.181681273183681];  % mm
smiData.RigidTransform(56).angle = 1.6378338249998232;  % rad
smiData.RigidTransform(56).axis = [0.25056280708573153 -0.25056280708573159 -0.9351131265310294];
smiData.RigidTransform(56).ID = 'RootGround[MG996R-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(57).translation = [-0.3680633379442716 -16.450000000000006 0.21249559827545006];  % mm
smiData.RigidTransform(57).angle = 2.6179938779914584;  % rad
smiData.RigidTransform(57).axis = [-0 -1 -0];
smiData.RigidTransform(57).ID = 'RootGround[FC-HWA-00582-3]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(58).translation = [-44.374084368195618 41.711262127917003 -30.494823725576143];  % mm
smiData.RigidTransform(58).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(58).axis = [-0.57735026918962584 0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(58).ID = 'RootGround[MG996R-2]';

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(59).translation = [0.36806333794234258 -16.450000000000006 0.2124955982803628];  % mm
smiData.RigidTransform(59).angle = 0.52359877559829882;  % rad
smiData.RigidTransform(59).axis = [0 -1 0];
smiData.RigidTransform(59).ID = 'RootGround[FC-HWA-00582-2]';


%============= Solid =============%
%Center of Mass (CoM) %Moments of Inertia (MoI) %Product of Inertia (PoI)

%Initialize the Solid structure array by filling in null values.
smiData.Solid(11).mass = 0.0;
smiData.Solid(11).CoM = [0.0 0.0 0.0];
smiData.Solid(11).MoI = [0.0 0.0 0.0];
smiData.Solid(11).PoI = [0.0 0.0 0.0];
smiData.Solid(11).color = [0.0 0.0 0.0];
smiData.Solid(11).opacity = 0.0;
smiData.Solid(11).ID = '';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(1).mass = 0.024418990257690766;  % kg
smiData.Solid(1).CoM = [-6.6900263861456559e-06 0.42466264298620748 3.9430291192342339e-06];  % mm
smiData.Solid(1).MoI = [15.834662676038688 29.205255277499063 15.834676194140531];  % kg*mm^2
smiData.Solid(1).PoI = [-4.3299649812931798e-07 2.2258880335385277e-06 2.1778551106837582e-07];  % kg*mm^2
smiData.Solid(1).color = [0.34862745098039216 0.34862745098039216 0.34862745098039216];
smiData.Solid(1).opacity = 1;
smiData.Solid(1).ID = 'FC-HWA-00551*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(2).mass = 0.14448038383097359;  % kg
smiData.Solid(2).CoM = [0 1.4784153331091801 0];  % mm
smiData.Solid(2).MoI = [451.02297051030934 901.82020987333669 451.02297051030968];  % kg*mm^2
smiData.Solid(2).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(2).color = [1 1 1];
smiData.Solid(2).opacity = 0.30000000000000004;
smiData.Solid(2).ID = 'FC-HWA-00553 REV 2*:*Magnet Cover';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(3).mass = 0.0027150764788224672;  % kg
smiData.Solid(3).CoM = [0 1.521791519121992 0];  % mm
smiData.Solid(3).MoI = [0.033577548781968877 0.062825604059898357 0.03357754878196887];  % kg*mm^2
smiData.Solid(3).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(3).color = [0.66666666666666663 0.69803921568627447 0.76862745098039209];
smiData.Solid(3).opacity = 1;
smiData.Solid(3).ID = 'RING MAGNET 02.20*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(4).mass = 4.6043098570896179e-313;  % kg
smiData.Solid(4).CoM = [4102720595.8638558 0 4.6043098570896179e-313];  % mm
smiData.Solid(4).MoI = [0 0 0];  % kg*mm^2
smiData.Solid(4).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(4).color = [0.79607843137254897 0.82352941176470584 0.93725490196078431];
smiData.Solid(4).opacity = 1;
smiData.Solid(4).ID = 'MASTER MODEL MOAB*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(5).mass = 0.16938527692520644;  % kg
smiData.Solid(5).CoM = [0.89516483016173631 13.255838173113117 -0.60508587814154846];  % mm
smiData.Solid(5).MoI = [1014.3332270954725 1914.5057246087747 1019.8109972424138];  % kg*mm^2
smiData.Solid(5).PoI = [0.11062465274823498 5.668094366637578 -0.46961568142213195];  % kg*mm^2
smiData.Solid(5).color = [0.69999999999999996 0.69999999999999996 0.69999999999999996];
smiData.Solid(5).opacity = 1;
smiData.Solid(5).ID = 'FC-HWA-00550*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(6).mass = 0.25756201007254864;  % kg
smiData.Solid(6).CoM = [1.575952932053198 -20.064753723663774 5.1075606342308451];  % mm
smiData.Solid(6).MoI = [1413.4049697991954 2480.3624137144971 1236.3108595220965];  % kg*mm^2
smiData.Solid(6).PoI = [1.1781920746542651 21.30034876972427 -7.0102749533601605];  % kg*mm^2
smiData.Solid(6).color = [0.34862745098039216 0.34862745098039216 0.34862745098039216];
smiData.Solid(6).opacity = 1;
smiData.Solid(6).ID = 'FC-HWA-00555*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(7).mass = 0.0039415997403554909;  % kg
smiData.Solid(7).CoM = [0.87414307789373302 0.011857359831643082 30.41346601595712];  % mm
smiData.Solid(7).MoI = [1.5486372101243422 1.449323294622288 0.12276200938853335];  % kg*mm^2
smiData.Solid(7).PoI = [0.0014197636256626275 -0.019767457017329938 -0.00013385583629979653];  % kg*mm^2
smiData.Solid(7).color = [0.35137254901960779 0.35137254901960779 0.35137254901960779];
smiData.Solid(7).opacity = 1;
smiData.Solid(7).ID = 'FC-HWA-00586 REV2*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(8).mass = 0.0032399397772319648;  % kg
smiData.Solid(8).CoM = [0.25733488571559898 -5.230373308758441e-06 -19.057668840293921];  % mm
smiData.Solid(8).MoI = [0.8197861344471753 0.74563962787393634 0.09713190484007618];  % kg*mm^2
smiData.Solid(8).PoI = [-1.9805271757674739e-07 0.010378037924256924 -1.0383778275827138e-07];  % kg*mm^2
smiData.Solid(8).color = [0.34862745098039216 0.34862745098039216 0.34862745098039216];
smiData.Solid(8).opacity = 1;
smiData.Solid(8).ID = 'FC-HWA-00590 REV2*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(9).mass = 0.029654565054248155;  % kg
smiData.Solid(9).CoM = [41.798265862795333 59.629168683022996 18.942687391920444];  % mm
smiData.Solid(9).MoI = [7.4339279158057856 4.3957262024246067 4.9119626412840667];  % kg*mm^2
smiData.Solid(9).PoI = [-0.11037893388824375 -1.4581363877931477e-06 3.2721233304551236e-06];  % kg*mm^2
smiData.Solid(9).color = [0.019607843137254902 0.019607843137254902 0.019607843137254902];
smiData.Solid(9).opacity = 1;
smiData.Solid(9).ID = 'MG996R*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(10).mass = 0.00063696909419459541;  % kg
smiData.Solid(10).CoM = [-4.6685559806591925 0 1.2605581086771829e-12];  % mm
smiData.Solid(10).MoI = [0.0039910294172053398 0.02909043474796924 0.029090434747969695];  % kg*mm^2
smiData.Solid(10).PoI = [0 0 0];  % kg*mm^2
smiData.Solid(10).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(10).opacity = 1;
smiData.Solid(10).ID = 'FC-HWA-00591*:*Default';

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(11).mass = 0.022187258301558731;  % kg
smiData.Solid(11).CoM = [87.982058824483616 15.941190504366217 2.318479834848119];  % mm
smiData.Solid(11).MoI = [6.7930172825188295 19.236876132960653 18.62574273427326];  % kg*mm^2
smiData.Solid(11).PoI = [0.17762946729090723 0.0096700897342004155 0.3364313704949185];  % kg*mm^2
smiData.Solid(11).color = [0.20862745098039215 0.20862745098039215 0.20862745098039215];
smiData.Solid(11).opacity = 1;
smiData.Solid(11).ID = 'FC-HWA-00582*:*Default';


%============= Joint =============%
%X Revolute Primitive (Rx) %Y Revolute Primitive (Ry) %Z Revolute Primitive (Rz)
%X Prismatic Primitive (Px) %Y Prismatic Primitive (Py) %Z Prismatic Primitive (Pz) %Spherical Primitive (S)
%Constant Velocity Primitive (CV) %Lead Screw Primitive (LS)
%Position Target (Pos)

%Initialize the CylindricalJoint structure array by filling in null values.
smiData.CylindricalJoint(5).Rz.Pos = 0.0;
smiData.CylindricalJoint(5).Pz.Pos = 0.0;
smiData.CylindricalJoint(5).ID = '';

smiData.CylindricalJoint(1).Rz.Pos = 93.801338098636904;  % deg
smiData.CylindricalJoint(1).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(1).ID = '[FC-HWA-00586 REV2-1:-:MG996R-1]';

smiData.CylindricalJoint(2).Rz.Pos = 102.08199713269495;  % deg
smiData.CylindricalJoint(2).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(2).ID = '[FC-HWA-00586 REV2-2:-:MG996R-2]';

smiData.CylindricalJoint(3).Rz.Pos = 57.968633346061104;  % deg
smiData.CylindricalJoint(3).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(3).ID = '[FC-HWA-00586 REV2-3:-:MG996R-3]';

smiData.CylindricalJoint(4).Rz.Pos = -64.077230385184407;  % deg
smiData.CylindricalJoint(4).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(4).ID = '[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-1]';

smiData.CylindricalJoint(5).Rz.Pos = 31.522695020705456;  % deg
smiData.CylindricalJoint(5).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(5).ID = '[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-3]';


%Initialize the PlanarJoint structure array by filling in null values.
smiData.PlanarJoint(5).Rz.Pos = 0.0;
smiData.PlanarJoint(5).Px.Pos = 0.0;
smiData.PlanarJoint(5).Py.Pos = 0.0;
smiData.PlanarJoint(5).ID = '';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(1).Rz.Pos = -149.1840076862172;  % deg
smiData.PlanarJoint(1).Px.Pos = 0;  % mm
smiData.PlanarJoint(1).Py.Pos = 0;  % mm
smiData.PlanarJoint(1).ID = '[RING MAGNET 02.20-1:-:RING MAGNET 02.20-2]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(2).Rz.Pos = -95.599925405889863;  % deg
smiData.PlanarJoint(2).Px.Pos = 0;  % mm
smiData.PlanarJoint(2).Py.Pos = 0;  % mm
smiData.PlanarJoint(2).ID = '[RING MAGNET 02.20-1:-:RING MAGNET 02.20-3]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(3).Rz.Pos = 12.199588961652207;  % deg
smiData.PlanarJoint(3).Px.Pos = 0;  % mm
smiData.PlanarJoint(3).Py.Pos = 0;  % mm
smiData.PlanarJoint(3).ID = '[MASTER MODEL MOAB-1:-:FC-HWA-00591-1]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(4).Rz.Pos = 93.668829319026315;  % deg
smiData.PlanarJoint(4).Px.Pos = 0;  % mm
smiData.PlanarJoint(4).Py.Pos = 0;  % mm
smiData.PlanarJoint(4).ID = '[MASTER MODEL MOAB-1:-:FC-HWA-00591-2]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.PlanarJoint(5).Rz.Pos = -123.07591740490025;  % deg
smiData.PlanarJoint(5).Px.Pos = 0;  % mm
smiData.PlanarJoint(5).Py.Pos = 0;  % mm
smiData.PlanarJoint(5).ID = '[MASTER MODEL MOAB-1:-:FC-HWA-00591-3]';


%Initialize the PrismaticJoint structure array by filling in null values.
smiData.PrismaticJoint(1).Pz.Pos = 0.0;
smiData.PrismaticJoint(1).ID = '';

smiData.PrismaticJoint(1).Pz.Pos = 0;  % m
smiData.PrismaticJoint(1).ID = '[MASTER MODEL MOAB-1:-:FC-HWA-00550-1]';


%Initialize the RevoluteJoint structure array by filling in null values.
smiData.RevoluteJoint(7).Rz.Pos = 0.0;
smiData.RevoluteJoint(7).ID = '';

smiData.RevoluteJoint(1).Rz.Pos = 85.10677730103275;  % deg
smiData.RevoluteJoint(1).ID = '[FC-HWA-00553 REV 2-1:-:RING MAGNET 02.20-2]';

smiData.RevoluteJoint(2).Rz.Pos = 7.4701674176631814;  % deg
smiData.RevoluteJoint(2).ID = '[FC-HWA-00590 REV2-2:-:FC-HWA-00586 REV2-1]';

smiData.RevoluteJoint(3).Rz.Pos = 24.281586094347116;  % deg
smiData.RevoluteJoint(3).ID = '[FC-HWA-00590 REV2-1:-:FC-HWA-00586 REV2-2]';

smiData.RevoluteJoint(4).Rz.Pos = -65.107284058839042;  % deg
smiData.RevoluteJoint(4).ID = '[FC-HWA-00590 REV2-3:-:FC-HWA-00586 REV2-3]';

smiData.RevoluteJoint(5).Rz.Pos = -90.000000000000014;  % deg
smiData.RevoluteJoint(5).ID = '[FC-HWA-00590 REV2-1:-:FC-HWA-00591-1]';

smiData.RevoluteJoint(6).Rz.Pos = -90.000000000000583;  % deg
smiData.RevoluteJoint(6).ID = '[FC-HWA-00590 REV2-2:-:FC-HWA-00591-2]';

smiData.RevoluteJoint(7).Rz.Pos = -89.999999999999574;  % deg
smiData.RevoluteJoint(7).ID = '[FC-HWA-00590 REV2-3:-:FC-HWA-00591-3]';


%Initialize the SphericalJoint structure array by filling in null values.
smiData.SphericalJoint(3).S.Pos.Angle = 0.0;
smiData.SphericalJoint(3).S.Pos.Axis = [0.0 0.0 0.0];
smiData.SphericalJoint(3).ID = '';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.SphericalJoint(1).S.Pos.Angle = 73.861207804788734;  % deg
smiData.SphericalJoint(1).S.Pos.Axis = [0.32201357468298786 -0.69989463052774303 -0.63753804896517186];
smiData.SphericalJoint(1).ID = '[RING MAGNET 02.20-2:-:FC-HWA-00591-3]';

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.SphericalJoint(2).S.Pos.Angle = 141.24735067636502;  % deg
smiData.SphericalJoint(2).S.Pos.Axis = [0.74706927467376349 -0.54502124566362453 -0.38057764071696065];
smiData.SphericalJoint(2).ID = '[RING MAGNET 02.20-3:-:FC-HWA-00591-1]';

smiData.SphericalJoint(3).S.Pos.Angle = 0;  % deg
smiData.SphericalJoint(3).S.Pos.Axis = [0 0 0];
smiData.SphericalJoint(3).ID = '[FC-HWA-00550-1:-:FC-HWA-00555-1]';