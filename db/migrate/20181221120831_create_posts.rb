class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :header, null: false
      t.text :content, null: false
      t.inet :author_ip, null: false
      t.references :user, null: false, index: true, foreign_key: {
          on_delete: :cascade,
          on_update: :cascade
      }
    end
  end
end
