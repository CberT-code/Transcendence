class User < ApplicationRecord
	has_many :games
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
		user.id_stats = @stat.id

		user.name = user.email.split('@')[0]
		user.picture_url = 'https://cdn.intra.42.fr/users/large_' + user.name + '.jpg'
		user.save!
	  end
	end
  end
  
