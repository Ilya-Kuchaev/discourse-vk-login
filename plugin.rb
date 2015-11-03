# name: vk.com
# about: Authenticate with discourse with vk.com, see more at: https://vk.com/developers.php?id=-1_37230422&s=1
# version: 0.1.0
# author: Sam Saffron

gem 'omniauth-vkontakte', '1.3.3'

class VkAuthenticator < ::Auth::Authenticator

  def name
    'vkontakte'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    # grap the info we need from omni auth
    data = auth_token[:info]
    raw_info = auth_token["extra"]["raw_info"]
    name = data["name"]
    vk_uid = auth_token["uid"]

    # plugin specific data storage
    current_info = ::PluginStore.get("vk", "vk_uid_#{vk_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.extra_data = { vk_uid: vk_uid }

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set("vk", "vk_uid_#{data[:vk_uid]}", {user_id: user.id })
  end

  def register_middleware(omniauth)
    omniauth.provider :vkontakte, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.vk_client_id
      strategy.options[:client_secret] = SiteSetting.vk_client_secret
    }
  end
end


auth_provider :frame_width => 920,
              :frame_height => 800,
              :authenticator => VkAuthenticator.new

# for icon vk we use https://github.com/raulghm/Font-Awesome-Stylus/blob/master/stylus/variables.styl

register_css <<CSS

.btn-social.vkontakte {
  background: #46698f;
}

.btn-social.vkontakte:before {
  content: $fa-var-vk; 
}

CSS
