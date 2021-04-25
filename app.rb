require 'sinatra'
require 'slim'

require_relative './model.rb'
require_relative './crypting.rb'
require_relative './functions.rb'
include Model 
include Crypting
include Functions


enable :sessions

# Displays landing page
#
get('/') do
    if session[:id] != nil
        redirect("/manager")
    else 
        slim(:"user/login")
    end
end


# Displays the Login page
#
get('/login') do 
    if session[:id] != nil
        redirect("/manager")
    else 
        slim(:"user/login")
    end
end
  

# Displays the register page with the cridentails
# 
get('/register') do 
    p "Register, #{session[:password]}"
    if session[:password] != nil
        slim(:"user/register")
    else 
        slim(:"user/login")
    end
end

# Displays all the passwords for the logged in user
#
# @see Model#select_passwords
get('/manager') do
    if session[:id] != nil
        raw_passwords = select_passwords(session[:id])
        passwords= {}
        raw_passwords.each do |password| 
            if passwords[password["cat_name"]] == nil
                passwords[password["cat_name"]] = {
                    id: password["cat_id"],
                    passwords: []
                }
            end
            decrypted_name = decrypt_string(password["pass_name"], session[:secret])
            decrypted_rnd_str = decrypt_string(password["random_str"], session[:secret])
            passwords[password["cat_name"]][:passwords].push({
                name: decrypted_name,
                id: password["pass_id"],
                password: "#{password['cat_name'][0]}#{password['cat_name'][-1]}#{decrypted_name[0].upcase!}#{decrypted_name[1]}#{decrypted_name[2]}#{decrypted_rnd_str}"
            }) 
        end

        slim(:manager, locals: {passwords: passwords})
    else 
        slim(:"user/login")
    end
end


# Registers a new user and redirects to '/register'
#
# @see Model#register_user
post('/user/register') do 

    user_char = rnd_char()
    password = rnd_number_string()
    identifier = password[0..7]
    login_cridentials = register_user(user_char, identifier)
    if login_cridentials[:valid] == true
        session[:secret] = identifier  # Hash med ett key från servern
        session[:id] = login_cridentials[:id]  # Hash med ett key från servern
        session[:username] = login_cridentials[:username]  # Hash med ett key från servern
        session[:password] = password  # Hash med ett key från servern
        
        p "Registration complete!"

        redirect("/register")
    end
end


# Completes the registation of a new user and redirects to '/manager'
#
post('/user/register_complete') do
    p "register finished!"
    session.delete(:password)
    redirect("/manager")
end 


# Logs the user out
#
get('/logout') do 
    if session[:id]
        session.destroy()
    end
    redirect("/")
end


# Trying to login a user and either redirects to '/manager' if logged in successfully or '/' if not
#
# @param [String] username, The username
# @param [String] password, The password
# @see Model#login_user
post('/user/login') do 
    username = params[:username].to_s
    password = params[:password].to_s
    login = login_user(username, password)
    if login[:ok]
       session[:msg] = login[:msg]
       session[:secret] = password
       session[:id] = login[:id]
       session[:username] = username
       redirect("/manager")
    else
        p login[:msg]
        redirect("/")
    end
end


# Adding a new password for the user and redirects to '/manager'
#
# @param [Integer] category, The id of the category
# @param [String] name, The name of the new password
# @see Model#get_category_name
# @see Model#add_password
post('/password/add') do
    if session[:id]
        category_id = params[:category].to_s
        name = params[:name].to_s
        p name
        if name.length >= 3 && name.length <= 20 && validString(name)
            if category_id == "new"
                category_id = get_rnd_category(session[:id]).to_i
            else 
                category_id = category_id.to_i
            end
            category = get_category_name(category_id)
            if category != nil && category["name"]
                rnd_string = generate_rnd(4)
                password = "#{category['name'][0]}#{category['name'][-1]}#{name[0].upcase!}#{name[1]}#{name[2]}#{rnd_string}"

                add_password(encrypt_string(name, session[:secret]), encrypt_string(rnd_string, session[:secret]), category_id, session[:id])
                redirect('/manager')
            else 
                p "Error getting category name "
            end
        else 
            p "Error with the name #{name} (must be between 3 and 20 characters / numbers)"
        end
    end
end


# Deletes a password and redirects to '/manager'
#
# @param [Integer] pass_id, The id of the password
# @see Model#delete_pass
post('/password/delete') do
    p "Trying to delete #{session[:id]}"
    if session[:id]
        pass_id = params[:pass_id].to_i
        p pass_id
        if my_pass(session[:id], pass_id)
            p "my pass ok!"
            delete_pass(pass_id)
            redirect('/manager')
        end
    end
    redirect('/')
end


# Gives information about the users if user is admin 
#
# @see Model#fetch_all_users
get('/admin') do 
    if session[:id] != nil
        if is_admin(session[:id])
            slim(:"admin", locals: {users: fetch_all_users()})
        end
    end
end