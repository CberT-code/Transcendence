FROM ruby:2.7.1
WORKDIR /Pong

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -;\
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt -y upgrade && apt install -y screen nodejs yarn && apt install -y build-essential;
RUN gem install rails
RUN gem install http
RUN gem install json
RUN gem install rake
RUN yarn add jquery
RUN yarn add underscore
RUN yarn install --check-files
RUN sed -i -e s/SECLEVEL=2/SECLEVEL=1/g /etc/ssl/openssl.cnf
CMD bash
ENTRYPOINT cd /Pong ; bundle install; npm i underscore; yarn add jquery;  yarn add underscore; yarn install --check-files;rails db:migrate; rails db:seed; rails s -b 0.0.0.0 -p 80;