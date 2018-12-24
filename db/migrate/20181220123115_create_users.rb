class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :login, null: false, index: { unique: true }
    end
    # change_column :users, :login, null: false, index: { unique: true }
  end
end
