class HomeController < TravelerAwareController

  def index
    @actions = []
    if user_signed_in?
      @actions += [
        {label: t(:plan_a_trip), target: new_user_trip_path(@traveler), icon: ACTION_ICONS[:plan_a_trip]},
        {label: t(:travel_profile), target: edit_user_registration_path, icon: ACTION_ICONS[:travel_profile]},
        {label: t(:my_trips), target: user_planned_trips_path(@traveler), icon: ACTION_ICONS[:my_trips]},
      ]
    else
      @actions += [
        {label: t(:plan_a_trip), target: new_user_trip_path(current_or_guest_user), icon: ACTION_ICONS[:plan_a_trip]},
        {label: t(:log_in), target: new_user_session_path, icon: ACTION_ICONS[:log_in]},
        {label: t(:create_an_account), target: new_user_registration_path, icon: ACTION_ICONS[:create_an_account]}
      ]
    end
# {label: t(:identify_places), target: error_501_path, icon: ACTION_ICONS[:identify_places]},
# {label: t(:change_my_settings), target: error_501_path, icon: ACTION_ICONS[:change_my_settings]},
# {label: t(:help_and_support), target: error_501_path, icon: ACTION_ICONS[:help_and_support]},

    render 'shared/home'
  end

end
