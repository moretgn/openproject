module Members
  class RowCell < Table::RowCell
    property :user

    def member
      model
    end

    def row_css_id
      "member-#{member.id}"
    end

    def row_css_class
      "member"
    end

    def lastname
      user.lastname if user
    end

    def firstname
      user.firstname if user
    end

    def mail
      if user
        link = mail_to(user.mail)

        if member.user && member.user.invited?
          i = "<i title=\"#{t("text_user_invited")}\" class=\"icon icon-mail1\"></i>".html_safe

          link + i
        else
          link
        end
      end
    end

    def roles
      label = h member.roles.sort.collect(&:name).join(', ')
      span = content_tag "span", label, id: "member-#{member.id}-roles"

      if may_update?
        span + role_form_cell.call
      else
        span
      end
    end

    def role_form_cell
      Members::RoleFormCell.new(
        member,
        row: self,
        params: controller.params,
        roles: table.available_roles,
        context: { controller: controller })
    end

    def groups
      if user
        user.groups.map(&:name).join(", ")
      else
        model.principal.name
      end
    end

    def status
      I18n.t("status_#{model.principal.status_name}")
    end

    def may_update?
      table.authorize_update
    end

    def button_links
      if may_update?
        [edit_link, delete_link].compact
      else
        []
      end
    end

    def edit_link
      link_to_function(
        '',
        edit_javascript,
        class: 'icon icon-edit',
        title: t(:button_edit))
    end

    def edit_javascript
      "jQuery('##{roles_css_id}').hide(); jQuery('##{roles_css_id}-form').show();"
    end

    def cancel_edit_javascript
      "jQuery('##{roles_css_id}').show(); jQuery('##{roles_css_id}-form').hide();"
    end

    def roles_css_id
      "member-#{member.id}-roles"
    end

    def delete_link
      delete_class, delete_title = if model.disposable?
        ['icon icon-delete', I18n.t(:title_remove_and_delete_user)]
      else
        ['icon icon-remove', I18n.t(:button_remove)]
      end

      link_to(
        '',
        { controller: '/members', action: 'destroy', id: model, page: params[:page] },
        method: :delete,
        data: {
          confirm: ((!User.current.admin? && model.include?(User.current)) ?
            t(:text_own_membership_delete_confirmation) : nil)
        },
        title: delete_title, class: delete_class) if model.deletable?
    end

    def column_css_class(column)
      if column == :mail
        "email"
      else
        super
      end
    end
  end
end
