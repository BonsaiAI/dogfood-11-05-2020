% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

%initializes variables, paths, etc.


%set the base variable moab_mdl which is used by other scripts to load it
moab_mdl = 'MOAB';

%load the paths
folder_pathlist = {...
    'CAD'...
    'Images'...
    'Scripts_Data'...
    };
addpath(pwd);
for i=1:length(folder_pathlist)
    addpath([pwd filesep folder_pathlist{i}]);
end

%load the model to set parameters
load_system(moab_mdl);

% Run variable initialization script
MOAB_PARAMS



% are we running in our local desktop
if usejava('desktop')
    disp('showing Mechanics Explorer');
    set_param(moab_mdl,'SimMechanicsOpenEditorOnUpdate','on');
else %or in the Bonsai server environment?
    disp('hiding Mechanics Explorer');
    set_param(moab_mdl,'SimMechanicsOpenEditorOnUpdate','off'); 
    set_param(moab_mdl,'SimscapeLogType','none');
    mode = get_param(moab_mdl,'SimulationMode')
end

%disable warnings
set_param(moab_mdl,'SimMechanicsUnsatisfiedHighPriorityTargets','none'); 
warning('off','all');