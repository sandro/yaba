class AddOpenIdAuthenticationTables < ActiveRecord::Migration
  def self.up
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

    create_table :open_id_authentication_associations, :force => true do |t|
      t.integer :issued, :lifetime
      t.string :handle, :assoc_type
      t.binary :server_url, :secret
    end

    create_table :open_id_authentication_nonces, :force => true do |t|
      t.integer :timestamp, :null => false
      t.string :server_url, :null => true
      t.string :salt, :null => false
    end
  end

  def self.down
    drop_table :openid_associations
    drop_table :openid_nonces

    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
  end
end
