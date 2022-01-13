module Admin::ProductAssignmentHelper

  def automatic_bundling_program_last_run_at_text
    last_run = AutomaticBundlingLastRun.last
    if last_run.present?
      "#{date_format_UK(last_run.created_at)} at #{get_time_from_date_time(last_run.created_at)}"
    else
      "Not ran yet"
    end
  end

  def automatic_bundling_program_next_run_at_text
    next_run = 1.month.from_now.beginning_of_month
    "#{date_format_UK(next_run)} at #{get_time_from_date_time(next_run)}"
  end

end