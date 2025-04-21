# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
parent_court = Court.find_or_create_by!(subdomain: 'narphung')


# Add User with secure password handling
password = "narphungregistrar"
registrar_user = User.find_or_create_by!(email: "narphungregistrar@example.com") do |user|
  user.password = password
  user.password_confirmation = password
  user.court_id = parent_court.id
  user.confirmed_at = Time.now
end


registrar_user.add_role(:Registrar)


# Add or Update Profile
profile = Profile.find_or_initialize_by(user_id: registrar_user.id)
profile.update!(
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  cid_no: Faker::Number.number(digits: 11).to_s,
  phone_number: Faker::Number.number(digits: 11).to_s,
  gender: :male
)





puts "✅ Seed data loaded successfully!"


