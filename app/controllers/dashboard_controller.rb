class DashboardController < ApplicationController
  include CASControllerIncludes
  before_filter :rm_login_required

  def index
      Analytics.track(user_id: @current_user.id, event: "Dashboard Viewed")
  end
end
