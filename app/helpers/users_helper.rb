module UsersHelper
  def gravatar_for user, id = ""
    avatar_url = user&.image_url || "svg/unknown_avatar.svg"
    avatar_url = user.avatar if user&.persisted? && user.avatar.attached?

    image_tag avatar_url, id: id, class: "gravatar"
  end

  def user_change_status_link user
    link_text = t "users.do_block"
    link_status = Settings.user.is_blocked

    if user.is_blocked?
      link_text = t "users.do_active"
      link_status = Settings.user.is_unblocked
    end

    link_to(
      link_text,
      admin_user_path(user, status: link_status.to_i),
      method: "patch",
      data: {confirm: t("global.you_sure?")},
      class: "dropdown-item"
    )
  end

  def user_status_badge user
    if user.is_blocked?
      {text: t("users.blocked"), variant: "danger"}
    else
      {text: t("users.active"), variant: "success"}
    end
  end

  def user_status_options
    options_for_select(
      [
        [t("users.active"), Settings.user.is_unblocked.to_i],
        [t("users.blocked"), Settings.user.is_blocked.to_i]
      ],
      params[:q].try(:[], :is_blocked_eq)
    )
  end
end
