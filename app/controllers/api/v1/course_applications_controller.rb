class Api::V1::CourseApplicationsController < ApplicationController

    skip_before_action :verify_authenticity_token

    def create
      @course_application = CourseApplication.new(course_application_params)
      if @course_application.save
        render status: 200, json: @course_application.to_json
        CourseApplicationMailer.confirm_application(@course_application).deliver_later
        CourseApplicationMailer.notify_team_of_new_application(@course_application).deliver_later
      else
        render status: 500
      end
    end

    def course_application_params
      params.require(:course_application).permit(
        :first_name, 
        :last_name, 
        :phone_number, 
        :email, 
        :intake_id
      )
    end

end