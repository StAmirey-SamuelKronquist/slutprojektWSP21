require 'sqlite3'
require 'bcrypt'



def db_connection()
    db = SQLite3::Database.new("db/passman.db")
    db.results_as_hash = true
    return db;
end

def register_user(password)
    digested_password = BCrypt::Password.create(password)
    db_connection().execute('INSERT INTO users (password) VALUES (?)', digested_password)
    return true
end

def login_user(password)

    digested_password = BCrypt::Password.create(password)
    p result

    result = db_connection().execute('SELECT * FROM users WHERE password=?', digested_password)
    p result
    if result.length > 0
        return {
            ok: true,
            msg: "Logged in!"
        }
    end
    return {
        ok: false,
        msg: "Password not located!"
    }
end


# Random string, first 8 is used to crypt the info, last 4 to add to the password
def rnd_number_string()
    12.times.map { rand(0..9) }.join
end