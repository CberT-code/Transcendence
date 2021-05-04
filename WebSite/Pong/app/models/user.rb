class User < ApplicationRecord
  devise :two_factor_authenticatable,
         :otp_secret_encryption_key => ENV['FT_KEY']

	has_many :t_users, class_name: 'TournamentUser', foreign_key: 'user_id'
	has_many :hosted_games, class_name: 'History', foreign_key: 'host_id'
	has_many :foreign_games, class_name: 'History', foreign_key: 'opponent_id'
	belongs_to :guild, class_name: 'Guild', foreign_key: 'guild_id', optional: true
	belongs_to :stat, optional: true
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :registerable,
		   :recoverable, :rememberable, :validatable, :trackable,
		   :omniauthable, omniauth_providers: [:marvin]
	
	def self.from_omniauth(auth)
	  where({provider: auth.provider, uid: auth.uid, email: auth.info.email}).first_or_create do |user|
		user.email = auth.info.email
		user.uid = auth.uid
		user.password = Devise.friendly_token[0,20]
		user.nickname = auth.info.nickname
		user.name = user.nickname
		user.image = auth.info.image
		user.otp_required_for_login = false
		
		@stat = Stat.new
		@stat.save
		user.stat_id = @stat.id
		user.save!

		tournament = TournamentUser.new
		tournament.update({user_id: user.id, tournament_id: 1})
		tournament.save
		end
	end

	def isOnline
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		status = redis.get("player_#{self.id}")
		if (status == "static" || status == "up" || status == "down")
			return "in_game"
		elsif status != nil
			return status
		else
			return "offline"
		end
	end

	def notifyFriends(type)
		self.friends.each do |id|
			user = User.find_by_id(id)
			if user && user.isOnline() != "offline"
				ActionCable.server.broadcast("presence_#{id}", {type: type, info: "#{self.nickname} is #{type}"})
			end
		end
	end

	def findLiveGame
		game = History.where("host_id = ? OR opponent_id = ?", self.id, self.id).where(statut: 2).first
		puts "Hello from findLiveMatch"
		if game
			return game.id
		else
			return -1
		end
	end

  end
  
