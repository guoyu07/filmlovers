class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :facebook_authenticate
  skip_before_filter :facebook_authenticate, if: -> {params[:signed_request].nil?}

  # def facebook_authenticate
  #   return if params[:signed_request] ? facebook_authenticate : logged_in?
  #   redirect_to_auth
  # end

  protected

  def page_results(query, default_sort_order, page_size=AdminConfig.instance.page_size)
    sort_order = sort_orders[sort_by || default_sort_order]
    query.order_by(sort_order).page(page_no).per page_size
  end

  def page_no
    params[:page] ? params[:page].to_i : 1
  end

  def sort_by
    params[:sort_by]
  end

  def genre
    @genre ||= Genre.find_by_name params[:genres]
  end


  def sort_orders
    {
      'title'                 =>  [:title, :asc], 
      'release_date'          =>  [:release_date, :desc],
      'earliest_release_date' =>  [:release_date, :asc],
      'popularity'            =>  [:popularity, :desc],
      'watched'               =>  ['counters.watched', :desc], 
      'loved'                 =>  ['counters.loved', :desc],
      'owned'                 =>  ['counters.owned', :desc] 
    }
  end

  private


  def facebook_authenticate
    user = FacebookAuth.authenticate(params[:signed_request])
    !user.new_record? ? env['warden'].set_user(user) : redirect_to_auth
  end

  def redirect_to_auth
    render('facebook/oauth_redirect', layout:nil)
  end
  

  def logged_in?
    user_signed_in?
  end
  
  def user_service
    @user_service ||= UserService.new current_user
  end

  def current_url(new_params={})
    url_for params.merge(new_params)
  end

  def get_layout
    request.xhr? ? {layout:nil} : {}
  end

  def render_template(view=nil)
    if view
      render view, get_layout
    else
      render get_layout
    end
  end

  helper_method :current_user, :user_service, :username, :logged_in?, :current_url
end
