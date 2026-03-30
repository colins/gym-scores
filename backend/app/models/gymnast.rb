class Gymnast < ApplicationRecord
  has_many :scores, dependent: :destroy
  has_many :competitions, through: :scores

  validates :name, presence: true
  validates :external_id, presence: true, uniqueness: true

  def personal_bests
    scores.group(:level).select(
      :level,
      "MAX(vault) as vault",
      "MAX(bars) as bars",
      "MAX(beam) as beam",
      "MAX(floor) as floor",
      "MAX(all_around) as all_around"
    )
  end
end
