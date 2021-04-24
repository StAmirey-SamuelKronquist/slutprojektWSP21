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
    result = db_connection().execute('SELECT id, password FROM users WHERE username=?', username)
    p result
    if result.length > 0
        if BCrypt::Password.new(result[0]["password"]) == password
            return {
                ok: true,
                msg: "Logged in!",
                id: result[0]["id"]
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
    return db_connection().execute('SELECT p.name as pass_name, random_str, c.name as cat_name, c.id as cat_id FROM passwords p JOIN pass_cat pc ON p.id=pc.pass_id JOIN categories c ON pc.cat_id=c.id WHERE p.user_id=?', id)
end
def add_password(hashed_name, hashed_rnd, category_id, id)
    current_connection = db_connection()
    current_connection.execute('INSERT INTO passwords (user_id, name, random_str) VALUES (?,?,?)', id, hashed_name, hashed_rnd)
    res = current_connection.execute('SELECT id FROM passwords WHERE user_id=? AND name=? AND random_str=?', id, hashed_name, hashed_rnd).first
    p res
    current_connection.execute('INSERT INTO pass_cat (cat_id, pass_id) VALUES (?,?)', category_id, res["id"])
end


def get_rnd_category(id)
    p "starting #{id}"
    result = db_connection().execute('SELECT id FROM categories WHERE id NOT IN (SELECT cat_id FROM passwords p JOIN pass_cat pc ON p.id=pc.pass_id JOIN categories c ON pc.cat_id=c.id WHERE p.user_id=?)', id)
    p "result #{result}"
    rnd = result.sample
    p rnd
    return rnd["id"].to_i
end

def get_category_name(id)
    return db_connection().execute('SELECT name FROM categories WHERE id=?', id).first
end