class CreateGymnasts < ActiveRecord::Migration[8.0]
  def change
    create_table :gymnasts do |t|
      t.string :name
      t.string :external_id
      t.string :team
      t.string :source_url

      t.timestamps
    end
    add_index :gymnasts, :external_id
  end
end
