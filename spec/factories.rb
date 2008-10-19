require 'factory_girl'

Factory.sequence(:user_email) {|n| "me+#{n}@dodgit.com"}
Factory.sequence(:user_identity_url) {|n| "http://me-#{n}.heythatsmylogin.com/"}

Factory.define :user do |u|
  u.email {Factory.next :user_email}
  u.first_name "Joe"
  u.last_name  "Bob"
  u.password   "abc123"
  u.password_confirmation "abc123"
end

Factory.define :user_with_identity_url, :class => User do |u|
  u.identity_url {Factory.next :user_identity_url}
  Factory.attributes_for(:user).each {|k,v| u.add_attribute(k,v) unless k == :email}
end

Factory.define :user_login_with_email, :class => UserLogin do |l|
  l.email {Factory.next :user_email}
  l.password "abc123"
end

Factory.define :user_login_with_openid, :class => UserLogin do |l|
  l.identity_url {Factory.next :user_identity_url}
end
