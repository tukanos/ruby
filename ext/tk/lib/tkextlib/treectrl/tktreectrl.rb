#
#  tkextlib/treectrl/tktreectrl.rb
#                               by Hidetoshi NAGAI (nagai@ai.kyutech.ac.jp)
#

require 'tk'

# call setup script for general 'tkextlib' libraries
require 'tkextlib/setup.rb'

# call setup script
require 'tkextlib/treectrl/setup.rb'

# TkPackage.require('treectrl', '1.0')
# TkPackage.require('treectrl', '1.1')
TkPackage.require('treectrl')

module Tk
  class TreeCtrl < TkWindow
    def self.package_version
      begin
        TkPackage.require('treectrl')
      rescue
        ''
      end
    end

    # dummy :: 
    #  pkgIndex.tcl of TreeCtrl-1.0 doesn't support auto_load for 
    #  'loupe' command (probably it is bug, I think). 
    #  So, calling a 'treectrl' command for loading the dll with 
    #  the auto_load facility. 
    begin
      tk_call('treectrl')
    rescue
    end
    def self.loupe(img, x, y, w, h, zoom)
      # NOTE: platform == 'unix' only

      # img  => TkPhotoImage
      # x, y => screen coords 
      # w, h => magnifier width and height
      # zoom => zooming rate
      Tk.tk_call_without_enc('loupe', img, x, y, w, h, zoom)
    end

    def self.text_layout(font, text, keys={})
      TkComm.list(Tk.tk_call_without_enc('textlayout', font, text, keys))
    end

    def self.image_tint(img, color, alpha)
      Tk.tk_call_without_enc('imagetint', img, color, alpha)
    end

    class NotifyEvent < TkUtil::CallbackSubst
    end

    module ConfigMethod
    end
  end
  TreeCtrl_Widget = TreeCtrl
end

##############################################

class Tk::TreeCtrl::NotifyEvent
  # [ <'%' subst-key char>, <proc type char>, <instance var (accessor) name>]
  KEY_TBL = [
    [ ?c, ?n, :item_num ], 
    [ ?d, ?s, :detail ], 
    [ ?D, ?l, :items ], 
    [ ?e, ?e, :event ], 
    [ ?I, ?n, :id ], 
    [ ?l, ?n, :lower_bound ], 
    [ ?p, ?n, :active_id ], 
    [ ?S, ?l, :sel_items ], 
    [ ?T, ?w, :widget ], 
    [ ?u, ?n, :upper_bound ], 
    [ ?W, ?o, :object ], 
    nil
  ]

  # [ <proc type char>, <proc/method to convert tcl-str to ruby-obj>]
  PROC_TBL = [
    [ ?n, TkComm.method(:num_or_str) ], 
    [ ?s, TkComm.method(:string) ], 
    [ ?l, TkComm.method(:list) ], 
    [ ?w, TkComm.method(:window) ], 

    [ ?e, proc{|val|
        case val
        when /^<<[^<>]+>>$/
          TkVirtualEvent.getobj(val[1..-2])
        when /^<[^<>]+>$/
          val[1..-2]
        else
          val
        end
      }
    ], 

    [ ?o, proc{|val| tk_tcl2ruby(val)} ], 

    nil
  ]

  # setup tables to be used by scan_args, _get_subst_key, _get_all_subst_keys
  #
  #     _get_subst_key() and _get_all_subst_keys() generates key-string 
  #     which describe how to convert callback arguments to ruby objects. 
  #     When binding parameters are given, use _get_subst_key(). 
  #     But when no parameters are given, use _get_all_subst_keys() to 
  #     create a Event class object as a callback parameter. 
  #
  #     scan_args() is used when doing callback. It convert arguments 
  #     ( which are Tcl strings ) to ruby objects based on the key string 
  #     that is generated by _get_subst_key() or _get_all_subst_keys(). 
  #
  _setup_subst_table(KEY_TBL, PROC_TBL);
end

##############################################

module Tk::TreeCtrl::ConfigMethod
  include TkItemConfigMethod

  def treectrl_tagid(key, obj)
    if key.kind_of?(Array)
      key = key.join(' ')
    else
      key = key.to_s
    end

    case key
    when 'column'
      obj

    when 'debug'
      obj

    when 'dragimage'
      obj

    when 'element'
      obj

    when 'item element'
      obj

    when 'marquee'
      obj

    when 'notify'
      obj

    when 'style'
      obj

    else
      obj
    end
  end

  def tagid(mixed_id)
    if mixed_id.kind_of?(Array)
      [mixed_id[0], treectrl_tagid(*mixed_id)]
    else
      tagid(mixed_id.split(':'))
    end
    fail ArgumentError, "unknown id format"
  end

  def __item_cget_cmd(mixed_id)
    if mixed_id[1].kind_of?(Array)
      id = mixed_id[1]
    else
      id = [mixed_id[1]]
    end

    if mixed_id[0].kind_of?(Array)
      ([self.path].concat(mixed_id[0]) << 'cget').concat(id)
    else
      [self.path, mixed_id[0], 'cget'].concat(id)
    end
  end
  private :__item_cget_cmd

  def __item_config_cmd(mixed_id)
    if mixed_id[1].kind_of?(Array)
      id = mixed_id[1]
    else
      id = [mixed_id[1]]
    end

    if mixed_id[0].kind_of?(Array)
      ([self.path].concat(mixed_id[0]) << 'configure').concat(id)
    else
      [self.path, mixed_id[0], 'configure'].concat(id)
    end
  end
  private :__item_config_cmd

  def __item_pathname(id)
    if id.kind_of?(Array)
      key = id[0]
      if key.kind_of?(Array)
        key = key.join(' ')
      end

      tag = id[1]
      if tag.kind_of?(Array)
        tag = tag.join(' ')
      end

      id = [key, tag].join(':')
    end
    [self.path, id].join(';')
  end
  private :__item_pathname

  def __item_configinfo_struct(id)
    if id.kind_of?(Array) && id[0].to_s == 'notify'
      {:key=>0, :alias=>nil, :db_name=>nil, :db_class=>nil, 
        :default_value=>nil, :current_value=>1}
    else
      {:key=>0, :alias=>1, :db_name=>1, :db_class=>2, 
        :default_value=>3, :current_value=>4}
    end
  end
  private :__item_configinfo_struct

  def __item_numstrval_optkeys(id)
    if id == 'debug'
      ['displaydelay']
    else
      super(id)
    end
  end
  private :__item_numstrval_optkeys

  def __item_boolval_optkeys(id)
    if id == 'debug'
      ['data', 'display', 'enable']
    elsif id.kind_of?(Array)
      case id[0]
      when 'column'
        ['button', 'expand', 'squeeze', 'sunken', 'visible', 'widthhack']
      when 'element'
        ['filled', 'showfocus']
      else
        super(id)
      end
    else
      super(id)
    end
  end
  private :__item_boolval_optkeys

  def __item_strval_optkeys(id)
    if id == 'debug'
      ['erasecolor']
    else
      super(id)
    end
  end
  private :__item_strval_optkeys

  def __item_listval_optkeys(id)
    if id.kind_of?(Array)
      case id[0]
      when 'column'
        ['itembackground']
      when 'element'
        ['relief']
      else
        []
      end
    else
      []
    end
  end
  private :__item_listval_optkeys

  def __item_keyonly_optkeys(id)  # { def_key=>(undef_key|nil), ... }
    {
      'notreally'=>nil, 
      'increasing'=>'decreasing',
      'decreasing'=>'increasing', 
      'ascii'=>nil,
      'dictionary'=>nil, 
      'integer'=>nil, 
      'real'=>nil
    }
  end
  private :__item_keyonly_optkeys

  def column_cget(tagOrId, option)
    itemcget(['column', tagOrId], option)
  end
  def column_configure(tagOrId, slot, value=None)
    itemconfigure(['column', tagOrId], slot, value)
  end
  def column_configinfo(tagOrId, slot=nil)
    itemconfiginfo(['column', tagOrId], slot)
  end
  def current_column_configinfo(tagOrId, slot=nil)
    current_itemconfiginfo(['column', tagOrId], slot)
  end

  def debug_cget(option)
    itemcget('debug', option)
  end
  def debug_configure(slot, value=None)
    itemconfigure('debug', slot, value)
  end
  def debug_configinfo(slot=nil)
    itemconfiginfo('debug', slot)
  end
  def current_debug_configinfo(slot=nil)
    current_itemconfiginfo('debug', slot)
  end

  def dragimage_cget(tagOrId, option)
    itemcget(['dragimage', tagOrId], option)
  end
  def dragimage_configure(tagOrId, slot, value=None)
    itemconfigure(['dragimage', tagOrId], slot, value)
  end
  def dragimage_configinfo(tagOrId, slot=nil)
    itemconfiginfo(['dragimage', tagOrId], slot)
  end
  def current_dragimage_configinfo(tagOrId, slot=nil)
    current_itemconfiginfo(['dragimage', tagOrId], slot)
  end

  def element_cget(tagOrId, option)
    itemcget(['element', tagOrId], option)
  end
  def element_configure(tagOrId, slot, value=None)
    itemconfigure(['element', tagOrId], slot, value)
  end
  def element_configinfo(tagOrId, slot=nil)
    itemconfiginfo(['element', tagOrId], slot)
  end
  def current_element_configinfo(tagOrId, slot=nil)
    current_itemconfiginfo(['element', tagOrId], slot)
  end

  def item_element_cget(tagOrId, option)
    itemcget([['item', 'element'], tagOrId], option)
  end
  def item_element_configure(tagOrId, slot, value=None)
    itemconfigure([['item', 'element'], tagOrId], slot, value)
  end
  def item_element_configinfo(tagOrId, slot=nil)
    itemconfiginfo([['item', 'element'], tagOrId], slot)
  end
  def current_item_element_configinfo(tagOrId, slot=nil)
    current_itemconfiginfo([['item', 'element'], tagOrId], slot)
  end

  def marquee_cget(tagOrId, option)
    itemcget(['marquee', tagOrId], option)
  end
  def marquee_configure(tagOrId, slot, value=None)
    itemconfigure(['marquee', tagOrId], slot, value)
  end
  def marquee_configinfo(tagOrId, slot=nil)
    itemconfiginfo(['marquee', tagOrId], slot)
  end
  def current_marquee_configinfo(tagOrId, slot=nil)
    current_itemconfiginfo(['marquee', tagOrId], slot)
  end

  def notify_cget(win, pattern, option)
    itemconfigure(['notify', [win, pattern]], option)
  end
  def notify_configure(win, pattern, slot, value=None)
    itemconfigure(['notify', [win, pattern]], slot, value)
  end
  def notify_configinfo(win, pattern, slot=nil)
    itemconfiginfo(['notify', [win, pattern]], slot)
  end
  alias current_notify_configinfo notify_configinfo

  def style_cget(tagOrId, option)
    itemcget(['style', tagOrId], option)
  end
  def style_configure(tagOrId, slot, value=None)
    itemconfigure(['style', tagOrId], slot, value)
  end
  def style_configinfo(tagOrId, slot=nil)
    itemconfiginfo(['style', tagOrId], slot)
  end
  def current_style_configinfo(tagOrId, slot=nil)
    current_itemconfiginfo(['style', tagOrId], slot)
  end

  private :itemcget, :itemconfigure
  private :itemconfiginfo, :current_itemconfiginfo
end

##############################################

class Tk::TreeCtrl
  include Tk::TreeCtrl::ConfigMethod
  include Scrollable

  TkCommandNames = ['treectrl'.freeze].freeze
  WidgetClassName = ''.freeze
  WidgetClassNames[WidgetClassName] = self

  #########################

  def __boolval_optkeys
    [
      'showbuttons', 'showheader', 'showlines', 'showroot', 
      'showrootbutton', 
    ]
  end
  private :__boolval_optkeys

  def __listval_optkeys
    [ 'defaultstyle' ]
  end
  private :__listval_optkeys

  #########################

  def install_bind(cmd, *args)
    install_bind_for_event_class(Tk::TreeCtrl::NotifyEvent, cmd, *args)
  end

  #########################

  def create_self(keys)
    if keys and keys != None
      tk_call_without_enc('treectrl', @path, *hash_kv(keys, true))
    else
      tk_call_without_enc('treectrl', @path)
    end
  end
  private :create_self

  #########################

  def activate(desc)
    tk_send('activate', desc)
    self
  end

  def canvasx(x)
    number(tk_send('canvasx', x))
  end

  def canvasy(y)
    number(tk_send('canvasy', y))
  end

  def collapse(*dsc)
    tk_send('collapse', *dsc)
    self
  end

  def collapse_recurse(*dsc)
    tk_send('collapse', '-recurse', *dsc)
    self
  end

  def column_bbox(idx)
    list(tk_send('column', 'bbox', idx))
  end

  def column_create(keys=nil)
    if keys && keys.kind_of?(Hash)
      num_or_str(tk_send('column', 'create', *hash_kv(keys)))
    else
      num_or_str(tk_send('column', 'create'))
    end
  end

  def column_delete(idx)
    tk_send('column', 'delete', idx)
    self
  end

  def column_index(idx)
    num_or_str(tk_send('column', 'index', idx))
  end

  def column_move(idx, to)
    tk_send('column', 'move', idx, to)
    self
  end

  def column_needed_width(idx)
    num_or_str(tk_send('column', 'neededwidth', idx))
  end
  alias column_neededwidth column_needed_width

  def column_width(idx)
    num_or_str(tk_send('column', 'width', idx))
  end

  def compare(item1, op, item2)
    number(tk_send('compare', item1, op, item2))
  end

  def contentbox()
    list(tk_send('contentbox'))
  end

  def depth(item=None)
    num_or_str(tk_send('depth', item))
  end

  def dragimage_add(item, *args)
    tk_send('dragimage', 'add', item, *args)
    self
  end

  def dragimage_clear()
    tk_send('dragimage', 'clear')
    self
  end

  def dragimage_offset(*args) # x, y
    if args.empty?
      list(tk_send('dragimage', 'offset'))
    else
      tk_send('dragimage', 'offset', *args)
      self
    end
  end

  def dragimage_visible(*args) # mode
    if args..empty?
      bool(tk_send('dragimage', 'visible'))
    else
      tk_send('dragimage', 'visible', *args)
      self
    end
  end
  def dragimage_visible?
    dragimage_visible()
  end

  def debug_dinfo
    tk_send('debug', 'dinfo')
    self
  end

  def debug_scroll
    tk_send('debug', 'scroll')
  end

  def element_create(elem, type, keys=nil)
    if keys && keys.kind_of?(Hash)
      tk_send('element', 'create', elem, type, *hash_kv(keys))
    else
      tk_send('element', 'create', elem, type)
    end
  end

  def element_delete(*elems)
    tk_send('element', 'delete', *elems)
    self
  end

  def element_names()
    list(tk_send('element', 'names'))
  end

  def element_type(elem)
    tk_send('element', 'type', elem)
  end

  def expand(*dsc)
    tk_send('expand', *dsc)
    self
  end

  def expand_recurse(*dsc)
    tk_send('expand', '-recurse', *dsc)
    self
  end

  def identify(x, y)
    list(tk_send('identify', x, y))
  end

  def index(idx)
    num_or_str(tk_send('index', idx))
  end

  def item_ancestors(item)
    list(tk_send('item', 'ancestors', item))
  end

  def item_bbox(item, *args)
    list(tk_send('item', 'bbox', item, *args))
  end

  def item_children(item)
    list(tk_send('item', 'children', item))
  end

  def item_collapse(item)
    tk_send('item', 'collapse', item)
    self
  end

  def item_collapse_recurse(item)
    tk_send('item', 'collapse', item, '-recurse')
    self
  end

  def item_complex(item, *args)
    tk_send('item', 'complex', item, *args)
    self
  end

  def item_create(keys={})
    num_or_str(tk_send('item', 'create', keys))
  end

  def item_delete(first, last=None)
    tk_send('item', 'delete', first, last)
    self
  end

  def item_dump(item)
    list(tk_send('item', 'dump', item))
  end

  def item_element_actual(item, column, elem, key)
    tk_send('item', 'element', 'actual', item, column, elem, "-#{key}")
  end

  def item_expand(item)
    tk_send('item', 'expand', item)
    self
  end

  def item_expand_recurse(item)
    tk_send('item', 'expand', item, '-recurse')
    self
  end

  def item_firstchild(parent, child=nil)
    if child
      tk_send('item', 'firstchild', parent, child)
      self
    else
      num_or_str(tk_send('item', 'firstchild', parent))
    end
  end
  alias item_first_child item_firstchild

  def item_hashbutton(item, st=None)
    if st == None
      bool(tk_send('item', 'hashbutton'))
    else
      tk_send('item', 'hashbutton', st)
      self
    end
  end
  def item_hashbutton?(item)
    item_hashbutton(item)
  end

  def item_index(item)
    list(tk_send('item', 'index', item))
  end

  def item_isancestor(item, des)
    bool(tk_send('item', 'isancestor', item, des))
  end
  alias item_is_ancestor  item_isancestor
  alias item_isancestor?  item_isancestor
  alias item_is_ancestor? item_isancestor

  def item_isopen(item)
    bool(tk_send('item', 'isopen', item))
  end
  alias item_is_open    item_isopen
  alias item_isopen?    item_isopen
  alias item_is_open?   item_isopen
  alias item_isopened?  item_isopen
  alias item_is_opened? item_isopen

  def item_lastchild(parent, child=nil)
    if child
      tk_send('item', 'lastchild', parent, child)
      self
    else
      num_or_str(tk_send('item', 'lastchild', parent))
    end
  end
  alias item_last_child item_lastchild

  def item_nextsibling(sibling, nxt=nil)
    if nxt
      tk_send('item', 'nextsibling', sibling, nxt)
      self
    else
      num_or_str(tk_send('item', 'nextsibling', sibling))
    end
  end
  alias item_next_sibling item_nextsibling

  def item_numchildren()
    number(tk_send('item', 'numchildren'))
  end
  alias item_num_children  item_numchildren
  alias item_children_size item_numchildren

  def item_parent(item)
    num_or_str(tk_send('item', 'parent', item))
  end

  def item_prevsibling(sibling, prev=nil)
    if prev
      tk_send('item', 'prevsibling', sibling, prev)
      self
    else
      num_or_str(tk_send('item', 'prevsibling', sibling))
    end
  end
  alias item_prev_sibling item_prevsibling

  def item_remove(item)
    list(tk_send('item', 'remove', item))
  end

  def item_rnc(item)
    list(tk_send('item', 'rnc', item))
  end

  def item_sort(item, *opts)
    flag = false
    if opts[-1].kind_of?(Hash)
      opts[-1,1] = __conv_item_keyonly_opts(item, opts[-1]).to_a
    end

    opts = opts.collect{|opt|
      if opt.kind_of?(Array)
        key = "-#{opt[0]}"
        flag = true if key == '-notreally'
        ["-#{opt[0]}", opt[1]]
      else
        key = "-#{opt}"
        flag = true if key == '-notreally'
        key
      end
    }.flatten

    ret = tk_send('item', 'sort', item, *opts)
    if flag
      list(ret)
    else
      ret
    end
  end

  def item_state_forcolumn(item, column, *args)
    tk_send('item', 'state', 'forcolumn', item, column, *args)
    self
  end
  alias item_state_for_column item_state_forcolumn

  def item_state_get(item, *args)
    if args.empty?
      list(tk_send('item', 'state', 'get', item *args))
    else
      bool(tk_send('item', 'state', 'get', item))
    end
  end

  def item_state_set(item, *args)
    tk_send('item', 'state', 'set', item, *args)
    self
  end

  def item_style_elements(item, column)
    list(tk_send('item', 'style', 'elements', item, column))
  end

  def item_style_map(item, column, style, map)
    tk_send('item', 'style', 'map', item, column, style, map)
    self
  end

  def item_style_set(item, column=nil, *args)
    if args.empty?
      if column
        tk_send('item', 'style', 'set', item, column)
      else
        list(tk_send('item', 'style', 'set', item))
      end
    else
      tk_send('item', 'style', 'set', item, *(args.flatten))
      self
    end
  end

  def item_text(item, column, txt=nil, *args)
    if args.empty?
      if txt
        tk_send('item', 'text', item, column, txt)
        self
      else
        tk_send('item', 'text', item, column)
      end
    else
      tk_send('item', 'text', item, txt, *args)
      self
    end
  end

  def item_toggle(item)
    tk_send('item', 'toggle', item)
    self
  end

  def item_toggle_recurse(item)
    tk_send('item', 'toggle', item, '-recurse')
    self
  end

  def item_visible(item, st=None)
    if st == None
      bool(tk_send('item', 'visible', item))
    else
      tk_send('item', 'visible', item, st)
      self
    end
  end
  def item_visible?(item)
    item_visible(item)
  end

  def marquee_anchor(*args)
    if args.empty?
      list(tk_send('marquee', 'anchor'))
    else
      tk_send('marquee', 'anchor', *args)
      self
    end
  end

  def marquee_coords(*args)
    if args.empty?
      list(tk_send('marquee', 'coords'))
    else
      tk_send('marquee', 'coords', *args)
      self
    end
  end

  def marquee_corner(*args)
    if args.empty?
      tk_send('marquee', 'corner')
    else
      tk_send('marquee', 'corner', *args)
      self
    end
  end

  def marquee_identify()
    list(tk_send('marquee', 'identify'))
  end

  def marquee_visible(st=None)
    if st == None
      bool(tk_send('marquee', 'visible'))
    else
      tk_send('marquee', 'visible', st)
      self
    end
  end
  def marquee_visible?()
    marquee_visible()
  end

  #def notify_bind(obj, event, cmd=Proc.new, *args)
  #  _bind([@path, 'notify', 'bind', obj], event, cmd, *args)
  #  self
  #end
  def notify_bind(obj, event, *args)
    # if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block_given?
      cmd = args.shift
    else
      cmd = Proc.new
    end
    _bind([@path, 'notify', 'bind', obj], event, cmd, *args)
    self
  end

  #def notify_bind_append(obj, event, cmd=Proc.new, *args)
  #  _bind([@path, 'notify', 'bind', obj], event, cmd, *args)
  #  self
  #end
  def notify_bind_append(obj, event, *args)
    # if args[0].kind_of?(Proc) || args[0].kind_of?(Method)
    if TkComm._callback_entry?(args[0]) || !block_given?
      cmd = args.shift
    else
      cmd = Proc.new
    end
    _bind([@path, 'notify', 'bind', obj], event, cmd, *args)
    self
  end

  def notify_bindremove(obj, event)
    _bind_remove([@path, 'notify', 'bind', obj], event)
    self
  end

  def notify_bindinfo(obj, event=nil)
    _bindinfo([@path, 'notify', 'bind', obj], event)
  end

  def notify_detailnames(event)
    list(tk_send('notify', 'detailnames', event))
  end

  def notify_eventnames()
    list(tk_send('notify', 'eventnames'))
  end

  def notify_generate(pattern, char_map=None)
    tk_send('notify', 'generate', pattern, char_map)
    self
  end

  def notify_install_detail(event, detail, percents_cmd=nil, &b)
    percents_cmd = Proc.new(&b) if !percents_cmd && b
    if percents_cmd
      tk_send('notify', 'install', 'detail', event, detail, percents_cmd)
    else
      tk_send('notify', 'install', 'detail', event, detail)
    end
  end

  def notify_install_event(event, percents_cmd=nil, &b)
    percents_cmd = Proc.new(&b) if !percents_cmd && b
    if percents_cmd
      tk_send('notify', 'install', 'event', event, percents_cmd)
    else
      tk_send('notify', 'install', 'event', event)
    end
  end

  def notify_linkage(event, detail=None)
    tk_send('notify', 'linkage', event, detail)
  end

  def notify_uninstall_detail(event, detail)
    tk_send('notify', 'uninstall', 'detail', event, detail)
    self
  end

  def notify_uninstall_event(event)
    tk_send('notify', 'uninstall', 'event', event)
    self
  end

  def numcolumns()
    num_or_str(tk_send('numcolumns'))
  end

  def numitems()
    num_or_str(tk_send('numitems'))
  end

  def orphans()
    list(tk_send('orphans'))
  end

  def range(first, last)
    list(tk_send('range', first, last))
  end

  def state_define(name)
    tk_send('state', 'define', name)
    self
  end

  def state_linkage(name)
    tk_send('state', 'linkage', name)
  end

  def state_names()
    list(tk_send('state', 'names'))
  end

  def state_undefine(*names)
    tk_send('state', 'undefine', *names)
    self
  end

  def see(item)
    tk_send('see', item)
    self
  end

  def selection_add(first, last=None)
    tk_send('selection', 'add', first, last)
    self
  end

  def selection_anchor(item=None)
    num_or_str(tk_send('selection', 'anchor', item))
  end

  def selection_clear(*args) # first, last
    tk_send('selection', 'clear' *args)
    self
  end

  def selection_count()
    number(tk_send('selection', 'count'))
  end

  def selection_get()
    list(tk_send('selection', 'get'))
  end

  def selection_includes(item)
    bool(tk_send('selection', 'includes', item))
  end

  def selection_modify(sel, desel)
    tk_send('selection', 'modify', sel, desel)
    self
  end

  def style_create(style, keys=None)
    if keys && keys != None
      tk_send('style', 'create', style, *hash_kv(keys))
    else
      tk_send('style', 'create', style)
    end
  end

  def style_delete(*args)
    tk_send('style', 'delete', *args)
    self
  end

  def style_elements(style, *elems)
    if elems.empty?
      list(tk_send('style', 'elements', style))
    else
      tk_send('style', 'elements', style, elems.flatten)
      self
    end
  end

  def style_layout(style, elem, keys=None)
    if keys && keys != None
      if keys.kind_of?(Hash)
        tk_send('style', 'layout', style, elem, *hash_kv(keys))
        self
      else
        tk_send('style', 'layout', style, elem, "-#{keys}")
      end
    else
      list(tk_send('style', 'layout', style, elem))
    end
  end

  def style_names()
    list(tk_send('style', 'names'))
  end

  def toggle(*items)
    tk_send('toggle', *items)
    self
  end

  def toggle_recurse()
    tk_send('toggle', '-recurse', *items)
    self
  end
end
