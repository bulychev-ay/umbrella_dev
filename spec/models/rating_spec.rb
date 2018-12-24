require 'rails_helper'

RSpec.describe Rating, type: :model do
  context 'validation tests' do
     let(:user) {User.create(login: 'some_login')}
     let(:post) {Post.create(header:'Header', content:'some content', author_ip: '0.0.0.0', user_id: user.id)}

     it 'ensures post_id presents' do
        expect {Rating.create!(value: 5)}.to raise_exception(ActiveRecord::RecordInvalid)
     end
     it 'ensures post_id is not a string' do
        expect {Rating.create!(value: 1, post_id: 'string_id')}.to raise_exception(ActiveRecord::RecordInvalid)
     end
     it 'ensures post_id is existed id' do
        expect {Rating.create!(value: 3, post_id: post.id+1)}.to raise_exception(ActiveRecord::RecordInvalid)
     end
     it 'ensures that accept values less than 10.00' do
        expect {Rating.create!(value: 5.01, post_id: post.id)}.to raise_exception(ActiveRecord::RecordInvalid)
     end
     it 'ensures that accept values greater than 0.00' do
        expect {Rating.create!(value: 0.99, post_id: post.id)}.to raise_exception(ActiveRecord::RecordInvalid)
     end
     it 'ensures that default value 5.00 given automatically with creating' do
        rating = Rating.create(post_id: post.id)
        expect(rating.value).to eq(5.00)
     end
     it 'ensures of cascade deleting of linked posts and ratings from users' do
        rating = Rating.create(value: 5, post_id: post.id)
        user.delete
        expect {rating.reload.present?}.to raise_exception(ActiveRecord::RecordNotFound)
     end
  end
end
