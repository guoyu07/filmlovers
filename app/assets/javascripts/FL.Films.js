FL = {}
FL.Films = {}

FL.Films = {
  initialised: false,

  init: function(){
    
    if(FL.Films.initialised) return

    FL.Films.initListeners()
    FL.Films.endlessScroll()
    FL.Films.initialised = true
  },

  initListeners: function(){
    $(document).on('ajax:success', 'a', FL.Films.displayContent)
    $(document).on('click', 'button.film-action', FL.Films.btnFilmActionClicked)
    $(document).on('click', 'i[data-action]', FL.Films.iconFilmActionClicked)
    $(document).on('click', '#signin-link, a.display-modal', FL.Films.displayModal)
    $(document).on('click', '.user-list .counter a', FL.Films.lnkFilmsActionClicked)
    $(document).on('click', '#filmsIndex .counter a', FL.Films.lnkUsersFilmsClicked)
    $(document).on('change', '#sort-option', FL.Films.sortUserFilms )
    $(document).on('change', '#userListsOptions', FL.Films.addFilmTolist )
  },

  displayContent: function(xhr, data, status){
    $('#container').html(data)
  },

  displayModal: function(e){
    e.preventDefault()
    $.get($(this).attr('href'), function(data, status){
      ModalController.queue_modal(data)
    })
  },
  
  endlessScroll: function(){
    var self = this
    var loading = false
    var threshold = 600

    $(window).scroll(function()
    {
      var currentPos = $(window).scrollTop() + threshold 
      var totalHeight = $(document).height() - $(window).height()
      if(currentPos >= totalHeight && !loading)
      {
        next = $('#filmsLinkNext').attr('href')
        if(!next) return false
          
        loading = true
        $.ajax({
          url: next,
          success: function(html){
            loading = false
            
            if(!html)
              return $('div#loadmoreajaxloader').html('<center>No more posts to show.</center>');
        
            $('#filmsLinkNext').remove()
            $("#filmsContent").append($(html).find('.film'))
            $("#filmsContent").append($(html).find('#filmsLinkNext'))
          } 
        })
      }
    })
  },

  sortUserFilms: function(){
    var url = $(this).attr('value')
    $('#contentHolder').load(url + ' #filmsContent')
  },

  navigateToOption: function(){
    window.location = $(this).attr('value')
  },

  addFilmTolist: function(){
    var url = $(this).attr('value')
    $.ajax({
      url: url,
      type: 'put',
      success: function(html){
        $('#modal-alerts').append(html)
        window.setTimeout(function(){
          $('.alert-box').fadeOut(function(){$(this).remove()})
        }, 3500)

        // if($('#queueListModal').length>0)
        //   $('#queueListModal .close-reveal-modal').click()
      } 
    })
  },

  btnFilmActionClicked: function(event){
    var button = $(this)
    
    var href = button.data('href')
    var method = button.data('method')
    var to_action = method == 'put'
    var incr = to_action ? 1 : -1
    var action = button.attr('name')
    $.ajax({
      url: href,
      type: method,
      dataType: 'json',
      success: function(xhr, data, status){
        button.data('method', (to_action ? 'delete' : 'put'))
        button.find('i').toggleClass('actioned unactioned')  
        // if(action=='watched')
        //   button.parents('.film').toggleClass('watched')
      }  
    })
  },

  iconFilmActionClicked: function(event){
    var icon = $(this)
    
    var href = icon.data('href')
    var method = icon.data('method')
    var id = icon.data('id')

    var to_action = method == 'put'
    var incr = to_action ? 1 : -1
    var action = icon.data('action')
    $.ajax({
      url: href,
      type: method,
      dataType: 'json',
      success: function(xhr, data, status){
        icon.data('method', (to_action ? 'delete' : 'put'))
        var film_counters = $("[data-id='" + id + "'][data-action='" + action + "']")
        film_counters.toggleClass('actioned unactioned') 

        if(!to_action)
          $(document).trigger('film:' + action + ':unactioned', [icon.parents('.film')])

        if(action=='queued')
          return
        // counter = icon.prev('label')
        counter = $("label[for='" + id + "'][data-counter='" + action + "']")
        counter.text(parseInt(counter.text()) + incr)
      }  
    })
  },

  lnkFilmsActionClicked: function(event){
    event.preventDefault()
    var url = $(this).attr('href')
    $('#contentHolder').load(url + ' .user-list')
  },

  lnkUsersFilmsClicked: function(event){
    event.preventDefault()
    var url = $(this).attr('href')
    $('#contentHolder').load(url + ' #filmsIndex')
  }
}