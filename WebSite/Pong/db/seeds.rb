
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

@date = DateTime.new(1902,1,1,1,1,1);
trnmt_list = [
	["Pong", "Standard rules", 11, 4.0, @date, nil]
]
  
trnmt_list.each do |name, desc, pts, speed, start_time, end_time|
	Tournament.create(name: name, description: desc, maxpoints: pts, speed: speed, start_time: start_time, end: end_time)
end