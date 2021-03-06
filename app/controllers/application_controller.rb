class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale, :check_user_activated

  rescue_from CanCan::AccessDenied do |_exception|
    respond_to do |format|
      format.html do
        check_logged_in_user
        redirect_to(request.referer || root_url, alert: t("global.no_permission"))
      end
      format.js{render nothing: true, status: :not_found}
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: User::PERMIT_ATTRIBUTES)
  end

  def format_params_date
    queries = params[:q] || {}
    if queries[:created_at_cont].present?
      date = queries[:created_at_cont].to_date
      queries[:created_at_gteq] = date.beginning_of_day.strftime Settings.global.strftime_format
      queries[:created_at_lteq] = date.end_of_day.strftime Settings.global.strftime_format
    end

    @query_params = queries.reject{|k, _v| k == "created_at_cont"}
  end

  def new_session_path _scope
    login_path
  end

  private

  def default_url_options
    {locale: I18n.locale}.merge(super)
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def extract_locale
    parsed_locale = params[:locale]
    parsed_locale if I18n.available_locales.map(&:to_s).include? parsed_locale
  end

  def check_logged_in_user
    return if user_signed_in?

    store_location
    flash[:error] = t "global.please_login"
    redirect_to login_url
  end

  def check_user_activated
    return if !user_signed_in? || user_activated?

    flash[:error] = t "users.sessions.blocked_account"
    sign_out current_user
  end

  def find_user
    @user = User.friendly.find_by slug: params[:id]
    return if @user

    flash[:error] = t "users.not_found"
    redirect_to request.referer || not_found_url
  end

  def find_campaign
    id = params[:campaign_id] || params[:id]
    @campaign = Campaign.friendly.find_by slug: id
    return if @campaign

    flash[:error] = t "campaigns.not_found"
    redirect_to request.referer || not_found_url
  end
end
