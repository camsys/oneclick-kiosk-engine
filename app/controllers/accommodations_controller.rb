class AccommodationsController < TravelerAwareController

  def update

    # set the @traveler variable
    get_traveler

    @user_accommodations_proxy = UserAccommodationsProxy.new(User.find(params[:user_id]))
    @user_accommodations_proxy.update_maps(params[:user_accommodations_proxy])

    @path = new_user_registration_path(inline: 1)

    #If we are editing eligbility inline, and we are signed in, do not go to the new_user_registrations_page.
    # Create the itineraries
    if params['inline'] == '1' and user_signed_in?
      @planned_trip = PlannedTrip.find(session[:current_trip_id])
      session[:current_trip_id] =  nil
      @planned_trip.create_itineraries
      @path = user_planned_trip_path(@traveler, @planned_trip)
    end

      # Check to see if it was an ajax request from the user profile page
    if request.xhr?    
      flash[:notice] = t(:profile_updated)
    end

    respond_to do |format|
      format.html { redirect_to @path }
      format.js { render "accommodations/update_form" }
    end

  end

  def new

    @user_accommodations_proxy = UserAccommodationsProxy.new(@traveler)

    get_traveler
    @planned_trip_id = session[:current_trip_id]

    respond_to do |format|
      format.html
    end
  end


end
