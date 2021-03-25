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
    if true
        # Hämta information,

        slim(:manager, locals: {type:"register", active: false})
    else 
        slim(:"user/login")
    end
end

get('/manager/:category') do
    if session[:username]
        slim(:manager, locals: {type:"register"})
    else 
        slim(:"user/login")
    end
end

post('/user/register') do 

    user_char = rnd_char()
    password = rnd_number_string()
    p user_char
    p password
    identifier = password[0..7]
    p identifier
    login_cridentials = register_user(user_char, identifier)
    p login_cridentials
    p login_cridentials[:valid]
    p login_cridentials[:valid] == true
    if login_cridentials[:valid] == true
        session[:secret] = identifier  # Hash med ett key från servern
        session[:username] = login_cridentials[:username]  # Hash med ett key från servern
        session[:password] = password  # Hash med ett key från servern
        
        p "Registration complete!"
        # "abc" --> "42379402" = "4723940"
        # "4723940" --> "42379402" = "abc"

        redirect("/register")
    end
end

post('/user/register_complete') do
    p "register finished!"
    session.delete(:password)
    redirect("/manager")
end 

post('/user/logout') do 
    if session[:id]
        session.destroy()
    else
    end
end

post('/user/login') do 
    password = params[:password].to_s
    p password
    login = login_user(password)
    if login.ok
        p "logged in"
       session[:msg] = login.msg
       session[:id] = password
    else
        p login.msg
    end
end


# puts plain = 'confidential'           # confidential
# puts key = 'secret'                   # secret
# puts cipher = plain.encrypt(key)      # 5C6D4C5FAFFCF09F271E01C5A132BE89

# puts cipher.decrypt('guess')          # raises OpenSSL::Cipher::CipherError
# puts cipher.decrypt(key)              # confidential