class ContactController < ApplicationController
  def create
    email = UserMailer.send_feedback_mail(params[:email], request)
    email.deliver
    #render :nothing => true
  end
end