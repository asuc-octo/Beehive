class DashboardController < ApplicationController
  include CASControllerIncludes
  before_filter :rm_login_required

  def index
      Analytics.page(user_id: @current_user.id,
                      name: 'Dashboard',
                      properties: { email: @current_user.email, name: @current_user.name })
  end
end
