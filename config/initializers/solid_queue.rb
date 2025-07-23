Rails.application.configure do
  config.solid_queue.connects_to = { database: { writing: :queue, reading: :queue } }
end

# Make sure Active Job uses Solid Queue
if Rails.env == "test"
  Rails.application.config.active_job.queue_adapter = :test
else
  Rails.application.config.active_job.queue_adapter = :solid_queue
end
