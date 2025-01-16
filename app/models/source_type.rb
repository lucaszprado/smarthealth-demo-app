class SourceType < ApplicationRecord
  has_many :sources, dependent: :nullify
end
