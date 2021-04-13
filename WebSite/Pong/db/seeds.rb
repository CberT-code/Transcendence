# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user_list = [
  [60326, "hbaudet"],
  [57651, "jereligi"],
  [58176, "cchudant"]
]

user_list.each do |uid, name|
	User.create(email: "#{name}@student.42.fr", guild_id: -1, role: 0, provider: "marvin", uid: uid, name: name, picture_url: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name)
end

Tournament.create(name: "friendly", description: "default set of rules for friendly games", maxpoints: 11, speed: 7.0)
Tournament.create(name: "ranked", description: "default set of rules for ranked games", maxpoints: 11, speed: 7.0)
Tournament.create(name: "duel", description: "default set of rules for duels", maxpoints: 11, speed: 7.0)