module Tmdb
  CONFIG = YAML.load_file(Rails.root.join("config/tmdb.yml"))[Rails.env]
  extend self
  
  def key
    CONFIG['key']
  end

  def api
    "http://api.themoviedb.org/3/"
  end

end
