class User < ApplicationRecord
	has_many :games
	has_many :hosted_games, class_name: 'History', foreign_key: 'host_id'
	has_many :foreign_games, class_name: 'History', foreign_key: 'opponent_id'
	belongs_to :guild, optional: true
	belongs_to :stat, optional: true
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable,
		   :recoverable, :rememberable, :validatable, :trackable,
		   :omniauthable, omniauth_providers: [:marvin]

   def self.from_omniauth(auth)
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
		user.email = auth.info.email
		user.uid = auth.uid
		user.password = Devise.friendly_token[0,20]
		user.nickname = auth.info.nickname
		user.image = auth.info.image

		@stat = Stat.new
		@stat.save
		user.stat_id = @stat.id
		user.save!
	  end
	end
  end
  
