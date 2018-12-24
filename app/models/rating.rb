class Rating < ApplicationRecord
   belongs_to :post
   validates :value, :inclusion => { :in => 1..5 }

   #Rate post. Creates a record in table ratings and gets new average rating
   #  of the post.
   #
   # @param params [Hash/ActionController::Parameters] - params for creating
   #                                                    rating record. Structure:
   #     :post_id [Fixnum]       - evaluated post id.
   #     :value   [Fixnum/Float] - new rating of post in range 0..10.
   #
   # @return [Hash] - return data. Structure:
   #     :avg_rating [Float]  - new average rating of the post.
   #     :error      [String] - message in case of error.
   #
   def self.rate_post(params)
      post_id = ActiveRecord::Base.connection.quote params[:post_id]
      value = ActiveRecord::Base.connection.quote params[:value].to_f
      return_params = Hash.new
      begin
         sql_string = "INSERT INTO ratings (value, post_id) VALUES (#{value}, #{post_id}); SELECT rating_avg FROM statistics WHERE post_id = #{post_id}"
         result = ActiveRecord::Base.connection.execute sql_string
         return_params[:avg_rating] = result.to_a.first.values.first
      rescue => error
         return_params[:error] = error.message
      end
      return_params
   end

end