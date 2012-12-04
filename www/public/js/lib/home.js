// Generated by CoffeeScript 1.4.0
(function() {
  var Home;

  $(document).ready(function() {
    return $('div').hide();
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
      var _this = this;
      $('#logo').fadeIn(1600);
      ($('#desc').delay(100)).fadeIn(800);
      (this._choices.delay(100)).fadeTo(0.01);
      this._choices.animate({
        opacity: 1,
        marginTop: '+=20'
      }, 600);
      this._stepOne.show();
      this.bindEvent();
      $('#newRoomBtn').click(function() {
        return _this.nextStep(stepOne, $('#newRoom'));
      });
      $('#newRoomCancel').click(function() {
        return _this.cancelStep(stepOne, $('#newRoom'));
      });
      $('#joinRoomBtn').click(function() {
        return _this.nextStep(stepOne, $('#joinRoom'));
      });
      $('#joinRoomCancel').click(function() {
        return _this.cancelStep(stepOne, $('#joinRoom'));
      });
      return this.signup();
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

    Home.prototype.disableButtonClick = function(element) {
      return $('#' + element.get(0).id + ' button').attr('disabled', true);
    };

    Home.prototype.enableButtonClick = function(element) {
      return $('#' + element.get(0).id + ' button').attr('disabled', false);
    };

    Home.prototype.nextStep = function(stepOne, stepTwo) {
      stepOne = $(stepOne);
      stepTwo = $(stepTwo);
      this.disableButtonClick(stepOne);
      this.enableButtonClick(stepTwo);
      $('#joinRoom,#newRoom').hide();
      stepOne.fadeTo(0.99);
      stepOne.animate({
        opacity: 0,
        left: '-=290'
      }, 600);
      stepTwo.fadeTo(0.01);
      return stepTwo.animate({
        opacity: 1,
        left: '-=290'
      }, 600);
    };

    Home.prototype.cancelStep = function(stepOne, stepTwo) {
      stepOne = $(stepOne);
      stepTwo = $(stepTwo);
      this.enableButtonClick(stepOne);
      this.disableButtonClick(stepTwo);
      stepOne.fadeTo(0.01);
      stepOne.animate({
        opacity: 1,
        left: '+=290'
      }, 600);
      stepTwo.fadeTo(0.99);
      stepTwo.animate({
        opacity: 0,
        left: '+=290'
      }, 600);
      $('#' + stepTwo.get(0).id + ' form input').attr('value', '');
      return $('#' + stepTwo.get(0).id + ' form input').blur();
    };

    Home.prototype.signup = function() {
      var _this = this;
      return $('#signup-btn').click(function() {
        var confirm, email, emailExp, evalEmail, evalPassword, msg, password, passwordExp;
        email = $('#signup_email').val();
        password = $('#signup_password').val();
        confirm = $('#signup_password_confirm').val();
        emailExp = new RegExp("^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$", "i");
        passwordExp = new RegExp("^(?=.*[a-z])(?!.*[^a-z0-9]).{5,}$", "gi");
        evalEmail = emailExp.test(email);
        evalPassword = passwordExp.test(password);
        msg = "";
        if (email === "" || password === "" || confirm === "") {
          $('#msg').html("Incomplete form");
          return;
        }
        if (evalEmail !== true) {
          msg += "Invalid email<br/>";
        }
        if (evalPassword !== true) {
          msg += "Password must be at least 5 characters<br/>";
        }
        if (password !== confirm) {
          msg += "Password does not match the confirm password";
        }
        $('#msg').html(msg);
        if (evalEmail && evalPassword && password === confirm) {
          $('#msg').html("Registration confirmed.");
          return $.ajax({
            type: "POST",
            url: "/user",
            data: {
              "mail": email,
              "password": password
            },
            dataType: "json"
          });
        }
      });
    };

    return Home;

  })();

  $(window).load(function() {
    var home;
    home = new Home;
    return home.init();
  });

}).call(this);
