FROM ruby:2.7.1
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -;\
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt -y upgrade && apt install -y screen nodejs yarn && apt install -y build-essential;
RUN apt install -y zsh vim
RUN yes y | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN echo 'alias kills="kill -9 \$(cat /Pong/tmp/pids/server.pid)"' >> ~/.zshrc
RUN gem install rails
RUN gem install http
RUN gem install json
RUN gem install rake
RUN sed -i -e s/SECLEVEL=2/SECLEVEL=1/g /etc/ssl/openssl.cnf
CMD bash
RUN mkdir -p /tmp/Pong
WORKDIR /Pong
ENTRYPOINT 	bundle install; npm i underscore; \
			yarn add jquery;  yarn add underscore; \
			yarn install --check-files;rails db:migrate; \
			echo "READY TO BOOT SERVER"; \
			sleep infinity;
			#rails s -b 0.0.0.0 -p 80;