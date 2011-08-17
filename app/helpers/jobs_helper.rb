module JobsHelper
  def activation_url(job)
    puts "\n\n\nACTIVATION COOOOOODE" + job.activation_code.to_s + "\n\n\n\n"
    "***REMOVED***{ROOT_URL}***REMOVED***{activate_job_path(job)}?a=***REMOVED***{job.activation_code}"
  end
end
