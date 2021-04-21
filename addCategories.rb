require_relative './model.rb'

file_data = File.read("categories.txt").split(' | ')

p file_data

file_data.each do |name|
    db_connection.execute('INSERT INTO categories (name) VALUES (?)', name)
end