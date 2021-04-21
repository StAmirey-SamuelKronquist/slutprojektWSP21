require 'sqlite3'
require 'bcrypt'


def db_connection()
    db = SQLite3::Database.new("db/passman.db")
    db.results_as_hash = true
    return db;
end

def register_user(user_char, password)
    digested_password = BCrypt::Password.create(password)
    current_connection = db_connection()

    current_connection.execute('INSERT INTO users (password) VALUES (?)', digested_password)
    res = current_connection.execute('SELECT id FROM users WHERE password=?', digested_password).first
    p res
    username = (user_char + res["id"].to_s)

    p username
        
    current_connection.execute('UPDATE users SET username=? WHERE id=?', username, res["id"])

    return {
        valid: true,
        username: username,
        id: res["id"]
    }
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

def select_passwords(id)
    result = db_connection().execute('SELECT * FROM passwords p JOIN pass_cat pc ON p.id=pc.pass_id JOIN categories c ON pc.cat_id=c.id WHERE p.user_id=?', id)
end
def add_password(category_id, name, user_id) 
    rnd_string = 
end


def get_rnd_category(id)
    p "starting #{id}"
    result = db_connection().execute('SELECT id FROM categories where id NOT IN (SELECT cat_id FROM passwords p JOIN pass_cat pc ON p.id=pc.pass_id JOIN categories c ON pc.cat_id=c.id WHERE p.user_id=?)', id)
    p "result #{result}"
end