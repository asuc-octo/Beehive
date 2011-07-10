module JobsHelper
  def activation_url(job)
    "***REMOVED***{ROOT_URL}***REMOVED***{activate_job_path(job)}?a=***REMOVED***{job.activation_code}"
  end
end
