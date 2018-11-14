class Form < ApplicationRecord
  has_many :parameters, dependent: :destroy
  accepts_nested_attributes_for :parameters, allow_destroy: true
end
