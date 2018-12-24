require 'rails_helper'

RSpec.describe User, type: :model do
   context 'validation tests' do
      it 'ensures login presence' do
         expect {User.create(login: nil)}.to raise_exception(ActiveRecord::NotNullViolation)
      end

      it 'ensures abscence of duplicate login of users' do
         User.create login: 'some_login'
         expect {User.create login: 'some_login'}.to raise_exception(ActiveRecord::RecordNotUnique)
      end

      it 'ensures of cascade deleting of linked posts' do
         user = User.create(login: 'some_login')
         post = Post.create(header: 'some_header',
                            content: 'some_content',
                            author_ip: '0.0.0.0',
                            user_id: user.id)
         user.delete
         expect {post.reload.present?}.to raise_exception(ActiveRecord::RecordNotFound)
      end

   end
end
