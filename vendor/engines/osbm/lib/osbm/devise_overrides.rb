module DeviseOverrides
  def find_for_authentication(conditions)
    unscoped { super(conditions) }
  end

  def serialize_from_session(key, salt)
    unscoped { super(key, salt) }
  end

  def send_reset_password_instructions(attributes={})
    unscoped { super(attributes) }
  end

  def reset_password_by_token(attributes={})
    unscoped { super(attributes) }
  end

  def find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
    unscoped { super(required_attributes, attributes, error) }
  end

  def send_confirmation_instructions(attributes={})
    unscoped { super(attributes) }
  end

  def confirm_by_token(confirmation_token)
    unscoped { super(confirmation_token) }
  end
end