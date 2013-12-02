class Itinerary < ActiveRecord::Base

  # Callbacks
  after_initialize :set_defaults

  # Associations
  belongs_to :trip_part
  belongs_to :mode
  belongs_to :service

  # You should usually *always* used the valid scope
  scope :valid, where('mode_id is not null and server_status=200')
  scope :invalid, where('mode_id is null or server_status!=200')
  scope :visible, where('hidden=false')
  scope :hidden, where('hidden=true')
  scope :good_score, where('match_score < 3')

  attr_accessible :duration, :cost, :end_time, :legs, :server_message, :mode, :start_time, :server_status, 
    :service, :transfers, :transit_time, :wait_time, :walk_distance, :walk_time, :icon_dictionary, :hidden,
    :ride_count, :external_info, :match_score, :missing_information, :missing_information_text, :date_mismatch,
    :time_mismatch, :too_late, :accommodation_mismatch, :missing_accommodations, :selected
    
  # returns true if this itinerary failed to work
  def failed
    mode.nil?
  end

  # returns true if this itinerary can be mapped
  def is_mappable
    return mode.name.downcase == 'transit' ? true : false
  end

  # This one is selected if no other valid ones in the trip_part are visible.
  # See also TripPart#selected?
  def selected?
    trip_part.selected?
  end
  
  # returns true if this itinerary is a walk-only trip. These are a special case of Transit
  # trips that only include a WALK leg
  def is_walk
    legs = get_legs
    return legs.size == 1 && legs.first.mode == TripLeg::WALK
  end
  
  # parses the legs and returns an array of TripLeg. If there are no legs then an
  # empty array is returned
  def get_legs
    return legs.nil? ? [] : ItineraryParser.parse(YAML.load(legs))
  end
  
  def unhide
    self.hidden = false
    self.save()
  end

  def hide
    self.hidden = true
    self.save()
  end

  def select
    Itinerary.update_all("selected = #{false}", "trip_part_id = #{self.trip_part_id}")
    self.selected = true
    self.save()
  end

  def unselect
    self.selected = false
    self.save()
  end

  def hide_others
    trip_part.itineraries.valid.each do |i|
      next if i==self
      i.hidden = true
      i.save
    end
  end


protected

  # Set resonable defaults for a new itinerary
  def set_defaults
    self.hidden ||= false
  end


end
