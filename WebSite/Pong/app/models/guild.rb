class Guild < ApplicationRecord
	has_many :users, class_name: 'User', foreign_key: 'guild_id'
	belongs_to :admin, class_name: 'User', foreign_key: 'id_admin'
	belongs_to :war, class_name: 'War', foreign_key: 'war_id', optional: true

	def notifyWarTimeStart(text = "Winter is coming")
		self.users.each do |user|
			ActionCable.server.broadcast("presence_#{user.id}", {info: text, type: "warTimeNotif", color: "red" })
		end
	end

	def notifyWarMatchRequest(id)
		self.users.each do |user|
			ActionCable.server.broadcast("presence_#{user.id}", {info: "We have been challenged! Click to accept", war_id: self.war_id, id: id, type: "warMatchRequest", color: "red" })
		end
	end
end