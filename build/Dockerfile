FROM new-aesa-registry-quay-local-quay.apps.ocpmgm.aviacion.fomento.es/aesa/base/redmine:4.0.9-passenger

ARG UNAME=redmine2
ARG UID=1000
ARG GID=1001

RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME
RUN usermod -a -G $UNAME redmine
RUN apt-get update

# ORIGEN DEL ERROR:NameError: uninitialized constant Nokogiri::HTML4 ----------------
# La dependencia definida en Gemfile.local soluciona el error original descrito arriba.
COPY Gemfile.local /usr/src/redmine
RUN apt-get install -y gcc g++ make libffi8
RUN chown -R $UNAME:$UNAME /usr/src/redmine && chmod 777 /usr/src/redmine

ADD src/plugins /usr/src/redmine/plugins
COPY src/config/configuration.yml  /usr/src/redmine/config/configuration.yml
COPY src/config/additional_environment.rb  /usr/src/redmine/config/additional_environment.rb
COPY src/public/images/logo.png /usr/src/redmine/public/images/
COPY src/public/stylesheets/application.css /usr/src/redmine/public/stylesheets/
COPY src/config/environments/production_test.rb /usr/src/redmine/config/environments/production.rb
COPY src/config/Gemfile.lock /usr/src/redmine/Gemfile.lock
ADD src/public/themes /usr/src/redmine/public/themes
ADD src/patch/app/controllers/timelog_controller.rb /usr/src/redmine/app/controllers/timelog_controller.rb
ADD src/patch/app/helper/timelog_helper.rb /usr/src/redmine/app/helper/timelog_helper.rb
ADD src/patch/app/views/issues/_attributes.html.erb /usr/src/redmine/app/views/issues/_attributes.html.erb
ADD src/patch/app/views/timelog/_form.html.erb /usr/src/redmine/app/views/timelog/_form.html.erb
ADD src/patch/config/locales/en.yml /usr/src/redmine/config/locales/en.yml
ADD src/patch/config/locales/es.yml /usr/src/redmine/config/locales/es.yml
ADD src/patch/lib/redmine.rb /usr/src/redmine/lib/redmine.rb
ADD src/patch/lib/redmine/my_page.rb  /usr/src/redmine/lib/redmine/my_page.rb
ADD src/patch/lib/redmine/scm/adapters/subversion_adapter.rb  /usr/src/redmine/lib/redmine/scm/adapters/subversion_adapter.rb
ADD src/patch/lib/redmine/wiki_formatting/macros.rb  /usr/src/redmine/lib/redmine/wiki_formatting/macros.rb


# ESTE CAMBIO SE APLICÓ PARA RESOLVER EL ISSUE DE LOS JAVASCRIPTS
RUN mkdir -p /usr/src/redmine/public/javascripts/redmine_extensions
RUN chmod 777 /usr/src/redmine/public/javascripts/redmine_extensions

USER $UNAME
