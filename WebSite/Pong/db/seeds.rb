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
  [34567, "cbertola"],
  [34578, "llepage"],
  [45687, "salty"],
  [58176, "cchudant"]
]

user_list.each do |uid, name|
	usr = User.find_by_name(name)
	if (usr != nil)
		usr.update(email: "#{name}@student.42.fr", uid: uid, name: name, picture_url: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name)
	else
		usr = User.new(email: "#{name}@student.42.fr", password: "password", provider: "marvin", uid: uid, name: name, picture_url: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name)
		usr.save!
	end
end

trnmt_list = [
	["normal", 1, "default set of rules for ladder games", 11, 1.5],
]

trnmt_list.each do |name, id, desc, pts, speed|
	tr = Tournament.find_by_id(id)
	if (tr != nil)
		tr.update(name: name, description: desc, maxpoints: pts, speed: speed)
	else
		Tournament.create(name: name, id: id, description: desc, maxpoints: pts, speed: speed)
	end
end