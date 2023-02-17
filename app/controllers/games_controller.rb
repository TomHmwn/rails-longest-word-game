require 'open-uri'
require 'json'

class GamesController < ApplicationController
  URL = "https://wagon-dictionary.herokuapp.com/"
  def new
    @letters = generate_grid(rand(10...15))
    @startTime = Time.now
  end

  def score
    @endTime = Time.now
    @letters = params[:letters]
    @word = params[:word]
    @startTime = Time.parse(params[:start_time])
    @score, @message = get_score_and_message(@startTime, @endTime, @word, @letters)
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    arr = []
    grid_size.times { arr << ("A".."Z").to_a.sample }
    arr
  end

  def calculate_score(time)
    if time < 3.0
      10
    elsif time < 5.0
      6
    elsif time < 7.0
      3
    else
      1
    end
  end

  def api(attempt)
    urls = URL + attempt.to_s
    dict_serialized = URI.open(urls).read
    JSON.parse(dict_serialized)
  end

  def valid_attempt(arr_res, grid)
    arr_res.all? do |letter|
      grid.count(letter) >= arr_res.count(letter)
    end
  end

  def get_score_and_message(end_time, start_time, attempt, grid)
    score = 0
    diff_time = 0
    if valid_attempt(api(attempt)["word"].upcase.chars, grid) && api(attempt)["found"]
      diff_time = end_time - start_time
      score = (score + calculate_score(diff_time)) * attempt.length
      message = "Well done"
    elsif !api(attempt)["found"]
      message = "the given word is not an english word"
    elsif !valid_attempt(api(attempt)["word"].upcase.chars, grid)
      message = "the given word is not in the grid"
    end
    [score, message]
  end

  def run_game(attempt, grid, start_time, end_time)
    score, message = get_score_and_message(end_time, start_time, attempt, grid)
    { score: score.to_i, message: message.to_s, time: end_time - start_time }
  end
end
