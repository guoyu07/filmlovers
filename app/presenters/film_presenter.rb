class FilmPresenter < BasePresenter
  extend Forwardable

  presents :film


  def_delegators :film, :title, :has_poster?, :id, :has_backdrop?, :has_trailer?, :overview, :score

  def title_with_year
    "#{film.title} " << year
  end

  def year
    return "" unless film.year
    "(#{film.year})"
  end

  def year_and_director
    if !director.blank?
      ("#{film.year} - Directed by " << link_to(film.director, person_path(director.id))).html_safe
    else
      film.year
    end
  end

  def alternative_titles
    film.alternative_titles.map {|t| t['title']}
  end
  
  def user_actions
    @user_actions ||= current_user.film_user_actions.where(film: film).distinct(:action)
  end

  def film_action_counter(action)
    action_css = user_actioned?(action) ? 'actioned' : 'unactioned'
    css = "#{icons[action]} #{action_css}"
    content_tag :i, nil,:class => css, data: {action: action, id: film.id}
  end

  def action_count(action)
    film.actions_for(action).count
  end

  def cast
    film.credits.cast.map do |person|

    end
  end

  def action_list_item(action, text, is_counter = false)
    actioned = user_actioned? action
    action_css = actioned ? 'complete' : nil 
    url = current_user ? update_user_film_path(current_user, action, film) : '#'
    method =  actioned ? :delete : :put
    css = "#{action} #{action_css}"  
    content_tag :li, :class => css  do
      if is_counter
        link_to text, url, data: {'method-type'=> method, action: action,  id: film.id, counter: "#{film.id}_#{action}" }
      else
        link_to text, url, data: {'method-type'=> method, action: action,  id: film.id }
      end
    end
  end

  def action_icon(action)
 
    return content_tag(:i,nil,  :class => icons[action]) unless current_user

    url = update_user_film_path(current_user, action, film)
   
    actioned = user_actioned? action
    method =  actioned ? :delete : :put
    action_css = actioned ? 'actioned' : 'unactioned' 
    css = "#{icons[action]} #{action_css}"  
    content_tag :i, nil, :class => css, data: {href: url, method: method, action: action, remote: true, id: film.id } 
  end

  def icons
    FilmPresenter.icons
  end

  def user_actioned?(action)
    current_user ? user_actions.include?(action) : false
  end

  def runtime
    "#{film.runtime} Mins" if film.runtime and film.runtime > 0
  end

  def similar_films
    film.similar.map do |film|
      {
        url: film_path(film),
        title: film.title
      }
    end
  end

  def status
    film.status if film.status != 'Released'
  end

  def languages
    film.spoken_languages.map {|l| l['name']}
  end

  def release_date
    film.uk_release_date.to_date.strftime('%d %B %Y') if film.release_date
  end

  def budget
    return unless film.budget and film.budget > 0
    Utilities.to_currency film.budget ,{precision: 0}
  end

  def original_title
    film.original_title if film.original_title != film.title
  end

  def rating
    film.uk_certification
  end

  def youtube_trailers
    return unless film.has_trailer?
    film.trailers['youtube'].map {|t| t['source'] }.select {|s| !s.start_with? 'http'} 
  end

 def youttube_url_for(trailer)
    "http://www.youtube.com/embed/#{trailer}?iv_load_policy=3&modestbranding=1&origin=localhost&rel=0&showinfo=0&controls=1"
  end

  def iframe_for(trailer)
    content_tag :iframe, nil, src: youttube_url_for(trailer), frameborder: 0, allowfullscreen: true
  end

  def genres
    film.genres.map {|g| Genre.find_by_id(g['id'])}
  end

  def other_links
    return unless film.imdb_id || !film.providers.empty?

    other = ''
    if film.imdb_id
      other = content_tag :a,  href: "http://www.imdb.com/title/#{film.imdb_id}",  alt:"IMDB link for #{film.title}", target: '_blank' do 
        image_tag 'imdb_logo.png'
      end
    end

    if netflix = film.provider_for(:netflix)
      other << content_tag(:a,  href: netflix.link,  alt:"Netflix link for #{film.title}", target: '_blank') do 
         image_tag('netflix-n-logo.png') << "#{netflix.rating}<font style='font-size:60%'>/5</font>".html_safe
      end
    end

    if rotten = film.provider_for(:rotten)
      other << content_tag(:a,  href: rotten.link,  alt:"RottenTomatoes link for #{film.title}", target: '_blank') do 
         image_tag('rotten.png') << "#{rotten.rating}".html_safe
      end
    end

    other 
  end


  def poster(size='w185')
    src = film.has_poster? ? film.poster(size) : "placeholder.jpg"
    image_tag src, :title=>film.title, alt: "poster for #{film.title}"
  end

  def poster_link(size='w185')
    link_to film_path(film), title: film.title do
      poster size
    end
  end

  def main_backdrop(size = 'w1280')
     backdrop(film.backdrops[0]) if film.has_backdrop? 
  end

  def backdrop(backdrop, size = 'w1280')
    return unless backdrop
    image_tag AppConfig.image_uri_for([size, backdrop['file_path']]), title: film.title, alt: "backdrop for #{film.title}"
  end

  def starring
    return unless film.credits and film.credits.cast
    @starring = film.credits.cast.take(3).map do |person|
      link_to person.name, person_path(person.id) 
    end
    @starring.join(', ').html_safe
  end

  def character
    film['character'] if film
  end

  def department
    film['department']
  end

  def job
    film['job']
  end

  def counter(action)
    film.counters[action]
  end

  def director
    @director ||= film.crew_member 'Director'
  end

end