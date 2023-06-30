ARG RUNTIME=hackmdio/hackmd:2.4.2
ARG BUILDPACK=node:10.24.1-buster

FROM $BUILDPACK as BUILD

RUN git clone -b feature/support-drawio https://github.com/seanly/codimd /home/hackmd/app
ENV QT_QPA_PLATFORM=offscreen
WORKDIR /home/hackmd/app

RUN set -xe && \
    npm install && \
    npm run build && \
    cp ./deployments/docker-entrypoint.sh ./ && \
    cp .sequelizerc.example .sequelizerc && \
    rm -rf .git .gitignore .travis.yml .dockerignore .editorconfig .babelrc .mailmap .sequelizerc.example \
        test docs contribute \
        package-lock.json webpack.prod.js webpack.htmlexport.js webpack.dev.js webpack.common.js \
        config.json.example README.md CONTRIBUTING.md AUTHORS node_modules

FROM $RUNTIME
USER hackmd
ENV QT_QPA_PLATFORM=offscreen
WORKDIR /home/hackmd/app
COPY --from=BUILD /home/hackmd/app .
RUN npm install --production && npm cache clean --force && rm -rf /tmp/{core-js-banners,phantomjs}
EXPOSE 3000
ENTRYPOINT ["/home/hackmd/app/docker-entrypoint.sh"]
