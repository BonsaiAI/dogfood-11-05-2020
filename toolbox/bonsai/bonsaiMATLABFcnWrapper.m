% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Called from the bonsai function block as external code.
% This wrapper is necessary to satisfy the matlab compiler.

function [action, reset] = bonsaiMATLABFcnWrapper(state, halted)    
    session = bonsai.Session.getInstance();
    logger = bonsai.Logger('bonsaiFcnWrapper', session.config.verbose);
    logger.verboseLog('bonsaiFcnWrapper')
    action = zeros(1, session.config.numActions);
    
    %TODO: Handle assessment initialization
    
    % get next event (unless last event was EpisodeFinish or Unregister)
    if eq(session.lastEvent, bonsai.EventTypes.EpisodeFinish) || ...
        eq(session.lastEvent, bonsai.EventTypes.Unregister)
        logger.verboseLog(['Last event was ', session.lastEvent.str, ', done requesting events.']);
    else
        logger.verboseLog('Get next event')
        time = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd:hh:mm:ss'));
        session.getNextEvent(time, state, halted);
    end

    % Determine action
    fields = fieldnames(session.lastAction);
    if strlength(session.config.action_bus) > 0
        logger.verboseLog('Configuration indicated action bus is being used. Returning action struct.')
        if isequal(session.lastAction, struct())
            action = Simulink.Bus.createMATLABStruct(session.config.action_bus);
        else
            action = session.lastAction;
        end
    elseif ~isempty(fields)
        logger.verboseLog('Configuration indicated action vector is being used. Returning action vector.')
        action = bonsai.Utilities.getStructValuesInOrder(session.lastAction, session.config.actionSchema);
    end

    % signal a reset if last event was episode finish or unregister
    if eq(session.lastEvent, bonsai.EventTypes.EpisodeFinish) || ...
        eq(session.lastEvent, bonsai.EventTypes.Unregister)
        reset = true;
    else
        reset = false;
    end
    
    logger.verboseLog('end bonsaiFcnWrapper')
end