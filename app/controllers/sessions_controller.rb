class SessionsController < ApplicationController
  layout "welcome"
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Za dużo nie udanych prób logowania. Poczekaj 3 minuty." }
  before_action -> { redirect_to root_url if authenticated? }, only: %i[new create]
  before_action -> { redirect_to root_url unless authenticated? }, only: %i[destroy]

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:name, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      flash[:name] = params[:name]
      redirect_to new_session_path, alert: "Nieprawidłowe dane logowania"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
