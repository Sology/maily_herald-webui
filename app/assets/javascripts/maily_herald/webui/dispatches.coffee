$.fn.handleDispatchForm = () ->
  $(this).each ->
    form = $(this)
    mailer_select = form.find("#item_mailer_name")
    list_select = form.find("#item_list")
    template_generic = form.find(".template-generic")
    template_mailer = form.find(".template-mailer")
    template_mailer = form.find(".template-mailer")
    mailing_from = form.find(".mailing-from")
    dispatch_start_at = form.find(".dispatch-start-at")

    update_form = () ->
      $.ajax(
        method: "post",
        url: form.data("update-form-path"),
        data: form.find("input[name^=item], textarea[name^=item], select[name^=item]").serialize(),
        dataType: "script"
      )

    update_from = () ->
      from_value = mailing_from.find("input[type=radio]:checked").val()
      from_field = mailing_from.find("input[type=text]")

      if from_value == "default"
        from_field.hide()
        from_field.val("")
      else if from_value == "specify"
        from_field.show()

    update_start_at = () ->
      dispatch_start_at.find('[data-toggle="tooltip"]').tooltip()
      dispatch_start_at.find('button:first-child').focus ->
        dispatch_start_at.find("input.form-control").focus()
        true
      dispatch_start_at.find("input.form-control").datepicker(
        forceParse: false,
        format: "yyyy-mm-dd"
      )

    mailer_select.change ->
      update_form()

    list_select.change ->
      update_form()

    if mailer_select.val() == "generic"
      template_mailer.hide()
    else
      template_generic.hide()

    mailing_from.on "change", "input[type=radio]", ->
      update_from()

    update_from()
    update_start_at()

$ ->
  $(".dispatch-form").handleDispatchForm()

