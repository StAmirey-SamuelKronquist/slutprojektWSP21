require 'sinatra'
require 'slim'

require_relative './model.rb'
require_relative './crypting.rb'
require_relative './functions.rb'

enable :sessions


get('/') do
    slim(:"user/login")
end

get('/login') do 
    slim(:"user/login")
end
  
get('/register') do 
    p "Register, #{session[:password]}"
    if session[:password] != nil
        slim(:"user/register")
    else 
        slim(:"user/login")
    end
end

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
                password: "#{password['cat_name'][0]}#{password['cat_name'][-1]}#{decrypted_name[0]}#{decrypted_name[1]}#{decrypted_name[2]}#{decrypted_rnd_str}"
            }) 
        end

        slim(:manager, locals: {passwords: passwords})
    else 
        slim(:"user/login")
    end
end

# get('/manager/:category') do
#     if session[:username]
#         slim(:manager, locals: {type:"register"})
#     else 
#         slim(:"user/login")
#     end
# end

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

post('/user/register_complete') do
    p "register finished!"
    session.delete(:password)
    redirect("/manager")
end 

get('/logout') do 
    if session[:id]
        session.destroy()
    end
    redirect("/")
end

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


post('/password/add') do
    if session[:id]
        category_id = params[:category].to_s
        name = params[:name]
        if name.length >= 3 && name.length <= 20 && validString(name)
            if category_id == "new"
                category_id = get_rnd_category(session[:id]).to_i
            else 
                category_id = category_id.to_i
            end
            category = get_category_name(category_id)
            if category != nil && category["name"]
                rnd_string = generate_rnd(4)
                password = "#{category['name'][0]}#{category['name'][-1]}#{name[0]}#{name[1]}#{name[2]}#{rnd_string}"

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


post('/password/add') do
    p session[:id]
    if session[:id]
        
    end
end