# frozen_string_literal: true

# Public and Private Key Generator
class EccKeyGenerator
  def self.generate
    ec_key = OpenSSL::PKey::EC.generate('secp256k1')
    {
      public_key: ec_key.public_to_pem,
      private_key: ec_key.to_pem
    }
  end
end
