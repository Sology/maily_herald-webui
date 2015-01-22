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
      $(this).html("")
      $(this).append($(this).data("edit-bkp"))
      $(this).removeData("edit-bkp")
  else
    $(this).editable("cancel")
    children = $(this).children()
    children.detach()
    $(this).data("edit-bkp", children)
    $(this).html(v)

$ ->
  SmartListing.config.merge()
  
  $(document).on "click", ".resource-editable button.cancel", ->
    $(this).closest(".resource-editable").editable("cancel")
    false

  $(document).tooltip
    selector: 'a[data-toggle=tooltip]'

  $(document).on 'hidden.bs.modal', (e) ->
    $(e.target).removeData('bs.modal')


  # form ui
  $('input[type=radio]').on 'change', ->
    $("input[type=radio][name=#{$(this).attr("name")}]").each ->
      if $(this).is(":checked")
        $(this).parent().addClass("radio-checked")
      else
        $(this).parent().removeClass("radio-checked")

  $('input[type=checkbox]').on 'change', ->
    if $(this).is(":checked")
      $(this).parent().addClass("checkbox-checked")
    else
      $(this).parent().removeClass("checkbox-checked")

  $('input[type="radio"]:checked').parent().addClass 'radio-checked'
  $('input[type="checkbox"]:checked').parent().addClass 'checkbox-checked'

  $(".select-wrap").click ->
    $(this).toggleClass "select-btn"
  # end form ui

  $(document).on "ajax:before", "a", (e) ->
    dummy = () ->
      false

    target = $(e.target)
    target.addClass("disabled")
    target.bind "click", dummy

    target.on "ajax:success", (e) ->
      target.removeClass("disabled")
      target.unbind "click", dummy

    target.on "ajax:error", (e) ->
      target.removeClass("disabled")
      target.addClass("error")

  $(document).on "ajax:before", "form", (e) ->
    target = $(e.target)
    button = target.find("button[type='submit']")
    button.attr("disabled", "disabled")
    button.prepend("<i class='fa fa-spinner fa-spin'></i>")

    button.on "ajax:success", (e) ->
      button.removeAttr("disabled")
      button.find("i.fa-spinner").remove()

  return

