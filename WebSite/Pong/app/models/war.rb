class War < ApplicationRecord
	belongs_to :tournament
	has_many :history
	has_many :user
	has_many :guild
end