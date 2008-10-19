class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|

      t.column :first_name,                :string, :limit => 40
      t.column :last_name,                 :string, :limit => 40
      t.column :identity_url,              :string
      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :state,                     :string, :default => "pending"
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :reset_code,                :string, :limit => 40
    end

    add_index :users, :email, :unique => true
    add_index :users, :identity_url, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
