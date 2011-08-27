if ["production", "staging"].include?(Rails.env)
  ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
    :access_key_id     => 'AKIAJHXKPYMNL3P56FSQ',
    :secret_access_key => '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'
end