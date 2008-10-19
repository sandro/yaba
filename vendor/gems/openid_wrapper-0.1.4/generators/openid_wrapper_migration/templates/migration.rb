class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :openid_identifier, :null => false

      # all fields of openid simple registration
      t.string :dob, :language, :nickname, :timezone, :country
      t.string :fullname, :gender, :email
      t.integer :postcode

      t.timestamps
    end
    
    create_table :openid_associations, :force => true do |t|
      t.binary :server_url, :secret
      t.string :handle, :assoc_type
      t.integer :issued, :lifetime
    end

    create_table :openid_nonces, :force => true do |t|
      t.string :server_url, :null => false
      t.integer :timestamp, :null => false
      t.string :salt, :null => false
    end
  end

  def self.down
    drop_table :users
    drop_table :openid_associations
    drop_table :openid_nonces
  end
end
