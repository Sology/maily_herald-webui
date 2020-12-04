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
  editable = link.closest(".editable")
  editable.addClass("force-visible")
  
  content = $("#popover-confirmation").clone().removeClass("fade")
  content.find(".popover-msg").html(message)
  content.find('.confirm').unbind "click"
  content.find('.confirm').click ->
    $.rails.confirmed(link)
    editable.removeClass("force-visible")
  content.find('.cancel').click ->
    link.popover('hide')
    editable.removeClass("force-visible")

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

$.fn.setup_form_inputs = (v) ->
  $(this).find('input[type="radio"]:checked').parent().addClass 'radio-checked'
  $(this).find('input[type="checkbox"]:checked').parent().addClass 'checkbox-checked'

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
    $(this).setup_form_inputs()

$.fn.historyGraph = () ->
  createSeries = (obj) ->
    series = []
    for date of obj
      value = obj[date]
      point =
        x: Date.parse(date) / 1000
        y: value

      series.unshift point
    series

  $(this).each ->
    container = $(this)

    clicked = createSeries(container.data("clicked"))
    opened = createSeries(container.data("opened"))
    delivered = createSeries(container.data("delivered"))
    skipped = createSeries(container.data("skipped"))
    error = createSeries(container.data("error"))

    if !container.data("graph")
      graph = new Rickshaw.Graph(
        element: container[0]
        width: container.width()
        height: 200
        renderer: "line"
        interpolation: "linear"
        series: [
          {
            color: "#c3a323"
            data: skipped
            name: "Skipped"
          }
          {
            color: "#a94442"
            data: error
            name: "Failed"
          }
          {
            color: "#3c763d"
            data: delivered
            name: "Delivered"
          }
          {
            color: "#5bc0de"
            data: opened
            name: "Opened"
          }
          {
            color: "#625bde"
            data: clicked
            name: "Clicked"
          }
        ]
      )
      x_axis = new Rickshaw.Graph.Axis.Time(graph: graph)
      y_axis = new Rickshaw.Graph.Axis.Y(
        graph: graph
        tickFormat: Rickshaw.Fixtures.Number.formatKMBT
        ticksTreatment: "glow"
      )
      graph.render()
      hoverDetail = new Rickshaw.Graph.HoverDetail(
        graph: graph
        yFormatter: (y) ->
          Math.floor(y)
      )

      container.data("graph", graph)
    else
      graph = container.data("graph")
      graph.series[0]["data"] = skipped
      graph.series[1]["data"] = error
      graph.series[2]["data"] = delivered
      graph.series[3]["data"] = opened
      graph.update()

$.fn.mailingFormHandler = () ->
  $('#item_kind').on 'change', ->
    track_checkbox = $('span.track-checkbox input')[1]
    switch @value
      when 'html'
        if track_checkbox
          $(track_checkbox).attr 'disabled', false
        $('span.track-checkbox').removeClass 'hide'
        $('span.track-warning').addClass 'hide'

        $('.template-inputs .nav-tabs a:last').addClass 'hid'
        $('.template-inputs .nav-tabs a:first').removeClass 'hide'
        $('#plain_form').addClass 'hid'
        $('#html_form').removeClass 'hid'
        $('.template-inputs .nav-tabs a:first').tab('show')
      when 'plain'
        if track_checkbox
          $(track_checkbox).attr 'disabled', 'disabled'
        $('span.track-checkbox').addClass 'hide'
        $('span.track-warning').removeClass 'hide'

        $('.template-inputs .nav-tabs a:first').addClass 'hide'
        $('.template-inputs .nav-tabs a:last').removeClass 'hid'
        $('#html_form').addClass 'hid'
        $('#plain_form').removeClass 'hid'
        $('.template-inputs .nav-tabs a:last').tab('show')
      when 'mixed'
        if track_checkbox
          $(track_checkbox).attr 'disabled', false
        $('span.track-checkbox').removeClass 'hide'
        $('span.track-warning').addClass 'hide'

        $('.template-inputs .nav-tabs a:first').removeClass 'hide'
        $('.template-inputs .nav-tabs a:last').removeClass 'hid'
        $('#plain_form').removeClass 'hid'
        $('#html_form').removeClass 'hid'
        $('.template-inputs .nav-tabs a:first').tab('show')

$.fn.codemirror = () ->
  if $('.CodeMirror').length == 0
    textarea = $('#html_form textarea')

    if textarea.length > 0# && textarea.attr('disabled') != 'disabled'
      interval = setInterval((->
        if CodeMirror.modes.css and CodeMirror.modes.xml and CodeMirror.modes.javascript
          cm_editor = CodeMirror.fromTextArea textarea[0],
            mode: 'htmlmixed'
            lineNumbers: true
          window.cm_editor = cm_editor
          clearInterval interval
        return
      ), 10)

$ ->
  SmartListing.config.merge()

  $(document).on "click", ".resource-editable button.cancel", ->
    $(this).closest(".resource-editable").editable("cancel")
    false

  $(document).tooltip
    selector: '*[data-toggle=tooltip]'

  $(document).on 'hidden.bs.modal', (e) ->
    $(e.target).removeData('bs.modal')


  # form ui
  $(document).on 'change', 'input[type=radio]', ->
    $("input[type=radio][name=#{$(this).attr("name")}]").each ->
      if $(this).is(":checked")
        $(this).parent().addClass("radio-checked")
      else
        $(this).parent().removeClass("radio-checked")

  $(document).on 'change', 'input[type=checkbox]', ->
    if $(this).is(":checked")
      $(this).parent().addClass("checkbox-checked")
    else
      $(this).parent().removeClass("checkbox-checked")

  $(document).setup_form_inputs()

  $(".select-wrap").click ->
    $(this).toggleClass "select-btn"
  # end form ui

  $(document).on "ajax:before", "a", (e) ->
    dummy = () ->
      false

    target = $(e.target)

    if target.parent().hasClass("statusbox-container")
      target.parent().html "<i class='fa fa-spinner fa-spin fa-2x'></i>"
    else
      target.addClass("disabled")
      target.bind "click", dummy
      if target.find("i.fa, span.fa").length == 0
        target.prepend("<i class='fa fa-spinner fa-spin'></i> ")

      target.on "ajax:success", (e) ->
        target.removeClass("disabled")
        target.find("i.fa-spinner").remove()
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

  $(".history-graph").historyGraph()

  $(document).codemirror()
  $(document).mailingFormHandler()

  $(document).on "click", ".btn-retry", (e) ->
    $('#modal-generic').modal('hide')
    false
  return

