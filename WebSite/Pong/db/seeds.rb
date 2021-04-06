# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user_list = [
  ["hbaudet@student.42.fr", "$2a$12$elUhLXrKhwCM2fQo06KB9uD8hd1Kkw9gq.ASAH8g/FwfFcYnIYYEq", -1, 1, "marvin", 60326, "hbaudet", "https://cdn.intra.42.fr/users/large_hbaudet.jpg", "hbaudet", "https://cdn.intra.42.fr/users/hbaudet.jpg" ],
  ["jereligi@student.42.fr", "$2a$12$dY1ya5zr/CiqkkxozUkcDeihWDC1mQByDhP/n5Fi69biNnHrFf1DC", -1, 2, "marvin", 57651, "jereligi", "https://cdn.intra.42.fr/users/large_jereligi.jpg", "jereligi", "https://cdn.intra.42.fr/users/jereligi.jpg" ],
  ["cchudant@student.42.fr", "", -1, 3, "marvin", 58176, "cchudant", "https://cdn.intra.42.fr/users/large_norminet.jpg", "cchudant", "https://cdn.intra.42.fr/users/norminet.jpg" ],
]

user_list.each do |email, password, id_guild, id_stats, provider, uid, name, picture_url, nickname, image|
  User.create(email: email, password: password, id_guild: id_guild, id_stats: id_stats, provider: provider, uid: uid, name: name, picture_url: picture_url, nickname: nickname, image: image)
end