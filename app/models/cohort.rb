class Cohort < ActiveRecord::Base
  belongs_to :campus
  has_many :students, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :days, dependent: :destroy
  has_and_belongs_to_many :instructors
  validates :start_date, :name, :campus_id, presence: true

  def self.unarchived
    all.where(archived: false)
  end

  def self.search(current_user, query)
    if current_user.instructor?
      Cohort.unarchived.where("name ILIKE (?)", "%#{query}%")
    else
      []
    end
  end

  def tz
    campus.time_zone if campus
  end

  def days_by_month
    days.group_by{ |d| d.start.month }.each do |month|
      yield DayDecorator.decorate_collection(month[1])
    end
  end

  def current_day
    time = DateTime.now.in_time_zone(tz)
    days.find_by("start >= ? AND start < ?", time.beginning_of_day.utc, time.end_of_day.utc)
  end

  def first_day
    days.order(:start).first
  end

  def ungraded_submissions
    Submission.ungraded_for self
  end

  def due_assignments
    assignments.where("due_date <= ?", Time.now)
  end

  def start_date= val
    return unless val.to_datetime
    self.start_time = val.to_datetime.change(offset: tz_offset).beginning_of_day
  end

  def start_date
    self.start_time.in_time_zone(tz).to_date if self.start_time
  end

  def operators
    campus.operators
  end

  private

  def tz_offset
    return 0 unless tz
    ActiveSupport::TimeZone.new(tz).formatted_offset
  end
end
