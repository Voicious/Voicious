// Generated by CoffeeScript 1.4.0
(function() {
  var Home;

  $(document).ready(function() {
    $('div').hide();
    return $('input', 'textarea').placeholder();
  });

  Home = (function() {

    function Home() {
      var initToggleTable;
      this._stepOne = $('#stepOne');
      this._choices = $('#choices');
      initToggleTable = function(selector) {
        return {
          toggle: false,
          domObj: $(selector)
        };
      };
      this._lis = [initToggleTable('#quick'), initToggleTable('#signin'), initToggleTable('#signup')];
    }

    Home.prototype.init = function() {
      $('#logo').fadeIn(1600);
      ($('#desc').delay(100)).fadeIn(800);
      (this._choices.delay(100)).fadeTo(0.01);
      this._choices.animate({
        opacity: 1,
        marginTop: '+=20'
      }, 600);
      this._stepOne.show();
      return this.bindEvent();
    };

    Home.prototype.bindEvent = function() {
      var i, that, _i, _ref, _results;
      that = this;
      _results = [];
      for (i = _i = 0, _ref = this._lis.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push($('#choices ul li.choice:nth-child(' + (i + 1) + ')').click(function() {
          var index, key, li, _ref1;
          index = $(this).index();
          $('li.selected').removeClass('selected');
          if (that._lis[index]['toggle'] === false) {
            _ref1 = that._lis;
            for (key in _ref1) {
              li = _ref1[key];
              if (Number(key) === index) {
                li['toggle'] = true;
                li.domObj.fadeIn(600);
              } else {
                li['toggle'] = false;
                li.domObj.hide();
              }
            }
          } else {
            that._lis[index]['toggle'] = false;
            that._lis[index]['domObj'].fadeOut(200);
          }
          return $(this).toggleClass('selected', that._lis[index]['toggle']);
        }));
      }
      return _results;
    };

    return Home;

  })();

  /*
      disableButtonClick: (element) ->
          $('#' + element.get(0).id + ' button').attr 'disabled', 'disabled'

      enableButtonClick: (element) ->
          $('#' + element.get(0).id + ' button').attr 'disabled', ''

      nextStep: (stepOne, stepTwo) ->
          disableButtonClick stepOne
          enableButtonClick stepTwo
  */


  $(window).load(function() {
    var home;
    home = new Home;
    return home.init();
  });

}).call(this);
