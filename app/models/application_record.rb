class ApplicationRecord < ActiveRecord::Base
  self.default_timezone = :local
  self.abstract_class = true
end
