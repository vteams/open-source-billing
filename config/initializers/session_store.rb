# Be sure to restart your server when you modify this file.

#Osb::Application.config.session_store :cookie_store, key: '_osb_session'
Osb::Application.config.session_store :active_record_store, :key => '_osb_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Osb::Application.config.session_store :active_record_store
