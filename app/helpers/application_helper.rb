module ApplicationHelper
  
  def breadcrumb_link_classes(index)
    return "breadcrumb-item active" if index == @breadcrumbs.size - 1

    "breadcrumb-item"
  end
end
