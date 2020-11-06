# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

inkling "2.0"

using Math

# thresholds
const PositionThreshold = 4.0
const AngleThreshold = 0.26

type SimState {
    position: number,
    velocity: number,
    angle: number,
    rotation: number
}

type Action {
    command: number<-10.0, 10.0,>
}

type CartPoleConfig {
    pos: number
}

function Reward(obs: SimState) {
    if FellOver(obs) or OutOfRange(obs) {
        return 0
    }
    return 1
}

function Terminal(obs: SimState) {
    return FellOver(obs) or OutOfRange(obs)
}

function FellOver(obs: SimState) {
    return Math.Abs(obs.angle) > AngleThreshold
}

function OutOfRange(obs: SimState) {
    return Math.Abs(obs.position) > PositionThreshold
}

simulator CartpoleSimulator(action: Action, config: CartPoleConfig): SimState {
}

graph (input: SimState): Action {
    concept balance(input): Action {
        curriculum {
            source CartpoleSimulator
            reward Reward
            terminal Terminal
            lesson balancing {
                scenario {
                    pos: 0.0
                }
            }
        }
    }
    output balance
}
