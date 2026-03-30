class Competition < ApplicationRecord
  has_many :scores, dependent: :destroy
  has_many :gymnasts, through: :scores

  validates :name, presence: true
  validates :external_id, uniqueness: true, allow_nil: true

  scope :recent, -> { order(date: :desc) }
end
