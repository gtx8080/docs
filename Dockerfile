# Multi-stage Dockerfile for rundao-docs documentation site
# This Dockerfile creates a production-ready static site build

FROM docker.m.daocloud.io/library/python:3.12-slim as builder

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and constraints
COPY requirements.txt constraints.txt ./

# Install Python dependencies
RUN pip install --timeout 100 --retries 5 \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --trusted-host pypi.tuna.tsinghua.edu.cn \
    -r requirements.txt -c constraints.txt
# Install mkdocs-material-insiders from private repo
RUN  pip install  mkdocs-material

# Install custom plugin with PDF support
#RUN pip install git+https://github.com/SAMZONG/mkdocs-with-pdf-support-material-v8

# Copy source files (external content already merged by workflow)
COPY . .

# Build Chinese documentation to site
RUN mkdocs build -f docs/zh/mkdocs.yml -d site

# Build English documentation to site/en

# Production stage with nginx
FROM docker.m.daocloud.io/nginx:alpine as production

# Copy built sites from builder stage
COPY --from=builder /app/docs/zh/site /usr/share/nginx/html

# Copy nginx configuration
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    listen [::]:80;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Handle Chinese docs (root)
    location / {
        try_files \$uri \$uri/ \$uri.html =404;

        # Add security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
    }

    # Handle English docs
    location /en/ {
        try_files \$uri \$uri/ \$uri.html =404;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Redirect old paths if needed
    location /zh/ {
        return 301 /;
    }

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
