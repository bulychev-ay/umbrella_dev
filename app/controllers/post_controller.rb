class PostController < ApplicationController

   #Creates post and return its params or message in case of error.
   #
   # @param params [ActionController::Parameters] - Structure params:
   #     :header    [String] - header of post.
   #     :content   [String] - content of post.
   #     :author_ip [String] - current ip address of author.
   #     :user_name [String] - author login from table users.
   #
   # @return [JSON] - Answer structure:
   #     :post_params [Hash] - parameters of created record. Structure:
   #        :id         [Fixnum] - id of created post.
   #        :header     [String] - header of created.
   #        :content    [String] - content of created post.
   #        :ip_address [Hash]   - represent of inet type from postgresql.
   #        :user_id    [Fixnum] - id of author from table users.
   #     :error [String] - message in case of error.
   #
   def create_post
      post_params = params
      return_data = Post.create_record(post_params)
      render status: return_data[:status], json:
          return_data.reject{|key, v| key.eql? :status}
   end

   #Adds rating to the post.
   #
   # @param params [ActionController::Parameters] - Structure:
   #     :post_id [Fixnum]       - evaluated post id.
   #     :value   [Fixnum/Float] - new rating of post in range 0..10.
   #
   # @return [JSON] - Answer structure:
   #     :avg_rating [Float]  - new average rating of the post.
   #     :error      [String] - message in case of error.
   #
   def rate_post
      rate_params = params
      return_data = Rating.rate_post(rate_params)
      render json: return_data
   end

   #Returns posts with given average rating.
   #
   # @param params [ActionController::Parameters] - Structure:
   #     :avg_rating        [Fixnum] - average rating of requested posts.
   #     :param posts_count [Fixnum] - number of requested posts.
   #
   # @return [JSON] - Answer structure:
   #     :posts [Array<Hash>]   - data of posts. Structure of hash:
   #        :header  [String] - header of post.
   #        :content [String] - content of post.
   #
   def get_posts_by_avg_rating
      avg_rating = params[:rating]
      posts_count = params[:posts_count]
      return_data = Post.get_posts_by_avg_rating(avg_rating, posts_count)
      render json: return_data
   end

   #Returns ip_addresses which used by at least given number of authors.
   #
   # @param params [ActionController::Parameters] - Structure:
   #     :users_count [Fixnum] - least number of authors which user ip address.
   #
   # @return [JSON] - Answer structure:
   #     :result [Array<Hash>] - founded data. Structure:
   #        :ip_address [String] - ip_address. example: '1.1.1.1'.
   #        :users      [String] - list of user_ids.
   #     :error  [String]      - message in case of error.
   #
   def get_ip_addresses_used_by_many_authors
      at_least_users = params[:users_count]
      return_data = Post.get_ip_addresses_used_by_many_authors(at_least_users)
      render json: return_data
   end

end
