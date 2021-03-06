module CsHelpers

    ACTION_ICONS = {
        :plan_a_trip => 'icon-share-sign',
        :log_in => 'icon-key',
        :create_an_account => 'icon-edit',
        :identify_places =>'icon-map-marker',
        :travel_profile => 'icon-cogs',
        :my_trips => 'icon-share-alt icon-flip-horizontal',
        :help_and_support => 'icon-question-sign',
        :find_traveler => 'icon-search',
        :create_traveler =>'icon-user',
        :agents_agencies => 'icon-umbrella',
        :reports => 'icon-bar-chart'
    }

  # TODO Unclear whether this will need to be more flexible depending on how clients want to do their domains
  # may have to vary by environment
  def brand
    Rails.application.config.brand
  end

  def assisting?
    session.include? :assisting
  end

  def assisted_user
    @assisted_user ||= User.find_by_id(session[:assisting])
  end

  def format_exception e
    [e.message, e.backtrace].flatten.join("\n")
  end
end
