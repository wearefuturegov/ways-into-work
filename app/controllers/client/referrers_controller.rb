class Client::ReferrersController < ApplicationController
  expose :referrer
  expose :client, -> { referrer.build_client(login: UserLogin.new) }
  
  def new; end
  
  def create
    if referrer.client.assign_area(referrer_params[:client_attributes][:postcode]) == false
      redirect_to(:outside_hackney) && return
    elsif referrer.save
      referrer.client.send_emails
      redirect_to just_registered_path
    else
      render :new
    end
  end
  
  private
  
  def referrer_params # rubocop:disable Metrics/MethodLength
    params.require(:referrer).permit(
      :name,
      :organisation,
      :phone,
      :email,
      :reason,
      client_attributes: [
        :title,
        :first_name,
        :last_name,
        :phone,
        :preferred_contact_method,
        :address_line_1,
        :address_line_2,
        :postcode,
        login_attributes: [:email]
      ]
    )
  end
  
end