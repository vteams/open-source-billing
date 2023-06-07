# Base image
FROM ruby:2.7.1

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential nodejs

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install bundler
RUN bundle install

# Copy the application code
COPY . .

# Set environment variables
ENV RAILS_ENV=development
ENV RAILS_SERVE_STATIC_FILES=true

# RUN bundle exec rake db:create
# RUN bundle rake db:migrate

# RUN RAILS_ENV=development bundle rake db:seed

# Precompile assets
# RUN bundle exec rake assets:precompile

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
