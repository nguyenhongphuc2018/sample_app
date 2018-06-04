module ApplicationHelper
  def full_title page_title = ""
    base_title = t(:ruby_rails_sample)
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
