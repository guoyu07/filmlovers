module Api
  module V1
    class FilmsController < BaseController

      def show
        @film = Film.fetch params[:id]
      end

      def coming_soon
        find_films Films.coming_soon
      end

      def in_cinemas
        find_films Films.in_cinemas
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
        @total_pages = (@films_count / AdminConfig.instance.page_size) + 1
        render :index, formats: :json
      end

    end
  end
end
