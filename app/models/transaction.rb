class Transaction < ApplicationRecord
  validates :uid, presence: true
  validates :tyc, presence: true
  validates :reason, presence: true
end
