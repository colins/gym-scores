class CreateScores < ActiveRecord::Migration[8.0]
  def change
    create_table :scores do |t|
      t.references :gymnast, null: false, foreign_key: true
      t.references :competition, null: false, foreign_key: true
      t.integer :level
      t.string :session
      t.string :division
      t.decimal :vault
      t.integer :vault_rank
      t.decimal :bars
      t.integer :bars_rank
      t.decimal :beam
      t.integer :beam_rank
      t.decimal :floor
      t.integer :floor_rank
      t.decimal :all_around
      t.integer :all_around_rank

      t.timestamps
    end
  end
end
