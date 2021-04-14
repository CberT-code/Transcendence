
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin_name = "hbaudet"

if User.where(id: 1).exists?
	User.find(1).destroy
end
stat = Stat.new()
stat.save
moi = User.create(id: 1, role: 1, email: "#{admin_name}@student.42.fr", password: "password", provider: "marvin", uid: 60326, name: admin_name, stat_id: stat.id, image: "https://cdn.intra.42.fr/users/#{admin_name}.jpg", nickname: admin_name)

guild_list = [
	["first", "first", 5, "cbertola"],
	["second", "second", 5, "hbaudet"],
	["third", "third", 15, "llepage"],
	["fourth", "fourth", 15, "salty"]
]
guild_list.each do |name, anagramme, nb, admin|
	guild = Guild.find_by_name(name)
	@stat = Stat.new;
	@stat.save;
	if (guild != nil)
		guild.update(name: name, anagramme: anagramme, admin: moi, description: name, id_stats: @stat.id, maxmember: nb, nbmember: nb)
	else
		guild = Guild.new(name: name, anagramme: anagramme, admin: moi, description: name, id_stats: @stat.id, maxmember: nb, nbmember: nb)
		guild.save!
	end
end

user_list = [
	[57610, "cbertola", 1, 1],
	[57651, "jereligi", 1, 0],
	[58176, "cchudant", 1, 0],
	[60326, "salty", 4, 0],
	[60326, "melissa", 2, 0],
	[60326, "edm", 2, 0],
	[60326, "neo", 2, 0],
	[60326, "llepage", 2, 1],
	[60326, "hbaudet", 3, 1],
	[60326, "user7", 3, 0],
	[60326, "user8", 3, 0],
	[60326, "user9", 3, 0],
	[60326, "user10", 3, 0],
	[60326, "user11", 3, 0],
	[60326, "user12", 3, 0],
	[60326, "user13", 3, 0],
	[60326, "user14", 3, 0],
	[60326, "user15", 3, 0],
	[60326, "user16", 3, 0],
	[60326, "user17", 3, 0],
	[60326, "user18", 3, 0],
	[60326, "user19", 3, 0],
	[60326, "user20", 3, 0],
	[60326, "user21", 3, 0],
	[60326, "user22", 4, 0],
	[60326, "user23", 4, 0],
	[60326, "user24", 4, 0],
	[60326, "user25", 4, 0],
	[60326, "user26", 4, 0],
	[60326, "user27", 4, 0],
	[60326, "user28", 4, 0],
	[60326, "user29", 4, 0],
	[60326, "user30", 4, 0],
	[60326, "user31", 4, 0],
	[60326, "user32", 4, 0],
	[60326, "user33", 4, 0],
	[60326, "user34", 4, 0],
	[60326, "user35", 4, 0],
	[60326, "user36", 4, 0]
  ]
  
  user_list.each do |uid, name, guild|
	  usr = User.find_by_name(name)
	  @stat = Stat.new;
	  @stat.save;
	  if (usr != nil)
		  usr.update(email: "#{name}@student.42.fr", uid: uid, name: name, stat_id: @stat.id, image: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name, guild_id: guild)
	  else
		  usr = User.new(email: "#{name}@student.42.fr", password: "password", provider: "marvin", uid: uid, name: name, stat_id: @stat.id,  image: "https://cdn.intra.42.fr/users/#{name}.jpg", nickname: name, guild_id: guild)
		  usr.save!
	  end
  end
  
  guild_list.each do |name, anagramme, nb, admin|
	guild = Guild.find_by_name(name)
	guild.update(admin: User.find_by_name(admin))
	end


  trnmt_list = [
	  ["normal_games", 1, "default set of rules for standard games", 11, 1.7]
  ]
  
  trnmt_list.each do |name, id, desc, pts, speed|
	  tr = Tournament.find_by_id(id)
	  if (tr != nil)
		  tr.update(name: name, description: desc, maxpoints: pts, speed: speed)
	  else
		  Tournament.create(name: name, id: id, description: desc, maxpoints: pts, speed: speed)
	  end
  end