Rails.application.routes.draw do
   get 'post/create_post', to: 'post#create_post', as: 'create_post'
   get 'post/rate_post', to: 'post#rate_post', as: 'rate_post'
   get 'post/posts_by_rating', to: 'post#get_posts_by_avg_rating', as: 'posts_by_rating'
   get 'post/ip_and_authors', to: 'post#get_ip_addresses_used_by_many_authors', as: 'ip_and_authors'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
