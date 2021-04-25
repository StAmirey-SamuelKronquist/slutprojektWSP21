module Functions
    # Random string, first 8 is used to crypt the info, last 4 to add to the password
    def rnd_number_string()
        12.times.map { rand(0..9) }.join
    end


    def rnd_char()
        chars = "abcdefghijklmnopqrstuvwxyz"
        return chars[rand(0..(chars.length - 1))]
    end

    def generate_rnd(length)
        chars = "abcdefghijklmnopqrstuvwxyz0123456789"
        i = 0
        res = "";
        while i < length
            res += chars[rand(0..(chars.length - 1))]
            i += 1
        end
        return res
    end

    def validString(str) 
        chars = "abcdefghijklmnopqrstuvwxyz0123456789 "
        i = 0
        ok = true
        while i < str.length
            if !chars.include?(str[i])
                ok = false;
                i = str.length
            end
            i += 1
        end
        return ok
    end
end