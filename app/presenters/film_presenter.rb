class FilmPresenter < BasePresenter
  extend Forwardable

  presents :film


  def_delegators :film, :title, :has_poster?, :id, :has_backdrop?, :has_trailer?, :overview, :score


  def self.icons
    @icons ||= {
      watched:  'icon-eye-open', 
      loved:    'icon-heart', 
      owned:    'icon-home', 
      queued:   'icon-pushpin',
      list:     'icon-list'
    }
  end


  def title_with_year
    "#{film.title} " << year
  end

  def year
    return "" unless film.year
    "(#{film.year})"
  end

  def actions_count
    @action ||= film.film_user_actions.group_by(&:action).map {|grouping, value| {action: grouping, count: value.length}}
  end

  def actions_count_for(action)
    actions_count.find {|ac| ac[:action]==action} || {}
  end

  def count_for(action)
    actions_count_for(action)[:count].to_i
  end

  def user_actions
    @user_actions ||= current_user.film_user_actions.where(film: film).distinct(:action)
  end

  def film_action_counter(action)
    action_css = user_actioned?(action) ? 'actioned' : 'unactioned'
    css = "#{icons[action]} #{action_css}"
    content_tag :i, nil,:class => css, data: {action: action, id: film.id}
  end


  def action_icon(action)
 
    return content_tag(:i,nil,  :class => icons[action]) unless current_user

    url = update_user_film_path(current_user, action, film.id)
   
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
    user_actions.include? action
  end



  # def self.from_films(user, film_ids)
  #   Film.find(film_ids).map {|film| FilmPresenter.new user, film } if !film_ids.empty?
  # end

  # def actioned?(action)
  #   return false unless user
  #   user.film_actioned? film, action
  # end

  # def stats(action)
  #   film.users[action].count
  # end

  # def thumbnail(size='w154')
  #   size = size ? size : 'w154'
  #   has_poster? ? film.poster(size ? size : thumbnail_size) : "http://placehold.it/#{size.slice(1..-1)}&text=#{film.title}"
  # end

  # def backdrop(size='original')
  #   film.backdrop(size)
  # end

  # def release_date
  #   film.release_date ? "#{Date.parse(film.release_date).year}" : ''
  # end

  # def director
  #   @director ||= film.credits.crew.find {|member| member['job']=='Director'}
  #   @director ? @director['name'] : ''
  # end

  # def year
  #   @year ||= (Date.parse(film.release_date).year if film.release_date)
  # end

  # def similar_films?
  #   film.similar_movies
  # end

  # def similar_films
  #   return unless similar_films?
  #   film.similar_movies['results'].compact.map {|f| FilmPresenter.new user, Film.new(f), 'w92'}
  # end
end