require 'yaml'

class Hangman
  def initialize
    @save_dir = "saved_games"
    Dir.mkdir(@save_dir) unless File.exists?(@save_dir)
    @word = pick_word
    @guesses_remaining = 16
    @guesses = []
    @solution = Array.new(@word.length, "_")
    @victory_state = "none"
    welcome_screen
  end

  def welcome_screen
    puts "Would you like to:"
    puts "\t1 - Start a new game"
    puts "\t2 - Load a saved game"
    choice = gets.chomp
    if choice == '1'
      play
    elsif choice == '2'
      load_game
    else
      puts "Invalid option"
      welcome_screen
    end
  end

  def save_game
    puts "Enter a name for your save file: "
    save_name = @save_dir + "/" + gets.chomp + ".save"
    if File.exists?(save_name)
      puts "Save file with that name already exists. Do you wish to"
      puts "overwrite? (yes/no)"
      choice = gets.chomp
      save_game unless choice == "yes" || choice == "y"
    end
    puts 'saving...'
    save_file = File.open(save_name, "w")
    save_data = self
    save_file.puts YAML::dump(save_data)
    save_file.close
    puts "Game saved!"
    exit
  end

  def load_game
    if (Dir.entries(@save_dir) - %w{ . .. }).empty?
      puts "No save files found!"
      welcome_screen
    else
      puts "Select which save to load: "
      save_files = Dir.entries(@save_dir) - %w{ . .. }
      save_files.sort!
      save_files.each_with_index do |save, index|
        puts "#{index + 1} - #{save}"
      end
      choice = gets.chomp
      if save_files[choice.to_i - 1].nil? || choice !~ /\d+/
        #need to check if user input is a digit
        puts "Invalid option!"
        load_game
      end
      selected_save = save_files[choice.to_i - 1]
      saved_game = YAML::load(File.open("#{@save_dir}/#{selected_save}"))
      saved_game.play
    end
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
      if input.length == 1 && input =~ /[a-z]/
        valid = true
        return input
      elsif input == 'save'
        valid = true
        save_game
      end
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

current_game = Hangman.new
