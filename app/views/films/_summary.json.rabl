object @film_view

attributes :id, :title, :release_date

node(:position) {|film| @position ? @position : 1}
node(:url) {|film| film_path(film.film)}
node(:thumbnail) {|film| film.thumbnail(@thumbnail_size)}

node :stats do |film|
  {
    :watched => film.stats(:watched),
    :loved => film.stats(:loved),
    :owned => film.stats(:owned)
  }
end

if current_user
  node(:actions) do |film|
    [:watched, :loved, :owned, :queued].map do |action|
      {
        name: action,
        url: update_user_film_path(current_user, action, film),
        isActioned: film.actioned?(action),
        count: 0
      }
    end
  end
end

