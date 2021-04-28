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
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
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
		end
	end

	def isOnline
		redis = Redis.new(	url:  ENV['REDIS_URL'],
							port: ENV['REDIS_PORT'],
							db:   ENV['REDIS_DB'])
		status = redis.get("player_#{params[:id]}")
		if (status == "static" || status == "up" || status == "down")
			return "in_game"
		elsif status != nil
			return status
		else
			return "offline"
		end
	end

  end
  
