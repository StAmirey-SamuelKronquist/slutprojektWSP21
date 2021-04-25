require 'openssl'

module Crypting

    def encrypt_string(str, secret)
        cipher_salt1 = secret.slice(0..3)
        cipher_salt2 = secret.slice(4..7)
        cipher = OpenSSL::Cipher.new('AES-128-ECB').encrypt
        cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(cipher_salt1, cipher_salt2, 20_000, cipher.key_len)
        encrypted = cipher.update(str) + cipher.final
        encrypted.unpack('H*')[0].upcase
    end

    def decrypt_string(encrypted_str, secret)
        cipher_salt1 = secret.slice(0..3)
        cipher_salt2 = secret.slice(4..7)
        cipher = OpenSSL::Cipher.new('AES-128-ECB').decrypt
        cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(cipher_salt1, cipher_salt2, 20_000, cipher.key_len)
        decrypted = [encrypted_str].pack('H*').unpack('C*').pack('c*')

        cipher.update(decrypted) + cipher.final
    end
end