# Application-wide job behaviors
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Add JobID tags for semantic logger
  # for context see https://github.com/rails/rails/blob/v7.0.8.1/activejob/lib/active_job/logging.rb#L17-L19
  def perform_now
    SemanticLogger.tagged(job_id: job_id) { super }
  end
end
