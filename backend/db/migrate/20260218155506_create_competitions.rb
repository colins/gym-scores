class CreateCompetitions < ActiveRecord::Migration[8.0]
  def change
    create_table :competitions do |t|
      t.string :name
      t.date :date
      t.string :location
      t.string :external_id
      t.string :source_url

      t.timestamps
    end
    add_index :competitions, :external_id
  end
end
