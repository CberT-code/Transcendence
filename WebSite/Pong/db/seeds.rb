# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
guild_list = [
	["first", "first", 5],
	["second", "secon", 5],
	["third", "third", 15],
	["fourth", "fourt", 15]
]
guild_list.each do |name, anagramme, nb|
	guild = Guild.find_by_name(name)
	@stat = Stat.new;
	@stat.save;
	if (guild != nil)
		guild.update(name: name, anagramme: anagramme, id_admin: 1, description: name, id_stats: @stat.id, maxmember: nb)
	else
		guild = Guild.new(name: name, anagramme: anagramme, id_admin: 1, description: name, id_stats: @stat.id, maxmember: nb)
		guild.save!
	end
end

user_list = [
	[57610, "cbertola"],
	[60326, "hbaudet"],
	[57651, "jereligi"],
	[58176, "cchudant"],
	[60326, "user1"],
	[60326, "user2"],
	[60326, "user3"],
	[60326, "user4"],
	[60326, "user5"],
	[60326, "user6"],
	[60326, "user7"],
	[60326, "user8"],
	[60326, "user9"],
	[60326, "user10"],
	[60326, "user11"],
	[60326, "user12"],
	[60326, "user13"],
	[60326, "user14"],
	[60326, "user15"],
	[60326, "user16"],
	[60326, "user17"],
	[60326, "user18"],
	[60326, "user19"],
	[60326, "user20"],
	[60326, "user21"],
	[60326, "user22"],
	[60326, "user23"],
	[60326, "user24"],
	[60326, "user25"],
	[60326, "user26"],
	[60326, "user27"],
	[60326, "user28"],
	[60326, "user29"],
	[60326, "user30"]
  ]
  
  user_list.each do |uid, name|
	  usr = User.find_by_name(name)
	  @stat = Stat.new;
	  @stat.save;
	  if (usr != nil)
		  usr.update(email: "#{name}@student.42.fr", uid: uid, name: name, stat_id: @stat.id, picture_url: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name)
	  else
		  usr = User.new(email: "#{name}@student.42.fr", password: "password", provider: "marvin", uid: uid, name: name, stat_id: @stat.id, picture_url: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name)
		  usr.save!
	  end
  end
  
  trnmt_list = [
	  ["friendly", 1, "default set of rules for friendly games", 11, 7.0],
	  ["ranked", 2, "default set of rules for ranked games", 11, 7.0],
	  ["duel", 3, "default set of rules for duels", 11, 7.0]
  ]
  
  trnmt_list.each do |name, id, desc, pts, speed|
	  tr = Tournament.find_by_id(id)
	  if (tr != nil)
		  tr.update(name: name, description: desc, maxpoints: pts, speed: speed)
	  else
		  Tournament.create(name: name, id: id, description: desc, maxpoints: pts, speed: speed)
	  end
  end