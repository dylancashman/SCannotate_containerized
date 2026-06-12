# Stage 1 — Frontend build
FROM node:22-bookworm-slim AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2 — Python runtime
FROM mambaorg/micromamba:1.5-jammy

USER root
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

COPY backend/environment.yml /tmp/environment.yml
RUN micromamba env create -n scannotate -f /tmp/environment.yml \
    && micromamba clean --all --yes

WORKDIR /app/backend
COPY backend/main.py backend/requirement.txt ./
COPY --from=frontend-build /app/frontend/dist ./dist

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -f http://localhost:8000/docs || exit 1

CMD ["micromamba", "run", "-n", "scannotate", \
     "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
