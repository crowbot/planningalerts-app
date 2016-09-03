module ActionMailerThemer

  private

  def themed_mail(params)
    theme = params.delete(:theme)

    # TODO Extract this into the theme
    if theme == "default"
      template_path = mailer_name
    elsif theme == "nsw"
      template_path = ["../../lib/themes/#{theme}/views/#{mailer_name}", mailer_name]
      self.prepend_view_path "lib/themes/#{theme}/views"
    elsif theme == "southwark"
      template_path = ["../../lib/themes/#{theme}/views/#{mailer_name}", mailer_name]
      self.prepend_view_path "lib/themes/#{theme}/views"
    else
      raise "Unknown theme #{theme}"
    end

    @themer = ThemeChooser.create(theme)
    @host = @themer.host
    # Only override mail delivery options in production
    if Rails.env.production? && theme == "nsw"
      delivery_options = {user_name: @themer.cuttlefish_user_name , password: @themer.cuttlefish_password }
    else
      delivery_options = {}
    end

    # Rails 4.0 supports a delivery_method_options as an option in the main method
    # In Rails 3.2 we have to do things more manually by setting the delivery settings
    # on the returned mail object
    m = mail(params.merge(template_path: template_path))
    m.delivery_method.settings.merge!(delivery_options)
    m
  end

  def email_from(theme)
    ThemeChooser.create(theme).email_from
  end
end
