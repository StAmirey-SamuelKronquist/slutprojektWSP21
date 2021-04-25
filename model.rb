require 'sqlite3'
require 'bcrypt'

module Model
    # Connects to the database
    #
    # @return [Hash] containing the connection
    def db_connection()
        db = SQLite3::Database.new("db/passman.db")
        db.results_as_hash = true
        return db;
    end

    # Registers a new user
    #
    # @param [String] user_char, The character that is the first part of the username 
    # @param [String] password, The password generated to the user
    #
    # @return [Hash]
    #   * :valid [Boolean] if valid registation 
    #   * :username [String] the full username
    #   * :id [Integer] the id of the newly created user
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

    # Tries to log in the user
    #
    # @param [String] username, The username for the user
    # @param [String] password, The password for the user
    #
    # @return [Hash]
    #   * :ok [Boolean] if the username and password where ok 
    #   * :msg [String] Msg with error or success
    #   * :id [Integer] the id of the user
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

    # Selects all the passwords for the user
    #
    # @param [Integer] id, The user_id of the user
    #
    # @return [Array] a list of all the passwords for the user
    def select_passwords(id)
        return db_connection().execute('SELECT p.name as pass_name, random_str, c.name as cat_name, c.id as cat_id, p.id as pass_id FROM passwords p JOIN pass_cat pc ON p.id=pc.pass_id JOIN categories c ON pc.cat_id=c.id WHERE p.user_id=?', id)
    end

    # Adds a new password
    #
    # @param [String] hashed_name, The name of the task - hashed
    # @param [String] hashed_rnd, The random string for the password - hashed
    # @param [Integer] category_id, The id of the currect passwords category
    # @param [Integer] id, The user_id
    def add_password(hashed_name, hashed_rnd, category_id, id)
        current_connection = db_connection()
        current_connection.execute('INSERT INTO passwords (user_id, name, random_str) VALUES (?,?,?)', id, hashed_name, hashed_rnd)
        res = current_connection.execute('SELECT id FROM passwords WHERE user_id=? AND name=? AND random_str=?', id, hashed_name, hashed_rnd).first
        p res
        current_connection.execute('INSERT INTO pass_cat (cat_id, pass_id) VALUES (?,?)', category_id, res["id"])
    end

    # Checks if the password is the users
    #
    # @param [Integer] user_id, The user_id of the user
    # @param [Integer] pass_id, The passwords id
    #
    # @return [Boolean] whether the password is the users or not
    def my_pass(user_id, pass_id)
        result = db_connection().execute('SELECT * FROM passwords WHERE user_id=? AND id=?', user_id, pass_id)
        p result
        p user_id
        p pass_id
        return result[0] != nil
    end

    # Deletes a password
    #
    # @param [Integer] pass_id, The id of the password
    def delete_pass(pass_id)
        current_connection = db_connection()
        current_connection.execute('DELETE FROM pass_cat WHERE pass_id=?', pass_id)
        current_connection.execute('DELETE FROM passwords WHERE id=?', pass_id)
    end

    # Checks if user is admin
    #
    # @param [Integer] user_id, The id of the user
    #
    # @return [Boolean] whether the user is admin or not
    def is_admin(user_id)
        result = db_connection().execute('SELECT admin FROM users WHERE id=?', user_id)
        p result
        return (result[0] && result[0]["admin"].to_i == 1)
    end

    # Fetches all users
    #
    # @return [Array] a list of all the users
    def fetch_all_users()
        return db_connection().execute('SELECT * FROM users')
    end

    # Returns a random category that the user haven't already "used"
    #
    # @param [Integer] id, The user_id of the user
    #
    # @return [Integer] the id of the chosen category
    def get_rnd_category(id)
        p "starting #{id}"
        result = db_connection().execute('SELECT id FROM categories WHERE id NOT IN (SELECT cat_id FROM passwords p JOIN pass_cat pc ON p.id=pc.pass_id JOIN categories c ON pc.cat_id=c.id WHERE p.user_id=?)', id)
        p "result #{result}"
        rnd = result.sample
        p rnd
        return rnd["id"].to_i
    end

    # Returns the name of the category
    #
    # @param [Integer] id, The id of the category
    #
    # @return [Hash] A hash containing the name of the category
    def get_category_name(id)
        return db_connection().execute('SELECT name FROM categories WHERE id=?', id).first
    end
end