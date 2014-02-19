module Admin::EnrollmentHelper
  
  # link to status change
  def link_to_status(title, enrollment, status)
    return content_tag(:b, title) if enrollment.status == status
    link_to_function title, 'new UpdateStatus(this,%i,%i)' % [enrollment.id, status]
  end
  
  # yes or no for bool
  def yesno(bool)
    bool ? '<center><img src="/images/bullet.png" alt="Yes"/></center>' : '&nbsp;'
  end
  
end
