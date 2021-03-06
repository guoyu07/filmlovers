module ApplicationHelper

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end


  def passport_link(provider, description)
    content_tag :li do 
      link_to "/auth/#{provider}", alt: "sign in to filmlovers using #{description}" do
        image_tag("site-basics/#{description.downcase}-icon-colour.svg", size: "30x30", alt: description) << description
      end
    end
  end

  def shorten(text, truncate_at=180)
     truncate text, separator: ' ', length: truncate_at, :omission => '...'
  end


  def advert(name)
    render partial: "adverts/#{name}"
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:dd, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def alert_msg
    case params[:msg]
      when 'profile' then 'Profile details updated'
    end
  end

  def error_msg
    case params[:err]
      when 'profile' then 'Unable to update your profile details'
    end
  end
end
