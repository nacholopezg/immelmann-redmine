class RedmineSilencerController < ApplicationController

  before_action :set_user, only: [:index]

  def index
    set_silencer_global_on(!get_silencer_global_on)
    redirect_to :back and return
  end


  private

    def set_silencer_global_on(value)
      return nil unless @user.logged?
      @user.pref[:silencer_global_on] = value
      @user.pref.save
    end

    def get_silencer_global_on
      @user.pref[:silencer_global_on] == true ? true : false
    end

    def set_user
      @user = User.current
    end

end
