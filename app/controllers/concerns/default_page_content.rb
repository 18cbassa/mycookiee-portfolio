module DefaultPageContent
    extend ActiveSupport::Concern
  
  included do
    before_filter :set_page_defaults
  end
  
  def set_page_defaults
    @page_title = "MyCookiee | My Portfolio Website"
    @seo_keywords = "Cece E portfolio"
  end
end
