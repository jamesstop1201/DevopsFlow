# !/bin/bash
curl -L -o website.zip https://www.tooplate.com/zip-templates/2135_mini_finance.zip \
    && unzip website.zip \
    && cp -rvf 2135_mini_finance ../docker/app/ \
    && rm -rf website.zip 2135_mini_finance