class Staff::AssignmentsController < Staff::ApplicationController

  def new
    cohort = Cohort.find(params[:cohort_id]).decorate
    assignment = Assignment.new(cohort: cohort)
    render locals: {
      assignment: assignment,
      cohort: cohort
    }
  end

  def show
    assignment = Assignment.find(params[:id])
    render locals: {
      assignment: assignment.decorate,
      submitted: assignment.submissions,
      unsubmitted: assignment.unsubmitted_by
    }
  end

  def index
    cohort = Cohort.find(params[:cohort_id])
    render locals: {
      cohort: cohort.decorate,
      assignments: cohort.assignments
    }
  end

  def edit
    render locals: {
      assignment: Assignment.find(params[:id]),
      cohort: Cohort.find(params[:cohort_id]).decorate
    }
  end

  def destroy
    assignment = Assignment.find(params[:id])
    if assignment.destroy
      redirect_to staff_cohort_assignments_path(assignment.cohort), notice: "Assignment deleted"
    else
      render :edit, alert: "Could not delete assignment"
    end
  end

  def create
    cohort = Cohort.find(params[:cohort_id])
    assignment = Assignment.new(assignment_params cohort)
    assignment.cohort   = cohort
    if assignment.save
      redirect_to staff_cohort_assignment_path(cohort, assignment), notice: 'Assignment successfully created'
    else
      render :new, alert: 'Assignment could not be saved', status: 422, locals: { cohort: cohort.decorate, assignment: assignment }
    end
  end

  def update
    assignment = Assignment.find(params[:id])
    if assignment.update(assignment_params(assignment.cohort))
      redirect_to staff_cohort_assignment_path(assignment.cohort, assignment), notice: 'Assignment updated'
    else
      render :edit, alert: 'Assignment could not be updated', status: 422, locals: { cohort: assignment.cohort.decorate, assignment: assignment }
    end
  end

  private

  def assignment_params cohort
    params[:assignment][:due_date] = ActiveSupport::TimeZone[cohort.tz].parse(params[:assignment][:due_date]) if params[:assignment][:due_date]
    params[:assignment][:start_at] = ActiveSupport::TimeZone[cohort.tz].parse(params[:assignment][:start_at]) if params[:assignment][:start_at]
    params.require(:assignment).permit(:title, :due_date, :start_at, :info, tag_ids: [])
  end
end
