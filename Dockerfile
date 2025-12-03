# Build the app
FROM ruby:3.3-alpine AS builder

# Install build deps
RUN apk add --no-cache build-base gcc make git
# Create app directory
WORKDIR /usr/src/app

# Install bundler
RUN gem install bundler



# Copy Gemfiles first (for caching)
COPY Gemfile ./

# Install Ruby dependencies
RUN bundle install
# Copy source
COPY . .

RUN bundle exec jekyll build


# Deploy to Nginx Server
FROM nginx:alpine AS server

# Remove default NGINX static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built site from builder stage
COPY --from=builder /usr/src/app/_site /usr/share/nginx/html

EXPOSE 80
