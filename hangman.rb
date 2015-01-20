class Hangman
  attr_reader :word

  def initialize
    @word = pick_word
    @guesses_remaining = 16
    @guesses = []
    @solution = Array.new(@word.length, "_")
    @victory_state = "none"
    play
  end

  def pick_word
    dictionary = File.open("dictionary.txt", 'r')
    word = ''
    until word.length.between?(5, 12) do
      word = File.readlines(dictionary).sample.chomp.downcase
    end
    dictionary.close
    return word
  end

  def game_over?
    if @guesses_remaining == 0
      @victory_state = "loss"
      return true
    elsif @solution.join == @word
      @victory_state = "win"
      return true
    else
      return false
    end
  end

  def check_guess(guess)
    @guesses << guess
    answer = @word.split(//)
    answer.each_with_index do |ans_let, ans_ind|
      @solution[ans_ind] = ans_let if @guesses.include?(ans_let)
    end
  end

  def display
    puts @solution.join
  end

  def player_input
    valid = false
    until valid == true do
      input = gets.chomp.downcase
      valid = true if input.length == 1 && input =~ /[a-z]/
    end
    return input
  end

  def play
    until game_over?
      display
      puts "You have #{@guesses_remaining} remaining."
      puts "Previous guesses: #{@guesses}"
      puts "Guess a letter: "
      guess = player_input
      check_guess(guess)
      display
      @guesses_remaining -= 1
    end
    if @victory_state == "win"
      puts "You win!"
    else
      puts "You lose!"
    end
    puts "The word was #{@word}."
  end
end

test = Hangman.new
