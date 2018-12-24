class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
      t.numeric :value, precision: 3, scale: 2, default: 2.50, null: false
      t.references :post, index: true, null: false, foreign_key: {on_delete: :cascade}
    end
  end
end
