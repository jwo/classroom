class Staff::ReportsController < Staff::ApplicationController
  before_action :set_cohort
  after_action :verify_authorized, :except => :index
  after_action :verify_policy_scoped, :only => :index

  def index
    @reports = policy_scope(Report).where(day_id: @cohort.days)
  end

  def new
    @report = Report.new
    authorize @report
  end

  def show
    @report = Report.find(params[:id]).decorate
    authorize @report
    respond_to do |format|
      format.html
      format.pdf { render pdf: "#{@report.student.name} Report", show_as_html: false}
    end
  end

  def create
    @report = Report.new(report_params)
    authorize @report
    @report.day = @cohort.current_day
    if @report.save
      redirect_to staff_cohort_report_path(@cohort, @report), notice: I18n.t('.created', resource: I18n.t('.report'))
    else
      render :new
    end
  end

  private
  def set_cohort
    @cohort = Cohort.find(params[:cohort_id])
  end

  def report_params
    params.require(:report).permit(:student_id, :participation, :participation_comments, :effort, :effort_comments, :skill, :skill_comments, :overall, :overall_comments, :status)
  end
end