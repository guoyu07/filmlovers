module Tmdb
  class Movie < MovieProvider
    include Mongoid::Document
    include Mongoid::Timestamps

    def self.find_or_fetch(id)  
      find(id) || fetch(id)
    end

    def self.fetch(id)  
      movie = with(safe:false).new(Client.movie(id))
      movie.upsert unless movie.not_allowed?
      movie
    end

    def self.fetch!(id)
      fetch(id).set_film_provider!
    end

    def self.adult
      where('adult' => true)
    end
    
    def imdb_id
      @imdb_id ||= self['imdb_id']
    end

    def imdb_id?
      self['imdb_id']
    end

    def title
      self['title'] || self['original_title']
    end

    def year
      initial_release_date.year if initial_release_date
    end

    def link
      "http://www.themoviedb.org/movie/#{id}"
    end

    def rating
      self['vote_average']
    end

    def popularity
      self['popularity']
    end

    def poster
      self['poster_path']
    end

    def backdrop
      self['backdrop_path']
    end

    def initial_release_date
      return unless self['release_date']
      self['release_date'].to_date
    end

    def release_date
      if uk_release = release_date_for('GB') 
        uk_release['release_date'].to_date
      else
        initial_release_date
      end
    end

    def presenter
      @presenter ||= TmdbPresenter.new self, Tmdb::Movie
    end

    def directors_name
      presenter.director.name if presenter.director?
    end

    def releases
      self['releases'] || {}
    end

    def genres
      (self['genres'] || {}).map{|g| g['name']}
    end

    def release_date_for(country)
      return if releases['countries'].blank?
      releases['countries'].find {|r| r['iso_3166_1']==country}
    end

    def release_date_country
      release_date_country = release_date_for('GB') ? 'UK' : nil
    end

    def classification
      release_date_for('GB') ? release_date_for('GB')['certification'] : nil
    end

    def has_trailer?(source=:youtube)
      trailers and !trailers[source.to_s].blank?
    end

    def trailers
      self[:trailers]
    end

    def trailer(source=:youtube)
      trailers[source.to_s][0]['source'] if has_trailer?(source)
    end

    def not_allowed?
      !release_date || self['adult'] || !title_id
    end

    protected

    def method_missing(m, *args, &block) 
      self[m] 
    end
  end
end