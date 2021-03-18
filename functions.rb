
# Random string, first 8 is used to crypt the info, last 4 to add to the password
def rnd_number_string()
    12.times.map { rand(0..9) }.join
end


def rnd_char()
    chars = "abcdefghijklmnopqrstuvwxyz"
    return chars[rand(0..(chars.length - 1))]
end