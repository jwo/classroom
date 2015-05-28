class Submission < ActiveRecord::Base
  belongs_to :student
  belongs_to :assignment
  has_many :ratings

  PENDING = 1
  # wat ^ aren't these the same?
  IN_PROGRESS = 2
  # wat ^ aren't these the same?
  GRADED = 3

  def self.ungraded_for(cohort)
      Submission.includes(:assignment)
        .where(state: Submission::PENDING)
        .where(completed: false).where("assignments.cohort_id = ?", cohort.id)
        .references(:assignment)
        .order('assignments.due_date DESC')
  end

  def graded?
    state == GRADED
  end

  def to_s
    "#{(student.name || student.email)} - #{link[0..45]}"
  end
end
