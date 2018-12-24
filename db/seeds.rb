users_count = 100
ip_addresses_count = 50
posts_count = 200000
ratings_count = 200000
rating_range = (1..5)
use_controllers_code = false

slice_size = 16000

tables = %w(users posts ratings statistics ip_addresses)
sql_query = "TRUNCATE #{tables.join(',')} RESTART IDENTITY"
ActiveRecord::Base.connection.execute sql_query

user_names = []
cycle = 0
until user_names.count > users_count || cycle > 5*users_count
   cycle += 1
   user_names << Faker::Internet.username.gsub('.','')
   user_names.uniq!
end
cycle = 0
ip_addresses = []
until ip_addresses.count > ip_addresses_count || cycle > 5*ip_addresses_count
   cycle += 1
   ip_addresses << Faker::Internet.ip_v4_address
   ip_addresses.uniq!
end

unless use_controllers_code
   ap "Загружается #{users_count} авторов #{Time.now}"
   user_names.each_slice(slice_size) do |group|
      values_to_insert = group.map do |user_name|
         "(#{ActiveRecord::Base.connection.quote user_name})"
      end.join(',')
      sql_string =
          "INSERT INTO users (login) VALUES #{values_to_insert}"
      ActiveRecord::Base.connection.execute sql_string
   end
   ap "Авторы загружены в #{Time.now}"

   user_ids = User.all.map{|user| [user.login, user.id]}.to_h
end

if use_controllers_code
   ap "Создаётся #{posts_count} постов на #{ip_addresses_count} ip-адресах #{Time.now} от #{users_count} авторов"
   posts_count.times do
      params = ActionController::Parameters.new({
          header: Faker::Book.title,
          content: Faker::Lorem.paragraph(2),
          author_ip: ip_addresses.sample,
          user_name: user_names.sample
      })
      asd = Post.create_record(params)
   end
   ap "Авторы загружены, посты созданы, ip-адреса учтены #{Time.now}"
else
   ap "Создаётся #{posts_count} постов на #{ip_addresses_count} ip-адресах #{Time.now}"
   posts_count.times.to_a.each_slice(slice_size) do |post_group|
      values_to_insert = []
      post_group.each do
         author = user_names.sample
         params = [
             Faker::Book.title,
             Faker::Lorem.paragraph(2),
             ip_addresses.sample,
             user_ids[author]
         ].map{|param| ActiveRecord::Base.connection.quote param}.join(',')
         values_to_insert << "(#{params})"
      end
      sql_string =
         "INSERT INTO posts (header, content, author_ip, user_id) VALUES #{values_to_insert.join(',')}"
      ActiveRecord::Base.connection.execute sql_string
   end
   ap "Посты созданы, ip-адреса учтены #{Time.now}"
end

first_id = Post.first.id
last_id = Post.last.id

ap "Загружается #{ratings_count} оценок #{Time.now}"
if use_controllers_code
   ratings_count.times do
      params = {
          value: Populator.value_in_range(rating_range),
          post_id: Populator.value_in_range(first_id..last_id)
      }
      Rating.rate_post(params)
   end
else
   ratings_count.times.to_a.each_slice(slice_size) do |rating_group|
      values_to_insert = []
      rating_group.each do
         params = [
             Populator.value_in_range(rating_range),
             Populator.value_in_range(first_id..last_id)
         ].map{|param| ActiveRecord::Base.connection.quote param}.join(',')
         values_to_insert << "(#{params})"
      end

      sql_string = "INSERT INTO ratings (value, post_id) VALUES #{values_to_insert.join(',')}"
      ActiveRecord::Base.connection.execute sql_string

   end
end
ap "Оценки загружены, средний рейтинг постов посчитан #{Time.now}"

