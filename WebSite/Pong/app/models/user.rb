class User < ApplicationRecord
	has_many :games
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable,
		   :recoverable, :rememberable, :validatable,
		   :omniauthable, omniauth_providers: [:marvin]

   def self.from_omniauth(auth)
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
		user.email = auth.info.email
		user.uid = auth.uid
		user.password = Devise.friendly_token[0,20]
		user.name = user.email.split('@')[0]
		user.opponent = 0
		user.status = 'idle'
		user.position = 0
		user.picture_url = 'https://cdn.intra.42.fr/users/large_' + user.name + '.jpg'
		user.save!
		# user.nickname = auth.info.nickname
	  end
	end
  end
  
