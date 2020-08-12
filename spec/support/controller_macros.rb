module ControllerMacros
  def log_in user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user ||= FactoryBot.create(:user)
    user.confirm
    user.add_role :admin
    sign_in user
  end
end
