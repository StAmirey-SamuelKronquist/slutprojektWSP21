require 'sinatra'
require 'slim'

require_relative './model.rb'
require_relative './crypting.rb'

enable :sessions


get('/') do
    slim(:login, locals: {type:"register"})
end

get('/login') do 
    slim(:login, locals: {type:"login"})
end
  
get('/register') do 
    slim(:login, locals: {type:"register"})
end

get('/manager') do
    if session[:id]
        # Hämta information,

        slim(:manager, locals: {type:"register", active: false})
    else 
        slim(:login, locals: {type:"login"})
    end
end

get('/manager/:category') do
    if session[:id]
        slim(:manager, locals: {type:"register"})
    else 
        slim(:login, locals: {type:"login"})
    end
end

post('/user/register') do 
    password = rnd_number_string()
    p password
    identifier = password[0..7]
    p identifier
    if register_user(identifier)
        session[:id] = identifier  # Hash med ett key från servern
        
        # "abc" --> "42379402" = "4723940"
        # "4723940" --> "42379402" = "abc"

        slim(:login, locals: {type:"register", active: true, pass: password})
    end
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