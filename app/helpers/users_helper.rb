module UsersHelper
  def gravatar_for user, options = {size: Settings.size}
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def show_follow
    current_user.active_relationships.build
  end

  def show_unfollow id
    current_user.active_relationships.find_by followed_id: id
  end
end
