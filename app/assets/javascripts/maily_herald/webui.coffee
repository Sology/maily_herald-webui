$.rails.allowAction = (link) ->
  return true unless link.attr('data-confirm')
  $.rails.showConfirmDialog(link) # look bellow for implementations
  false # always stops the action since code runs asynchronously

$.rails.confirmed = (link) ->
  confirm = link.attr("data-confirm")
  link.removeAttr('data-confirm')
  link.trigger('click.rails')
  link.popover('destroy')
  link.attr("data-confirm", confirm)

$.rails.showConfirmDialog = (link) ->
  message = link.attr 'data-confirm'
  link.popover('destroy')
  
  content = $("#popover-confirmation").clone().removeClass("fade")
  content.find(".popover-msg").html(message)
  content.find('.confirm').unbind "click"
  content.find('.confirm').click ->
    $.rails.confirmed(link)
  content.find('.cancel').click ->
    link.popover('hide')

  link.popover(content: content, html: true, trigger: 'manual', title: $("#popover-confirmation").data("title"))
  link.popover('show')

# Bootstrap tabs
$('.btn-default a').click  (e) ->
  e.preventDefault()
  $(this).tab('show')
 $.fn.observeField = (opts = {}) ->
   field = $(this)
   key_timeout = null
   last_value = null
   options =
     onFilled: () ->
     onEmpty: () ->
     onChange: () ->
   options = $.extend(options, opts)
 
   keyChange = () ->
     if field.val().length > 0
       options.onFilled()
     else
       options.onEmpty()
 
     if field.val() == last_value && field.val().length != 0
       return
     lastValue = field.val()
 
     options.onChange()
 
   field.data('observed', true)
 
   field.bind 'keydown', (e) ->
     if(key_timeout)
       clearTimeout(key_timeout)

     key_timeout = setTimeout(->
       keyChange()
     , 400)

$.fn.editable = (v) ->
  if v == "cancel"
    if $(this).data("edit-bkp")
      $(this).html($(this).data("edit-bkp"))
      $(this).removeData("edit-bkp")
  else
    $(this).editable("cancel")
    $(this).data("edit-bkp", $(this).html())
    $(this).html(v)

$ ->
  $(document).on "click", ".editable button.cancel", ->
    $(this).closest(".editable").editable("cancel")
    false

  $(document).tooltip
    selector: 'a[data-toggle=tooltip]'

  $(document).on 'hidden.bs.modal', (e) ->
    $(e.target).removeData('bs.modal')


  # form ui

  $('input[type="radio"]').wrap '<span class="radio-btn"></span>'
  $('.radio-btn').on 'click', ->
    _this = $(this)
    block = _this.parent().parent()
    block.find('input:radio').attr 'checked', false
    block.find('.radio-btn').removeClass 'checkedRadio'
    _this.addClass 'checkedRadio'
    _this.find('input:radio').attr 'checked', true
    return

  $('input[type="checkbox"]').wrap '<span class="check-box"></span>'
  $.fn.toggleCheckbox = ->
    @attr 'checked', not @attr('checked')
    return

  $('.check-box').on 'click', ->
    $(this).find(':checkbox').toggleCheckbox()
    $(this).toggleClass 'checkedBox'
    return

  $('input[type="radio"]:checked').parent().addClass 'checkedRadio'
  $('input[type="checkbox"]:checked').parent().addClass 'checkedBox'
  $('select').wrap '<span class="select-wrap"></span>'
  $(".select-wrap").click ->
    $(this).toggleClass "select-btn"
  return

