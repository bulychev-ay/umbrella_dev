class Post < ApplicationRecord
   belongs_to :user
   has_many :ratings

   #Creates record in table posts and returns its params and status code.
   #
   # @param params [ActionController::Parameters] - params for creating record.
   #                             Structure:
   #     :user_name  [String] - login of author in table users.
   #     :header     [String] - header of the post.
   #     :content    [String] - content of the post.
   #     :author_ip  [String] - ip_address. example: '1.1.1.1'.
   #
   # @return [Hash] - result data. Structure:
   #     :post_params [Hash]   - params of created record.
   #     :error       [String] - message in case of error.
   #     :status      [Fixnum] - status code of request.
   #
   def self.create_record(params)
      post_params = params
      user_name = post_params[:user_name]
      return_params = Hash.new
      status = 200
      begin
         user = User.where(login: user_name).first_or_create
         post_params[:user_id] = user.id
         created_object = Post.create post_params.permit(Post.column_names)
         return_params[:post_params] = created_object
      rescue => error
         status = 422
         return_params[:error] = error.message
      end
      return_params[:status] = status
      return_params
   end
   
   #Return N posts with given average rating.
   #
   # @param avg_rating  [Fixnum] - average rating of requested posts.
   # @param posts_count [Fixnum] - number of requested posts.
   #
   # @return [Hash] - result data. Structure:
   #     :posts [Array<Hash>]   - data of posts. Structure of hash:
   #        :header  [String] - header of post.
   #        :content [String] - content of post.
   #     :error [String] - message in case of error.
   #
   def self.get_posts_by_avg_rating(avg_rating, posts_count)
      rating = ActiveRecord::Base.connection.quote avg_rating
      posts_count = ActiveRecord::Base.connection.quote posts_count
      sql_string = "SELECT post_id FROM statistics WHERE rating_avg = #{rating} LIMIT #{posts_count}"
      return_params = Hash.new
      begin
         result = ActiveRecord::Base.connection.execute sql_string
         post_ids = result.map{|post| post.values.first}
         if post_ids.present?
            second_sql_string = "SELECT header, content FROM posts WHERE id IN (#{post_ids.join(',')})"
            posts = ActiveRecord::Base.connection.execute second_sql_string
         else
            posts = []
         end
         return_params[:posts] = posts
      rescue => error
         return_params[:error] = error.message
      end
      return_params
   end

   #Return ip_addresses which was used by at least N authors.
   #
   # @param users_count [Fixnum] - least number of authors which user ip address.
   #
   # @return [Hash] - result data. Structure:
   #     :result - founded data. Structure:
   #        :ip_address [String] - ip_address. example: '1.1.1.1'.
   #        :users      [String] - list of user_ids.
   #     :error      [String] - message in case of error.
   #
   def self.get_ip_addresses_used_by_many_authors(users_count)
      users_count = ActiveRecord::Base.connection.quote users_count.to_i
      sql_string =
          "SELECT ip_address, users FROM ip_addresses WHERE count_noticed_authors > #{users_count}"
      return_params = Hash.new
      begin
         result = ActiveRecord::Base.connection.execute sql_string
         return_params[:result] = result
      rescue => error
         return_params[:error] = error.message
      end
      return_params
   end

end