class Client::StepsController < Client::BaseController
  def edit; end
  
  def update
    if current_client.update_attributes(client_params) && params[:commit]
      if params[:commit] == 'Next Step'
        redirect_to profile_steps.next_step.url
      elsif params[:commit] == 'Come back later'
        redirect_to :client_profile
      elsif params[:commit] == 'Complete Profile'
        redirect_to :client_next_steps
      else
        redirect_to step_url(params[:commit])
      end
    else
      render :edit
    end
  end
  
  def profile_steps
    @profile_steps ||= ProfileSteps.new(current_client, step)
  end
  helper_method :profile_steps
  
  private
  
  def step_url(step)
    profile_steps.find_step(step).url
  end
  
end
