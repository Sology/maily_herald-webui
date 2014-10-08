Rails.application.routes.draw do
  mount MailyHerald::Webui::Engine => "/"
  mount MailyHerald::Engine => "/maily_herald"
end
