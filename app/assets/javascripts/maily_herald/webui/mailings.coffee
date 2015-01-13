$ ->
  $(".new-mailing-form").each ->
    form = $(this)
    mailer_select = form.find("#item_mailer_name")
    list_select = form.find("#item_list")
    template_generic = form.find(".template-generic")
    template_mailer = form.find(".template-mailer")

    update_template = () ->
      $.ajax(
        method: "post",
        url: form.data("template-path"),
        data: form.serialize(),
        dataType: "script"
      )

    mailer_select.change ->
      update_template()

    list_select.change ->
      update_template()

    if mailer_select.val() == "generic"
      template_mailer.hide()
    else
      template_generic.hide()
