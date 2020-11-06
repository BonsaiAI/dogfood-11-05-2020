% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

function config = bonsaiConfig

    config = BonsaiConfiguration();

    % % override api url, defaults to "https://api.bons.ai"
    % config.url = "https://api.bons.ai";

    % bonsai workspace
    config.workspace = "<your workspace here>";

    % access key, generated from https://beta.bons.ai/brains/accounts/settings
    config.accessKey = "<your access key here>";

    % simulator name, for an unmanaged simulator launched from the desktop to show up on the web
    config.name = "Simulink Cartpole";

    % path to bonsai block in your model, used to determine state and action schemas
    config.bonsaiBlock = "cartpole_discrete/Bonsai";

    % % set state and action schemas (overrides data from bonsaiBlock)
    % config.stateSchema = ["position", "velocity", "angle", "rotation"];
    % config.actionSchema = ["command"];

    % set config schema
    config.configSchema = ["pos"];

    % % time (in seconds) the simulator gateway should wait for
    % %   your simulator to advance, defaults to 60
    % config.timeout = 60;

    % path to csv file where episode data should be logged
    config.outputCSV = "cartpole-training.csv";

    % % display verbose logs
    % config.verbose = true;

end
