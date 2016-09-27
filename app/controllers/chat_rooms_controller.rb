class ChatRoomsController < ApplicationController
  def index
    @user = User.all
  end
end