class War < ApplicationRecord
	belongs_to :tournament, foreign_key: 'tournament_id'
	belongs_to :guild1, class_name: 'Guild', foreign_key: 'guild1_id'
	belongs_to :guild2, class_name: 'Guild', foreign_key: 'guild2_id'
	has_many :games, class_name: 'History', foreign_key: 'war_id'

	def self.startwar
		warsstatus1 = War.where(['status = ?', 1])
		warsstatus1.each do |war|

			timetostart = ((war.start.to_date) - DateTime.current.to_date).to_i
			if (timetostart < 1)
				if (war.team1.count < war.players)
					while war.team1.count < war.players do
						war.guild1.users.all.each do |user|
							if (!war.team1.include?user.id)
								war.team1.push(user.id)
								break
							end
						end
						if war.guild1.users.size < war.players
							break
						end
					end
				end
				if (war.team2.count < war.players)
					while war.team2.count < war.players do
						war.guild2.users.all.each do |user|
							if (!war.team2.include?user.id)
								war.team2.push(user.id)
								break
							end
						end
					end
					if war.guild2.users.size < war.players
						break
					end
				end
				war.update({status: 2})
			end
		end
	end

	def self.endwar
		warsstatus2 = War.where(['status = ?', 2])
		warsstatus2.each do |war|
			timetostart2 = ((war.end.to_i) - DateTime.current.to_i).to_i
			if (timetostart2 < 1)
				guild = Guild.find_by_id(war.guild1_id)
				guild2 = Guild.find_by_id(war.guild2_id)
				if (war.points_guild1 > war.points_guild2)
					guild.update({points: guild.points + war.points})
				elsif (war.points_guild1 < war.points_guild2)
					guild2.update({points: guild2.points + war.points})
				end
				guild.update({war_id: nil})
				guild2.update({war_id: nil})

				war.update({status: 3, wartime: false})
			end
		end
	end

	def self.startwartime
		warsstatus2 = War.where(['status = ?', 2])
		warsstatus2.each do |war|
			war.update({wartime: true})
		end
	end

	def self.stopwartime
		warsstatus2 = War.where(['status = ?', 2])
		warsstatus2.each do |war|
			war.update({wartime: false})
		end
	end

	def self.isAvailable(id)
		war = War.find_by_id(id)
		if !war || !war.wartime || war.ongoingMatch
			return false
		end
		return true
	end

	def self.canDuel(host, opponent)
		if !opponent || !host
			return false
		elsif host.guild && host.guild.war && opponent.guild &&
				host.guild != opponent.guild &&
				host.guild.war == opponent.guild.war &&
				host.guild.war.start < Time.now &&
				Time.now < host.guild.war.end && 
				(host.guild.war.team1.include?(host.id) ||
					host.guild.war.team2.include?(host.id)) &&
				(opponent.guild.war.team1.include?(opponent.id) ||
					opponent.guild.war.team2.include?(opponent.id))
			return true
		end
		return false
	end
end