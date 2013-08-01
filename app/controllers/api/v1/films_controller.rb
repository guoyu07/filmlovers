module Api
  module V1
    class FilmsController < BaseController

      def show
        @film = Film.fetch params[:id]
      end

      def coming_soon
        find_films FilmCollection.coming_soon.films
      end

      def in_cinemas
        find_films FilmCollection.in_cinemas.films
      end

      def categories

      end

      def search
        find_films Films.search(params[:query])
      end

      def popular
        find_films Film
      end

      protected

      def find_films(query, sort_by=:popularity, direction=:desc)
        @films = page_results query, sort_by, direction
        @films_count = @films.count
        @total_pages = (@films_count / page_size) + 1
        render :index, formats: :json
      end

    end
  end
end