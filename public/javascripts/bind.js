var Bind = {}

Bind.bind_tree = {}
Bind.current_state = null;

Bind.init = function (observed_elem, state_str) {
  var elem = observed_elem ? $(observed_elem) : window;
  Bind.state_str = state_str;
  Element.observe(elem, 'keypress', Bind.get_keys);
}

Bind.parse = function (str, f, state) {
  var arr = str.split(' '), cur = Bind.bind_tree;
  arr = arr.map(function (e) { return e.split('-') });

  arr.map(String.toLowerCase).each(function(e, i) {
    if (i != arr.length-1)
     {
      cur[e] = cur[e] ? cur[e] : {};
      cur = cur[e];
     }
    else
     {
      var o;
      if (state)
       {
        o = {};
        o[state] = f;
        o['type'] = 'state';
       }
      else 
       o = f;

      cur[e] = o;
     }
  });
}

Bind.bind = function (arr, f, state) {
  if (typeof(arr) == 'string')
  {
    Bind.parse(arr, f, state);
  }
  else
  {
   arr = arr.map(String.toLowerCase);
   var o;
   if (state)
    {
     o = {};
     o[state] = f;
     o['type'] = 'state';
    }
   else 
    o = f;
   Bind.bind_tree[arr.sort()] = o;
  }
}

Bind.get = function (arr) {
  if (typeof(arr) == 'string')
    arr = [arr];
  arr = arr.map(String.toLowerCase);

  var c = Bind.current_state ? Bind.current_state : Bind.bind_tree;
  var tmp = c[arr.sort()];
  if (tmp) 
  {
   if (typeof(tmp) == 'function')
    {
     $(document.body).setStyle({cursor:'default'});
     Bind.current_state = null;
     return tmp;
    }
   else if (tmp.type == 'state') {
     $(document.body).setStyle({cursor:'default'});
     Bind.current_state = null;
     var f = tmp[eval(Bind.state_str)] || tmp['default'];
     return f;
    }
   else
    {
     Bind.current_state = tmp;
     $(document.body).setStyle({cursor:'crosshair'});
    }
  }
  else
   {
    $(document.body).setStyle({cursor:'default'});
    Bind.current_state = null;
   }
}

Bind.get_keys = function (event) {
  function isAlt (e) { return e.altKey }
  function isCtrl (e) { return e.ctrlKey }
  function isShift (e) { return e.shiftKey }
  function get_char (key) { 
    switch(key)
     {
      case Event.KEY_TAB:
        return 'Tab';
      case Event.KEY_RIGHT:
        return 'Right';
      case Event.KEY_LEFT:
        return 'Left';
      case Event.KEY_DOWN:
        return 'Down';
      case Event.KEY_UP:
        return 'Up';
      case Event.KEY_DELETE:
        return 'Del';
      case Event.KEY_BACKSPACE:
        return 'Backspace';
      case Event.KEY_RETURN:
        return 'Return';
      case Event.KEY_ESC:
        return 'Esc';
      case 32:
        return 'Space';
      default:
        return String.fromCharCode(key);
     }
  }

  var key = event.which || event.keyCode;

  var arr = Array();
  if (isAlt(event)) arr.push('Alt');
  if (isCtrl(event)) arr.push('Ctrl');
  if (isShift(event)) arr.push('Shift');
  arr.push(get_char(key));
  Bind.exec(arr, event);
}

Bind.exec = function (arr, event) {
  var f = Bind.get('default');
  if (f) f(event);

  var f = Bind.get(arr);

  if (f)
   {
    if(!f(event)) event.stop();
   }
  else
   {
    if (parent && parent.Bind)
     {
      parent.Bind.exec(arr, event);
     }
   }
}
