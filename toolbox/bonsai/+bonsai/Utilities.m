% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Generic helper functions for the Bonsai toolbox

classdef Utilities

   methods(Static)

        function orderedValues = getStructValuesInOrder(structInput, schemaInput)
            % Given an unordered dictionary (structInput) and an ordered array
            % of keys (schemaInput), return an ordered list of map values.

            % make sure struct is a struct
            if ~strcmp(class(structInput), 'struct')
                error('First argument must be of type struct.');
            end

            % ensure inputs are non-empty
            fields = fieldnames(structInput);
            if isempty(fields)
                error('Struct argument cannot be empty');
            elseif isempty(schemaInput)
                error('Schema argument cannot be empty');
            end

            % make sure input sizes match
            numFields = numel(fields);
            schemaLength = numel(schemaInput);
            if schemaLength ~= numFields
                error('Invalid inputs: struct and schema inputs have differing sizes');
            end

            % iterate over schema, writing to output var            
            orderedValues = zeros(1, schemaLength);
            for k=1:schemaLength
                orderedValues(k) = structInput.(schemaInput{k});
            end
        end
        
        function headers = getCSVHeadersFromStruct(structInput, headerStr)
             % Given a structure and headerStr, return a list of strings.
             % For example the following structure returns the following input
             % Input:
             %    {
             %        cart: {
             %            position: number,
             %            velocity: number,
             %        },
             %        pole: {
             %            angle: number,
             %            rotation: number,
             %        },
             %        array: number[2]
             %    },
             % Output: [state.cart.position, state.cart.velocity, state.cart.angle, state.cart.rotation]
            headers = bonsai.Utilities.intGetCSVHeadersFromStruct(structInput, headerStr, []);
        end
        
        function values = getCSVValuesFromStruct(structInput)
             % Given a structure, extracts all the values from the Struct.
             % For example the following structure returns the following input
             % Input:
             %    {
             %        cart: {
             %            position: 0,
             %            number: 0,
             %        },
             %        pole: {
             %            angle: 0,
             %            velocity: 0,
             %        },
             %        array: [10, 20]
             %     }
             % Output: [0, 0, 0, 0, 10, 20]
            values = bonsai.Utilities.intGetCSVValuesFromStruct(structInput, []);
        end
        
        function numValues = getNumValuesFromStruct(structInput)
             % Given a structure, extracts all the values from the Struct.
             % For example the following structure returns the following input
             % Input:
             %    {
             %        cart: {
             %            position: 0,
             %            number: 0,
             %        },
             %        pole: {
             %            angle: 0,
             %            velocity: 0,
             %        },
             %        array: [10, 20]
             %     }
             % Output: 6
            numValues = bonsai.Utilities.intGetNumValuesFromStruct(structInput, 0);
        end
   end

   methods(Access = private, Static)
       
       function output = intGetCSVHeadersFromStruct(structInput, headerStr, output)
            fieldNames = fields(structInput);
            for idx = 1:length(fieldNames)
                fieldValue = structInput.(fieldNames{idx});
                if isstruct(fieldValue)
                    newStr = append(headerStr, '.', string(fieldNames{idx}));
                    output = bonsai.Utilities.intGetCSVHeadersFromStruct(fieldValue, newStr, output);
                else
                    newStr = append(headerStr, '.', string(fieldNames{idx}));
                    
                    %TODO Support multidimensional arrays
                    valueSize = size(fieldValue, 2);
                    if valueSize > 1
                        for k = 1:length(fieldValue)
                            tempStr = append(newStr, '.', string(k));
                            output = [output, tempStr];
                        end
                    else
                        output = [output, newStr];
                    end
                end
            end
       end
       
       function output = intGetCSVValuesFromStruct(structInput, output)
            fieldNames = fields(structInput);
            for idx = 1:length(fieldNames)
                fieldValue = structInput.(fieldNames{idx});
                if isstruct(fieldValue) 
                    output = bonsai.Utilities.intGetCSVValuesFromStruct(fieldValue, output);
                else
                    %TODO Support multidimensional arrays
                    output = [output, fieldValue];
                end
            end
       end
       
       function output = intGetNumValuesFromStruct(structInput, output)
           fieldNames = fields(structInput);
            for idx = 1:length(fieldNames)
                fieldValue = structInput.(fieldNames{idx});
                if isstruct(fieldValue)
                    output = bonsai.Utilities.intGetNumValuesFromStruct(fieldValue, output);
                else
                    %TODO Support multidimensional arrays
                    valueSize = size(fieldValue, 2);
                    if valueSize > 1
                        output = output + valueSize;
                    else
                        output = output + 1;
                    end
                end
            end
        end
   end
end