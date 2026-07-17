// Namespace creation
var liveLabs = {};

(function($, server, liveLabs) {
  var body$ = $('body'),
    KEYS = $.ui.keyCode;

  // Header Search (copied from Aria)
  liveLabs.buildTopSearch = function() {
    var searchMarkup = function(inputId) {
      var cl,
        curPage = $v('pFlowStepId');

      if (inputId === 'mobile_search') {
        cl = 'll-Search-responsive is-hidden';
      } else {
        cl = 'll-Header-search';
      }
      return '<div class="' + cl + '" id="' + inputId + '_wrap">' +
        '<label class="ll-Header-searchLabel" for="' + inputId + '"><span class="fa fa-search" aria-hidden="true"></span>' +
        '<span class="u-VisuallyHidden">Search</span></label>' +
        '<input type="search" placeholder="Search Workshops..." id="' + inputId + '" class="ll-Header-searchInput" /></div>';
    };

    $(searchMarkup('desktop_search')).insertAfter(".t-Header-logo");

    $('#desktop_search').val(apex.item('SEARCH').getValue());

    $(document).on('keydown', '#desktop_search, #mobile_search', function(e) {
      var kw = $(this).val();
      if (e.keyCode === KEYS.ENTER) {
        e.preventDefault();
        apex.navigation.redirect("f?p=" + $v("pFlowId") + ":51:" + $v("pInstance") + '::::SEARCH:' + kw);
      }
    });

    var toggleResponsiveSearch = function() {
      var mobileSearchWrap$ = $('#mobile_search_wrap'),
        searchButton$ = $('.header-search-item a');

      var hide = function() {
        mobileSearchWrap$
          .removeClass('is-visible')
          .addClass('is-hidden');
      };

      searchButton$.click(function() {
        if (!mobileSearchWrap$[0]) {
          mobileSearchWrap$ = $('form#wwvFlowForm')
            .append(searchMarkup('mobile_search'))
            .find('#mobile_search_wrap');
        }

        mobileSearchWrap$
          .removeClass('is-hidden')
          .addClass('is-visible');

        var input$ = $('#mobile_search');

        input$
          .focus()
          .on('keydown', function(e) {
            switch (e.which) {
              case KEYS.ESCAPE:
                hide();
                searchButton$.focus();
                break;

              case KEYS.TAB:
                input$.focus();
                e.preventDefault();
                break;

              case KEYS.ENTER:
                hide();
                break;

              default:
                return;
            }
          })
          .on('click', function(e) {
            e.stopPropagation();
          })
          .on('blur', function() {
            hide();
          });

        mobileSearchWrap$.click(function() {
          hide();
          searchButton$.focus();
        });

        mobileSearchWrap$.on("keydown", function(e) {
          switch (e.which) {
            case KEYS.TAB:
              input$.focus();
              break;
            default:
              return;
          }

        });
      });
    };

    toggleResponsiveSearch();
  };


  liveLabs.initQ = function() {
    liveLabs.buildTopSearch();
  };

})(apex.jQuery, apex.server, liveLabs);

$(document).on('apexreadyend', function() {
  liveLabs.initQ();
});
