#!/usr/bin/env ruby

r = Random.new()
words = File.read('/root/bin/francais-divers.txt').split("\n")
sentence = words[r.rand(words.length)]
s_array = sentence.split("").map(&:downcase)
co = s_array - [" "]
final_s = sentence.gsub(/[a-zA-Z]/, "_").split("")
i = 0
tries = []
pendu = """   ___
  |   |
  |   o
  |  /|\\
  |  / \\
__|__
"""
    
if sentence.length > 6
    lvl = 1
else
    lvl = 2
end
puts "\nWord is : #{final_s.join}"
while s_array.count("") < co.count-1
    puts "Choose a letter: "
    guess = gets.downcase.chomp

    if guess == ""
        puts "Nothing ? :("

    elsif tries.include?(guess)
        puts "You already guessed it :)"

    elsif s_array.include?(guess)
        tries.push(guess)
        0.upto(sentence.length) do
            begin
                let_index = s_array.find_index(guess)
                s_array[let_index] = ""
                final_s[let_index] = guess
                puts "\033[92mCorrect ! =>                 \033[0m#{final_s.join}"
            rescue
            end
        end
    else
        i += lvl
        tries.push(guess)
        puts "\033[91mSorry, wrong letter :(   =>\033[0m      #{final_s.join}"
        puts pendu[0...i*5]
        puts
        puts "Tries: #{tries.join(', ')}"
    end
    if i == 10
        puts "\033[91mSorry, you loose :(\033[0m"
        puts "\n :: Answer was #{sentence}"
        exit
    end 
end
puts "\n\033[92m [+]  !!BRAVO!!\033[0m\n"
