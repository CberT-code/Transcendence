
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin_name = "sudo"

guild_list = [ 			# [ name, tag, max_members, admin ]
	["first", "first", 5, "cbertola"],
	["second", "second", 5, "hbaudet"],
	["third", "third", 15, "llepage"],
	["fourth", "fourth", 15, "salty"]
]
user_list = [ 			# [ UID, name, guild, role ]
	[12421, "salty", "first", 0],
	[12421, "melberg", "first", 0],
	[12421, "edm", "first", 0],
	[12421, "neo", "first", 0],
	[12421, "llepage", "second", 1],
	[60326, "hbaudet", "second", 1],
	[12421, "sophie", "second", 0],
	[12421, "bibiche", "second", 0],
	[12421, "user9", "second", 0],
	[12421, "user10", "third", 0],
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
	[12421, "user26", "fourth", 0],
	[12421, "user27", "fourth", 0],
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
war_list = [			# [ id, guild1, guild2, tournament_id]
  	[1, "first", "second", 2],
	[2, "second", "first", 3],
	[3, "fourth", "third", 4],
	[4, "third", "fourth", 1],
	[5, "third", "first", 2],
	[6, "second", "fourth", 3]
]
games_list = [			# [ host, opponent, host score, opponent score, tournament id, war id, ranked, status ]
	["cbertola", "hbaudet", 11, 4, 1, -1, false, 3],
	["llepage", "cbertola", 0, 11, 1, -1, true, 3],
	["salty", "neo", 0, 11, 2, -1, false, 3],
	["melberg", "sophie", 0, 11, 2, -1, true, 3],
	["edm", "hbaudet", 6, 3, 2, 1, true, 3],
	["hbaudet", "cbertola", 6, 1, 3, 2, true, 3],
	["salty", "llepage", 3, 2, 4, 3, true, 3],
	["melberg", "user7", 0, 11, 3, 2, true], 3,
	["cbertola", "hbaudet", 4, 11, 2, -1, true, 3],
	["melberg", "user34", 11, 0, 3, 6, true, 2],
	["neo", "charly", 3, 2, 1, -1, true, 2]
]
	@date = DateTime.new(1902,1,1,1,1,1);
	trnmt_list = [
		["Normal", "11 points to win", 11, 7.0, @date, nil],
		["Mort Subite", "1 points to win", 1, 7.0, DateTime.current, DateTime.current + 6.days]
	]
  
trnmt_list.each do |name, desc, pts, speed, start, endd|
	Tournament.create(name: name, description: desc, maxpoints: pts, speed: speed, start: start, end: endd)
end 

stat = Stat.new()
stat.save


moi = User.create(email: "cbertola@student.42.fr", password: "password", provider: "marvin", uid: 57610, name: "cbertola", stat_id: stat.id, image: "https://cdn.intra.42.fr/users/cbertola.jpg", nickname: "cbertola")
moi.save

tournamentUser = TournamentUser.new();
tournamentUser.update(user_id: 1, tournament_id: 1);
tournamentUser.save

guild_list.each do |name, anagramme, nb, admin|
	guild = Guild.find_by_name(name)
	@stat = Stat.new;
	@stat.save;
	if (guild != nil)
		guild.update(name: name, anagramme: anagramme,
			id_admin: 1, description: name,
			id_stats: @stat.id, maxmember: nb, nbmember: nb)
	else
		guild = Guild.new(name: name, anagramme: anagramme,
			id_admin: 1, description: name,
			id_stats: @stat.id, maxmember: nb, nbmember: nb)
		guild.save!
	end
end

user_list.each do |uid, name, guild|
	usr = User.find_by_name(name)
	@stat = Stat.new;
	@stat.save;
	if (usr != nil)
		usr.update(email: "#{name}@student.42.fr",
		uid: uid, name: name, stat_id: @stat.id,
		image: "https://cdn.intra.42.fr/users/#{name}.jpg",
		nickname: name, guild: Guild.find_by_name(guild), elo: rand(800..1200))
	else
		usr = User.new(email: "#{name}@student.42.fr",
		password: "password", provider: "marvin", uid: uid,
		name: name, stat_id: @stat.id,
		image: "https://cdn.intra.42.fr/users/#{name}.jpg",
		nickname: name, guild: Guild.find_by_name(guild), elo: rand(800..1200))
		usr.save!
		tournamentUser = TournamentUser.new();
		tournamentUser.update(user_id: usr.id, tournament_id: 1);
		tournamentUser.save
	end
end

guild_list.each do |name, anagramme, nb, admin|
	guild = Guild.find_by_name(name)
	guild.update(admin: User.find_by_name(admin))
end

war_list.each do |id, guild1, guild2, tr|
	war = War.find_by_id(id)
	if (war != nil)
		war.update(guild1: Guild.find_by_name(guild1),
		guild2: Guild.find_by_name(guild2),
		points: 50, players: 10, tournament_id: tr)
	else
		War.create(guild1: Guild.find_by_name(guild1),
		id: id, guild2: Guild.find_by_name(guild2),
		points: 50, players: 10, tournament_id: tr)
	end
end

games_list.each do |host, opponent, host_score, oppo_score, tid, wid, ranked, status|
	game = History.create(host: User.find_by_name(host),
		opponent: User.find_by_name(opponent), statut: status,
		host_score: host_score, opponent_score: oppo_score,
		tournament_id: tid, war_id: wid, ranked: ranked)
end