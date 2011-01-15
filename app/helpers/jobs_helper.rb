module JobsHelper
  def activation_url(job)
    "***REMOVED***{$rm_root}jobs/activate/***REMOVED***{self.id}?a=***REMOVED***{job.activation_code}"
    ***REMOVED***"***REMOVED***{activate_job_url(job)}?a=***REMOVED***{job.activation_code}"
  end
end
