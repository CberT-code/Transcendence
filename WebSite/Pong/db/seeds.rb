# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user_list = [
  ["hbaudet@student.42.fr", 60326, "hbaudet"],
  ["jereligi@student.42.fr", 57651, "jereligi"],
  ["cchudant@student.42.fr", 58176, "cchudant"]
]

user_list.each do |email, uid, name|
	User.create(email: email, guild_id: -1, provider: "marvin", uid: uid, name: name, picture_url: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name)
end

Tournament.create(name: "default", description: "default set of rules", maxpoints: 11, speed: 7.0)