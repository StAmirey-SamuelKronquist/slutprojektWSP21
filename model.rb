require 'sqlite3'
require 'bcrypt'



def db_connection()
    db = SQLite3::Database.new("db/passman.db")
    db.results_as_hash = true
    return db;
end

def register_user(username, password)
    digested_password = BCrypt::Password.create(password)
    db_connection().execute('INSERT INTO users (password) VALUES (?)', digested_password)
    return true
end

def login_user(username, password) # a[userid], 
    p result

    result = db_connection().execute('SELECT password FROM users WHERE username=?', username)
    p result
    if result.length > 0
        if BCrypt::Password.new(result[0]["password"]) == password
            return {
                ok: true,
                msg: "Logged in!"
            }
        end
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

