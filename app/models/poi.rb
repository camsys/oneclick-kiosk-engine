class Poi < ActiveRecord::Base
  
  # Associations
  belongs_to :poi_type

  after_validation :reverse_geocode
  
  # Updatable attributes
  attr_accessible :name, :address1, :address2, :city, :state, :zip, :lat, :lon

  # set the default scope
  default_scope order('name')

  def to_s
    name
  end
  
  reverse_geocoded_by :lat, :lon do |obj,results|
    if geo = results.first
      obj.address1 = geo.street_address
      obj.city    = geo.city
      obj.zip     = geo.postal_code
      obj.state   = geo.state_code
    end
  end
end