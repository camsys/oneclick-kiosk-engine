class EligibilityHelpers

  def get_eligible_services_for_traveler(user_profile, trip=nil)

    all_services = Service.all
    fully_eligible_services = []
    all_services.each do |service|
      is_eligible = true
      service_characteristic_maps = service.service_traveler_characteristics_maps
      service_characteristic_maps.each do |service_characteristic_map|
        service_requirement = service_characteristic_map.traveler_characteristic
        if service_requirement.code = 'age'
          if trip
            age_date = trip.trip_datetime
          else
            age_date = Time.now
          end

          update_age(user_profile, age_date)
        end

        passenger_characteristic = UserTravelerCharacteristicsMap.where(user_profile_id: user_profile.id, characteristic_id: service_requirement.id)
        if passenger_characteristic.count == 0 #This passenger characteristic is not listed #TODO: Currently we reject ont his but perhaps we should ask for more info
          is_eligible = false
          break
        end
        if !test_condition(passenger_characteristic.first.value, service_characteristic_map.value_relationship_id , service_characteristic_map.value)
          is_eligible = false
          break
        end
      end
      if is_eligible
        fully_eligible_services << service
      end
    end

    fully_eligible_services

  end

  def update_age(user_profile, date = Time.now)

    dob = TravelerCharacteristic.find_by_code('date_of_birth')
    age = TravelerCharacteristic.find_by_code('age')
    passenger_dob = UserTravelerCharacteristicsMap.where(user_profile_id: user_profile.id, characteristic_id: dob.id)
    if passenger_dob.count != 0 && passenger_dob.first.value != 'na'
      passenger_dob = passenger_dob.first.value.to_date
    else
      return
    end
    passenger_age_characteristic = UserTravelerCharacteristicsMap.find_or_initialize_by_user_profile_id_and_characteristic_id(user_profile.id, age.id)

    new_age = date.year - passenger_dob.year
    new_age -= 1 if date < passenger_dob + new_age.years
    passenger_age_characteristic.value = new_age
    passenger_age_characteristic.save()

  end


  def get_accommodating_services_for_traveler(user_profile)

    if user_profile.nil?   #TODO: Fix this to handle anonymous users.
      return []
    end

    #user accommodations
    accommodations_maps = user_profile.user_traveler_accommodations_maps.where('value = ? ', 'true')
    user_accommodations = []
    accommodations_maps.each do |map|
      user_accommodations << map.traveler_accommodation
    end

    #service accommodations
    accommodating_services = []
    all_services = Service.all
    all_services.each do |service|
      accommodations_maps = service.service_traveler_accommodations_maps
      service_accommodations  = []
      accommodations_maps.each do |map|
        service_accommodations << map.traveler_accommodation
      end

      if user_accommodations.count == (service_accommodations & user_accommodations).count
        accommodating_services << service
      end
    end

    accommodating_services

  end

  def get_accommodating_and_eligible_services_for_traveler(user_profile, trip=nil)

    if user_profile.nil? #TODO:  Need to update to handle anonymous users.  This currently only works with user logged in.
      return []
    end

    Rails.logger.debug "Get eligible services"
    eligible = get_eligible_services_for_traveler(user_profile, trip)
    Rails.logger.debug "Done get eligible services, get accommodating"
    accommodating = get_accommodating_services_for_traveler(user_profile)
    Rails.logger.debug "Done get accommodating"
    Rails.logger.debug eligible.ai
    Rails.logger.debug accommodating.ai
    eligible & accommodating

  end

  def get_eligible_services_for_trip(planned_trip, services)
    eligible_by_location = eligible_by_location(planned_trip, services)
    eligible_by_service_time = eligible_by_service_time(planned_trip, services)
    eligible_by_advanced_notice = eligible_by_advanced_notice(planned_trip, services)
    eligible_by_trip_purpose = eligible_by_trip_purpose(planned_trip, services)

    if Rails.logger.debug?
      {location: eligible_by_location, service_time: eligible_by_service_time,
        advanced_notice: eligible_by_advanced_notice, purpose: eligible_by_trip_purpose}.each do |k, v|
          Rails.logger.debug  "#{k} - #{v.map(&:name)}"
        end
    end

    eligible_by_location & eligible_by_service_time & eligible_by_advanced_notice & eligible_by_trip_purpose

  end

  def eligible_by_location(planned_trip, services)

    eligible_services  = []
    services.each do |service|
      #Match Residence
      #TODO:  Need to add home Place for each traveler

      #Match Origin
      coverages = service.service_coverage_maps.where(rule: 'origin').map {|c| c.geo_coverage.value.delete(' ').downcase}
      county_name = planned_trip.trip.origin.county_name || ""
      unless (coverages.count == 0) or (planned_trip.trip.origin.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
        next
      end

      #Match Destination
      county_name = planned_trip.trip.destination.county_name || ""
      coverages = service.service_coverage_maps.where(rule: 'destination').map {|c| c.geo_coverage.value.delete(' ').downcase}
      unless (coverages.count == 0) or (planned_trip.trip.destination.zipcode.in? coverages) or (county_name.delete(' ').downcase.in? coverages)
        next
      end

      eligible_services << service
    end
    eligible_services
  end

  def eligible_by_trip_purpose(planned_trip, services)
    eligible_services = []
    services.each do |service|
      maps = service.service_trip_purpose_maps
      purposes = []
      maps.each do |map|
        purposes << map.trip_purpose
      end
      if purposes.include? planned_trip.trip.trip_purpose
        eligible_services << service
      end
    end

    eligible_services

  end

  def eligible_by_service_time(planned_trip, services)
    #TODO: This does not handle services with 24 hour operations well.
    wday = planned_trip.trip_datetime.wday
    eligible_services  = []
    services.each do |service|
      schedules = Schedule.where(day_of_week: wday, service_id: service.id)
      schedules.each do |schedule|
        # puts "%-30s %-30s %s" % [Time.zone, planned_trip.trip_datetime, planned_trip.trip_datetime.seconds_since_midnight]
        # puts "%-30s %-30s %s" % [Time.zone, schedule.start_time, schedule.start_time.seconds_since_midnight]
        # puts "%-30s %-30s %s" % [Time.zone, schedule.end_time, schedule.end_time.seconds_since_midnight]
        if planned_trip.trip_datetime.seconds_since_midnight.between?(schedule.start_time.seconds_since_midnight,schedule.end_time.seconds_since_midnight)
          # puts "eligible"
          eligible_services << service
          break
        else
          # puts "--- NOT ELIGIBLE ---"
        end
      end
    end

    eligible_services

  end

  def eligible_by_advanced_notice(planned_trip, services)
    advanced_notice = (planned_trip.trip_datetime - planned_trip.created_at)/60
    within_notice_period = Service.where('advanced_notice_minutes < ?', advanced_notice)

    services & within_notice_period

  end

  def test_condition(value1, operator, value2)
    case operator
      when 1 # general equals
        return value1 == value2
      when 2 # float equals
        return value1.to_f == value2.to_f
      when 3 # greater than
        return value1.to_f > value2.to_f
      when 4 # greather than or equal
        return value1.to_f >= value2.to_f
      when 5 # less than
        return value1.to_f < value2.to_f
      when 6 # less than or equal
        return value1.to_f <= value2.to_f
      else
        return false
      end
    end

  end