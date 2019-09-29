FROM appropriate/curl as downloader
# Use a separate docker for downloading
# installing/uninstalling usually leaves some junk in the layer
RUN curl -OL https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql


FROM openmaptiles/postgis:2.9

# Using VT_UTIL_DIR var allows user to override it with some path, and mount a volume with the custom version
ENV VT_UTIL_DIR=/opt/postgis-vt-util \
    SQL_DIR=/sql

VOLUME /sql

COPY --from=downloader /postgis-vt-util.sql ${VT_UTIL_DIR}/
COPY . /usr/src/app/

WORKDIR /usr/src/app

CMD ["./import_sql.sh"]
