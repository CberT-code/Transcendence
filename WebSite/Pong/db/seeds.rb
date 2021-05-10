
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

guild_list = [ 			# [ name, tag, max_members, admin ]
	["first", "first", 5, "cbertola"],
	["second", "second", 5, "bibiche"],
	["third", "third", 15, "user11"],
	["fourth", "fourth", 15, "hbaudet"]
]
user_list = [ 			# [ UID, name, guild, role ]
	[12421, "salty", "first", 0],
	[57610, "cbertola", "first", 0],
	[12421, "melberg", "first", 0],
	[12421, "edm", "first", 0],
	[12421, "neo", "first", 0],
	[63184, "llepage", "fourth", 1],
	[60326, "hbaudet", "fourth", 1],
	[12421, "sophie", "second", 0],
	[12421, "bibiche", "second", 0],
	[12421, "user11", "third", 0],
	[12421, "user12", "third", 0],
	[12421, "user13", "third", 0],
	[12421, "user14", "third", 0],
	[12421, "user15", "third", 0],
	[12421, "user16", "third", 0],
	[12421, "user17", "third", 0],
	[12421, "user18", "third", 0],
	[12421, "user19", "third", 0],
	[12421, "user20", "third", 0],
	[12421, "user21", "third", 0],
	[12421, "charly", "third", 0],
	[12421, "user23", "third", 0],
	[12421, "user24", "third", 0],
	[12421, "user25", "fourth", 0],
	[12421, "user26", "second", 0],
	[12421, "user27", "second", 0],
	[12421, "user28", "fourth", 0],
	[12421, "user29", "fourth", 0],
	[12421, "user30", "fourth", 0],
	[12421, "user31", "fourth", 0],
	[12421, "user32", "fourth", 0],
	[12421, "user33", "fourth", 0],
	[12421, "user34", "fourth", 0],
	[12421, "user35", "fourth", 0],
	[12421, "user36", "fourth", 0],
	[12421, "user37", "fourth", 0],
	[12421, "user38", "fourth", 0],
	[12421, "user39", "fourth", 0]
  ]

@date = DateTime.new(1902,1,1,1,1,1);
trnmt_list = [
	["Ping Pong", "11 points to win", 11, 1.0, @date, nil],
]
  
trnmt_list.each do |name, desc, pts, speed, start, endd|
	Tournament.create(name: name, description: desc, maxpoints: pts, speed: speed, start: start, end: endd, status: 1)
end 

user_list.each do |uid, name, guild|
	usr = User.find_by_nickname(name)
	if (usr != nil)
		usr.update(email: "#{name}@student.42.fr",
		uid: uid, name: name,
		image: "https://cdn.intra.42.fr/users/#{name}.jpg",
		nickname: name)
	else
		stat = Stat.new;
		stat.save!
		usr = User.new(email: "#{name}@student.42.fr",
		password: "password", provider: "marvin", uid: uid,
		name: name, stat_id: stat.id,
		image: "https://cdn.intra.42.fr/users/#{name}.jpg",
		nickname: name)
		usr.save!
		tournamentUser = TournamentUser.new();
		tournamentUser.update(user_id: usr.id, tournament_id: 1);
		tournamentUser.save
	end
end

guild_list.each do |name, anagramme, nb, admin_name|
	guild = Guild.find_by_name(name)
	admin = User.find_by_name(admin_name)
	stat = Stat.new;
	stat.save;
	if (guild != nil)
		guild.update({name: name, anagramme: anagramme,
			admin: admin, description: name,
			id_stats: stat.id, maxmember: nb, nbmember: nb})
	else
		guild = Guild.new(name: name, anagramme: anagramme,
			id_admin: 1, description: name, admin: admin,
			id_stats: stat.id, maxmember: nb, nbmember: nb)
		guild.save!
	end
end

user_list.each do |uid, name, guild|
	User.find_by_nickname(name).update(guild: Guild.find_by_name(guild))
end