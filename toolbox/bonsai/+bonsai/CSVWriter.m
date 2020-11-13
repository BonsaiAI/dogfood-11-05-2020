% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Class to write training data to CSV for the Bonsai toolbox

classdef CSVWriter

    properties (Access = private)
        config BonsaiConfiguration
        fileHandle
        logger bonsai.Logger
    end

    methods

        function obj = CSVWriter(config)
            obj.config = config;
            obj.logger = bonsai.Logger('CSVWriter', config.verbose);

            % check if file exists
            foundFile = mlreportgen.utils.findFile(config.outputCSV, 'FileMustExist', false);
            if isfile(foundFile)
                obj.logger.verboseLog(['CSV file ', char(foundFile), ' already exists, overwriting...']);
                delete(foundFile);
            else
                obj.logger.verboseLog(['Simulator data will be logged to ', char(foundFile)]);
            end

            % open file for writing
            obj.fileHandle = fopen(foundFile,'w');

            % write headers to file
            if config.usingStateBus
                prefixedStates = bonsai.Utilities.getCSVHeadersFromStruct(...
                    Simulink.Bus.createMATLABStruct(config.state_bus), ...
                    'state');
            else
                prefixedStates = arrayfun(@(x) strcat('state.', x), config.stateSchema);
            end

            if config.usingActionBus
                prefixedActions = bonsai.Utilities.getCSVHeadersFromStruct(...
                    Simulink.Bus.createMATLABStruct(config.action_bus), ...
                    'action');
            else
                prefixedActions = arrayfun(@(x) strcat('action.', x), config.actionSchema);
            end

            stateHeaders = join(prefixedStates, ',');
            actionHeaders = join(prefixedActions, ',');
            allHeaders = strcat('Real Time (UTC),Sim Time,Event,', stateHeaders, ...
                ',Halted,', actionHeaders);

            % add config headers to the end if there are configs
            if config.usingConfigBus
                prefixedConfigs = bonsai.Utilities.getCSVHeadersFromStruct(...
                    Simulink.Bus.createMATLABStruct(config.config_bus), ...
                    'config');
                configHeaders = join(prefixedConfigs, ',');
                allHeaders = strcat(allHeaders, ',', configHeaders);
            elseif obj.config.numConfigs > 0
                prefixedConfigs = arrayfun(@(x) strcat('config.', x), config.configSchema);
                configHeaders = join(prefixedConfigs, ',');
                allHeaders = strcat(allHeaders, ',', configHeaders);
            end

            obj.writeEntry(allHeaders);
        end

        function outString = stringifyDoubles(obj, values)
            outString = false;

            % input must be a double (or array of doubles)
            if ~strcmp(class(values), 'double')
                error(['Unable to convert type ', class(values), 'to string.']);
            end

            % loop over values and convert + concatenate
            for i = 1:obj.config.numStates
                charVersion = num2str(values(i));
                if ~outString
                    outString = charVersion;
                else
                    outString = strcat(outString, ',', charVersion);
                end
            end

        end

        function outString = stringifyStruct(obj, values, numValues, schema, usingBus)
            outString = false;

            % input must be a struct
            if ~strcmp(class(values), 'struct')
                error(['Unable to convert type ', class(values), 'to string.']);
            end

            % if input is empty, return empty csv string of length numValues
            fields = fieldnames(values);
            if isempty(fields)
                blankStrings = strings(1, numValues);
                outString = join(blankStrings, ',');

            % else loop over values and convert + concatenate
            elseif usingBus
                csvValues = bonsai.Utilities.getCSVValuesFromStruct(values);
                outString = join(string(csvValues), ',');
            else
                for k=1:numValues
                    charVersion = '<empty>';
                    if isfield(values, schema{k})
                        charVersion = num2str(values.(schema{k}));
                    end
                    if ~outString
                        outString = charVersion;
                    else
                        outString = strcat(outString, ',', charVersion);
                    end
                end
            end
        end

        function addEntry(obj, time, lastEvent, state, halted, action, config)

            simTime = '';
            if ~isequal(time, -1)
                simTime = num2str(time);
            end
            realTime = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd:hh:mm:ss'));
            
            if isstruct(state)
                values = bonsai.Utilities.getCSVValuesFromStruct(state);
                stateStr = join(string(values), ',');
            else
                stateStr = obj.stringifyDoubles(state);
            end
            
            % TODO: Handle for buses
            if obj.config.usingActionBus
                actionStr = obj.stringifyStruct(action, obj.config.numActions, obj.config.actionSchema, true);
            else
                actionStr = obj.stringifyStruct(action, obj.config.numActions, obj.config.actionSchema, false);
            end

            haltedStr = 'false';
            if halted
                haltedStr = 'true';
            end

            entry = strcat(realTime, ',', simTime, ',', lastEvent, ',', stateStr, ...
                ',', haltedStr, ',', actionStr);

            % add configs to the end if there are configs
            if obj.config.usingConfigBus
                configStr = obj.stringifyStruct(config, obj.config.numConfigs, obj.config.configSchema, true);
                entry = strcat(entry, ',', configStr);
            end
            if obj.config.numConfigs > 0
                configStr = obj.stringifyStruct(config, obj.config.numConfigs, obj.config.configSchema, false);
                entry = strcat(entry, ',', configStr);
            end

            fprintf(obj.fileHandle, entry);
            fprintf(obj.fileHandle, newline);
        end

        function writeEntry(obj, text)
            fprintf(obj.fileHandle, text);
            fprintf(obj.fileHandle, newline);
        end

        function close(obj)
            fclose(obj.fileHandle);
        end

    end

end
