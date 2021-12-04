# Use asciidoctor docker image has html renderer
FROM docker.io/asciidoctor/docker-asciidoctor:latest AS html_renderer

# Copy the src files in to a temp folder in the html_renderer
COPY src /tmp/src

# Change in to the temp folder and run the asciidoctor command to convert the files to html 
RUN cd /tmp && asciidoctor -R src -D rendered_html '**/*.adoc'

# Use the alpine version of NGINX as web server to keep the image size small
FROM docker.io/nginx:alpine AS nginx

# Copy the rendered HTML and images in to the appropriate folders
COPY --from=html_renderer /tmp/rendered_html /usr/share/nginx/html
COPY src/images /usr/share/nginx/html/images