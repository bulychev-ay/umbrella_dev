require 'rails_helper'

RSpec.describe PostController, type: :controller do
   context 'tests method create_post' do
      it 'create post has a 422 status code if params empty' do
         get :create_post
         expect(response.status).to eq(422)
      end

      it 'create post has a 200 status code if params are correct' do
         get :create_post, :params => { header: 'some_header', content: 'some content', user_name: 'some_login', author_ip: '0.0.0.0' }
         expect(response.status).to eq(200)
      end

      it 'create post has details of created post if params are correct' do
         get :create_post, :params => { header: 'some_header', content: 'some content', user_name: 'some_login', author_ip: '0.0.0.0' }
         expect(response.body).to match(/.*"post_params":.*"user_id":.*/)
      end

      it 'create has error message if no params' do
         get :create_post
         expect(response.body).to match('"error":')
      end

   end

   context 'tests rate post method' do
      let(:user) {User.create(login: 'some_login')}
      let(:post) {Post.create(header:'Header', content:'some content', author_ip: '0.0.0.0', user_id: user.id)}

      it 'rate_post has error message if no params' do
         get :rate_post
         expect(response.body).to match('"error":')
      end

      it 'rate_post post has json type of response' do
         get :rate_post
         expect(response.content_type).to eq("application/json")
      end
   end

   context 'tests get_posts_by_avg_rating method' do
      it 'get_posts_by_avg_rating has empty array response if no params' do
         get :get_posts_by_avg_rating
         expect(response.body).to match('"posts":\[\]')
      end

      it 'get_posts_by_avg_rating post has json type of response' do
         get :get_posts_by_avg_rating
         expect(response.content_type).to eq("application/json")
      end
   end

   context 'tests get_ip_addresses_used_by_many_authors method' do
      it 'get_ip_addresses_used_by_many_authors return all ip_addresses if no params' do
         get :get_ip_addresses_used_by_many_authors
         ip_addresses = ActiveRecord::Base.connection.
             execute("SELECT count(*) FROM statistics").values.flatten.first.to_i
         expect(JSON.parse(response.body)['result'].count).to eq(ip_addresses)
      end

      it 'get_ip_addresses_used_by_many_authors post has json type of response' do
         get :get_ip_addresses_used_by_many_authors
         expect(response.content_type).to eq("application/json")
      end
   end

end
