require 'rails_helper'


RSpec.describe Post, type: :model do
   context 'validation tests' do
      let(:user) {User.create(login: 'some_login')}
      it 'ensures header presence' do
         expect {Post.create(content:'some content', author_ip: '0.0.0.0', user_id: user.id)}.to raise_exception(ActiveRecord::NotNullViolation)
      end
      it 'ensures content presence' do
         expect {Post.create(header:'Header', author_ip: '0.0.0.0', user_id: user.id)}.to raise_exception(ActiveRecord::NotNullViolation)
      end
      it 'ensures author_ip presence' do
         expect {Post.create(header:'Header', content:'some content', user_id: user.id)}.to raise_exception(ActiveRecord::NotNullViolation)
      end
      it 'ensures user_id presence' do
         expect {Post.create(header:'Header', content:'some content', user_id: user.id)}.to raise_exception(ActiveRecord::NotNullViolation)
         #post = Post.create(header:'Header', content:'some content', author_ip: '0.0.0.0')
         #expect(post).to eq(false)
      end
      it 'ensures of cascade deleting of linked ratings' do
         post = Post.create(header: 'some_header',
                            content: 'some_content',
                            author_ip: '0.0.0.0',
                            user_id: user.id)
         rating = Rating.create(value: 5, post_id: post.id)
         post.delete
         expect {rating.reload.present?}.to raise_exception(ActiveRecord::RecordNotFound)
      end
   end
end