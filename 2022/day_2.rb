#!/usr/bin/ruby
require 'pp'

# I prefer human readable solutions, mappers below
# just help me track the logic.
# There's ways to do this with less code, for sure.

LEFT = { A: :ROCK, B: :PAPER, C: :SCISSORS }

RIGHT_IS_THROW = { X: :ROCK, Y: :PAPER, Z: :SCISSORS }
RIGHT_IS_OUTCOME = { X: :lose, Y: :draw, Z: :win }

WEIGHT = { ROCK: 1, PAPER: 2, SCISSORS: 3 }
SCORE = { lose: 0, draw: 3, win: 6 }

POSSIBLE_STATES = {
    lose: { 
      ROCK: :SCISSORS,
      PAPER: :ROCK,
      SCISSORS: :PAPER
    },
    draw: {
      ROCK: :ROCK,
      PAPER: :PAPER,
      SCISSORS: :SCISSORS
    },
    win: {
      ROCK: :PAPER,
      PAPER: :SCISSORS,
      SCISSORS: :ROCK
    }
}

def play_round(round)
  opponent = round[:opponent]
  me = round[:me]

  if opponent == me
    return :draw
  elsif (opponent == :ROCK and me == :PAPER) or
        (opponent == :PAPER and me == :SCISSORS) or
        (opponent == :SCISSORS and me == :ROCK)
    return :win
  else
    return :lose
  end
end

def determine_round(opponent, outcome)
  { opponent: opponent, me: POSSIBLE_STATES[outcome][opponent] }
end

def score_round(round, outcome)
  WEIGHT[round[:me]] + SCORE[outcome]
end

def build_throw_strategy(value)
  round = { opponent: LEFT[value[0].to_sym], me: RIGHT_IS_THROW[value[1].to_sym] }
  outcome = play_round(round)
  {
    round: round,
    outcome: outcome,
    score: score_round(round, outcome)
  }
end

def build_outcome_strategy(value)
  outcome = RIGHT_IS_OUTCOME[value[1].to_sym]
  round = determine_round(LEFT[value[0].to_sym], outcome)
  {
    round: round,
    outcome: outcome,
    score: score_round(round, outcome)
  }
end
 
def process_strategy(file)
  strategy_a = {}
  strategy_b = {}
     
  file.each_line.with_index do |line, round_count|
    line.strip!
    val = line.split

    strategy_a[round_count] = build_throw_strategy(val)
    strategy_b[round_count] = build_outcome_strategy(val)
  end

  return [strategy_a, strategy_b]
end

def total_score(strategy)
  strategy.values.sum { |h| h[:score] }
end

file = File.open(ARGV.first)

strategies = process_strategy(file)
puts "Total score if right strategy column is throw: " + total_score(strategies[0]).to_s
puts "Total score if right strategy column is outcome: " + total_score(strategies[1]).to_s