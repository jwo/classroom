class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @cohort = Cohort.find(params[:cohort_id]) if params[:cohort_id]
    super
  end

  def create
    super do |resource|
      if resource.valid?
        resource.student = Student.create!(cohort_id: params[:cohort_id]) if params[:cohort_id]
        resource.save
      end
    end
  end

  def update
    super
  end

  private

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
