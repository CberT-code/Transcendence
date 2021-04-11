class Guild < ApplicationRecord
	has_many :user
	belongs_to :war, optional: true
end