class FriendshipsController < ApplicationController
  def create
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    if @friendship.save
      redirect_to stored_path
    else
      raise "What the fuck"
    end
  end

  def destroy

    @friendship = current_user.friendships.find(params[:id])
    @friendship.destroy

    redirect_to stored_path
  end
end
