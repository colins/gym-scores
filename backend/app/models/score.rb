class Score < ApplicationRecord
  belongs_to :gymnast
  belongs_to :competition

  validates :gymnast_id, uniqueness: { scope: [:competition_id, :level, :division] }

  scope :by_date, -> { joins(:competition).order("competitions.date DESC") }
  scope :for_level, ->(level) { where(level: level) }

  def total_score
    all_around || [vault, bars, beam, floor].compact.sum
  end
end
