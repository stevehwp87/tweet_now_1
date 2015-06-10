class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |u|
      u.string :username
      u.string :token
      u.string :secret
      u.timestamps
    end
  end
end
