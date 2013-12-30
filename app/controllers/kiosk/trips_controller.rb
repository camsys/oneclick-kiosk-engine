module Kiosk
  class TripsController < ::TripsController

    layout 'kiosk'

    # def index
    # end

    # def show
    # end

    # def show_printer_friendly
    # end

    # def email
    # end

    # def email_provider
    # end

    # def email_itinerary
    # end

    # def email_feedback
    # end

    # def email_itinerary2_values
    # end

    # def email2
    # end

    # def details
    # end

    # def repeat
    # end

    # def edit
    # end

    # def unset_traveler
    # end

    # def set_traveler
    # end

    # def destroy
    # end

    # def new
    #   super
    # end

    def new

      @trip_proxy = TripProxy.new()
      @trip_proxy.traveler = @traveler

      # set the flag so we know what to do when the user submits the form
      @trip_proxy.mode = MODE_NEW

      # Set the travel time/date to the default
      travel_date = default_trip_time

      @trip_proxy.trip_date = travel_date.strftime(TRIP_DATE_FORMAT_STRING)
      @trip_proxy.trip_time = travel_date.strftime(TRIP_TIME_FORMAT_STRING)

      # Set the trip purpose to its default
      @trip_proxy.trip_purpose_id = TripPurpose.all.first.id

      # default to a round trip. The default return trip time is set the the default trip time plus
      # a configurable interval
      return_trip_time = travel_date + DEFAULT_RETURN_TRIP_DELAY_MINS.minutes
      @trip_proxy.is_round_trip = "1"
      @trip_proxy.return_trip_time = return_trip_time.strftime(TRIP_TIME_FORMAT_STRING)

      # Create markers for the map control
      @markers = create_trip_proxy_markers(@trip_proxy).to_json
      @places = create_place_markers(@traveler.places)

      respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip_proxy }
    end
  end

    # def update
    # end

    # def create
    # end

    # def skip
    # end

    # def itinerary
    # end

    # def hide
    # end

    # def unhide_all
    # end

    # def select
    # end

    # def comments
    # end

    # def admin_comments
    # end

  end
end
